import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';

class MockProfileRepository extends Fake implements ProfileRepository {
  bool shouldThrow = false;
  Profile profileToReturn = const Profile(
    id: 'prof-state-1',
    phone: '+1234567890',
    nationality: 'Germany',
    gender: 'female',
    onboardingStep: 'welcome',
  );

  @override
  Future<Profile> getProfile() async {
    if (shouldThrow) {
      throw const NetworkException('Failed to fetch profile');
    }
    return profileToReturn;
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
    if (shouldThrow) {
      throw const ValidationException('Invalid profile data');
    }
    profileToReturn = profileToReturn.copyWith(
      phone: phone,
      nationality: nationality,
      gender: gender,
      dateOfBirth: dateOfBirth,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry,
    );
    return profileToReturn;
  }
}

void main() {
  group('ProfileNotifier State Tests', () {
    late MockProfileRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockProfileRepository();
      container = ProviderContainer(
        overrides: [profileRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build loads traveler profile initially', () async {
      final profile = await container.read(currentProfileProvider.future);

      expect(profile.id, 'prof-state-1');
      expect(profile.nationality, 'Germany');
      expect(profile.gender, 'female');
    });

    test('updateProfile updates state successfully and returns true', () async {
      await container.read(currentProfileProvider.future);

      final success = await container
          .read(currentProfileProvider.notifier)
          .updateProfile(nationality: 'Japan', phone: '+819012345678');

      expect(success, isTrue);
      final updated = container.read(currentProfileProvider).value;
      expect(updated?.nationality, 'Japan');
      expect(updated?.phone, '+819012345678');
    });

    test(
      'updateProfile sets AsyncError and returns false on failure',
      () async {
        await container.read(currentProfileProvider.future);

        mockRepo.shouldThrow = true;
        final success = await container
            .read(currentProfileProvider.notifier)
            .updateProfile(nationality: 'Invalid');

        expect(success, isFalse);
        final state = container.read(currentProfileProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<ValidationException>());

        // clearError resets error state
        container.read(currentProfileProvider.notifier).clearError();
        expect(container.read(currentProfileProvider).hasError, isFalse);
      },
    );
  });
}
