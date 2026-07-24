import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';import 'package:trvlez_mobile/features/verification/data/verification_repository.dart';import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';import 'package:trvlez_mobile/features/verification/domain/verification_status.dart' as domain;import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_polling_service.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_validator.dart';
/// Tracks the current phase of the verification flow in the UI.
enum VerificationPhase {
  /// No operation in progress.
  idle,

  /// Uploading a file to S3.
  uploading,

  /// File upload succeeded (passport or selfie).
  uploadSuccess,

  /// Extracting MRZ data from uploaded passport.
  extractingMrz,

  /// Extracting MRZ data failed.
  mrzExtractionFailed,

  /// MRZ data confirmed by traveller — ready to proceed to selfie.
  mrzReviewed,

  /// Confirming MRZ data with the backend.
  confirmingMrz,

  /// Submitting documents for verification (triggers ML pipeline).
  submitting,

  /// ML pipeline is running — polling for results.
  verifying,

  /// Verification pipeline completed successfully.
  verified,

  /// Verification pipeline completed with failure.
  verificationFailed,

  /// An error occurred (upload, submit, or network failure).
  error,
}

class VerificationNotifier extends ChangeNotifier {
  final VerificationRepository repository;
  late final VerificationPollingService _pollingService;

  VerificationNotifier({VerificationRepository? repository})
    : repository = repository ?? VerificationRepository() {
    _pollingService = VerificationPollingService(repository: this.repository);
  }

  File? capturedImage;
  File? capturedVideo;
  VerificationPhase phase = VerificationPhase.idle;
  double uploadProgress = 0.0;
  String? errorMessage;
  VerificationSubmitResult? submitResult;
  VerificationJobResult? jobResult;
  domain.VerificationStatus? verificationStatus;

  // MRZ State
  MrzExtractionResult? mrzExtractionResult;

  // NFC State
  NfcPassportResult? nfcResult;
  bool isNfcSkipped = false;
  String? extractedDocumentNumber;
  DateTime? extractedDateOfBirth;
  DateTime? extractedDateOfExpiry;

  /// Backward-compatible status getter used by existing UI code.
  VerificationStatus get status => switch (phase) {
    VerificationPhase.idle => VerificationStatus.idle,
    VerificationPhase.uploading => VerificationStatus.uploading,
    VerificationPhase.uploadSuccess ||
    VerificationPhase.mrzReviewed ||
    VerificationPhase.confirmingMrz ||
    VerificationPhase.submitting ||
    VerificationPhase.verifying ||
    VerificationPhase.verified => VerificationStatus.success,
    VerificationPhase.extractingMrz => VerificationStatus.uploading, // Keep UI in loading state
    VerificationPhase.mrzExtractionFailed ||
    VerificationPhase.verificationFailed ||
    VerificationPhase.error => VerificationStatus.error,
  };

  /// Computes the effective verification state for the UI, similar to what
  /// VerificationStatusScreen previously did manually.
  TravelerVerificationState effectiveState(TravelerVerificationState profileState) {
    if (phase == VerificationPhase.verified) {
      return TravelerVerificationState.verified;
    }
    if (phase == VerificationPhase.verificationFailed || phase == VerificationPhase.error) {
      return TravelerVerificationState.failed;
    }
    
    if (jobResult?.isComplete == true) {
      if (jobResult!.isVerified) return TravelerVerificationState.verified;
      if (jobResult!.isFailed) return TravelerVerificationState.failed;
    }
    
    if (submitResult?.isVerified == true) return TravelerVerificationState.verified;
    if (submitResult?.isFailed == true) return TravelerVerificationState.failed;
    
    if (phase == VerificationPhase.submitting || 
        phase == VerificationPhase.verifying || 
        (jobResult != null && !jobResult!.isComplete) || 
        (submitResult?.isProcessing == true)) {
      return TravelerVerificationState.submitted;
    }
    
    if (verificationStatus != null) {
      if (verificationStatus!.isVerified) return TravelerVerificationState.verified;
      if (verificationStatus!.isFailed) return TravelerVerificationState.failed;
      if (!verificationStatus!.isProcessing) {
        return TravelerVerificationState.verificationStarted;
      }
    }
    
    return profileState;
  }

  Future<void> fetchVerificationStatus() async {
    try {
      verificationStatus = await repository.getVerificationStatus();
      notifyListeners();
    } catch (_) {}
  }

  void setImage(File image) {
    capturedImage = image;
    phase = VerificationPhase.idle;
    errorMessage = null;
    notifyListeners();
  }

  void clearImage() {
    capturedImage = null;
    phase = VerificationPhase.idle;
    errorMessage = null;
    uploadProgress = 0.0;
    notifyListeners();
  }

  void setVideo(File video) {
    capturedVideo = video;
    phase = VerificationPhase.idle;
    errorMessage = null;
    notifyListeners();
  }

  void clearVideo() {
    capturedVideo = null;
    phase = VerificationPhase.idle;
    errorMessage = null;
    uploadProgress = 0.0;
    notifyListeners();
  }

  /// Resets the notifier state completely for a new verification session.
  void reset() {
    capturedImage = null;
    capturedVideo = null;
    phase = VerificationPhase.idle;
    uploadProgress = 0.0;
    errorMessage = null;
    submitResult = null;
    jobResult = null;
    verificationStatus = null;
    mrzExtractionResult = null;
    nfcResult = null;
    isNfcSkipped = false;
    extractedDocumentNumber = null;
    extractedDateOfBirth = null;
    extractedDateOfExpiry = null;
    stopPolling();
    notifyListeners();
  }

