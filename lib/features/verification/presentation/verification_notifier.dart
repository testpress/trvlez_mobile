import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart'
    as domain;
import 'package:trvlez_mobile/features/verification/domain/verification_polling_service.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_validator.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Tracks the current phase of the verification flow in the UI.
enum VerificationPhase {
  idle,
  uploading,
  checkingImageQuality,
  imageQualityFailed,
  uploadSuccess,
  extractingMrz,
  mrzExtractionFailed,
  mrzReviewed,
  confirmingMrz,
  checkingVideoQuality,
  videoQualityFailed,
  submitting,
  verifying,
  verified,
  verificationFailed,
  error,
}

/// Backward-compatible status enum used by existing UI code.
enum VerificationActionStatus { idle, uploading, success, error }

class VerificationState {
  final File? capturedImage;
  final File? capturedVideo;
  final VerificationPhase phase;
  final double uploadProgress;
  final String? errorMessage;
  final VerificationSubmitResult? submitResult;
  final VerificationJobResult? jobResult;
  final domain.VerificationStatus? verificationStatus;

  // Quality State
  final ImageQualityResult? imageQualityResult;
  final VideoQualityResult? videoQualityResult;

  // MRZ State
  final MrzExtractionResult? mrzExtractionResult;

  // NFC State
  final NfcPassportResult? nfcResult;
  final bool isNfcSkipped;
  final String? extractedDocumentNumber;
  final DateTime? extractedDateOfBirth;
  final DateTime? extractedDateOfExpiry;

  const VerificationState({
    this.capturedImage,
    this.capturedVideo,
    this.phase = VerificationPhase.idle,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.submitResult,
    this.jobResult,
    this.verificationStatus,
    this.imageQualityResult,
    this.videoQualityResult,
    this.mrzExtractionResult,
    this.nfcResult,
    this.isNfcSkipped = false,
    this.extractedDocumentNumber,
    this.extractedDateOfBirth,
    this.extractedDateOfExpiry,
  });

  VerificationState copyWith({
    File? capturedImage,
    bool clearImage = false,
    File? capturedVideo,
    bool clearVideo = false,
    VerificationPhase? phase,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    VerificationSubmitResult? submitResult,
    VerificationJobResult? jobResult,
    domain.VerificationStatus? verificationStatus,
    ImageQualityResult? imageQualityResult,
    VideoQualityResult? videoQualityResult,
    MrzExtractionResult? mrzExtractionResult,
    NfcPassportResult? nfcResult,
    bool clearNfcResult = false,
    bool? isNfcSkipped,
    String? extractedDocumentNumber,
    DateTime? extractedDateOfBirth,
    DateTime? extractedDateOfExpiry,
  }) {
    return VerificationState(
      capturedImage: clearImage ? null : (capturedImage ?? this.capturedImage),
      capturedVideo: clearVideo ? null : (capturedVideo ?? this.capturedVideo),
      phase: phase ?? this.phase,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submitResult: submitResult ?? this.submitResult,
      jobResult: jobResult ?? this.jobResult,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      imageQualityResult: imageQualityResult ?? this.imageQualityResult,
      videoQualityResult: videoQualityResult ?? this.videoQualityResult,
      mrzExtractionResult: mrzExtractionResult ?? this.mrzExtractionResult,
      nfcResult: clearNfcResult ? null : (nfcResult ?? this.nfcResult),
      isNfcSkipped: isNfcSkipped ?? this.isNfcSkipped,
      extractedDocumentNumber:
          extractedDocumentNumber ?? this.extractedDocumentNumber,
      extractedDateOfBirth: extractedDateOfBirth ?? this.extractedDateOfBirth,
      extractedDateOfExpiry:
          extractedDateOfExpiry ?? this.extractedDateOfExpiry,
    );
  }
}

class VerificationNotifier extends Notifier<VerificationState> {
  late final VerificationPollingService _pollingService;

  @override
  VerificationState build() {
    final repository = ref.read(verificationRepositoryProvider);
    _pollingService = VerificationPollingService(repository: repository);
    return const VerificationState();
  }

  /// Backward-compatible status getter used by existing UI code.
  VerificationActionStatus get status => switch (state.phase) {
    VerificationPhase.idle => VerificationActionStatus.idle,
    VerificationPhase.uploading ||
    VerificationPhase.checkingImageQuality ||
    VerificationPhase.checkingVideoQuality ||
    VerificationPhase.extractingMrz => VerificationActionStatus.uploading,
    VerificationPhase.uploadSuccess ||
    VerificationPhase.mrzReviewed ||
    VerificationPhase.confirmingMrz ||
    VerificationPhase.submitting ||
    VerificationPhase.verifying ||
    VerificationPhase.verified => VerificationActionStatus.success,
    VerificationPhase.imageQualityFailed ||
    VerificationPhase.videoQualityFailed ||
    VerificationPhase.mrzExtractionFailed ||
    VerificationPhase.verificationFailed ||
    VerificationPhase.error => VerificationActionStatus.error,
  };

