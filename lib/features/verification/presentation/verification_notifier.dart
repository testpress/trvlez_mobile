import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_validator.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_image_processor.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_polling_service.dart';
import 'package:trvlez_mobile/features/verification/presentation/models/verification_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart'
    show verificationRepositoryProvider;

class VerificationNotifier extends Notifier<VerificationState> {
  late final VerificationPollingService _pollingService;

  /// Guards against duplicate submissions from rapid taps.
  bool _isSubmitting = false;

  /// Guards against concurrent reconciliation calls.
  bool _isReconciling = false;

  @override
  VerificationState build() {
    final repository = ref.read(verificationRepositoryProvider);
    _pollingService = VerificationPollingService(repository: repository);
    return const VerificationState();
  }

  /// Backward-compatible status getter used by existing UI code.
  VerificationActionStatus get status => state.status;

  /// Computes the effective verification state for the UI.
  TravelerVerificationState effectiveState(
    TravelerVerificationState profileState,
  ) => state.effectiveState(profileState);

  // ─── Backend Reconciliation ──────────────────────────────────────

  /// Reconciles local state with the backend's source of truth.
  ///
  /// Called on app startup, app resume from background, and when
  /// entering the verification status screen. Handles the case where
  /// local state was lost due to process death or navigation away.
  ///
  /// Maps server status to the appropriate [VerificationPhase] and
  /// automatically resumes polling if verification is processing.
  Future<void> reconcileWithBackend() async {
    if (_isReconciling) return;
    _isReconciling = true;

    try {
      final repository = ref.read(verificationRepositoryProvider);
      final verificationStatus = await repository.getVerificationStatus();
      state = state.copyWith(verificationStatus: verificationStatus);

      if (!verificationStatus.hasActiveSession) {
        // No session exists — fresh start is valid
        return;
      }

      final serverStatus = verificationStatus.status;

      if (verificationStatus.isVerified) {
        state = state.copyWith(phase: VerificationPhase.verified);
        return;
      }

      if (verificationStatus.isFailed) {
        state = state.copyWith(
          phase: VerificationPhase.verificationFailed,
          errorMessage: verificationStatus.errorReason,
        );
        return;
      }

      if (verificationStatus.isProcessing) {
        final jobId = verificationStatus.verificationJobId;
        if (jobId != null) {
          state = state.copyWith(phase: VerificationPhase.verifying);
          _startPollingForJob(jobId);
        }
        return;
      }

      // Backend says 'uploaded' — user has documents but hasn't submitted.
      // Let them continue from the NFC/submit step.
      if (verificationStatus.isUploaded) {
        // Don't change phase if user is actively in the middle of a step.
        // Only recover if we're in idle (i.e., state was lost).
        if (state.phase == VerificationPhase.idle) {
          state = state.copyWith(phase: VerificationPhase.uploadSuccess);
        }
        return;
      }

      // For other statuses (started, etc.), check if user was mid-flow
      // and only reset to idle if truly no local state exists
      if (serverStatus == 'submitted') {
        // Submitted but not yet processing — treat like processing
        state = state.copyWith(phase: VerificationPhase.verifying);
        final jobId = verificationStatus.verificationJobId;
        if (jobId != null) {
          _startPollingForJob(jobId);
        }
      }
    } catch (e) {
      // Reconciliation is best-effort — if network is down, we'll try
      // again on next resume. Don't show errors to the user for this.
    } finally {
      _isReconciling = false;
    }
  }

  Future<void> fetchVerificationStatus() async {
    try {
      final repository = ref.read(verificationRepositoryProvider);
      final verificationStatus = await repository.getVerificationStatus();
      state = state.copyWith(verificationStatus: verificationStatus);
    } catch (_) {}
  }

  void setImage(File image, {PassportCropParams? cropParams}) {
    state = state.copyWith(
      capturedImage: image,
      cropParams: cropParams,
      clearCropParams: cropParams == null,
      phase: VerificationPhase.idle,
      clearError: true,
    );
  }

  void clearImage() {
    state = state.copyWith(
      clearImage: true,
      clearCropParams: true,
      phase: VerificationPhase.idle,
      clearError: true,
      uploadProgress: 0.0,
    );
  }

  void setVideo(File video) {
    state = state.copyWith(
      capturedVideo: video,
      phase: VerificationPhase.idle,
      clearError: true,
    );
  }

  void clearVideo() {
    state = state.copyWith(
      clearVideo: true,
      phase: VerificationPhase.idle,
      clearError: true,
      uploadProgress: 0.0,
    );
  }

