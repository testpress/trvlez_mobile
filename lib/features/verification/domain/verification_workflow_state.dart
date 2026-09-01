import 'dart:io';

import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';

/// Stages within the passport document processing phase.
enum PassportProcessingSubStage {
  uploading,
  checkingQuality,
  qualityPassed,
  extractingMrz,
}

/// Stages within the selfie video processing phase.
enum SelfieProcessingSubStage { uploading, checkingQuality, qualityPassed }

/// Durable workflow identity and recovery data.
///
/// Contains only persistent or reconstructible metadata, NOT transient UI state.
class VerificationDurableData {
  final String? sessionId;
  final String? jobId;
  final String? lastKnownStatus;
  final DateTime? lastReconciledAt;
  final String? extractedDocumentNumber;
  final DateTime? extractedDateOfBirth;
  final DateTime? extractedDateOfExpiry;
  final double? verificationScore;

  const VerificationDurableData({
    this.sessionId,
    this.jobId,
    this.lastKnownStatus,
    this.lastReconciledAt,
    this.extractedDocumentNumber,
    this.extractedDateOfBirth,
    this.extractedDateOfExpiry,
    this.verificationScore,
  });

  VerificationDurableData copyWith({
    String? sessionId,
    String? jobId,
    String? lastKnownStatus,
    DateTime? lastReconciledAt,
    String? extractedDocumentNumber,
    DateTime? extractedDateOfBirth,
    DateTime? extractedDateOfExpiry,
    double? verificationScore,
  }) {
    return VerificationDurableData(
      sessionId: sessionId ?? this.sessionId,
      jobId: jobId ?? this.jobId,
      lastKnownStatus: lastKnownStatus ?? this.lastKnownStatus,
      lastReconciledAt: lastReconciledAt ?? this.lastReconciledAt,
      extractedDocumentNumber:
          extractedDocumentNumber ?? this.extractedDocumentNumber,
      extractedDateOfBirth: extractedDateOfBirth ?? this.extractedDateOfBirth,
      extractedDateOfExpiry:
          extractedDateOfExpiry ?? this.extractedDateOfExpiry,
      verificationScore: verificationScore ?? this.verificationScore,
    );
  }

  static const empty = VerificationDurableData();
}

/// Root sealed class for all verification workflow states.
sealed class VerificationWorkflowState {
  final VerificationDurableData durableData;

  const VerificationWorkflowState({required this.durableData});

  /// The equivalent [TravelerVerificationState] for top-level routing and UI banners.
  TravelerVerificationState get effectiveTravelerState => switch (this) {
    VerificationStateVerified() => TravelerVerificationState.verified,
    VerificationStateFailed() => TravelerVerificationState.failed,
    VerificationStateProcessing() ||
    VerificationStateSubmitting() => TravelerVerificationState.submitted,
    VerificationStateNfcIntro() ||
    VerificationStateNfcScanning() ||
    VerificationStateNfcResult() ||
    VerificationStateSelfieProcessing(
      stage: SelfieProcessingSubStage.qualityPassed,
    ) => TravelerVerificationState.documentsUploaded,
    VerificationStateSelfieInstruction() ||
    VerificationStateSelfieCapture() ||
    VerificationStateSelfieProcessing() ||
    VerificationStateSelfieQualityFailed() =>
      TravelerVerificationState.passportReviewed,
    VerificationStateMrzReview() ||
    VerificationStateConfirmingMrz() ||
    VerificationStatePassportProcessing() ||
    VerificationStatePassportQualityFailed() ||
    VerificationStateMrzExtractionFailed() ||
    VerificationStatePassportCapture() =>
      TravelerVerificationState.verificationStarted,
    VerificationStateNotStarted() ||
    VerificationStateUninitialized() ||
    VerificationStateReconciling() ||
    VerificationStateError() => TravelerVerificationState.profileComplete,
  };

