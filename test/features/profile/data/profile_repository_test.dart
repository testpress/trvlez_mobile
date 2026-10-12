import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:trvlez_mobile/features/profile/data/dto/profile_dto.dart';
import 'package:trvlez_mobile/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDataSource extends Fake
    implements ProfileRemoteDataSource {
  bool shouldThrow = false;
  int statusCode = 500;
  String? lastUpdatePhone;
  String? lastUpdateNationality;
  String? lastUpdateDob;

  @override
  Future<ProfileDto> getProfile() async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/traveler/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/traveler/profile'),
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return const ProfileDto(
      id: 'prof-test-1',
      phone: '+15551234',
      nationality: 'Australia',
      gender: 'male',
      dateOfBirth: '1990-01-01',
      onboardingStep: 'welcome',
    );
  }

  @override
  Future<ProfileDto> updateProfile({
    String? phone,
    String? nationality,
    String? gender,
    String? dateOfBirth,
    String? passportNumber,
    String? passportExpiry,
  }) async {
    lastUpdatePhone = phone;
    lastUpdateNationality = nationality;
    lastUpdateDob = dateOfBirth;

    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/traveler/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/traveler/profile'),
          statusCode: statusCode,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    return ProfileDto(
      id: 'prof-test-1',
      phone: phone,
      nationality: nationality,
      gender: gender,
      dateOfBirth: dateOfBirth,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry,
      onboardingStep: 'profile_pending',
    );
  }
}

void main() {
  late MockProfileRemoteDataSource mockRemote;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockRemote = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('ProfileRepositoryImpl Unit Tests', () {
    test('getProfile returns mapped domain Profile', () async {
      final profile = await repository.getProfile();

      expect(profile.id, 'prof-test-1');
      expect(profile.phone, '+15551234');
      expect(profile.nationality, 'Australia');
      expect(profile.gender, 'male');
    });

    test('getProfile maps DioException to AppException', () async {
      mockRemote.shouldThrow = true;
      mockRemote.statusCode = 404;

      expect(() => repository.getProfile(), throwsA(isA<AppException>()));
    });

    test(
      'updateProfile formats dates and returns updated domain Profile',
      () async {
        final dob = DateTime.utc(1993, 10, 25);
        final expiry = DateTime.utc(2033, 10, 25);

        final updated = await repository.updateProfile(
          phone: '+919999988888',
          nationality: 'India',
          gender: 'female',
          dateOfBirth: dob,
          passportNumber: 'IND112233',
          passportExpiry: expiry,
        );

        expect(mockRemote.lastUpdatePhone, '+919999988888');
        expect(mockRemote.lastUpdateNationality, 'India');
        expect(mockRemote.lastUpdateDob, '1993-10-25');
        expect(updated.nationality, 'India');
        expect(updated.passportNumber, 'IND112233');
      },
    );

    test('updateProfile maps DioException to AppException', () async {
      mockRemote.shouldThrow = true;
      mockRemote.statusCode = 500;

      expect(
        () => repository.updateProfile(nationality: 'USA'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
