import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'profile_dto.dart';

class ProfileRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  const ProfileRemoteDataSource({
    required this.apiClient,
    required this.tokenStorage,
  });

  /// Fetches the current traveler profile.
  Future<ProfileDto> getProfile() async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.get(
      '/traveler/profile',
      authToken: token,
    );
    return ProfileDto.fromJson(response);
  }

  Future<ProfileDto> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    String? dateOfBirth,
    String? passportNumber,
    String? passportExpiry,
  }) async {
    final token = await tokenStorage.getToken();
    
    final response = await apiClient.patch(
      '/traveler/profile',
      authToken: token,
      body: {
        if (phone != null) 'phone': phone,
        if (nationality != null) 'nationality': nationality,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (passportNumber != null) 'passport_number': passportNumber,
        if (passportExpiry != null) 'passport_expiry': passportExpiry,
      },
    );

    return ProfileDto.fromJson(response);
  }
}
