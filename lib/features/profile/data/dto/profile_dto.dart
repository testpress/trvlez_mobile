import 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';

/// Data transfer object for the traveler profile response payload.
class ProfileDto {
  final String id;
  final String? phone;
  final String? nationality;
  final String? gender;
  final String? dateOfBirth;
  final String? passportNumber;
  final String? passportExpiry;
  final String onboardingStep;
  final String? fullName;
  final String? email;
  final String? legalName;

  const ProfileDto({
    required this.id,
    this.phone,
    this.nationality,
    this.gender,
    this.dateOfBirth,
    this.passportNumber,
    this.passportExpiry,
    required this.onboardingStep,
    this.fullName,
    this.email,
    this.legalName,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      passportNumber: json['passport_number'] as String?,
      passportExpiry: json['passport_expiry'] as String?,
      onboardingStep: json['onboarding_step'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      legalName: json['legal_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nationality': nationality,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      if (passportNumber != null) 'passport_number': passportNumber,
      if (passportExpiry != null) 'passport_expiry': passportExpiry,
      'onboarding_step': onboardingStep,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (legalName != null) 'legal_name': legalName,
    };
  }

  Profile toDomain() {
    return Profile(
      id: id,
      phone: phone,
      nationality: nationality,
      gender: gender,
      dateOfBirth: dateOfBirth != null ? DateTime.tryParse(dateOfBirth!) : null,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry != null
          ? DateTime.tryParse(passportExpiry!)
          : null,
      onboardingStep: onboardingStep,
      displayName: fullName,
      email: email,
      legalName: legalName,
    );
  }
}