  /// Computes the effective verification state for the UI, similar to what
  /// VerificationStatusScreen previously did manually.
  TravelerVerificationState effectiveState(
    TravelerVerificationState profileState,
  ) {
    if (state.phase == VerificationPhase.verified) {
      return TravelerVerificationState.verified;
    }
    if (state.phase == VerificationPhase.verificationFailed ||
        state.phase == VerificationPhase.error) {
      return TravelerVerificationState.failed;
    }

    if (state.jobResult?.isComplete == true) {
      if (state.jobResult!.isVerified) {
        return TravelerVerificationState.verified;
      }
      if (state.jobResult!.isFailed) {
        return TravelerVerificationState.failed;
      }
    }

    if (state.submitResult?.isVerified == true) {
      return TravelerVerificationState.verified;
    }
    if (state.submitResult?.isFailed == true) {
      return TravelerVerificationState.failed;
    }

    if (state.phase == VerificationPhase.submitting ||
        state.phase == VerificationPhase.verifying ||
        (state.jobResult != null && !state.jobResult!.isComplete) ||
        (state.submitResult?.isProcessing == true)) {
      return TravelerVerificationState.submitted;
    }

    if (state.verificationStatus != null) {
      if (state.verificationStatus!.isVerified) {
        return TravelerVerificationState.verified;
      }
      if (state.verificationStatus!.isFailed) {
        return TravelerVerificationState.failed;
      }
      if (!state.verificationStatus!.isProcessing) {
        return TravelerVerificationState.verificationStarted;
      }
    }

    return profileState;
  }

  Future<void> fetchVerificationStatus() async {
    try {
      final repository = ref.read(verificationRepositoryProvider);
      final verificationStatus = await repository.getVerificationStatus();
      state = state.copyWith(verificationStatus: verificationStatus);
    } catch (_) {}
  }

  void setImage(File image) {
    state = state.copyWith(
      capturedImage: image,
      phase: VerificationPhase.idle,
      clearError: true,
    );
  }

  void clearImage() {
    state = state.copyWith(
      clearImage: true,
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
    if (state.capturedImage == null) return;

    state = state.copyWith(
      phase: VerificationPhase.uploading,
      uploadProgress: 0.0,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.uploadPassport(
        state.capturedImage!,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // 1. After successful upload, perform targeted image quality check
      state = state.copyWith(phase: VerificationPhase.checkingImageQuality);

      final qualityResult = await repository.checkImageQuality();
      state = state.copyWith(imageQualityResult: qualityResult);

      if (!qualityResult.isAcceptable) {
        final errorMsg = qualityResult.uiGuidance ??
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
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: 'Upload failed: $e',
      );
    }
  }

  /// Confirms MRZ-extracted data by calling the backend confirm-mrz endpoint.
  Future<void> confirmMrz() async {
    if (state.mrzExtractionResult == null) return;

    state = state.copyWith(
      phase: VerificationPhase.confirmingMrz,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.confirmMrz(
        state.mrzExtractionResult!.toConfirmPayload(),
      );
      state = state.copyWith(phase: VerificationPhase.mrzReviewed);
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: 'Failed to confirm passport data: $e',
      );
    }
  }

  /// Uploads the selfie video.
  Future<void> uploadSelfie() async {
    if (state.capturedVideo == null) return;

    state = state.copyWith(
      phase: VerificationPhase.uploading,
      uploadProgress: 0.0,
      clearError: true,
    );

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.uploadSelfie(
        state.capturedVideo!,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // 1. After successful upload, perform targeted video quality check
      state = state.copyWith(phase: VerificationPhase.checkingVideoQuality);

      final qualityResult = await repository.checkVideoQuality();
      state = state.copyWith(videoQualityResult: qualityResult);

      if (!qualityResult.isAcceptable) {
        final errorMsg = qualityResult.uiGuidance ??
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
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: 'Upload failed: $e',
      );
    }
  }

  Future<void> submitVerificationAsync() async {
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
        _pollingService.startPolling(
          jobId: submitResult.verificationJobId!,
          onUpdate: (pollingResult, domainStatus) {
            state = state.copyWith(
              phase: pollingResult.isVerified
                  ? VerificationPhase.verified
                  : (pollingResult.isFailed
                        ? VerificationPhase.verificationFailed
                        : VerificationPhase.verifying),
              jobResult: pollingResult,
            );
          },
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: VerificationPhase.error,
        errorMessage: 'Submission failed: $e',
      );
    }
  }

  void startPollingVerificationJob(String jobId) {
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
        );
      },
    );
  }

  void stopPolling() {
    _pollingService.stopPolling();
  }
}