  /// Resets the notifier state completely for a new verification session.
  void reset() {
    stopPolling();
    _isSubmitting = false;
    _isReconciling = false;
    state = const VerificationState();
  }

  void setNfcResult(NfcPassportResult result) {
    state = state.copyWith(nfcResult: result, isNfcSkipped: false);
  }

  void skipNfc() {
    state = state.copyWith(isNfcSkipped: true, clearNfcResult: true);
  }

  void setExtractedMrz(String docNum, DateTime dob, DateTime doe) {
    state = state.copyWith(
      extractedDocumentNumber: docNum,
      extractedDateOfBirth: dob,
      extractedDateOfExpiry: doe,
    );
  }

  Future<void> uploadPassport() async {
    final image = state.capturedImage;
    if (image == null) return;

    File fileToUpload = image;

    // 0. If crop parameters exist, process and crop the image within the frame with 100% JPEG quality
    final cropParams = state.cropParams;
    if (cropParams != null) {
      state = state.copyWith(
        phase: VerificationPhase.preparingImage,
        uploadProgress: 0.0,
        clearError: true,
      );

      try {
        final croppedFile = await compute(
          cropAndOptimizePassportImage,
          cropParams.toMap(),
        );

        if (croppedFile != null) {
          fileToUpload = croppedFile;
          state = state.copyWith(
            capturedImage: croppedFile,
            clearCropParams: true,
          );
        }
      } catch (_) {
        // Fallback to original image if cropping encounters an unexpected error
      }
    }

    state = state.copyWith(
      phase: VerificationPhase.uploading,
      uploadProgress: 0.0,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.uploadPassport(
        fileToUpload,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // 1. After successful upload, perform targeted image quality check
      state = state.copyWith(phase: VerificationPhase.checkingImageQuality);

      final qualityResult = await repository.checkImageQuality();
      state = state.copyWith(imageQualityResult: qualityResult);

      if (!qualityResult.isAcceptable) {
        final errorMsg =
            qualityResult.uiGuidance ??
            qualityResult.message ??
            'Passport photo quality is insufficient. Please retake the photo.';
        state = state.copyWith(
          phase: VerificationPhase.imageQualityFailed,
          errorMessage: errorMsg,
        );
        return;
      }

      // 2. Only on PASS: Proceed to MRZ extraction with the same uploaded image
      state = state.copyWith(phase: VerificationPhase.extractingMrz);

      final mrzResult = await repository.extractMrz();

      if (mrzResult.success) {
        bool isValidMrz = false;

        final validatedMrz = MrzValidator.validate(
          documentNumber: mrzResult.documentNumber,
          dateOfBirthStr: mrzResult.dateOfBirth,
          dateOfExpiryStr: mrzResult.dateOfExpiry,
        );

        if (validatedMrz != null) {
          setExtractedMrz(
            validatedMrz.documentNumber,
            validatedMrz.dateOfBirth,
            validatedMrz.dateOfExpiry,
          );
          isValidMrz = true;
        }

        if (isValidMrz) {
          state = state.copyWith(
            phase: VerificationPhase.uploadSuccess,
            mrzExtractionResult: mrzResult,
          );
        } else {
          state = state.copyWith(
            phase: VerificationPhase.mrzExtractionFailed,
            errorMessage:
                'Could not read all required passport data (Document Number, Date of Birth, Expiry). Please ensure the MRZ code is clearly visible and retake the photo.',
          );
        }
      } else {
        state = state.copyWith(
          phase: VerificationPhase.mrzExtractionFailed,
          errorMessage:
              mrzResult.errorMessage ?? 'Could not read passport MRZ data',
        );
      }
    } catch (e) {
      // Handle 409 "already verified" — transition to verified, not error
      final apiException = ApiException.from(e);
      if (apiException?.isAlreadyVerified == true) {
        state = state.copyWith(phase: VerificationPhase.verified);
        return;
      }
      if (apiException?.isAlreadySubmitted == true) {
        await reconcileWithBackend();
        return;
      }

      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: ApiException.extractMessage(e, 'Upload failed'),
      );
    }
  }

