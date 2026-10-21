import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_steps_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_step_tile.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  Reservation? reservationToReturn;

  @override
  Future<Reservation> getReservation(String id) async {
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
        id: 'room-1',
        roomNumber: '101',
        roomTypeId: 'rt-standard',
        roomTypeName: 'Deluxe King Room',
        pricePerNight: 150.0,
        currencyCode: 'USD',
        numberOfNights: 3,
        lineTotal: 450.0,
      ),
    ],
    propertySummary: const ReservationPropertySummary(
      id: 'prop-1',
      name: 'The Grand Resort',
      city: 'Honolulu',
      countryCode: 'US',
      heroImageUrl: 'https://example.com/resort.jpg',
      requiresPrearrivalForm: false,
    ),
    createdAt: DateTime.utc(2026, 9, 1, 10, 0),
  );

  Widget createWidget({
    required TravelerVerificationState verificationState,
    required bool isVerified,
  }) {
    final mockRepo = MockReservationRepository();
    mockRepo.reservationToReturn = testReservation;

    return ProviderScope(
      overrides: [
        reservationRepositoryProvider.overrideWithValue(mockRepo),
        travelerVerificationStateProvider.overrideWithValue(verificationState),
        isKycVerifiedProvider.overrideWithValue(isVerified),
      ],
      child: const MaterialApp(
        home: CheckInStepsScreen(reservationId: 'res-101'),
      ),
    );
  }

  testWidgets(
    'shows identity verification required and does not ask to upload visa when unverified',
    (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createWidget(
          verificationState: TravelerVerificationState.profileComplete,
          isVerified: false,
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 should be active and prompt to verify identity
      expect(find.text('Your identity'), findsOneWidget);
      expect(find.text('Passport and selfie scan'), findsOneWidget);

      // Step 2 (Visa) should be present but in 'todo' state, not active
      expect(find.text('Upload your visa'), findsOneWidget);

      final tiles = tester
          .widgetList<CheckInStepTile>(find.byType(CheckInStepTile))
          .toList();
      expect(tiles.length, 4);

      // Step 1: state should be 'now'
      expect(tiles[0].number, 1);
      expect(tiles[0].state, CheckInStepState.now);

      // Step 2: state should be 'todo' (not 'now'!)
      expect(tiles[1].number, 2);
      expect(tiles[1].state, CheckInStepState.todo);

      // CTA button should prompt to verify identity
      expect(find.text('Verify identity'), findsOneWidget);
    },
  );

  testWidgets('shows verification in review when submitted/processing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createWidget(
        verificationState: TravelerVerificationState.submitted,
        isVerified: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verification in review'), findsOneWidget);
    expect(find.text('Check status'), findsOneWidget);

    final tiles = tester
        .widgetList<CheckInStepTile>(find.byType(CheckInStepTile))
        .toList();
    expect(tiles[0].state, CheckInStepState.now);
    expect(tiles[1].state, CheckInStepState.todo);
  });

  testWidgets('shows step 1 done and step 2 active when traveler is verified', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createWidget(
        verificationState: TravelerVerificationState.verified,
        isVerified: true,
      ),
    );
    await tester.pumpAndSettle();

    // Step 1 should be already verified
    expect(find.text('Already verified'), findsOneWidget);

    final tiles = tester
        .widgetList<CheckInStepTile>(find.byType(CheckInStepTile))
        .toList();

    // Step 1: done
    expect(tiles[0].number, 1);
    expect(tiles[0].state, CheckInStepState.done);

    // Step 2: now
    expect(tiles[1].number, 2);
    expect(tiles[1].state, CheckInStepState.now);

    // CTA button should be Continue
    expect(find.text('Continue'), findsOneWidget);
  });
}
