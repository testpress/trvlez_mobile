class QualityFailureReason {
  final String code;
  final String message;

  QualityFailureReason({required this.code, required this.message});

  factory QualityFailureReason.fromJson(Map<String, dynamic> json) {
    return QualityFailureReason(
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class ImageQualityResult {
  final bool success;
  final String status;
  final bool isAcceptable;
  final List<QualityFailureReason> failureReasons;
  final String? message;
  final String? uiGuidance;
  final Map<String, dynamic>? checks;

  ImageQualityResult({
    required this.success,
    required this.status,
    required this.isAcceptable,
    this.failureReasons = const [],
    this.message,
    this.uiGuidance,
    this.checks,
  });

  factory ImageQualityResult.fromJson(Map<String, dynamic> json) {
    final reasonsList = json['failure_reasons'] as List<dynamic>? ?? [];
    final parsedReasons = reasonsList
        .whereType<Map<String, dynamic>>()
        .map((r) => QualityFailureReason.fromJson(r))
        .toList();

    return ImageQualityResult(
      success: (json['success'] as bool?) ?? false,
      status: json['status']?.toString() ?? 'passed',
      isAcceptable:
          (json['is_acceptable'] as bool?) ?? (json['status'] == 'passed'),
      failureReasons: parsedReasons,
      message: json['message'] as String?,
      uiGuidance: json['ui_guidance'] as String?,
      checks: json['checks'] as Map<String, dynamic>?,
    );
  }
}

class VideoQualityResult {
  final bool success;
  final String status;
  final bool isAcceptable;
  final List<QualityFailureReason> failureReasons;
  final String? message;
  final String? uiGuidance;
  final Map<String, dynamic>? checks;

  VideoQualityResult({
    required this.success,
    required this.status,
    required this.isAcceptable,
    this.failureReasons = const [],
    this.message,
    this.uiGuidance,
    this.checks,
  });

  factory VideoQualityResult.fromJson(Map<String, dynamic> json) {
    final reasonsList = json['failure_reasons'] as List<dynamic>? ?? [];
    final parsedReasons = reasonsList
        .whereType<Map<String, dynamic>>()
        .map((r) => QualityFailureReason.fromJson(r))
        .toList();

    return VideoQualityResult(
      success: (json['success'] as bool?) ?? false,
      status: json['status']?.toString() ?? 'passed',
      isAcceptable:
          (json['is_acceptable'] as bool?) ?? (json['status'] == 'passed'),
      failureReasons: parsedReasons,
      message: json['message'] as String?,
      uiGuidance: json['ui_guidance'] as String?,
      checks: json['checks'] as Map<String, dynamic>?,
    );
  }
}
