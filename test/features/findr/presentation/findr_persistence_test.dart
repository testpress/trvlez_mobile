import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/home/presentation/screens/home_screen.dart';

class _FakeFinderRepository implements FinderRepository {
  FinderStateSummary currentSummary;

  _FakeFinderRepository({required this.currentSummary});

  @override
  Future<FinderStateSummary> getFinderStatus() async => currentSummary;

  @override
  FinderTerms getFinderTerms() => FinderTerms.defaultTerms;

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) async {
    final activeFinder = FinderIdentity(
      id: 'finder-123',
      userId: 'user-123',
      status: FinderStatusType.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    currentSummary = FinderStateSummary(
      finder: activeFinder,
      eligibility: const FinderEligibility(
        isEligible: true,
        reason: FinderEligibilityReason.eligible,
      ),
      reverificationRequired: false,
    );
    return activeFinder;
  }

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) async {
    throw UnimplementedError();
  }

  @override
  Future<List<HotelReferralItem>> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async => const [];

  @override
  Future<int> countAssociatedHotels() async => 0;

  @override
  Future<TravelerShareLink> getTravelerShareLink() async =>
      const TravelerShareLink(
        shareCode: 'TRV-TEST-1',
        shareUrl: 'https://trvlez.com/r/TRV-TEST-1',
      );

  @override
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async {
    return HotelReferralItem(
      id: 'ref-1',
      finderId: 'f-1',
      hotelName: params.hotelName,
      status: 'introduction_sent',
      statusLabel: 'Invited',
      state: FindrRecommendationState.awaiting,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<FindrPortfolio> getFindrPortfolio() async {
    final active = currentSummary.finder?.isActive ?? false;
    return FindrPortfolio.empty.copyWith(joined: active);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Findr Profile Activation State Management & App Restart Tests', () {
    late SharedPreferences prefs;
    late SettingsRepository settingsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsRepo = SettingsRepository(prefs);
    });

    test(
      'findrPortfolioProvider restores joined: true from SettingsRepository on startup',
      () {
        prefs.setBool('isFindrActivated', true);

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);

        final portfolio = container.read(liveFindrPortfolioProvider);
        expect(portfolio.joined, isTrue);
      },
    );

    test(
      'findrPortfolioProvider defaults to joined: false when unactivated',
      () {
        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);

        final portfolio = container.read(liveFindrPortfolioProvider);
        expect(portfolio.joined, isFalse);
      },
    );

    test(
      'joinFindr updates in-memory state and persists to SettingsRepository',
      () async {
        final fakeRepo = _FakeFinderRepository(
          currentSummary: const FinderStateSummary(
            finder: null,
            eligibility: FinderEligibility(
              isEligible: true,
              reason: FinderEligibilityReason.eligible,
            ),
            reverificationRequired: false,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            finderRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(liveFindrPortfolioProvider).joined, isFalse);
        expect(settingsRepo.isFindrActivated(), isFalse);

        await container.read(findrPortfolioProvider.notifier).joinFindr();

        expect(container.read(liveFindrPortfolioProvider).joined, isTrue);
        expect(settingsRepo.isFindrActivated(), isTrue);
      },
    );

    testWidgets(
      'HomeScreen retains active state (Recommend a hotel) when clearing the app and returning',
      (tester) async {
        final fakeRepo = _FakeFinderRepository(
          currentSummary: const FinderStateSummary(
            finder: null,
            eligibility: FinderEligibility(
              isEligible: true,
              reason: FinderEligibilityReason.eligible,
            ),
            reverificationRequired: false,
          ),
        );

        // Step 1: User launches the app for the first time
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(settingsRepo),
              finderRepositoryProvider.overrideWithValue(fakeRepo),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Initial state before activation: Shows "Activate Findr"
        expect(find.byType(FindrCard), findsOneWidget);
        expect(find.text('Activate Findr'), findsOneWidget);
        expect(find.text('Recommend a hotel'), findsNothing);

        // Step 2: User activates Findr
        final element = tester.element(find.byType(HomeScreen));
        final container = ProviderScope.containerOf(element);
        await container.read(findrPortfolioProvider.notifier).joinFindr();
        await tester.pumpAndSettle();

        // Post-activation in active session: Shows "Recommend a hotel"
        expect(find.text('Recommend a hotel'), findsOneWidget);
        expect(find.text('Activate Findr'), findsNothing);

        // Step 3: User CLEARS the app (app process killed, memory reset)
        // Simulate app restart by pumping a completely new ProviderScope with the same prefs
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        final restartedSettingsRepo = SettingsRepository(prefs);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(
                restartedSettingsRepo,
              ),
              finderRepositoryProvider.overrideWithValue(fakeRepo),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // CRITICAL CHECK: After clearing and returning, it must NOT show "Activate Findr"
        expect(find.text('Activate Findr'), findsNothing);
        expect(find.text('Recommend a hotel'), findsOneWidget);
        expect(find.text('Open'), findsOneWidget);
      },
    );

    test(
      'findrPortfolioProvider reactively syncs with live backend finderNotifierProvider',
      () async {
        final fakeRepo = _FakeFinderRepository(
          currentSummary: const FinderStateSummary(
            finder: null,
            eligibility: FinderEligibility(
              isEligible: true,
              reason: FinderEligibilityReason.eligible,
            ),
            reverificationRequired: false,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            finderRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );
        addTearDown(container.dispose);

        // Initially false
        expect(container.read(liveFindrPortfolioProvider).joined, isFalse);

        // Backend activates
        await container
            .read(finderNotifierProvider.notifier)
            .activate(
              const FinderActivationParams(
                addressLine1: '10 Downing St',
                city: 'London',
                postalCode: 'SW1A 2AA',
                residentialCountryCode: 'GB',
                agreementVersion: '2026-v1.0',
                agreementAccepted: true,
              ),
            );

        // Expect liveFindrPortfolioProvider to be synced
        expect(container.read(liveFindrPortfolioProvider).joined, isTrue);
        expect(settingsRepo.isFindrActivated(), isTrue);
      },
    );
  });
}
