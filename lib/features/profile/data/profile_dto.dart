import '../domain/profile.dart';

class ProfileDto {
  final String id;
  final String? phone;
  final String? nationality;
  final String? gender;
  final String? dateOfBirth;
  final String onboardingStep;

  const ProfileDto({
    required this.id,
    this.phone,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    required this.onboardingStep,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      onboardingStep: json['onboarding_step'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nationality': nationality,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'onboarding_step': onboardingStep,
    };
  }

  Profile toDomain() {
    return Profile(
      id: id,
      phone: phone,
      nationality: nationality,
      gender: gender,
      dateOfBirth: dateOfBirth != null ? DateTime.tryParse(dateOfBirth!) : null,
      onboardingStep: onboardingStep,
    );
  }
}
