import 'dart:io';

import 'package:trvlez_mobile/features/profile/domain/profile.dart';
import 'package:trvlez_mobile/features/verification/domain/mrz_extraction_result.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_passport_result.dart';
import 'package:trvlez_mobile/features/verification/domain/quality_check_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_job_result.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';

/// Root sealed class for all verification domain events.
sealed class VerificationEvent {
  const VerificationEvent();
}

// ── Lifecycle & Backend Synchronization Events ───────────────────────

/// Triggered to reconcile the local workflow with authoritative backend state.
final class ReconcileRequested extends VerificationEvent {
  final bool force;
  const ReconcileRequested({this.force = false});
}

/// Dispatched by the ReconciliationActor when backend status and profile are received.
final class BackendReconciled extends VerificationEvent {
  final VerificationStatus status;
  final Profile profile;
  const BackendReconciled({required this.status, required this.profile});
}

// ── Passport Workflow Events ─────────────────────────────────────────

/// User starts the verification process.
final class StartVerification extends VerificationEvent {
  const StartVerification();
}

/// User has captured or picked a passport photo.
final class PassportCaptured extends VerificationEvent {
  final File imageFile;
  const PassportCaptured(this.imageFile);
}

/// S3 upload progress update for passport image.
final class PassportUploadProgressUpdate extends VerificationEvent {
  final double progress;
  const PassportUploadProgressUpdate(this.progress);
}

/// Passport S3 upload completed.
final class PassportUploaded extends VerificationEvent {
  final String fileId;
  const PassportUploaded(this.fileId);
}

/// Passport image quality check passed.
final class PassportQualityPassed extends VerificationEvent {
  final ImageQualityResult result;
  const PassportQualityPassed(this.result);
}

/// Passport image quality check failed.
final class PassportQualityFailed extends VerificationEvent {
  final String message;
  final ImageQualityResult? result;
  const PassportQualityFailed(this.message, [this.result]);
}

/// MRZ data extracted from passport image.
final class MrzExtracted extends VerificationEvent {
  final MrzExtractionResult result;
  const MrzExtracted(this.result);
}

/// MRZ extraction unreadable.
final class MrzExtractionFailed extends VerificationEvent {
  final String message;
  const MrzExtractionFailed(this.message);
}

/// User confirmed extracted MRZ details.
final class ConfirmMrzRequested extends VerificationEvent {
  const ConfirmMrzRequested();
}

/// MRZ details confirmed with backend.
final class MrzConfirmed extends VerificationEvent {
  const MrzConfirmed();
}

// ── Selfie Video Workflow Events ─────────────────────────────────────

/// User begins selfie video recording.
final class StartSelfieCapture extends VerificationEvent {
  const StartSelfieCapture();
}

/// User has captured a selfie video.
final class SelfieCaptured extends VerificationEvent {
  final File videoFile;
  const SelfieCaptured(this.videoFile);
}

/// S3 upload progress update for selfie video.
final class SelfieUploadProgressUpdate extends VerificationEvent {
  final double progress;
  const SelfieUploadProgressUpdate(this.progress);
}

/// Selfie S3 upload completed.
final class SelfieUploaded extends VerificationEvent {
  final String fileId;
  const SelfieUploaded(this.fileId);
}

/// Selfie video quality check passed.
final class SelfieQualityPassed extends VerificationEvent {
  final VideoQualityResult result;
  const SelfieQualityPassed(this.result);
}

/// Selfie video quality check failed.
final class SelfieQualityFailed extends VerificationEvent {
  final String message;
  final VideoQualityResult? result;
  const SelfieQualityFailed(this.message, [this.result]);
}

// ── NFC Workflow Events ──────────────────────────────────────────────

/// User initiates NFC scan.
final class StartNfcScan extends VerificationEvent {
  const StartNfcScan();
}

/// NFC chip reading succeeded.
final class NfcScanCompleted extends VerificationEvent {
  final NfcPassportResult result;
  const NfcScanCompleted(this.result);
}

/// User elected to skip NFC chip scanning.
final class NfcSkipped extends VerificationEvent {
  const NfcSkipped();
}

// ── Submission & Processing Events ───────────────────────────────────

/// User requests submission of verification documents.
final class SubmitRequested extends VerificationEvent {
  final Map<String, dynamic>? nfcPayload;
  final bool isSkipped;
  const SubmitRequested({this.nfcPayload, this.isSkipped = false});
}

/// Backend accepted submission and started background processing job.
final class SubmissionAccepted extends VerificationEvent {
  final String jobId;
  const SubmissionAccepted(this.jobId);
}

/// Backend completed verification synchronously during submission.
final class SubmissionCompletedImmediate extends VerificationEvent {
  final bool isVerified;
  final double? score;
  const SubmissionCompletedImmediate({required this.isVerified, this.score});
}

/// Polling update received for in-progress verification job.
final class VerificationJobUpdated extends VerificationEvent {
  final VerificationJobResult result;
  final VerificationStatus? status;
  const VerificationJobUpdated(this.result, this.status);
}

/// Verification job completed with approval.
final class VerificationJobCompleted extends VerificationEvent {
  final bool isVerified;
  final double? score;
  final VerificationJobResult? result;
  const VerificationJobCompleted({
    required this.isVerified,
    this.score,
    this.result,
  });
}

/// Verification job failed or rejected.
final class VerificationJobFailed extends VerificationEvent {
  final String errorReason;
  final String? failedStep;
  final String? uiMitigation;
  final VerificationJobResult? result;
  const VerificationJobFailed({
    required this.errorReason,
    this.failedStep,
    this.uiMitigation,
    this.result,
  });
}

// ── Domain Conflict & Recovery Events ─────────────────────────────────

/// Backend reported HTTP 409: User is already verified.
final class AlreadyVerifiedDetected extends VerificationEvent {
  final double? score;
  const AlreadyVerifiedDetected([this.score]);
}

/// Operational or network error occurred during an actor execution.
final class OperationalErrorOccurred extends VerificationEvent {
  final String userMessage;
  const OperationalErrorOccurred(this.userMessage);
}

/// User requested retry after an error or failed quality check.
final class RetryRequested extends VerificationEvent {
  const RetryRequested();
}

/// User requested complete reset for re-submitting documents.
final class ResetRequested extends VerificationEvent {
  const ResetRequested();
}
