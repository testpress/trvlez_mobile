import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/screens/findr_referrals_screen.dart';

class _FakePortfolioNotifier extends FindrPortfolioNotifier {
  _FakePortfolioNotifier(this._portfolio);

  final FindrPortfolio _portfolio;

  @override
  Future<FindrPortfolio> build() async => _portfolio;
}

void main() {
  group('FindrReferralsScreen Widget Tests', () {
    late List<HotelReferralItem> sampleReferrals;

    setUp(() {
      sampleReferrals = [
        HotelReferralItem(
          id: 'ref-1',
          finderId: 'f-1',
          hotelName: 'Hotel Splendido',
          city: 'Portofino',
          countryCode: 'IT',
          streetAddress: 'Salita Baratta 16',
          targetEmail: 'info@splendido.it',
          status: 'converted',
          statusLabel: 'Joined',
          state: FindrRecommendationState.confirmed,
          createdAt: DateTime(2026, 9, 1),
        ),
        HotelReferralItem(
          id: 'ref-2',
          finderId: 'f-1',
          hotelName: 'Villa dEste',
          city: 'Cernobbio',
          countryCode: 'IT',
          streetAddress: 'Via Regina 40',
          targetEmail: 'gm@villadeste.it',
          status: 'introduction_sent',
          statusLabel: 'Invited',
          state: FindrRecommendationState.awaiting,
          createdAt: DateTime(2026, 10, 1),
        ),
        HotelReferralItem(
          id: 'ref-3',
          finderId: 'f-1',
          hotelName: 'Eden Roc',
          city: 'Positano',
          countryCode: 'IT',
          streetAddress: 'Via Marconi 110',
          targetEmail: 'stay@edenroc.it',
          status: 'onboarding_started',
          statusLabel: 'Onboarding started',
          state: FindrRecommendationState.awaiting,
          createdAt: DateTime(2026, 10, 10),
        ),
      ];
    });

    Widget createScreen(FindrPortfolio portfolio) {
      return ProviderScope(
        overrides: [
          findrPortfolioProvider.overrideWith(
            () => _FakePortfolioNotifier(portfolio),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FindrReferralsScreen(),
        ),
      );
    }

    testWidgets('renders all referrals and filter tabs', (tester) async {
      final portfolio = FindrPortfolio(
        joined: true,
        earned: '£0.00',
        joinedCount: 1,
        inReviewCount: 2,
        dueAmount: '£0.00',
        dueDate: '—',
        recommendations: const [],
        payouts: const [],
        hotelReferrals: sampleReferrals,
      );

      await tester.pumpWidget(createScreen(portfolio));
      await tester.pumpAndSettle();

      expect(find.text('All Recommendations'), findsOneWidget);
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Live (1)'), findsOneWidget);
      expect(find.text('In Review (1)'), findsOneWidget);
      expect(find.text('Outreach (1)'), findsOneWidget);

      expect(find.text('Hotel Splendido'), findsOneWidget);
      expect(find.text('Villa dEste'), findsOneWidget);
      expect(find.text('Eden Roc'), findsOneWidget);
    });

    testWidgets('filtering by Live shows only converted hotels', (tester) async {
      final portfolio = FindrPortfolio(
        joined: true,
        earned: '£0.00',
        joinedCount: 1,
        inReviewCount: 2,
        dueAmount: '£0.00',
        dueDate: '—',
        recommendations: const [],
        payouts: const [],
        hotelReferrals: sampleReferrals,
      );

      await tester.pumpWidget(createScreen(portfolio));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Live (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Hotel Splendido'), findsOneWidget);
      expect(find.text('Villa dEste'), findsNothing);
      expect(find.text('Eden Roc'), findsNothing);
    });

    testWidgets('tapping referral item opens details sheet', (tester) async {
      final portfolio = FindrPortfolio(
        joined: true,
        earned: '£0.00',
        joinedCount: 1,
        inReviewCount: 2,
        dueAmount: '£0.00',
        dueDate: '—',
        recommendations: const [],
        payouts: const [],
        hotelReferrals: sampleReferrals,
      );

      await tester.pumpWidget(createScreen(portfolio));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hotel Splendido'));
      await tester.pumpAndSettle();

      expect(find.text('Salita Baratta 16, Portofino, IT'), findsOneWidget);
      expect(find.text('info@splendido.it'), findsOneWidget);
    });

    testWidgets('renders empty state when filter has no items', (tester) async {
      const emptyPortfolio = FindrPortfolio(
        joined: true,
        earned: '£0.00',
        joinedCount: 0,
        inReviewCount: 0,
        dueAmount: '£0.00',
        dueDate: '—',
        recommendations: [],
        payouts: [],
        hotelReferrals: [],
      );

      await tester.pumpWidget(createScreen(emptyPortfolio));
      await tester.pumpAndSettle();

      expect(
        find.text('No recommendations in this category'),
        findsOneWidget,
      );
      expect(find.text('Recommend a hotel'), findsOneWidget);
    });
  });
}
