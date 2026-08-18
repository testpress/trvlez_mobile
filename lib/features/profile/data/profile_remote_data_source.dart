import 'package:dio/dio.dart';

import 'package:trvlez_mobile/features/profile/data/profile_dto.dart';

/// Remote data source for traveler profile API calls.
///
/// Auth token injection is handled by the Dio [AuthInterceptor].
/// Errors are mapped to [ApiException] by the Dio [ErrorInterceptor].
class ProfileRemoteDataSource {
  final Dio dio;

  const ProfileRemoteDataSource({required this.dio});

  /// Fetches the current traveler profile.
  Future<ProfileDto> getProfile() async {
    final response = await dio.get<Map<String, dynamic>>('/traveler/profile');
    return ProfileDto.fromJson(response.data!);
  }

  Future<ProfileDto> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    String? dateOfBirth,
    String? passportNumber,
    String? passportExpiry,
  }) async {
    final response = await dio.patch<Map<String, dynamic>>(
      '/traveler/profile',
      data: {
        'phone': ?phone,
        'nationality': ?nationality,
        'gender': ?gender,
        'date_of_birth': ?dateOfBirth,
        'passport_number': ?passportNumber,
        'passport_expiry': ?passportExpiry,
      },
    );

    return ProfileDto.fromJson(response.data!);
  }
}
