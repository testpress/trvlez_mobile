/// DTOs for the traveler signup API response.
class TravelerProfileNestedDto {
  final String id;
  final String onboardingStep;
  final String? nationality;
  final String? phone;

  const TravelerProfileNestedDto({
    required this.id,
    required this.onboardingStep,
    this.nationality,
    this.phone,
  });

  factory TravelerProfileNestedDto.fromJson(Map<String, dynamic> json) {
    return TravelerProfileNestedDto(
      id: json['id'] as String,
      onboardingStep: json['onboarding_step'] as String,
      nationality: json['nationality'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'onboarding_step': onboardingStep,
    if (nationality != null) 'nationality': nationality,
    if (phone != null) 'phone': phone,
  };
}

class TravelerSignupResponseDto {
  final String id;
  final String email;
  final String? fullName;
  final TravelerProfileNestedDto travelerProfile;

  const TravelerSignupResponseDto({
    required this.id,
    required this.email,
    this.fullName,
    required this.travelerProfile,
  });

  factory TravelerSignupResponseDto.fromJson(Map<String, dynamic> json) {
    return TravelerSignupResponseDto(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      travelerProfile: TravelerProfileNestedDto.fromJson(
        json['traveler_profile'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (fullName != null) 'full_name': fullName,
    'traveler_profile': travelerProfile.toJson(),
  };
}
