import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_hotel_bottom_sheet.dart';

class _FakeFinderRepository implements FinderRepository {
  HotelReferralCreateParams? submittedParams;
  bool shouldFail = false;

  @override
  Future<FinderStateSummary> getFinderStatus() async =>
      const FinderStateSummary(
        finder: null,
        eligibility: FinderEligibility(
          isEligible: true,
          reason: FinderEligibilityReason.eligible,
        ),
        reverificationRequired: false,
      );

  @override
  FinderTerms getFinderTerms() => FinderTerms.defaultTerms;

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) {
    throw UnimplementedError();
  }

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) {
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
      const TravelerShareLink(shareCode: 'TEST', shareUrl: 'https://test');

  @override
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async {
    if (shouldFail) {
      throw Exception('Server rejected referral');
    }
    submittedParams = params;
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
  Future<FindrPortfolio> getFindrPortfolio() async => FindrPortfolio.empty;
}

void main() {
  group('ReferHotelBottomSheet Widget Tests', () {
    late _FakeFinderRepository fakeRepo;

    setUp(() {
      fakeRepo = _FakeFinderRepository();
    });

    Widget createWidget() {
      return ProviderScope(
        overrides: [finderRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: ReferHotelBottomSheet()),
        ),
      );
    }

    testWidgets('renders all input fields and submit button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Refer a Hotel'), findsOneWidget);
      expect(find.text('Hotel Name'), findsOneWidget);
      expect(find.text('Street Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Postal Code'), findsOneWidget);
      expect(find.text('Country Code (ISO 2-letter)'), findsOneWidget);
      expect(find.text('Contact Email'), findsOneWidget);
      expect(find.text('Contact Phone (Optional)'), findsOneWidget);
      expect(find.text('Personal Note (Optional)'), findsOneWidget);
      expect(find.text('Submit Recommendation'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Recommendation'));
      await tester.pumpAndSettle();

      expect(find.text('Hotel name is required'), findsOneWidget);
      expect(find.text('Street address is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('Postal code is required'), findsOneWidget);
      expect(find.text('Contact email is required'), findsOneWidget);
      expect(fakeRepo.submittedParams, isNull);
    });

    testWidgets('submits referral when valid data is entered', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Grand Palace Hotel'),
        'Royal Seaside Hotel',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. 10 High Street'),
        '100 Promenade des Anglais',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. London'),
        'Nice',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. SW1A 1AA'),
        '06000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. generalmanager@hotel.com'),
        'director@royalseaside.fr',
      );

      await tester.tap(find.text('Submit Recommendation'));
      await tester.pumpAndSettle();

      expect(fakeRepo.submittedParams, isNotNull);
      expect(fakeRepo.submittedParams!.hotelName, 'Royal Seaside Hotel');
      expect(fakeRepo.submittedParams!.city, 'Nice');
      expect(fakeRepo.submittedParams!.targetEmail, 'director@royalseaside.fr');
    });
  });
}
