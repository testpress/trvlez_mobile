import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';

class MockPropertiesRepository extends Fake implements PropertiesRepository {
  List<Property> propertiesToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to load properties');
    }
    return propertiesToReturn;
  }

  @override
  Future<Property> getPropertyDetail(String id) async {
    if (shouldThrow) {
      throw const NotFoundException('Property not found');
    }
    return propertiesToReturn.firstWhere((p) => p.id == id);
  }
}

void main() {
  group('PropertyDetailScreen Widget', () {
    const detailProperty = Property(
      id: 'prop-detail-1',
      name: 'Grand Bayfront Hotel',
      city: 'Kochi',
      stateRegion: 'Kerala',
      countryCode: 'IN',
      propertyType: 'hotel',
      shortDescription: 'Luxury seaside stay',
      longDescription:
          'Experience unparalleled luxury at the waterfront with spectacular harbor views, award-winning restaurants, and personalized service across every floor of our historic establishment.',
      heroImageUrl: 'https://example.com/kochi.jpg',
      amenities: ['wifi', 'swimming_pool', 'gym', 'spa'],
      checkinTime: '15:00',
      checkoutTime: '11:00',
      totalRooms: 45,
      roomTypes: [
        RoomType(
          id: 'rt-1',
          name: 'Deluxe King Harbour View',
          maxOccupancy: 3,
          maxAdults: 2,
          maxChildren: 1,
          description: 'Spacious king room facing the Arabian Sea',
          pricePerNight: 180.0,
        ),
        RoomType(
          id: 'rt-2',
          name: 'Executive Suite',
          maxOccupancy: 4,
          maxAdults: 3,
          maxChildren: 2,
          description: 'Two-room suite with private lounge access',
          pricePerNight: 260.0,
        ),
      ],
    );

    testWidgets('renders full property details, facilities, and room types', (
      tester,
    ) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            property: detailProperty,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify name, location, and type badge
      expect(find.text('Grand Bayfront Hotel'), findsOneWidget);
      expect(find.text('Kochi, Kerala, IN'), findsOneWidget);
      expect(find.text('HOTEL'), findsOneWidget);

      // Verify operational badges
      expect(find.text('Check-in: 15:00'), findsOneWidget);
      expect(find.text('Check-out: 11:00'), findsOneWidget);
      expect(find.text('45 Rooms'), findsOneWidget);

      // Verify facility pills
      expect(find.text('Wifi'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Spa'), findsOneWidget);

      // Verify room types section and pricing
      expect(find.text('Available Rooms'), findsOneWidget);
      expect(find.text('Deluxe King Harbour View'), findsOneWidget);
      expect(find.text('\$180 / night'), findsOneWidget);
      expect(find.text('Max 3'), findsOneWidget);
      expect(find.text('Executive Suite'), findsOneWidget);
      expect(find.text('\$260 / night'), findsOneWidget);
      expect(find.text('Max 4'), findsOneWidget);

      // Verify CTA button with starting rate
      expect(find.text('Book Now'), findsOneWidget);
      expect(find.text('From \$180 / night'), findsOneWidget);
    });

    testWidgets('expands and collapses description when Read more is tapped', (
      tester,
    ) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            property: detailProperty,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('supports deep linking by ID when initial property is null', (
      tester,
    ) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            propertyId: 'prop-detail-1',
            repository: mockRepo,
          ),
        ),
      );

      // Initially shows loading
      expect(find.text('Loading property details...'), findsOneWidget);

      // After future completes
      await tester.pumpAndSettle();
      expect(find.text('Grand Bayfront Hotel'), findsOneWidget);
      expect(find.text('Deluxe King Harbour View'), findsOneWidget);
    });

    testWidgets('shows error state with retry when deep link fetch fails', (
      tester,
    ) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            propertyId: 'non-existent',
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load property'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets(
      'highlights tapped room type card and updates selection state',
      (tester) async {
        final mockRepo = MockPropertiesRepository();
        mockRepo.propertiesToReturn = [detailProperty];

        await tester.pumpWidget(
          MaterialApp(
            home: PropertyDetailScreen(
              property: detailProperty,
              repository: mockRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tap to select'), findsNWidgets(2));
        expect(find.text('Selected'), findsNothing);

        await tester.ensureVisible(find.text('Deluxe King Harbour View'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Deluxe King Harbour View'));
        await tester.pumpAndSettle();

        expect(find.text('Selected'), findsOneWidget);
        expect(find.text('Tap to select'), findsOneWidget);
        // Bottom bar updates from starting price to selected room type price
        expect(find.text('Selected Room'), findsOneWidget);
        expect(
          find.text('\$180 / night'),
          findsNWidgets(2),
        ); // Card and bottom bar
      },
    );

    testWidgets(
      'renders pricing unavailable and disables book now when room types are unpriced',
      (tester) async {
        const unpricedProperty = Property(
          id: 'prop-unpriced',
          name: 'Unpriced Inn',
          city: 'Shimla',
          countryCode: 'IN',
          shortDescription: 'Basic lodge',
          longDescription: 'Basic lodge without rates set',
          heroImageUrl: '',
          roomTypes: [
            RoomType(
              id: 'rt-unpriced',
              name: 'Dorm Bed',
              maxOccupancy: 1,
              maxAdults: 1,
              maxChildren: 0,
              description: 'Shared dorm',
            ),
          ],
        );

        final mockRepo = MockPropertiesRepository();
        mockRepo.propertiesToReturn = [unpricedProperty];

        await tester.pumpWidget(
          MaterialApp(
            home: PropertyDetailScreen(
              property: unpricedProperty,
              repository: mockRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Pricing unavailable'),
          findsNWidgets(2),
        ); // Card and bottom bar
        expect(find.text('Unavailable'), findsOneWidget);

        final bookNowButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Book Now'),
        );
        expect(bookNowButton.onPressed, isNull);
      },
    );
  });
}
