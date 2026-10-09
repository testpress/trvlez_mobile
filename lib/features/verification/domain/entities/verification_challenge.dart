/// Domain entity representing a liveness / verification challenge.
class VerificationChallenge {
  final String challengeId;
  final String challengeType;
  final String? instructions;
  final int? timeoutSeconds;
  final Map<String, dynamic> metadata;

  const VerificationChallenge({
    required this.challengeId,
    required this.challengeType,
    this.instructions,
    this.timeoutSeconds,
    this.metadata = const {},
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationChallenge &&
        other.challengeId == challengeId &&
        other.challengeType == challengeType &&
        other.instructions == instructions &&
        other.timeoutSeconds == timeoutSeconds;
  }

  @override
  int get hashCode => Object.hash(
    challengeId,
    challengeType,
    instructions,
    timeoutSeconds,
  );
}
