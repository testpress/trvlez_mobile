import 'dart:io';

import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_submit_result.dart';

/// Tracks the current phase of the verification flow in the UI.
enum VerificationPhase {
  idle,
  preparingImage,
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

/// Immutable state holder for the verification pipeline.
class VerificationState {
  final File? capturedImage;
  final File? capturedVideo;
  final PassportCropParams? cropParams;
  final VerificationPhase phase;
  final double uploadProgress;
  final String? errorMessage;
  final VerificationSubmitResult? submitResult;
  final VerificationJobResult? jobResult;
  final VerificationStatus? verificationStatus;

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
    this.cropParams,
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

  /// Backward-compatible status getter.
  VerificationActionStatus get status => switch (phase) {
    VerificationPhase.idle => VerificationActionStatus.idle,
    VerificationPhase.preparingImage ||
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

  /// Computes the effective verification state for the UI.
  TravelerVerificationState effectiveState(
    TravelerVerificationState profileState,
  ) {
    if (phase == VerificationPhase.verified) {
      return TravelerVerificationState.verified;
    }
    if (phase == VerificationPhase.verificationFailed ||
        phase == VerificationPhase.error) {
      return TravelerVerificationState.failed;
    }

    final job = jobResult;
    if (job?.isComplete == true && job != null) {
      if (job.isVerified) {
        return TravelerVerificationState.verified;
      }
      if (job.isFailed) {
        return TravelerVerificationState.failed;
      }
    }

    if (submitResult?.isVerified == true) {
      return TravelerVerificationState.verified;
    }
    if (submitResult?.isFailed == true) {
      return TravelerVerificationState.failed;
    }

    if (phase == VerificationPhase.submitting ||
        phase == VerificationPhase.verifying ||
        (job != null && !job.isComplete) ||
        (submitResult?.isProcessing == true)) {
      return TravelerVerificationState.submitted;
    }

    final status = verificationStatus;
    if (status != null) {
      if (status.isVerified) {
        return TravelerVerificationState.verified;
      }
      if (status.isFailed) {
        return TravelerVerificationState.failed;
      }
      if (!status.isProcessing) {
        return TravelerVerificationState.verificationStarted;
      }
    }

    return profileState;
  }

  VerificationState copyWith({
    File? capturedImage,
    bool clearImage = false,
    File? capturedVideo,
    bool clearVideo = false,
    PassportCropParams? cropParams,
    bool clearCropParams = false,
    VerificationPhase? phase,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    VerificationSubmitResult? submitResult,
    VerificationJobResult? jobResult,
    VerificationStatus? verificationStatus,
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
      cropParams: clearCropParams ? null : (cropParams ?? this.cropParams),
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
