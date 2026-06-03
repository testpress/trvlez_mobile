/// Response from `GET /traveler/verification/status`.
///
/// All fields are nullable because no active session may exist.
class VerificationStatus {
  final String? sessionId;
  final String? status;
  final bool passportUploaded;
  final bool videoUploaded;

  const VerificationStatus({
    this.sessionId,
    this.status,
    this.passportUploaded = false,
    this.videoUploaded = false,
  });

  /// Whether the verification session has failed.
  bool get isFailed => status == 'failed';

  /// Whether the verification session is currently being processed.
  bool get isProcessing => status == 'processing';

  /// Whether the verification session has been verified.
  bool get isVerified => status == 'verified';

  /// Whether there is an active session at all.
  bool get hasActiveSession => sessionId != null;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      sessionId: json['session_id'] as String?,
      status: json['status'] as String?,
      passportUploaded: json['passport_uploaded'] as bool? ?? false,
      videoUploaded: json['video_uploaded'] as bool? ?? false,
    );
  }
}
