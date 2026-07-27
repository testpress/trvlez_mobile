/// Domain model representing a successful traveler signup.
///
/// Framework-agnostic — no Flutter imports.
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
}
