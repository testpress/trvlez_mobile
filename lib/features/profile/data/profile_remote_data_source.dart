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
    final response = await apiClient.get('/traveler/profile', authToken: token);
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
        'phone': ?phone,
        'nationality': ?nationality,
        'gender': ?gender,
        'date_of_birth': ?dateOfBirth,
        'passport_number': ?passportNumber,
        'passport_expiry': ?passportExpiry,
      },
    );

    return ProfileDto.fromJson(response);
  }
}
