import 'traveler_verification_state.dart';

class Profile {
  final String id;
  final String? phone;
  final String? nationality;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? passportNumber;
  final DateTime? passportExpiry;
  final String onboardingStep;

  const Profile({
    required this.id,
    this.phone,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    this.passportNumber,
    this.passportExpiry,
    required this.onboardingStep,
  });

  /// Typed verification state derived from the raw backend step string.
  TravelerVerificationState get verificationState =>
      TravelerVerificationState.fromBackendStep(onboardingStep);

  Profile copyWith({
    String? id,
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
    String? onboardingStep,
  }) {
    return Profile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      onboardingStep: onboardingStep ?? this.onboardingStep,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.id == id &&
        other.phone == phone &&
        other.nationality == nationality &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.passportNumber == passportNumber &&
        other.passportExpiry == passportExpiry &&
        other.onboardingStep == onboardingStep;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phone.hashCode ^
        nationality.hashCode ^
        gender.hashCode ^
        dateOfBirth.hashCode ^
        passportNumber.hashCode ^
        passportExpiry.hashCode ^
        onboardingStep.hashCode;
  }
}
