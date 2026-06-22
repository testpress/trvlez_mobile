/// Response from `POST /traveler/verification/submit`.
///
/// Contains the verification job ID for polling and an optional
/// score when the ML pipeline completes synchronously.
class VerificationSubmitResult {
  final String sessionId;
  final String status;
  final DateTime submittedAt;
  final String? verificationJobId;
  final double? verificationScore;

  const VerificationSubmitResult({
    required this.sessionId,
    required this.status,
    required this.submittedAt,
    this.verificationJobId,
    this.verificationScore,
  });

  /// Whether the ML pipeline has already completed during submission.
  bool get hasImmediateResult => verificationScore != null;

  /// Whether the session transitioned to verified during submission.
  bool get isVerified => status == 'verified';

  /// Whether the session transitioned to failed during submission.
  bool get isFailed => status == 'failed';

  /// Whether the pipeline is still processing (needs polling).
  bool get isProcessing => status == 'processing';

  factory VerificationSubmitResult.fromJson(Map<String, dynamic> json) {
    return VerificationSubmitResult(
      sessionId: json['session_id'] as String,
      status: (json['status'] as String).toLowerCase(),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      verificationJobId: json['verification_job_id'] as String?,
      verificationScore: (json['verification_score'] as num?)?.toDouble(),
    );
  }
}