  /// Confirms MRZ-extracted data by calling the backend confirm-mrz endpoint.
  Future<void> confirmMrz() async {
    final mrzResult = state.mrzExtractionResult;
    if (mrzResult == null) return;

    state = state.copyWith(
      phase: VerificationPhase.confirmingMrz,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.confirmMrz(mrzResult.toConfirmPayload());
      state = state.copyWith(phase: VerificationPhase.mrzReviewed);
    } catch (e) {
      final apiException = ApiException.from(e);
      if (apiException?.isAlreadyVerified == true) {
        state = state.copyWith(phase: VerificationPhase.verified);
        return;
      }

      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: ApiException.extractMessage(
          e,
          'Failed to confirm passport data',
        ),
      );
    }
  }

  /// Uploads the selfie video.
  Future<void> uploadSelfie() async {
    final video = state.capturedVideo;
    if (video == null) return;

    state = state.copyWith(
      phase: VerificationPhase.uploading,
      uploadProgress: 0.0,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.uploadSelfie(
        video,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // 1. After successful upload, perform targeted video quality check
      state = state.copyWith(phase: VerificationPhase.checkingVideoQuality);

      final qualityResult = await repository.checkVideoQuality();
      state = state.copyWith(videoQualityResult: qualityResult);

      if (!qualityResult.isAcceptable) {
        final errorMsg =
            qualityResult.uiGuidance ??
            qualityResult.message ??
            'Selfie video quality is insufficient. Please re-record your video.';
        state = state.copyWith(
          phase: VerificationPhase.videoQualityFailed,
          errorMessage: errorMsg,
        );
        return;
      }

      // 2. Only on PASS: Proceed to NFC / submission step
      state = state.copyWith(phase: VerificationPhase.uploadSuccess);
    } catch (e) {
      // Handle 409 "already verified" — transition to verified, not error
      final apiException = ApiException.from(e);
      if (apiException?.isAlreadyVerified == true) {
        state = state.copyWith(phase: VerificationPhase.verified);
        return;
      }
      if (apiException?.isAlreadySubmitted == true) {
        await reconcileWithBackend();
        return;
      }

      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: ApiException.extractMessage(e, 'Upload failed'),
      );
    }
  }

  /// Submits the verification session for ML pipeline processing.
  ///
  /// Guarded against duplicate calls from rapid taps.
  Future<void> submitVerificationAsync() async {
    // Guard against duplicate submissions
    if (_isSubmitting) return;
    if (state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying ||
        state.phase == VerificationPhase.verified) {
      return;
    }

    _isSubmitting = true;
    state = state.copyWith(phase: VerificationPhase.submitting);

    try {
      final repository = ref.read(verificationRepositoryProvider);
      final submitResult = await repository.submitVerification(
        nfcPayload: state.nfcResult?.toJson(),
      );

      state = state.copyWith(submitResult: submitResult);

      if (submitResult.isVerified) {
        state = state.copyWith(phase: VerificationPhase.verified);
      } else if (submitResult.isFailed) {
        state = state.copyWith(
          phase: VerificationPhase.verificationFailed,
          errorMessage:
              'Identity verification was unsuccessful. Please try again.',
        );
      } else {
        state = state.copyWith(phase: VerificationPhase.verifying);
        final jobId = submitResult.verificationJobId;
        if (jobId != null) {
          _startPollingForJob(jobId);
        }
      }
    } catch (e) {
      // Handle 409 conflicts as domain transitions, not errors
      final apiException = ApiException.from(e);
      if (apiException != null && apiException.isConflict) {
        if (apiException.isAlreadyVerified) {
          state = state.copyWith(phase: VerificationPhase.verified);
          return;
        }
        // "Already submitted" or "Already processing" — reconcile to get
        // the job ID and resume polling
        await reconcileWithBackend();
        return;
      }

      // Handle session expired — try to reconcile silently
      if (apiException?.isSessionExpired == true) {
        await reconcileWithBackend();
        return;
      }

      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: ApiException.extractMessage(e, 'Submission failed'),
      );
    } finally {
      _isSubmitting = false;
    }
  }

  void startPollingVerificationJob(String jobId) {
    _startPollingForJob(jobId);
  }

  /// Starts polling for a verification job with proper state management.
  void _startPollingForJob(String jobId) {
    _pollingService.startPolling(
      jobId: jobId,
      onUpdate: (pollingResult, domainStatus) {
        state = state.copyWith(
          phase: pollingResult.isVerified
              ? VerificationPhase.verified
              : (pollingResult.isFailed
                    ? VerificationPhase.verificationFailed
                    : VerificationPhase.verifying),
          jobResult: pollingResult,
          // Update verification status if available (for failedStep, uiMitigation)
          verificationStatus: domainStatus ?? state.verificationStatus,
        );
      },
    );
  }

  void stopPolling() {
    _pollingService.stopPolling();
  }
}
