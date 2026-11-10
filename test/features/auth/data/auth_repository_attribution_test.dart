import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/storage/attribution_storage.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:trvlez_mobile/features/auth/data/dto/traveler_signup_dto.dart';
import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class MockSecureStorage extends Fake implements FlutterSecureStorage {}

class RecordingAuthRemoteDataSource extends Fake implements AuthRemoteDataSource {
  String? lastEmail;
  String? lastPassword;
  String? lastClickReference;

  @override
  Future<TravelerSignupResponseDto> signUp({
    required String email,
    required String password,
    String? clickReference,
  }) async {
    lastEmail = email;
    lastPassword = password;
    lastClickReference = clickReference;

    return const TravelerSignupResponseDto(
      id: 'traveler-user-id-123',
      email: 'traveler@example.com',
      fullName: 'Test Traveler',
      travelerProfile: TravelerProfileNestedDto(
        id: 'traveler-profile-id-456',
        onboardingStep: 'COMPLETED',
      ),
    );
  }
}

void main() {
  group('AuthRepositoryImpl Attribution Integration', () {
    late RecordingAuthRemoteDataSource mockRemoteDataSource;
    late TokenStorage tokenStorage;
    late AttributionStorage attributionStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockRemoteDataSource = RecordingAuthRemoteDataSource();
      tokenStorage = TokenStorage(storage: MockSecureStorage());
      attributionStorage = AttributionStorage();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenStorage: tokenStorage,
        attributionStorage: attributionStorage,
      );
    });

    test('forwards captured click_reference to remoteDataSource.signUp',
        () async {
      const capturedRef = 'play_store_click_ref_1234567890';
      await attributionStorage.saveClickReference(capturedRef);

      await repository.signUp(
        email: 'traveler@example.com',
        password: 'securePassword123!',
      );

      expect(mockRemoteDataSource.lastEmail, equals('traveler@example.com'));
      expect(mockRemoteDataSource.lastPassword, equals('securePassword123!'));
      expect(mockRemoteDataSource.lastClickReference, equals(capturedRef));
    });

    test('signs up with null click_reference when none is stored', () async {
      await repository.signUp(
        email: 'direct_user@example.com',
        password: 'securePassword123!',
      );

      expect(mockRemoteDataSource.lastEmail, equals('direct_user@example.com'));
      expect(mockRemoteDataSource.lastClickReference, isNull);
    });
  });
}

