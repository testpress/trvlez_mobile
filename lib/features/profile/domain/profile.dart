class Profile {
  final String id;
  final String? phone;
  final String? nationality;
  final String? gender;
  final DateTime? dateOfBirth;
  final String onboardingStep;

  const Profile({
    required this.id,
    this.phone,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    required this.onboardingStep,
  });

  Profile copyWith({
    String? id,
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? onboardingStep,
  }) {
    return Profile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
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
        other.onboardingStep == onboardingStep;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phone.hashCode ^
        nationality.hashCode ^
        gender.hashCode ^
        dateOfBirth.hashCode ^
        onboardingStep.hashCode;
  }
}
