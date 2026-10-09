import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

class MockReservationRepository extends Fake implements ReservationRepository {
  List<Reservation> reservationsToReturn = [];
  Reservation? singleReservationToReturn;
  CheckInToken? tokenToReturn;
  bool shouldThrow = false;

  @override
  Future<Reservation> createReservation({
    required String propertyId,
    required String checkInDate,
    required String checkOutDate,
    required String guestName,
    String? guestEmail,
    String? guestPhone,
    int numberOfGuests = 1,
    required List<String> roomTypeIds,
    String? specialRequests,
  }) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to create reservation');
    }
    return singleReservationToReturn!;
  }

  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to fetch reservations');
    }
    return reservationsToReturn;
  }

  @override
  Future<Reservation> getReservation(String id) async {
    if (shouldThrow) {
      throw const NotFoundException('Reservation not found');
    }
    return singleReservationToReturn!;
  }

  @override
  Future<Reservation> cancelReservation(String id) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to cancel reservation');
    }
    return singleReservationToReturn!;
  }

  @override
  Future<CheckInToken> generateCheckInToken(String reservationId) async {
    if (shouldThrow) {
      throw const NetworkException('Failed to generate token');
    }
    return tokenToReturn ??
        CheckInToken(
          token: 'mock-qr-token',
          reservationId: reservationId,
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );
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

  group('ReservationListNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.reservationsToReturn = [testReservation];
      mockRepo.singleReservationToReturn = testReservation;
    });

    test('initial build loads reservations from repository', () async {
      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final state = await container.read(reservationListProvider.future);
      expect(state.length, 1);
      expect(state.first.id, 'res-101');
    });

    test('addReservation prepends new reservation to state list', () async {
      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(reservationListProvider.future);

      final newRes = testReservation.copyWith(
        id: 'res-new-202',
        confirmationCode: 'TRV-99998888',
      );

      container.read(reservationListProvider.notifier).addReservation(newRes);

      final current = container.read(reservationListProvider).value!;
      expect(current.length, 2);
      expect(current.first.id, 'res-new-202');
      expect(current.last.id, 'res-101');
    });

    test('cancelReservation updates reservation status in list', () async {
      final cancelledRes = testReservation.copyWith(
        status: ReservationStatus.cancelled,
      );
      mockRepo.singleReservationToReturn = cancelledRes;

      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(reservationListProvider.future);

      final success = await container
          .read(reservationListProvider.notifier)
          .cancelReservation('res-101');

      expect(success, isTrue);
      final current = container.read(reservationListProvider).value!;
      expect(current.first.status, ReservationStatus.cancelled);
    });
  });

  group('CreateReservationNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.singleReservationToReturn = testReservation;
    });

    test(
      'createReservation creates reservation and prepends to list',
      () async {
        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );
        addTearDown(container.dispose);

        final created = await container
            .read(createReservationProvider.notifier)
            .createReservation(
              propertyId: 'prop-azure-1',
              checkInDate: '2026-10-15T14:00:00Z',
              checkOutDate: '2026-10-18T11:00:00Z',
              guestName: 'Alex Traveler',
              roomTypeIds: ['rt-deluxe'],
            );

        expect(created, isNotNull);
        expect(created?.id, 'res-101');

        final list = container.read(reservationListProvider).value;
        expect(list, isNotNull);
        expect(list?.first.id, 'res-101');
      },
    );

    test('createReservation sets error state on repository failure', () async {
      mockRepo.shouldThrow = true;

      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final created = await container
          .read(createReservationProvider.notifier)
          .createReservation(
            propertyId: 'prop-azure-1',
            checkInDate: '2026-10-15T14:00:00Z',
            checkOutDate: '2026-10-18T11:00:00Z',
            guestName: 'Alex Traveler',
            roomTypeIds: ['rt-deluxe'],
          );

      expect(created, isNull);
      expect(container.read(createReservationProvider).hasError, isTrue);
    });
  });

  group('ReservationDetailNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
      mockRepo.singleReservationToReturn = testReservation;
    });

    test('loads reservation detail by id', () async {
      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final loaded = await container.read(
        reservationDetailNotifierProvider('res-101').future,
      );
      expect(loaded.id, 'res-101');
      expect(loaded.confirmationCode, 'TRV-12345678');
    });

    test('refresh re-fetches reservation detail', () async {
      final container = ProviderContainer(
        overrides: [reservationRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(reservationDetailNotifierProvider('res-101').future);

      final updated = testReservation.copyWith(
        status: ReservationStatus.checkedIn,
      );
      mockRepo.singleReservationToReturn = updated;

      await container
          .read(reservationDetailNotifierProvider('res-101').notifier)
          .refresh();

      final state = container
          .read(reservationDetailNotifierProvider('res-101'))
          .value;
      expect(state?.status, ReservationStatus.checkedIn);
    });
  });

  group('CheckInTokenNotifier State Management', () {
    late MockReservationRepository mockRepo;

    setUp(() {
      mockRepo = MockReservationRepository();
    });

    test('generates token when traveler is verified', () async {
      final container = ProviderContainer(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(mockRepo),
          isKycVerifiedProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(checkInTokenProvider('res-101').notifier)
          .generateCheckInToken();

      final state = container.read(checkInTokenProvider('res-101'));
      expect(state.value?.token, 'mock-qr-token');
      expect(state.value?.reservationId, 'res-101');
    });
  });
}
