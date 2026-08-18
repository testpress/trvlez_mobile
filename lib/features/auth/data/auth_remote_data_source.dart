import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/core/network/dio_provider.dart';

import 'package:trvlez_mobile/features/auth/data/login_response_dto.dart';
import 'package:trvlez_mobile/features/auth/data/traveler_signup_dto.dart';

/// Remote data source for authentication API calls.
///
/// Handles the raw HTTP calls and JSON → DTO conversion.
/// Auth token injection is handled by the Dio [AuthInterceptor].
/// Errors are mapped to [ApiException] by the Dio [ErrorInterceptor].
class AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSource({required this.dio});

  /// Creates a new traveler account.
  ///
  /// Calls `POST /traveler/signup` with the provided credentials.
  /// Returns the parsed signup response DTO.
  Future<TravelerSignupResponseDto> signUp({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/signup',
      data: {'email': email, 'password': password},
    );

    return TravelerSignupResponseDto.fromJson(response.data!);
  }

  /// Logs in an existing traveler.
  ///
  /// Calls `POST /login/access-token` with URL-encoded credentials.
  /// Returns the parsed [LoginResponseDto] containing the access token.
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/login/access-token',
      data: {
        'username': email, // OAuth2 specification requires 'username'
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return LoginResponseDto.fromJson(response.data!);
  }
}

/// Provider for the [AuthRemoteDataSource].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(dio: ref.watch(dioProvider));
});
