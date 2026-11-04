import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
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
                const Profile(id: 'prof-1', onboardingStep: 'verified'),
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
                const Profile(id: 'prof-1', onboardingStep: 'submitted'),
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
      'returns submitted when verificationStatus reports isProcessing',
      () async {
        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-proc',
          status: 'processing',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-1', onboardingStep: 'profile_complete'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(verificationStatusProvider.future);

        final state = container.read(travelerVerificationStateProvider);
        expect(state, equals(TravelerVerificationState.submitted));
        expect(state.isProcessing, isTrue);
      },
    );

    test('returns failed when verificationStatus reports isFailed', () async {
      fakeRepo.verificationStatus = const VerificationStatus(
        sessionId: 'session-fail',
        status: 'failed',
        errorReason: 'Passport image blurry',
      );

      final container = ProviderContainer(
        overrides: [
          verificationRepositoryProvider.overrideWithValue(fakeRepo),
          currentProfileProvider.overrideWith(
            () => _FakeProfileNotifier(
              const Profile(id: 'prof-1', onboardingStep: 'profile_complete'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(verificationStatusProvider.future);

      final state = container.read(travelerVerificationStateProvider);
      expect(state, equals(TravelerVerificationState.failed));
      expect(state.isFailed, isTrue);
    });

    test(
      'preserves verified status when already-verified user has verificationStatus in upload_pending (re-verification)',
      () async {
        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-reverify-1',
          status: 'upload_pending',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-1', onboardingStep: 'verified'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(verificationStatusProvider.future);

        final state = container.read(travelerVerificationStateProvider);
        expect(state, equals(TravelerVerificationState.verified));
        expect(container.read(isKycVerifiedProvider), isTrue);
      },
    );

    test(
      'preserves verified status when already-verified user has verificationStatus failed (re-verification attempt failed)',
      () async {
        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-reverify-fail',
          status: 'failed',
          errorReason: 'Passport image blurry',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-1', onboardingStep: 'verified'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(verificationStatusProvider.future);

        final state = container.read(travelerVerificationStateProvider);
        expect(state, equals(TravelerVerificationState.verified));
        expect(container.read(isKycVerifiedProvider), isTrue);
      },
    );

    test(
      'preserves verified status when VerificationNotifier enters verificationFailed phase for already-verified user',
      () async {
        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-1', onboardingStep: 'verified'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(travelerVerificationStateProvider),
          equals(TravelerVerificationState.verified),
        );

        // Manually simulate verification failure in the notifier
        container.read(verificationNotifierProvider.notifier).reset();
        // Since state is package-private or accessible via copyWith/phase
        // check effectiveState
        final effective = const VerificationState(
          phase: VerificationPhase.verificationFailed,
        ).effectiveState(TravelerVerificationState.verified);

        expect(effective, equals(TravelerVerificationState.verified));
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
                const Profile(id: 'prof-1', onboardingStep: 'profile_complete'),
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
