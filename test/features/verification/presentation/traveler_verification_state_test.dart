import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_status.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

import '../../../fixtures/fake_verification_repository.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  final Profile _profile;
  _FakeProfileNotifier(this._profile);

  @override
  FutureOr<Profile> build() => _profile;
}

void main() {
  group('travelerVerificationStateProvider', () {
    late FakeVerificationRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeVerificationRepository();
    });

    test(
      'returns verified when profile has onboarding_step = verified',
      () async {
        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-1',
                  onboardingStep: 'verified',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final state = container.read(travelerVerificationStateProvider);
        expect(state, equals(TravelerVerificationState.verified));
        expect(container.read(isKycVerifiedProvider), isTrue);
      },
    );

    test(
      'returns verified when VerificationNotifier enters verified phase even if profile is not yet updated',
      () async {
        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-1',
                  onboardingStep: 'verification_started',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(travelerVerificationStateProvider),
          equals(TravelerVerificationState.verificationStarted),
        );

        // Submit returns verified in fakeRepo
        await container
            .read(verificationNotifierProvider.notifier)
            .submitVerificationAsync();

        expect(
          container.read(verificationNotifierProvider).phase,
          equals(VerificationPhase.verified),
        );
        expect(
          container.read(travelerVerificationStateProvider),
          equals(TravelerVerificationState.verified),
        );
        expect(container.read(isKycVerifiedProvider), isTrue);
      },
    );

    test(
      'returns verified when verificationStatus reports isVerified',
      () async {
        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-123',
          status: 'verified',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-1',
                  onboardingStep: 'submitted',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Trigger verificationStatusProvider
        await container.read(verificationStatusProvider.future);

        final state = container.read(travelerVerificationStateProvider);
        expect(state, equals(TravelerVerificationState.verified));
      },
    );

    test(
      'reconcileWithBackend recovers verified status and updates travelerVerificationStateProvider',
      () async {
        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-456',
          status: 'verified',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-1',
                  onboardingStep: 'profile_complete',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(travelerVerificationStateProvider),
          equals(TravelerVerificationState.profileComplete),
        );

        await container
            .read(verificationNotifierProvider.notifier)
            .reconcileWithBackend();

        expect(
          container.read(verificationNotifierProvider).phase,
          equals(VerificationPhase.verified),
        );
        expect(
          container.read(travelerVerificationStateProvider),
          equals(TravelerVerificationState.verified),
        );
      },
    );
  });
}
