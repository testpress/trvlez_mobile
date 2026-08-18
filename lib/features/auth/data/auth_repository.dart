import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/domain/signup_result.dart';
import 'package:trvlez_mobile/features/auth/data/auth_remote_data_source.dart';

///
/// Currently delegates to the remote data source directly.
/// Can be extended to add caching, offline support, or
/// combine multiple data sources in the future.
class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const AuthRepository({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  /// Creates a new traveler account and returns a [SignupResult].
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    final dto = await remoteDataSource.signUp(email: email, password: password);

    return SignupResult(
      id: dto.id,
      email: dto.email,
      travelerProfileId: dto.travelerProfile.id,
      onboardingStep: dto.travelerProfile.onboardingStep,
    );
  }

  /// Logs in an existing traveler and saves the access token.
  Future<void> login({required String email, required String password}) async {
    final dto = await remoteDataSource.login(email: email, password: password);

    await tokenStorage.saveToken(dto.accessToken);
  }
}

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
