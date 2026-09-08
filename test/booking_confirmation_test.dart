import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/booking_confirmation_screen.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  Reservation? reservationToReturn;
  bool shouldThrow = false;
  String? lastFetchedId;

  @override
  Future<Reservation> getReservation(String id) async {
    lastFetchedId = id;
    if (shouldThrow) {
      throw Exception('Failed to load reservation');
    }
    return reservationToReturn!;
  }
}

void main() {
  final testReservation = Reservation(
    id: 'res-101',
    confirmationCode: 'TRV-88219042',
    status: ReservationStatus.confirmed,
    checkInDate: DateTime.utc(2026, 10, 15, 14, 0),
    checkOutDate: DateTime.utc(2026, 10, 18, 11, 0),
    guestName: 'Alex Mercer',
    guestEmail: 'alex@example.com',
    guestPhone: '+1234567890',
    numberOfGuests: 2,
    rooms: [
      const RoomSummary(
        id: 'room-1',
        roomNumber: '101',
        roomTypeId: 'rt-deluxe',
      ),
    ],
    specialRequests: 'High floor preferred',
    propertySummary: const ReservationPropertySummary(
      id: 'prop-1',
      name: 'Azure Coastlines Beach Resort',
      city: 'Goa',
      countryCode: 'IN',
      heroImageUrl: 'https://example.com/resort.jpg',
    ),
    createdAt: DateTime.utc(2026, 9, 8, 10, 0),
  );

  group('BookingConfirmationScreen Widget', () {
    testWidgets('renders all booking confirmation details and action buttons',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationScreen(
            reservation: testReservation,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(
        find.text('Your stay has been officially reserved and confirmed.'),
        findsOneWidget,
      );

      // Verify Confirmation Code & Status
      expect(find.text('CONFIRMATION CODE'), findsOneWidget);
      expect(find.text('TRV-88219042'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);

      // Verify Property Summary
      expect(find.text('Azure Coastlines Beach Resort'), findsOneWidget);
      expect(find.text('Goa, IN'), findsOneWidget);

      // Verify Stay Details
      expect(find.text('Lead Guest'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);
      expect(find.text('High floor preferred'), findsOneWidget);
      expect(find.text('2 Guests • 1 Room'), findsOneWidget);

      // Verify Action CTAs
      expect(find.text('View Check-in QR'), findsOneWidget);
      expect(find.text('View in My Trips'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('copies confirmation code to clipboard on copy tap',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            copiedText = (methodCall.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationScreen(
            reservation: testReservation,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap copy icon button
      final copyBtn = find.byIcon(Icons.copy_rounded);
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pump();

      // Verify SnackBar appears
      expect(
        find.text('Confirmation code copied to clipboard!'),
        findsOneWidget,
      );
      expect(copiedText, 'TRV-88219042');
    });

    testWidgets('fetches reservation by ID when deep-linked (no initial reservation)',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationScreen(
            reservationId: 'res-101',
            repository: mockRepo,
          ),
        ),
      );

      // Loading view is initially shown
      expect(find.text('Loading booking confirmation...'), findsOneWidget);

      await tester.pumpAndSettle();

      // After load
      expect(mockRepo.lastFetchedId, 'res-101');
      expect(find.text('TRV-88219042'), findsOneWidget);
      expect(find.text('Azure Coastlines Beach Resort'), findsOneWidget);
    });

    testWidgets('renders error view with retry button when deep link fetch fails',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmationScreen(
            reservationId: 'res-unknown',
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load confirmation'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Recover on retry
      mockRepo.shouldThrow = false;
      mockRepo.reservationToReturn = testReservation;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('TRV-88219042'), findsOneWidget);
    });
  });
}
