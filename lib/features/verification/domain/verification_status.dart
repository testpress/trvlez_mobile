/// Response from `GET /traveler/verification/status`.
///
/// All fields are nullable because no active session may exist.
class VerificationStatus {
  final String? sessionId;
  final String? status;
  final bool passportUploaded;
  final bool videoUploaded;
  final String? passportFileId;
  final String? videoFileId;
  final String? verificationJobId;
  final String? failedStep;
  final String? errorReason;
  final String? uiMitigation;

  const VerificationStatus({
    this.sessionId,
    this.status,
    this.passportUploaded = false,
    this.videoUploaded = false,
    this.passportFileId,
    this.videoFileId,
    this.verificationJobId,
    this.failedStep,
    this.errorReason,
    this.uiMitigation,
  });

  /// Whether the verification session has failed.
  bool get isFailed => status == 'failed';

  /// Whether the verification session is currently being processed.
  bool get isProcessing => status == 'processing';

  /// Whether the verification session has been verified.
  bool get isVerified => status == 'verified';

  /// Whether both documents have been uploaded and session is ready to submit.
  bool get isUploaded => status == 'uploaded';

  /// Whether there is an active session at all.
  bool get hasActiveSession => sessionId != null;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      sessionId: json['session_id'] as String?,
      status: json['status'] as String?,
      passportUploaded: json['passport_uploaded'] as bool? ?? false,
      videoUploaded: json['video_uploaded'] as bool? ?? false,
      passportFileId: json['passport_file_id'] as String?,
      videoFileId: json['video_file_id'] as String?,
      verificationJobId: json['verification_job_id'] as String?,
      failedStep: json['failed_step'] as String?,
      errorReason: json['error_reason'] as String?,
      uiMitigation: json['ui_mitigation'] as String?,
    );
  }
}

