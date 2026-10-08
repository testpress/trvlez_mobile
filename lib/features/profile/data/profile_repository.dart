import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/profile/data/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/domain/profile.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepository({required this.remoteDataSource});

  Future<Profile> getProfile() async {
    final dto = await remoteDataSource.getProfile();
    return dto.toDomain();
  }

  Future<Profile> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    DateTime? dateOfBirth,
    String? passportNumber,
    DateTime? passportExpiry,
  }) async {
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
  }
}

/// Provider for the [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});
