import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/my_trips_screen.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  List<Reservation> reservationsToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to fetch reservations');
    }
    return reservationsToReturn;
  }
}

void main() {
  final testUpcomingReservation = Reservation(
    id: 'res-upcoming',
    confirmationCode: 'TRV-UPCOMING',
    status: ReservationStatus.confirmed,
    checkInDate: DateTime.utc(2026, 11, 1, 14, 0),
    checkOutDate: DateTime.utc(2026, 11, 5, 11, 0),
    guestName: 'Alex Traveler',
    numberOfGuests: 2,
    rooms: const [
      RoomSummary(
        id: 'r-1',
        roomNumber: '101',
        roomTypeId: 'rt-1',
        roomTypeName: 'Ocean Suite',
      ),
    ],
    propertySummary: const ReservationPropertySummary(
      id: 'p-1',
      name: 'Azure Coastal Resort',
      city: 'Goa',
      countryCode: 'IN',
    ),
    createdAt: DateTime.utc(2026, 9, 1),
  );

  final testCompletedReservation = Reservation(
    id: 'res-completed',
    confirmationCode: 'TRV-COMPLETED',
    status: ReservationStatus.checkedOut,
    checkInDate: DateTime.utc(2026, 8, 1, 14, 0),
    checkOutDate: DateTime.utc(2026, 8, 5, 11, 0),
    guestName: 'Alex Traveler',
    numberOfGuests: 2,
    rooms: const [
      RoomSummary(
        id: 'r-2',
        roomNumber: '202',
        roomTypeId: 'rt-2',
        roomTypeName: 'Mountain Villa',
      ),
    ],
    propertySummary: const ReservationPropertySummary(
      id: 'p-2',
      name: 'Alpine Vista Lodge',
      city: 'Manali',
      countryCode: 'IN',
    ),
    createdAt: DateTime.utc(2026, 7, 1),
  );

  group('MyTripsScreen Widget Tests', () {
    testWidgets('satisfies accessibility guidelines', (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [testUpcomingReservation];

      await tester.pumpWidget(
        testAppWithProviders(
          child: const MyTripsScreen(),
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testMaterialScreenMatrix(
      'renders upcoming reservation card across phone matrix',
      builder: (tester, scenario) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationsToReturn = [testUpcomingReservation];

        await tester.pumpWidget(
          testAppWithProviders(
            textScaler: scenario.textScaler,
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MyTripsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('My Trips'), findsOneWidget);
        expect(find.text('Azure Coastal Resort'), findsOneWidget);
        expect(find.text('TRV-UPCOMING'), findsOneWidget);
      },
    );

    testWidgets(
      'renders empty state with Explore Properties CTA when no trips exist',
      (tester) async {
        final mockRepo = MockReservationRepository();
        mockRepo.reservationsToReturn = [];

        await tester.pumpWidget(
          testAppWithProviders(
            child: const MyTripsScreen(),
            overrides: [
              reservationRepositoryProvider.overrideWithValue(mockRepo),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('My Trips'), findsOneWidget);
        expect(find.text('No upcoming trips'), findsOneWidget);
        expect(find.text('Explore Properties'), findsOneWidget);
        expect(find.text('Upcoming (0)'), findsOneWidget);
      },
    );

    testWidgets('tapping Explore Properties CTA navigates to ezStays', (
      tester,
    ) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [];

      String? pushedLocation;
      final router = GoRouter(
        initialLocation: '/bookings',
        routes: [
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const MyTripsScreen(),
          ),
          GoRoute(
            path: AppRoutes.ezStays,
            builder: (context, state) {
              pushedLocation = AppRoutes.ezStays;
              return const Scaffold(body: Text('ezStays Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore Properties'), findsOneWidget);
      await tester.tap(find.text('Explore Properties'));
      await tester.pumpAndSettle();

      expect(pushedLocation, equals(AppRoutes.ezStays));
      expect(find.text('ezStays Screen'), findsOneWidget);
    });

    testWidgets('renders upcoming reservation card when reservations exist', (
      tester,
    ) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [testUpcomingReservation];

      await tester.pumpWidget(
        testAppWithProviders(
          child: const MyTripsScreen(),
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming (1)'), findsOneWidget);
      expect(find.text('Azure Coastal Resort'), findsOneWidget);
      expect(find.text('TRV-UPCOMING'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows completed trip under Completed tab', (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [
        testUpcomingReservation,
        testCompletedReservation,
      ];

      await tester.pumpWidget(
        testAppWithProviders(
          child: const MyTripsScreen(),
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);

      // Tap the Completed tab
      await tester.tap(find.text('Completed (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Alpine Vista Lodge'), findsOneWidget);
      expect(find.text('TRV-COMPLETED'), findsOneWidget);
      expect(find.text('Checked Out'), findsOneWidget);
    });

    testWidgets('displays error state when repository throws', (tester) async {
      final mockRepo = MockReservationRepository();
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        testAppWithProviders(
          child: const MyTripsScreen(),
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load reservations'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
