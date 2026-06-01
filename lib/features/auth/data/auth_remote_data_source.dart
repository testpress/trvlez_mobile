import '../../../core/network/api_client.dart';
import 'traveler_signup_dto.dart';

/// Remote data source for authentication API calls.
///
/// Handles the raw HTTP calls and JSON ↔ DTO conversion.
/// Throws [ApiException] on any failure.
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  // ignore: prefer_initializing_formals
  const AuthRemoteDataSource({required this._apiClient});

  /// Creates a new traveler account.
  ///
  /// Calls `POST /traveler/signup` with the provided credentials.
  /// Returns the parsed signup response DTO.
  Future<TravelerSignupResponseDto> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final responseJson = await _apiClient.post(
      '/traveler/signup',
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
    );

    return TravelerSignupResponseDto.fromJson(responseJson);
  }
}
