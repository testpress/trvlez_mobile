/// Response from `GET /traveler/verification/job/{job_id}`.
///
/// Represents the current state and result of a verification job.
/// Used for polling the backend to track ML pipeline progress.
class VerificationJobResult {
  final String id;
  final String travelerId;
  final String verificationSessionId;
  final String status;
  final String verificationType;
  final double? verificationScore;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const VerificationJobResult({
    required this.id,
    required this.travelerId,
    required this.verificationSessionId,
    required this.status,
    required this.verificationType,
    this.verificationScore,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  /// Whether the job has finished (either verified or failed).
  bool get isComplete => isVerified || isFailed;

  /// Whether the verification passed.
  bool get isVerified => status == 'verified';

  /// Whether the verification was rejected.
  bool get isFailed => status == 'failed';

  /// Whether the pipeline is still running.
  bool get isProcessing => status == 'processing';

  /// Whether the job is queued but not yet started.
  bool get isPending => status == 'pending';

  factory VerificationJobResult.fromJson(Map<String, dynamic> json) {
    return VerificationJobResult(
      id: json['id'] as String,
      travelerId: json['traveler_id'] as String,
      verificationSessionId: json['verification_session_id'] as String,
      status: (json['status'] as String).toLowerCase(),
      verificationType: json['verification_type'] as String? ?? 'full',
      verificationScore: (json['verification_score'] as num?)?.toDouble(),
      errorMessage: json['error_message'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
