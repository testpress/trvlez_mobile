import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/providers/repository_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

class _FakeAuthRepo extends Fake implements AuthRepository {
  bool shouldFail = false;
  @override
  Future<void> login({required String email, required String password}) async {
    if (shouldFail) throw const ServerException('Login failed');
  }
}

class _FakePropertiesRepo extends Fake implements PropertiesRepository {
  bool shouldFail = false;
  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    if (shouldFail) throw const ServerException('Failed to load properties');
    return [];
  }
}

class _FakeReservationsRepo extends Fake implements ReservationRepository {
  bool shouldFail = false;
  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    if (shouldFail) throw const ServerException('Failed to load reservations');
    return [];
  }
}

class _FakeProfileRepo extends Fake implements ProfileRepository {
  bool shouldFail = false;
  @override
  Future<Profile> getProfile() async {
    if (shouldFail) throw const ServerException('Profile error');
    return const Profile(
      id: 'p-1',
      onboardingStep: 'done',
      email: 'test@trvlez.com',
    );
  }
}

class _FakeFinderRepo extends Fake implements FinderRepository {
  bool shouldFail = false;
  @override
  Future<FinderStateSummary> getFinderStatus() async {
    if (shouldFail) throw const ServerException('Finder error');
    return const FinderStateSummary(
      eligibility: FinderEligibility(
        isEligible: true,
        reason: FinderEligibilityReason.eligible,
      ),
      reverificationRequired: false,
    );
  }
}

class _FakeVerificationRepo extends Fake implements VerificationRepository {
  @override
  Future<VerificationChallenge> getVerificationChallenge() async {
    return const VerificationChallenge(
      challengeId: 'c-1',
      challengeType: 'liveness',
    );
  }
}

class _FakeNfcService extends Fake implements NfcPassportService {
  @override
  Future<NfcDeviceStatus> getNfcStatus() async => NfcDeviceStatus.available;
}

void main() {
  group('Repository Composition & Provider Contract Tests', () {
    test('exposes interface-typed providers from composition boundary', () {
      expect(authRepositoryProvider, isA<Provider<AuthRepository>>());
      expect(
        propertiesRepositoryProvider,
        isA<Provider<PropertiesRepository>>(),
      );
      expect(
        reservationRepositoryProvider,
        isA<Provider<ReservationRepository>>(),
      );
      expect(profileRepositoryProvider, isA<Provider<ProfileRepository>>());
      expect(finderRepositoryProvider, isA<Provider<FinderRepository>>());
      expect(
        verificationRepositoryProvider,
        isA<Provider<VerificationRepository>>(),
      );
      expect(nfcPassportServiceProvider, isA<Provider<NfcPassportService>>());
    });

    test(
      'presentation notifiers receive domain interface and handle success & error transitions',
      () async {
        final authRepo = _FakeAuthRepo();
        final propRepo = _FakePropertiesRepo();
        final resRepo = _FakeReservationsRepo();
        final profileRepo = _FakeProfileRepo();
        final finderRepo = _FakeFinderRepo();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            propertiesRepositoryProvider.overrideWithValue(propRepo),
            reservationRepositoryProvider.overrideWithValue(resRepo),
            profileRepositoryProvider.overrideWithValue(profileRepo),
            finderRepositoryProvider.overrideWithValue(finderRepo),
            verificationRepositoryProvider.overrideWithValue(
              _FakeVerificationRepo(),
            ),
            nfcPassportServiceProvider.overrideWithValue(_FakeNfcService()),
          ],
        );
        addTearDown(container.dispose);

        // Auth: data -> error transitions
        final authNotifier = container.read(loginNotifierProvider.notifier);
        await authNotifier.login(email: 'test@example.com', password: 'secret');
        expect(container.read(loginNotifierProvider).hasError, isFalse);

        authRepo.shouldFail = true;
        await authNotifier.login(email: 'test@example.com', password: 'secret');
        expect(container.read(loginNotifierProvider).hasError, isTrue);

        // Properties: data -> error transitions
        expect(await container.read(propertiesProvider.future), isEmpty);
        propRepo.shouldFail = true;
        await container.read(propertiesProvider.notifier).fetchProperties();
        expect(container.read(propertiesProvider).hasError, isTrue);

        // Reservations: data -> error transitions
        expect(await container.read(reservationListProvider.future), isEmpty);
        resRepo.shouldFail = true;
        await container
            .read(reservationListProvider.notifier)
            .fetchReservations();
        expect(container.read(reservationListProvider).hasError, isTrue);

        // Profile: data -> error transitions
        expect((await container.read(currentProfileProvider.future)).id, 'p-1');

        // Finder: data -> error transitions
        expect(
          (await container.read(
            finderNotifierProvider.future,
          )).eligibility.isEligible,
          isTrue,
        );
        finderRepo.shouldFail = true;
        await container.read(finderNotifierProvider.notifier).refresh();
        expect(container.read(finderNotifierProvider).hasError, isTrue);
      },
    );
  });
}
