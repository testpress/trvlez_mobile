import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/qr_code_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  Reservation? reservationToReturn;
  CheckInToken? tokenToReturn;
  bool shouldThrow = false;
  int generateTokenCallCount = 0;
  String? lastFetchedId;

  @override
  Future<Reservation> getReservation(String id) async {
    lastFetchedId = id;
    if (shouldThrow) {
      throw const NotFoundException('Failed to load reservation');
    }
    return reservationToReturn!;
  }

  @override
  Future<CheckInToken> generateCheckInToken(String reservationId) async {
    generateTokenCallCount++;
    if (shouldThrow) {
      throw const NetworkException('Failed to generate token');
    }
    return tokenToReturn ??
        CheckInToken(
          token: 'tok_url_safe_64char_example_1234567890',
          reservationId: reservationId,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );
  }
}

void main() {
  final testReservation = Reservation(
    id: 'res-qr-1',
    confirmationCode: 'TRV-77665544',
    status: ReservationStatus.confirmed,
    checkInDate: DateTime.utc(2026, 11, 1, 14, 0),
    checkOutDate: DateTime.utc(2026, 11, 4, 11, 0),
    guestName: 'Taylor Morgan',
    numberOfGuests: 2,
    rooms: const [
      RoomSummary(id: 'r-1', roomNumber: '202', roomTypeId: 'rt-standard'),
    ],
    propertySummary: const ReservationPropertySummary(
      id: 'prop-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
      heroImageUrl: 'https://example.com/resort.jpg',
    ),
    createdAt: DateTime.utc(2026, 9, 8, 10, 0),
  );

  group('QrCodeScreen Widget Tests', () {
    testWidgets(
      'renders property header and auto-generates QR token on load when verified',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationToReturn = testReservation;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
              isKycVerifiedProvider.overrideWithValue(true),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: MaterialApp(
              home: QrCodeScreen(
                reservation: testReservation,
                repository: mockRepo,
                isKycVerified: true,
                verificationState: TravelerVerificationState.verified,
              ),
            ),
          ),
        );

        // Verify header before token arrives
        expect(find.text('Azure Coastal Resort'), findsOneWidget);
        expect(find.text('TRV-77665544'), findsOneWidget);

        // Settle auto-generation call
        await tester.pumpAndSettle();

        expect(mockRepo.generateTokenCallCount, 1);

        // Verify QR Code image is rendered with the generated token
        expect(find.byType(QrImageView), findsOneWidget);

        // Verify countdown badge is rendered
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
        expect(find.textContaining('Valid for'), findsOneWidget);
      },
    );

    testWidgets(
      'displays expired badge and allows regeneration when token expires',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationToReturn = testReservation;
        // Start with an expired token
        mockRepo.tokenToReturn = CheckInToken(
          token: 'tok_old_expired',
          reservationId: 'res-qr-1',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
              isKycVerifiedProvider.overrideWithValue(true),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: MaterialApp(
              home: QrCodeScreen(
                reservation: testReservation,
                repository: mockRepo,
                isKycVerified: true,
                verificationState: TravelerVerificationState.verified,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify expired badge is rendered
        expect(find.text('Token Expired'), findsOneWidget);

        // Now update mock repo to return fresh token
        mockRepo.tokenToReturn = CheckInToken(
          token: 'tok_fresh_regenerated',
          reservationId: 'res-qr-1',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );

        final regenerateButton = find.widgetWithText(
          AppButton,
          'Refresh QR Code',
        );
        expect(regenerateButton, findsOneWidget);
        await tester.tap(regenerateButton);
        await tester.pumpAndSettle();

        expect(mockRepo.generateTokenCallCount, greaterThanOrEqualTo(2));
      },
    );

    testWidgets(
      'supports deep-linking by reservation ID when reservation is null',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationToReturn = testReservation;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
              isKycVerifiedProvider.overrideWithValue(true),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.verified,
              ),
            ],
            child: MaterialApp(
              home: QrCodeScreen(
                reservationId: 'res-qr-1',
                repository: mockRepo,
                isKycVerified: true,
                verificationState: TravelerVerificationState.verified,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(mockRepo.lastFetchedId, 'res-qr-1');
        expect(find.text('Azure Coastal Resort'), findsOneWidget);
        expect(find.text('TRV-77665544'), findsOneWidget);
        expect(find.byType(QrImageView), findsOneWidget);
      },
    );

    testWidgets('shows error state with retry when deep link fetch fails', (
      tester,
    ) async {
      final mockRepo = MockReservationRepository();
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
            isKycVerifiedProvider.overrideWithValue(true),
            travelerVerificationStateProvider.overrideWithValue(
              TravelerVerificationState.verified,
            ),
          ],
          child: MaterialApp(
            home: QrCodeScreen(
              reservationId: 'res-error-id',
              repository: mockRepo,
              isKycVerified: true,
              verificationState: TravelerVerificationState.verified,
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
    });

    testWidgets(
      'blocks auto-generation and renders KYC required guidance when unverified',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationToReturn = testReservation;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
              isKycVerifiedProvider.overrideWithValue(false),
              travelerVerificationStateProvider.overrideWithValue(
                TravelerVerificationState.profilePending,
              ),
            ],
            child: MaterialApp(
              home: QrCodeScreen(
                reservation: testReservation,
                repository: mockRepo,
                isKycVerified: false,
                verificationState: TravelerVerificationState.profilePending,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(mockRepo.generateTokenCallCount, 0);
        expect(find.byType(QrImageView), findsNothing);
        expect(find.text('Verification Required'), findsOneWidget);
        expect(find.text('Start Identity Verification'), findsOneWidget);
      },
    );
  });
}
