import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  Reservation? reservationToReturn;
  bool shouldThrow = false;
  String? lastFetchedId;
  String? lastCancelledId;

  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to fetch reservations');
    }
    return reservationToReturn != null ? [reservationToReturn!] : [];
  }

  @override
  Future<Reservation> getReservation(String id) async {
    lastFetchedId = id;
    if (shouldThrow) {
      throw const NotFoundException('Reservation not found');
    }
    return reservationToReturn!;
  }

  @override
  Future<Reservation> cancelReservation(String id) async {
    lastCancelledId = id;
    if (shouldThrow) {
      throw const NetworkException('Failed to cancel reservation');
    }
    return reservationToReturn!;
  }
}

void main() {
  final testReservation = Reservation(
    id: 'res-101',
    confirmationCode: 'TRV-12345678',
    status: ReservationStatus.confirmed,
    formStatus: 'completed',
    checkInDate: DateTime.utc(2026, 10, 15, 14, 0),
    checkOutDate: DateTime.utc(2026, 10, 18, 11, 0),
    guestName: 'Alex Traveler',
    guestEmail: 'alex@example.com',
    guestPhone: '+15551234567',
    numberOfGuests: 2,
    totalAmount: 450.0,
    currencyCode: 'USD',
    rooms: const [
      RoomSummary(
        id: 'room-summary-1',
        roomNumber: '302',
        roomTypeId: 'rt-deluxe',
        roomTypeName: 'Deluxe Ocean Suite',
        pricePerNight: 150.0,
        currencyCode: 'USD',
        numberOfNights: 3,
        lineTotal: 450.0,
      ),
    ],
    specialRequests: 'Quiet room on upper floor',
    propertySummary: const ReservationPropertySummary(
      id: 'prop-azure-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
      heroImageUrl: 'https://example.com/azure.jpg',
      requiresPrearrivalForm: false,
    ),
    createdAt: DateTime.utc(2026, 9, 1, 10, 0),
  );

  group('ReservationDetailScreen Widget Tests', () {
    testWidgets(
      'renders stay details, guest info, and confirmation code when loaded',
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
              home: ReservationDetailScreen(
                reservation: testReservation,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reservation Details'), findsOneWidget);
        expect(find.text('Azure Coastal Resort'), findsOneWidget);
        expect(find.text('TRV-12345678'), findsOneWidget);
        expect(find.text('Confirmed'), findsOneWidget);
        expect(find.text('Alex Traveler'), findsOneWidget);
        expect(find.text('302'), findsOneWidget);
        expect(find.text('Total Amount'), findsOneWidget);
        expect(find.text(r'$450 USD'), findsOneWidget);
        expect(find.text('Check-in Pass (QR Code)'), findsOneWidget);
      },
    );

    testWidgets(
      'renders Complete Pre-arrival Form button when property requires prearrival form',
      (tester) async {
        final prearrivalRes = testReservation.copyWith(
          propertySummary: const ReservationPropertySummary(
            id: 'prop-azure-1',
            name: 'Azure Coastal Resort',
            city: 'Goa',
            countryCode: 'IN',
            heroImageUrl: 'https://example.com/azure.jpg',
            requiresPrearrivalForm: true,
          ),
        );
        final mockRepo = MockReservationRepository();
        mockRepo.reservationToReturn = prearrivalRes;

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
              home: ReservationDetailScreen(
                reservation: prearrivalRes,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Complete Pre-arrival Form'), findsOneWidget);
      },
    );

    testWidgets('supports deep-linking by ID when reservation is null', (
      tester,
    ) async {
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
            home: ReservationDetailScreen(
              reservationId: 'res-101',
              repository: mockRepo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(mockRepo.lastFetchedId, 'res-101');
      expect(find.text('Azure Coastal Resort'), findsOneWidget);
      expect(find.text('TRV-12345678'), findsOneWidget);
    });

    testWidgets(
      'shows error state with retry button when deep link fetch fails',
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
              home: ReservationDetailScreen(
                reservationId: 'res-fail',
                repository: mockRepo,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ErrorView), findsOneWidget);
        expect(find.text('Unable to load reservation'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        // Recover on retry
        mockRepo.shouldThrow = false;
        mockRepo.reservationToReturn = testReservation;
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(find.text('Azure Coastal Resort'), findsOneWidget);
      },
    );

    testWidgets('shows confirmation dialog on cancel reservation tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
            home: ReservationDetailScreen(
              reservation: testReservation,
              repository: mockRepo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cancelBtn = find.widgetWithText(AppButton, 'Cancel Reservation');
      expect(cancelBtn, findsOneWidget);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      expect(find.text('Cancel Reservation?'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to cancel this reservation'),
        findsOneWidget,
      );

      // Confirm in dialog
      await tester.tap(
        find.widgetWithText(FilledButton, 'Cancel Reservation'),
      );
      await tester.pumpAndSettle();

      expect(mockRepo.lastCancelledId, 'res-101');
    });
  });
}
