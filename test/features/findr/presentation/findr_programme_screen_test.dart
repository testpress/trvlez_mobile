import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/screens/findr_programme_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';

class _MockFinderRepository implements FinderRepository {
  @override
  Future<FinderStateSummary> getFinderStatus() async => throw UnimplementedError();

  @override
  FinderTerms getFinderTerms() => FinderTerms.defaultTerms;

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) async =>
      throw UnimplementedError();

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) async =>
      throw UnimplementedError();

  @override
  Future<List<HotelReferralItem>> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async =>
      const [];

  @override
  Future<int> countAssociatedHotels() async => 0;

  @override
  Future<TravelerShareLink> getTravelerShareLink() async =>
      const TravelerShareLink(
        shareCode: 'TRV-MOCK-1',
        shareUrl: 'https://trvlez.com/r/TRV-MOCK-1',
      );

  @override
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async =>
      throw UnimplementedError();

  @override
  Future<FindrPortfolio> getFindrPortfolio() async =>
      FindrPortfolio.empty.copyWith(joined: true);
}

class TestFinderNotifier extends FinderNotifier {
  TestFinderNotifier(this._initial);

  final AsyncValue<FinderStateSummary> _initial;

  @override
  Future<FinderStateSummary> build() async {
    return _initial.value!;
  }
}

class _TestProfileNotifier extends ProfileNotifier {
  _TestProfileNotifier(this._profile);

  final Profile _profile;

  @override
  FutureOr<Profile> build() => _profile;
}

void main() {
  group('FindrProgrammeScreen Widget Tests', () {
    Widget buildScreen({
      required AsyncValue<FinderStateSummary> asyncState,
      Profile? profile,
    }) {
      final effectiveProfile = profile ??
          const Profile(
            id: 'p-1',
            nationality: 'GBR',
            onboardingStep: 'verified',
          );

      return ProviderScope(
        overrides: [
          finderRepositoryProvider.overrideWithValue(_MockFinderRepository()),
          finderNotifierProvider.overrideWith(
            () => TestFinderNotifier(asyncState),
          ),
          currentProfileProvider.overrideWith(
            () => _TestProfileNotifier(effectiveProfile),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FindrProgrammeScreen(),
        ),
      );
    }


    testWidgets('shows loading view while loading status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            finderNotifierProvider.overrideWith(
              () => _AlwaysLoadingFinderNotifier(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FindrProgrammeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Checking Findr status...'), findsOneWidget);
    });

    testWidgets('shows error view with retry action on failure',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            finderNotifierProvider.overrideWith(
              () => _FailingFinderNotifier(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FindrProgrammeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Network unavailable'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets(
        'shows blocked view with Start Verification CTA when verification incomplete',
        (tester) async {
      const summary = FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: false,
          reason: FinderEligibilityReason.verificationIncomplete,
        ),
        reverificationRequired: false,
      );

      await tester.pumpWidget(
        buildScreen(asyncState: const AsyncData(summary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Passport Verification Required'), findsOneWidget);
      expect(find.text('Start Verification'), findsOneWidget);
    });

    testWidgets(
        'shows blocked view with Age Requirement when user is underage',
        (tester) async {
      const summary = FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: false,
          reason: FinderEligibilityReason.underage,
        ),
        reverificationRequired: false,
      );

      await tester.pumpWidget(
        buildScreen(asyncState: const AsyncData(summary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Age Requirement (18+)'), findsOneWidget);
      expect(find.text('Start Verification'), findsNothing);
    });

    testWidgets(
        'shows Activate Findr CTA when user has GBR passport and is eligible',
        (tester) async {
      const summary = FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: true,
          reason: FinderEligibilityReason.eligible,
        ),
        reverificationRequired: false,
      );

      const gbrProfile = Profile(
        id: 'p-gb',
        nationality: 'GBR',
        onboardingStep: 'verified',
      );

      await tester.pumpWidget(
        buildScreen(
          asyncState: const AsyncData(summary),
          profile: gbrProfile,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Activate Findr'), findsOneWidget);
      expect(find.text('How it works'), findsOneWidget);
    });

    testWidgets(
        'pre-informs user with UK Only blocked view when passport is non-GBR',
        (tester) async {
      const summary = FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: false,
          reason: FinderEligibilityReason.marketUnavailable,
        ),
        reverificationRequired: false,
      );

      const nonGbrProfile = Profile(
        id: 'p-us',
        nationality: 'USA',
        onboardingStep: 'verified',
      );

      await tester.pumpWidget(
        buildScreen(
          asyncState: const AsyncData(summary),
          profile: nonGbrProfile,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Market Unavailable'), findsOneWidget);
      expect(find.text('Activate Findr'), findsNothing);
    });


    testWidgets('shows active dashboard and recommendations when active',
        (tester) async {
      final summary = FinderStateSummary(
        finder: FinderIdentity(
          id: 'f-active-1',
          userId: 'u-1',
          status: FinderStatusType.active,
          address: const FinderAddress(
            addressLine1: '10 Downing St',
            city: 'London',
            postalCode: 'SW1A 2AA',
            residentialCountryCode: 'GB',
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        eligibility: const FinderEligibility(
          isEligible: true,
          reason: FinderEligibilityReason.eligible,
        ),
        reverificationRequired: false,
      );

      await tester.pumpWidget(
        buildScreen(asyncState: AsyncData(summary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recommend a hotel'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('Payouts'), findsOneWidget);
    });

    testWidgets('shows reverification banner when reverificationRequired',
        (tester) async {
      final summary = FinderStateSummary(
        finder: FinderIdentity(
          id: 'f-active-1',
          userId: 'u-1',
          status: FinderStatusType.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        eligibility: const FinderEligibility(
          isEligible: true,
          reason: FinderEligibilityReason.eligible,
        ),
        reverificationRequired: true,
      );

      await tester.pumpWidget(
        buildScreen(asyncState: AsyncData(summary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Passport Re-Verification Required'), findsOneWidget);
      expect(find.text('Re-verify Passport'), findsOneWidget);
    });

    testWidgets(
        'shows suspension banner and Activity Paused when temporarily suspended',
        (tester) async {
      final summary = FinderStateSummary(
        finder: FinderIdentity(
          id: 'f-susp-1',
          userId: 'u-1',
          status: FinderStatusType.suspendedTemporary,
          suspensionEndsAt: DateTime.parse('2026-12-01T00:00:00Z'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        eligibility: const FinderEligibility(
          isEligible: false,
          reason: FinderEligibilityReason.terminalStatus,
        ),
        reverificationRequired: false,
      );

      await tester.pumpWidget(
        buildScreen(asyncState: AsyncData(summary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Membership Temporarily Suspended'), findsOneWidget);
      expect(find.text('Activity Paused'), findsOneWidget);
    });
  });
}

class _AlwaysLoadingFinderNotifier extends FinderNotifier {
  @override
  Future<FinderStateSummary> build() async {
    // Return pending future that never resolves during test pump
    return Completer<FinderStateSummary>().future;
  }
}

class _FailingFinderNotifier extends FinderNotifier {
  @override
  Future<FinderStateSummary> build() async {
    throw Exception('Network unavailable');
  }
}
