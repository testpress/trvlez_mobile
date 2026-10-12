import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/counter_tile.dart';

void main() {
  group('CreateReservationScreen Widget Tests', () {
    const testProperty = Property(
      id: 'prop-azure-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
      currencyCode: 'USD',
      shortDescription: 'A serene beachside escape',
      longDescription:
          'Experience luxury and tranquility with panoramic ocean views.',
      heroImageUrl: 'https://example.com/azure.jpg',
      roomTypes: [
        RoomType(
          id: 'rt-deluxe',
          name: 'Deluxe Ocean Suite',
          pricePerNight: 150.0,
          currencyCode: 'USD',
          maxOccupancy: 2,
          maxAdults: 2,
          maxChildren: 0,
          description: 'Spacious ocean-view room with king bed',
        ),
      ],
    );

    testWidgets(
      'renders property title, room type, and disabled button on mount',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CreateReservationScreen(property: testProperty),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Book Your Stay'), findsOneWidget);
        expect(find.text('Azure Coastal Resort'), findsOneWidget);
        expect(find.text('Deluxe Ocean Suite'), findsOneWidget);
        expect(find.text('Confirm Reservation'), findsOneWidget);

        final button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Confirm Reservation'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'enforces occupancy limit and strictly disables submission button when guests exceed capacity',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CreateReservationScreen(property: testProperty),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter guest name
        await tester.enterText(find.byType(TextField).first, 'John Traveler');
        await tester.pumpAndSettle();

        // Initial state: 1 guest, 1 room (maxOccupancy = 2)
        // Increment guests to 2: still valid
        final guestTile = find.widgetWithText(CounterTile, 'Guests');
        final guestIncrement = find.descendant(
          of: guestTile,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(guestIncrement);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Selected rooms accommodate up to'),
          findsNothing,
        );

        // Increment guests to 3: exceeds maxOccupancy 2!
        await tester.tap(guestIncrement);
        await tester.pumpAndSettle();

        // Occupancy warning must appear and button must remain disabled
        expect(
          find.textContaining('Selected rooms accommodate up to 2 guests'),
          findsOneWidget,
        );
        var button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Confirm Reservation'),
        );
        expect(button.onPressed, isNull);

        // Add another room: capacity becomes 4, warning disappears
        final roomTile = find.widgetWithText(CounterTile, 'Deluxe Ocean Suite');
        final roomIncrement = find.descendant(
          of: roomTile,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(roomIncrement);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Selected rooms accommodate up to'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'pre-selects specified room type when initialRoomTypeId is passed',
      (tester) async {
        final multiRoomProperty = testProperty.copyWith(
          roomTypes: const [
            RoomType(
              id: 'rt-std',
              name: 'Standard Suite',
              pricePerNight: 120.0,
              currencyCode: 'USD',
              maxOccupancy: 2,
              maxAdults: 2,
              maxChildren: 0,
              description: 'Standard room',
            ),
            RoomType(
              id: 'rt-ocean',
              name: 'Oceanfront Penthouse',
              pricePerNight: 350.0,
              currencyCode: 'USD',
              maxOccupancy: 4,
              maxAdults: 4,
              maxChildren: 2,
              description: 'Penthouse suite',
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CreateReservationScreen(
                property: multiRoomProperty,
                initialRoomTypeId: 'rt-ocean',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Oceanfront Penthouse'), findsOneWidget);
        expect(find.text('Standard Suite'), findsOneWidget);
      },
    );

    testWidgets('displays room rate subtitle on room selector tile', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateReservationScreen(property: testProperty),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$150 / night'), findsOneWidget);
    });

    testWidgets(
      'displays "Pricing unavailable" and disables booking when room has no price',
      (tester) async {
        final unpricedProperty = testProperty.copyWith(
          roomTypes: const [
            RoomType(
              id: 'rt-unpriced',
              name: 'Unpriced Suite',
              maxOccupancy: 2,
              maxAdults: 2,
              maxChildren: 0,
              description: 'Room without price',
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: CreateReservationScreen(property: unpricedProperty),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pricing unavailable'), findsAtLeastNWidgets(1));

        // Warning message should be displayed about invalid pricing
        expect(
          find.textContaining(
            'Pricing is unavailable for one or more selected rooms',
          ),
          findsOneWidget,
        );

        // Submit button must be disabled
        final button = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'Confirm Reservation'),
        );
        expect(button.onPressed, isNull);
      },
    );
  });
}