  /// Progress index for KYC stepper (0: Passport, 1: Review, 2: Selfie, 3: NFC, 4: Complete)
  int get progressIndex => switch (this) {
    VerificationStateVerified() => 4,
    VerificationStateProcessing() || VerificationStateSubmitting() => 4,
    VerificationStateNfcIntro() ||
    VerificationStateNfcScanning() ||
    VerificationStateNfcResult() => 3,
    VerificationStateSelfieInstruction() ||
    VerificationStateSelfieCapture() ||
    VerificationStateSelfieProcessing() ||
    VerificationStateSelfieQualityFailed() => 2,
    VerificationStateMrzReview() || VerificationStateConfirmingMrz() => 1,
    _ => 0,
  };

  bool get isProcessing =>
      this is VerificationStateProcessing ||
      this is VerificationStateSubmitting;
  bool get isVerified => this is VerificationStateVerified;
  bool get isFailed => this is VerificationStateFailed;

  File? get capturedImage => null;
  File? get capturedVideo => null;
  NfcPassportResult? get nfcResult => null;
  MrzExtractionResult? get mrzResult => null;
  String? get errorMessage => null;
}

/// Initial state before any reconciliation with backend.
final class VerificationStateUninitialized extends VerificationWorkflowState {
  const VerificationStateUninitialized({
    super.durableData = VerificationDurableData.empty,
  });
}

/// Ready to start verification.
final class VerificationStateNotStarted extends VerificationWorkflowState {
  const VerificationStateNotStarted({
    super.durableData = VerificationDurableData.empty,
  });
}

/// User is capturing passport photo.
final class VerificationStatePassportCapture extends VerificationWorkflowState {
  const VerificationStatePassportCapture({required super.durableData});
}

/// Processing passport: uploading to S3, running ML image quality, extracting MRZ.
final class VerificationStatePassportProcessing
    extends VerificationWorkflowState {
  final PassportProcessingSubStage stage;
  final double uploadProgress;
  final File? passportImage;

  const VerificationStatePassportProcessing({
    required super.durableData,
    this.stage = PassportProcessingSubStage.uploading,
    this.uploadProgress = 0.0,
    this.passportImage,
  });

  @override
  File? get capturedImage => passportImage;
}

/// Passport quality check failed (blur, lighting, glare, no face).
final class VerificationStatePassportQualityFailed
    extends VerificationWorkflowState {
  @override
  final String errorMessage;
  final ImageQualityResult? qualityResult;
  final File? passportImage;

  const VerificationStatePassportQualityFailed({
    required super.durableData,
    required this.errorMessage,
    this.qualityResult,
    this.passportImage,
  });

  @override
  File? get capturedImage => passportImage;
}

/// MRZ extraction failed (unreadable MRZ text).
final class VerificationStateMrzExtractionFailed
    extends VerificationWorkflowState {
  @override
  final String errorMessage;
  final File? passportImage;

  const VerificationStateMrzExtractionFailed({
    required super.durableData,
    required this.errorMessage,
    this.passportImage,
  });

  @override
  File? get capturedImage => passportImage;
}

/// Extracted MRZ details ready for traveler review.
final class VerificationStateMrzReview extends VerificationWorkflowState {
  final MrzExtractionResult mrzExtractionResult;
  final File? passportImage;

  const VerificationStateMrzReview({
    required super.durableData,
    required this.mrzExtractionResult,
    this.passportImage,
  });

  @override
  MrzExtractionResult get mrzResult => mrzExtractionResult;

  @override
  File? get capturedImage => passportImage;
}

/// Calling confirm-mrz to persist verified passport data.
final class VerificationStateConfirmingMrz extends VerificationWorkflowState {
  final MrzExtractionResult mrzExtractionResult;
  final File? passportImage;

  const VerificationStateConfirmingMrz({
    required super.durableData,
    required this.mrzExtractionResult,
    this.passportImage,
  });

  @override
  MrzExtractionResult get mrzResult => mrzExtractionResult;

  @override
  File? get capturedImage => passportImage;
}

/// Selfie video instructions before camera.
final class VerificationStateSelfieInstruction
    extends VerificationWorkflowState {
  const VerificationStateSelfieInstruction({required super.durableData});
}

