import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/domain/entities/profile.dart';
import 'package:trvlez_mobile/features/profile/domain/repositories/profile_repository.dart';

/// Concrete implementation of [ProfileRepository] using remote API.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Profile> getProfile() async {
    try {
      final dto = await remoteDataSource.getProfile();
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Profile> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
    try {
      final dateOfBirthStr = dateOfBirth?.toIso8601String().split('T').first;
      final passportExpiryStr = passportExpiry
          ?.toIso8601String()
          .split('T')
          .first;

      final dto = await remoteDataSource.updateProfile(
        phone: phone,
        nationality: nationality,
        gender: gender,
        dateOfBirth: dateOfBirthStr,
        passportNumber: passportNumber,
        passportExpiry: passportExpiryStr,
      );

      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

/// Provider for the domain [ProfileRepository] interface.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});
