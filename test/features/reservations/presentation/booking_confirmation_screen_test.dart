import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/features/reservations/presentation/booking_confirmation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  Reservation? reservationToReturn;
  bool shouldThrow = false;
  String? lastFetchedId;

  @override
  Future<Reservation> getReservation(String id) async {
    lastFetchedId = id;
    if (shouldThrow) {
      throw const NotFoundException('Failed to load reservation');
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

  group('BookingConfirmationScreen Widget Tests', () {
    testWidgets(
      'renders all booking confirmation details and action buttons when verified',
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
              reservationRepositoryProvider.overrideWithValue(mockRepo),
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

        // Verify Confirmation Code
        expect(find.text('CONFIRMATION CODE'), findsOneWidget);
        expect(find.text('TRV-88219042'), findsOneWidget);

        // Verify Property Summary
        expect(find.text('Azure Coastlines Beach Resort'), findsOneWidget);
        expect(find.text('Goa, IN'), findsOneWidget);

        // Verify Stay Details
        expect(find.text('2 Guests'), findsOneWidget);
        expect(find.text('Total Amount'), findsOneWidget);
        expect(find.text(r'$540 USD'), findsOneWidget);

        // Verify Action CTAs
        expect(find.text('View in My Trips'), findsOneWidget);
      },
    );

    testWidgets('copies confirmation code to clipboard on copy tap', (
      tester,
    ) async {
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
            reservationRepositoryProvider.overrideWithValue(mockRepo),
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

      final copyBtn = find.byIcon(Icons.copy_outlined);
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pump();

      expect(find.text('Confirmation code copied!'), findsOneWidget);
      expect(copiedText, 'TRV-88219042');
    });

    testWidgets('fetches reservation by ID when deep-linked', (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationToReturn = testReservation;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
            reservationRepositoryProvider.overrideWithValue(mockRepo),
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

      await tester.pumpAndSettle();

      expect(mockRepo.lastFetchedId, 'res-101');
      expect(find.text('TRV-88219042'), findsOneWidget);
      expect(find.text('Azure Coastlines Beach Resort'), findsOneWidget);
    });

    testWidgets(
      'renders error view with retry button when deep link fetch fails',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.shouldThrow = true;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isKycVerifiedProvider.overrideWithValue(true),
              reservationRepositoryProvider.overrideWithValue(mockRepo),
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

        expect(find.byType(ErrorView), findsOneWidget);
        expect(find.text('Unable to load confirmation'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        // Recover on retry
        mockRepo.shouldThrow = false;
        mockRepo.reservationToReturn = testReservation;
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(find.text('TRV-88219042'), findsOneWidget);
      },
    );

    testWidgets(
      'displays KYC instructions banner and Verify Identity button when unverified',
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
              reservationRepositoryProvider.overrideWithValue(mockRepo),
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

        expect(find.text('Verification Required to Check In'), findsOneWidget);
        expect(find.text('Verify Your Identity Now'), findsOneWidget);
        expect(find.text('Start Identity Verification'), findsOneWidget);
      },
    );
  });
}