/// Recording selfie video.
final class VerificationStateSelfieCapture extends VerificationWorkflowState {
  const VerificationStateSelfieCapture({required super.durableData});
}

/// Processing selfie: uploading to S3 and running video quality check.
final class VerificationStateSelfieProcessing
    extends VerificationWorkflowState {
  final SelfieProcessingSubStage stage;
  final double uploadProgress;
  final File? selfieVideo;

  const VerificationStateSelfieProcessing({
    required super.durableData,
    this.stage = SelfieProcessingSubStage.uploading,
    this.uploadProgress = 0.0,
    this.selfieVideo,
  });

  @override
  File? get capturedVideo => selfieVideo;
}

/// Selfie video quality check failed.
final class VerificationStateSelfieQualityFailed
    extends VerificationWorkflowState {
  @override
  final String errorMessage;
  final VideoQualityResult? qualityResult;
  final File? selfieVideo;

  const VerificationStateSelfieQualityFailed({
    required super.durableData,
    required this.errorMessage,
    this.qualityResult,
    this.selfieVideo,
  });

  @override
  File? get capturedVideo => selfieVideo;
}

/// NFC Intro screen (proceed to scan or skip).
final class VerificationStateNfcIntro extends VerificationWorkflowState {
  const VerificationStateNfcIntro({required super.durableData});
}

/// NFC chip scanning in progress.
final class VerificationStateNfcScanning extends VerificationWorkflowState {
  const VerificationStateNfcScanning({required super.durableData});
}

/// NFC reading succeeded and ready for review.
final class VerificationStateNfcResult extends VerificationWorkflowState {
  final NfcPassportResult passportNfcResult;

  const VerificationStateNfcResult({
    required super.durableData,
    required this.passportNfcResult,
  });

  @override
  NfcPassportResult get nfcResult => passportNfcResult;
}

/// Submitting verification session to backend ML pipeline.
final class VerificationStateSubmitting extends VerificationWorkflowState {
  final Map<String, dynamic>? nfcPayload;
  final bool isNfcSkipped;

  const VerificationStateSubmitting({
    required super.durableData,
    this.nfcPayload,
    this.isNfcSkipped = false,
  });
}

/// Verification submitted and actively processing in background (Polling active).
final class VerificationStateProcessing extends VerificationWorkflowState {
  final String jobId;
  final double? interimScore;
  final VerificationJobResult? jobResult;
  final VerificationStatus? verificationStatus;

  const VerificationStateProcessing({
    required super.durableData,
    required this.jobId,
    this.interimScore,
    this.jobResult,
    this.verificationStatus,
  });
}

/// Identity verified successfully.
final class VerificationStateVerified extends VerificationWorkflowState {
  final double? verificationScore;
  final VerificationJobResult? jobResult;
  final VerificationStatus? verificationStatus;

  const VerificationStateVerified({
    required super.durableData,
    this.verificationScore,
    this.jobResult,
    this.verificationStatus,
  });
}

/// Verification failed or rejected.
final class VerificationStateFailed extends VerificationWorkflowState {
  final String? errorReason;
  final String? failedStep;
  final String? uiMitigation;
  final VerificationJobResult? jobResult;
  final VerificationStatus? verificationStatus;

  const VerificationStateFailed({
    required super.durableData,
    this.errorReason,
    this.failedStep,
    this.uiMitigation,
    this.jobResult,
    this.verificationStatus,
  });

  @override
  String? get errorMessage =>
      uiMitigation ?? errorReason ?? 'Identity verification was unsuccessful.';
}

/// Actively reconciling with backend.
final class VerificationStateReconciling extends VerificationWorkflowState {
  final VerificationWorkflowState? previousState;

  const VerificationStateReconciling({
    required super.durableData,
    this.previousState,
  });
}

/// Recoverable operational error with user-friendly guidance.
final class VerificationStateError extends VerificationWorkflowState {
  final String userMessage;
  final VerificationWorkflowState previousState;

  const VerificationStateError({
    required super.durableData,
    required this.userMessage,
    required this.previousState,
  });

  @override
  String get errorMessage => userMessage;
}
