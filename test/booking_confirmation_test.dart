import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/booking_confirmation_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

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
    totalAmount: 540.0,
    currencyCode: 'USD',
    rooms: const [
      RoomSummary(
        id: 'room-1',
        roomNumber: '101',
        roomTypeId: 'rt-deluxe',
        roomTypeName: 'Deluxe Suite',
        pricePerNight: 180.0,
        currencyCode: 'USD',
        numberOfNights: 3,
        lineTotal: 540.0,
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
    testWidgets('renders all booking confirmation details and action buttons when verified',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservation: testReservation,
              repository: mockRepo,
              isKycVerified: true,
              verificationState: TravelerVerificationState.verified,
            ),
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
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('\$540 USD'), findsOneWidget);

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
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservation: testReservation,
              repository: mockRepo,
              isKycVerified: true,
              verificationState: TravelerVerificationState.verified,
            ),
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
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservationId: 'res-101',
              repository: mockRepo,
              isKycVerified: true,
              verificationState: TravelerVerificationState.verified,
            ),
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
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservationId: 'res-unknown',
              repository: mockRepo,
              isKycVerified: true,
              verificationState: TravelerVerificationState.verified,
            ),
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

    testWidgets('displays KYC required banner and Verify Identity button when unverified',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(false),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.profilePending,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservation: testReservation,
              repository: mockRepo,
              isKycVerified: false,
              verificationState: TravelerVerificationState.profilePending,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify KYC reminder banner is visible
      expect(find.text('Identity Verification Required'), findsOneWidget);
      expect(
        find.textContaining('complete your identity verification before your arrival'),
        findsOneWidget,
      );
      expect(find.text('Verify Identity Now'), findsOneWidget);

      // Primary CTA directs to verify, secondary lets traveler view pass details
      expect(find.text('Verify Identity to Check In'), findsOneWidget);
      expect(find.text('Check-in Pass Details'), findsOneWidget);
    });

    testWidgets('displays review status banner when verification is submitted',
        (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(false),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.submitted,
            ),
          ],
          child: MaterialApp(
            home: BookingConfirmationScreen(
              reservation: testReservation,
              repository: mockRepo,
              isKycVerified: false,
              verificationState: TravelerVerificationState.submitted,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verification Under Review'), findsOneWidget);
      expect(
        find.textContaining('Your identity documents are currently under review'),
        findsOneWidget,
      );
      expect(find.text('Check Verification Status'), findsOneWidget);
    });
  });
}
