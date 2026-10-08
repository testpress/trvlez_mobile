/// Domain entity representing a successful traveler signup result.
///
/// Framework-agnostic — no Flutter or Dio dependencies.
class SignupResult {
  final String id;
  final String email;
  final String travelerProfileId;
  final String onboardingStep;

  const SignupResult({
    required this.id,
    required this.email,
    required this.travelerProfileId,
    required this.onboardingStep,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignupResult &&
        other.id == id &&
        other.email == email &&
        other.travelerProfileId == travelerProfileId &&
        other.onboardingStep == onboardingStep;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      travelerProfileId.hashCode ^
      onboardingStep.hashCode;
}
