import 'package:trvlez_mobile/features/verification/domain/entities/verification_challenge.dart';

/// DTO for deserializing verification challenge responses from `/traveler/verification/challenge`.
class VerificationChallengeDto {
  final String challengeId;
  final String challengeType;
  final String? instructions;
  final int? timeoutSeconds;
  final Map<String, dynamic> metadata;

  const VerificationChallengeDto({
    required this.challengeId,
    required this.challengeType,
    this.instructions,
    this.timeoutSeconds,
    this.metadata = const {},
  });

  factory VerificationChallengeDto.fromJson(Map<String, dynamic> json) {
    return VerificationChallengeDto(
      challengeId: (json['challenge_id'] ?? json['id'] ?? json['session_id'] ?? '') as String,
      challengeType: (json['challenge_type'] ?? json['type'] ?? 'default') as String,
      instructions: json['instructions'] as String?,
      timeoutSeconds: json['timeout_seconds'] as int?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'challenge_type': challengeType,
      if (instructions != null) 'instructions': instructions,
      if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  VerificationChallenge toDomain() {
    return VerificationChallenge(
      challengeId: challengeId,
      challengeType: challengeType,
      instructions: instructions,
      timeoutSeconds: timeoutSeconds,
      metadata: metadata,
    );
  }
}
