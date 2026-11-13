import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booked_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_card_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_dates_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_review_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/property_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

class _MockPropertiesRepository extends Fake implements PropertiesRepository {
  List<Property> propertiesToReturn = [];

  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async => propertiesToReturn;

  @override
  Future<Property> getPropertyDetail(String id) async {
    return propertiesToReturn.firstWhere((p) => p.id == id);
  }
}

Widget _buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
  TextScaler? textScaler,
}) {
  return testAppWithProviders(
    overrides: overrides,
    textScaler: textScaler,
    child: child,
  );
}

void main() {
  const testProperty = Property(
    id: 'prop-1',
    name: 'Seaside Grand Resort',
    city: 'Nice',
    countryCode: 'FR',
    shortDescription: 'Nice hotel',
    longDescription: 'Nice hotel description',
    heroImageUrl: 'https://example.com/hero.jpg',
    pricePerNight: 200,
    roomTypes: [
      RoomType(
        id: 'rt-1',
        name: 'Deluxe Sea View',
        maxOccupancy: 2,
        maxAdults: 2,
        maxChildren: 1,
        description: 'Room description',
        pricePerNight: 200,
      ),
    ],
  );

  group('PropertyScreen', () {
    testWidgets('renders empty state when no draft exists', (tester) async {
      await tester.pumpWidget(_buildTestApp(child: const PropertyScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Open a property from ezStays or Saved to start a booking.'),
        findsOneWidget,
      );
      expect(find.text('Go to ezStays'), findsOneWidget);
    });

    testWidgets('renders property info and room cards when draft is active', (
      tester,
    ) async {
      final container = ProviderContainer();
      container.read(bookingDraftProvider.notifier).beginBooking(testProperty);
      final range = BookingDateRange(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 5),
      );
      container.read(bookingDraftProvider.notifier).setBookingRange(range);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: PropertyScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Seaside Grand Resort'), findsOneWidget);
      expect(find.text('Verified partner'), findsOneWidget);
      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('Deluxe Sea View'), findsOneWidget);
      expect(find.text('Select a room'), findsOneWidget);
    });

    testWidgets(
      'fetches full property details and real room types when property has empty roomTypes',
      (tester) async {
        const listingProperty = Property(
          id: 'prop-1',
          name: 'Seaside Grand Resort',
          city: 'Nice',
          countryCode: 'FR',
          shortDescription: 'Nice hotel',
          longDescription: 'Nice hotel description',
          heroImageUrl: 'https://example.com/hero.jpg',
          pricePerNight: 200,
          roomTypes: [], // Empty, as returned by /properties/listing
        );

        final mockRepo = _MockPropertiesRepository();
        mockRepo.propertiesToReturn = [testProperty];

        await tester.pumpWidget(
          _buildTestApp(
            overrides: [
              propertiesRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const PropertyScreen(
              property: listingProperty,
              propertyId: 'prop-1',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Seaside Grand Resort'), findsOneWidget);
        expect(find.text('Rooms'), findsOneWidget);
      },
    );

    testWidgets('renders empty selection view when propertyId is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(child: const PropertyScreen(propertyId: '')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Open a property from ezStays or Saved to start a booking.'),
        findsOneWidget,
      );
    });
  });

  group('BookingDatesScreen', () {
    testWidgets('renders month grids and Done CTA', (tester) async {
      final container = ProviderContainer();
      container.read(bookingDraftProvider.notifier).beginBooking(testProperty);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: BookingDatesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your dates'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('BookingReviewScreen', () {
    testWidgets('renders review summary and breakdown', (tester) async {
      final container = ProviderContainer();
      container.read(bookingDraftProvider.notifier).beginBooking(testProperty);
      final range = BookingDateRange(
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 5),
      );
      container.read(bookingDraftProvider.notifier).setBookingRange(range);
      container.read(bookingDraftProvider.notifier).setRoomQuantity('rt-1', 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: BookingReviewScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsWidgets);
      expect(find.text('Seaside Grand Resort'), findsOneWidget);
      expect(find.text('Deluxe Sea View'), findsOneWidget);
      expect(find.text('Confirm booking'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      container.dispose();
    });

    testMaterialScreenMatrix(
      'maintains booking review summary and confirmation action across phone matrix',
      builder: (tester, scenario) async {
        final container = ProviderContainer();
        container
            .read(bookingDraftProvider.notifier)
            .beginBooking(testProperty);
        final range = BookingDateRange(
          DateTime(2026, 11, 1),
          DateTime(2026, 11, 5),
        );
        container.read(bookingDraftProvider.notifier).setBookingRange(range);
        container
            .read(bookingDraftProvider.notifier)
            .setRoomQuantity('rt-1', 1);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              textScaler: scenario.textScaler,
              child: const BookingReviewScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Review'), findsWidgets);
        expect(find.text('Seaside Grand Resort'), findsOneWidget);

        final confirmBtn = find.text('Confirm booking');
        await tester.ensureVisible(confirmBtn);
        expect(confirmBtn, findsOneWidget);
        container.dispose();
      },
    );
  });

  group('BookingCardScreen', () {
    testWidgets('renders card fields and Save card CTA', (tester) async {
      await tester.pumpWidget(_buildTestApp(child: const BookingCardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Name on card'), findsOneWidget);
      expect(find.text('Card number'), findsOneWidget);
      expect(find.text('Expiry'), findsOneWidget);
      expect(find.text('Security code'), findsOneWidget);
      expect(find.text('Save card'), findsOneWidget);
    });
  });

  group('BookedScreen', () {
    testWidgets('renders booked confirmation and action buttons', (
      tester,
    ) async {
      final now = DateTime.now();
      final sampleRange = BookingDateRange(
        now.add(const Duration(days: 5)),
        now.add(const Duration(days: 8)),
      );
      final sampleBooking = CreatedBooking(
        id: 'bk-1',
        propertyId: 'prop-1',
        propertyName: 'Seaside Grand Resort',
        propertyPlace: 'Nice, France',
        range: sampleRange,
        guests: const GuestCounts(),
        picks: [
          RoomPick(
            type: const BookingRoomType(
              id: 'rt-1',
              name: 'Deluxe Sea View',
              sleeps: 2,
              nightly: 200,
            ),
            quantity: 1,
            range: sampleRange,
          ),
        ],
      );

      final container = ProviderContainer();
      container.read(lastCreatedBookingsProvider.notifier).state = [
        sampleBooking,
      ];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: BookedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("You're booked"), findsOneWidget);
      expect(find.text('View booking'), findsOneWidget);
      expect(find.text('Back to ezStays'), findsOneWidget);
    });
  });
}
