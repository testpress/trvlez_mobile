import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/domain/entities/signup_result.dart';
import 'package:trvlez_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] interacting with the remote API and secure token storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await remoteDataSource.signUp(
        email: email,
        password: password,
      );

      return SignupResult(
        id: dto.id,
        email: dto.email,
        travelerProfileId: dto.travelerProfile.id,
        onboardingStep: dto.travelerProfile.onboardingStep,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final dto = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await tokenStorage.saveToken(dto.accessToken);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

/// Provider for the domain [AuthRepository] interface.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