  void setNfcResult(NfcPassportResult result) {
    nfcResult = result;
    isNfcSkipped = false;
    notifyListeners();
  }

  void skipNfc() {
    isNfcSkipped = true;
    nfcResult = null;
    notifyListeners();
  }
  
  void setExtractedMrz(String docNum, DateTime dob, DateTime doe) {
    extractedDocumentNumber = docNum;
    extractedDateOfBirth = dob;
    extractedDateOfExpiry = doe;
    notifyListeners();
  }

  Future<void> uploadPassport() async {
    if (capturedImage == null) return;

    phase = VerificationPhase.uploading;
    uploadProgress = 0.0;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.uploadPassport(
        capturedImage!,
        onProgress: (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      // After successful upload, immediately extract MRZ
      phase = VerificationPhase.extractingMrz;
      notifyListeners();

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
            validatedMrz.dateOfExpiry
          );
          isValidMrz = true;
        }
        
        if (isValidMrz) {
          phase = VerificationPhase.uploadSuccess;
          // Store the full MRZ result for the review screen
          mrzExtractionResult = mrzResult;
        } else {
          phase = VerificationPhase.mrzExtractionFailed;
          errorMessage = 'Could not read all required passport data (Document Number, Date of Birth, Expiry). Please ensure the MRZ code is clearly visible and retake the photo.';
        }
      } else {
        phase = VerificationPhase.mrzExtractionFailed;
        errorMessage = mrzResult.errorMessage ?? 'Could not read passport MRZ data';
      }
      
      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  /// Confirms MRZ-extracted data by calling the backend confirm-mrz endpoint.
  ///
  /// Persists the passport data to the traveller profile and advances onboarding.
  Future<void> confirmMrz() async {
    if (mrzExtractionResult == null) return;

    phase = VerificationPhase.confirmingMrz;
    errorMessage = null;
    notifyListeners();

    try {
      await repository.confirmMrz(mrzExtractionResult!.toConfirmPayload());
      phase = VerificationPhase.mrzReviewed;
      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Failed to confirm passport data: $e';
      notifyListeners();
    }
  }

  /// Uploads the selfie video.
  ///
  /// After a successful upload, this method transitions the phase to
  /// [VerificationPhase.uploadSuccess] so the UI can proceed without waiting.
  /// It then asynchronously triggers the backend ML verification pipeline.
  Future<void> uploadSelfie() async {
    if (capturedVideo == null) return;

    phase = VerificationPhase.uploading;
    uploadProgress = 0.0;
    errorMessage = null;
    submitResult = null;
    jobResult = null;
    verificationStatus = null;
    notifyListeners();

    try {
      await repository.uploadSelfie(
        capturedVideo!,
        onProgress: (progress) {
          uploadProgress = progress;
          notifyListeners();
        },
      );

      // Upload complete. Wait for user to proceed to NFC.
      phase = VerificationPhase.uploadSuccess;
      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<void> submitVerificationAsync() async {
    phase = VerificationPhase.submitting;
    notifyListeners();

    try {
      submitResult = await repository.submitVerification(
        nfcPayload: nfcResult?.toJson(),
      );

      if (submitResult!.isVerified) {
        phase = VerificationPhase.verified;
      } else if (submitResult!.isFailed) {
        phase = VerificationPhase.verificationFailed;
        errorMessage =
            'Identity verification was unsuccessful. Please try again.';
      } else {
        phase = VerificationPhase.verifying;
        startPollingVerificationJob();
      }

      if (!submitResult!.isProcessing) {
        try {
          verificationStatus = await repository.getVerificationStatus();
          if (submitResult!.isFailed) {
            errorMessage =
                verificationStatus?.uiMitigation ??
                verificationStatus?.errorReason ??
                errorMessage;
          }
        } catch (_) {}
      }

      notifyListeners();
    } on ApiException catch (e) {
      phase = VerificationPhase.error;
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      phase = VerificationPhase.error;
      errorMessage = 'Verification submit failed: $e';
      notifyListeners();
    }
  }

  /// Polls the verification job using the VerificationPollingService.
  void startPollingVerificationJob({
    int initialIntervalSeconds = 2,
    int maxIntervalSeconds = 15,
    int maxDurationSeconds = 300,
    VoidCallback? onComplete,
  }) {
    final jobId = submitResult?.verificationJobId;
    if (jobId == null) return;

    _pollingService.startPolling(
      jobId: jobId,
      initialIntervalSeconds: initialIntervalSeconds,
      maxIntervalSeconds: maxIntervalSeconds,
      maxDurationSeconds: maxDurationSeconds,
      onUpdate: (updatedJobResult, updatedStatus) {
        jobResult = updatedJobResult;
        if (updatedStatus != null) {
          verificationStatus = updatedStatus;
        }

        if (jobResult!.isComplete) {
          phase = jobResult!.isVerified
              ? VerificationPhase.verified
              : VerificationPhase.verificationFailed;

          if (jobResult!.isFailed) {
            errorMessage =
                verificationStatus?.uiMitigation ??
                verificationStatus?.errorReason ??
                jobResult!.errorMessage ??
                'Identity verification was unsuccessful. Please try again.';
          }
          onComplete?.call();
        }
        notifyListeners();
      },
    );
  }

  /// Stops any active polling timer.
  void stopPolling() {
    _pollingService.stopPolling();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

/// Legacy status enum kept for backward compatibility with passport screens.
enum VerificationStatus { idle, uploading, success, error }
