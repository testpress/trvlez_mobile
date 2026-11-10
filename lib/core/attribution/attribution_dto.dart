/// Data transfer objects for mobile app attribution and install evidence.
library;

/// Payload submitted by mobile app containing install referrer evidence.
class InstallEvidenceRequestDto {
  final String clickReference;
  final DateTime? occurredAt;

  const InstallEvidenceRequestDto({
    required this.clickReference,
    this.occurredAt,
  });

  Map<String, dynamic> toJson() => {
    'click_reference': clickReference,
    'occurred_at': ?occurredAt?.toUtc().toIso8601String(),
  };
}

/// Confirmation payload returned upon recording install referrer evidence.
class InstallEvidenceResponseDto {
  final bool valid;
  final String message;
  final String referralId;

  const InstallEvidenceResponseDto({
    required this.valid,
    required this.message,
    required this.referralId,
  });

  factory InstallEvidenceResponseDto.fromJson(Map<String, dynamic> json) {
    return InstallEvidenceResponseDto(
      valid: json['valid'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      referralId: json['referral_id'] as String,
    );
  }
}
