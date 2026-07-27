/// DTOs for the traveler signup API response.
///
/// Maps the FastAPI [TravelerSignupResponse] schema:
/// ```json
/// {
///   "id": "uuid",
///   "email": "...",
///   "full_name": "...",
///   "traveler_profile": {
///     "id": "uuid",
///     "onboarding_step": "profile_pending",
///     "nationality": null,
///     "phone": null
///   }
/// }
/// ```
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
}
