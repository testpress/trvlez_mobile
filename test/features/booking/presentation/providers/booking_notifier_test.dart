import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';

class FakeReservationRepository implements ReservationRepository {
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
    return Reservation(
      id: 'res-123',
      confirmationCode: 'TZ-CONF-123',
      status: ReservationStatus.confirmed,
      checkInDate: DateTime.parse(checkInDate),
      checkOutDate: DateTime.parse(checkOutDate),
      guestName: guestName,
      numberOfGuests: numberOfGuests,
      rooms: const [],
      propertySummary: ReservationPropertySummary(
        id: propertyId,
        name: 'Seaside Grand Resort',
      ),
      createdAt: DateTime.now(),
      totalAmount: 400,
      currencyCode: 'GBP',
    );
  }

  @override
  Future<List<Reservation>> getReservations({String? status}) async => [];

  @override
  Future<Reservation> getReservation(String id) async =>
      throw UnimplementedError();

  @override
  Future<Reservation> cancelReservation(String id) async =>
      throw UnimplementedError();

  @override
  Future<CheckInToken> generateCheckInToken(String reservationId) async =>
      throw UnimplementedError();
}

void main() {
  late ProviderContainer container;

  const testProperty = Property(
    id: 'prop-1',
    name: 'Seaside Grand Resort',
    city: 'Nice',
    countryCode: 'FR',
    shortDescription: 'Nice hotel',
    longDescription: 'Nice hotel description',
    heroImageUrl: 'https://example.com/hero.jpg',
    pricePerNight: 200,
    roomTypes: [
      RoomType(
        id: 'rt-1',
        name: 'Deluxe Sea View',
        maxOccupancy: 2,
        maxAdults: 2,
        maxChildren: 1,
        description: 'Room description',
        pricePerNight: 200,
      ),
      RoomType(
        id: 'rt-2',
        name: 'Executive Suite',
        maxOccupancy: 4,
        maxAdults: 4,
        maxChildren: 2,
        description: 'Suite description',
        pricePerNight: 350,
      ),
    ],
  );

  setUp(() {
    container = ProviderContainer(
      overrides: [
        reservationRepositoryProvider.overrideWithValue(
          FakeReservationRepository(),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('beginBooking sets up initial draft with rooms catalog', () {
    final notifier = container.read(bookingDraftProvider.notifier);
    notifier.beginBooking(testProperty);

    final draft = container.read(bookingDraftProvider);
    expect(draft, isNotNull);
    expect(draft!.propertyId, 'prop-1');
    expect(draft.propertyName, 'Seaside Grand Resort');
    expect(draft.picks.length, 2);
    expect(draft.picks.every((p) => p.quantity == 0), isTrue);
  });

  test('setBookingRange updates overarching range and unpicked rooms', () {
    final notifier = container.read(bookingDraftProvider.notifier);
    notifier.beginBooking(testProperty);

    final newRange = BookingDateRange(
      DateTime(2026, 12, 1),
      DateTime(2026, 12, 5),
    );
    notifier.setBookingRange(newRange);

    final draft = container.read(bookingDraftProvider);
    expect(draft!.range, isNotNull);
    expect(draft.range!.sameAs(newRange), isTrue);
    expect(draft.picks.first.range.sameAs(newRange), isTrue);
  });

  test('setBookingGuests updates guests count', () {
    final notifier = container.read(bookingDraftProvider.notifier);
    notifier.beginBooking(testProperty);

    notifier.setBookingGuests(const GuestCounts(adults: 3, children: 1));
    final draft = container.read(bookingDraftProvider);
    expect(draft!.guests.adults, 3);
    expect(draft.guests.children, 1);
  });

  test('setRoomQuantity and setRoomRange update specific rooms', () {
    final notifier = container.read(bookingDraftProvider.notifier);
    notifier.beginBooking(testProperty);

    notifier.setRoomQuantity('rt-1', 2);
    final draft1 = container.read(bookingDraftProvider);
    expect(draft1!.picks.firstWhere((p) => p.type.id == 'rt-1').quantity, 2);

    final customRange = BookingDateRange(
      DateTime(2026, 12, 2),
      DateTime(2026, 12, 6),
    );
    notifier.setRoomRange('rt-1', customRange);
    final draft2 = container.read(bookingDraftProvider);
    expect(
      draft2!.picks
          .firstWhere((p) => p.type.id == 'rt-1')
          .range
          .sameAs(customRange),
      isTrue,
    );
  });

  test(
    'addBookingCard and confirmBooking flow adds to reservations and resets draft',
    () async {
      final notifier = container.read(bookingDraftProvider.notifier);
      notifier.beginBooking(testProperty);

      final range = BookingDateRange(
        DateTime(2026, 12, 1),
        DateTime(2026, 12, 4),
      );
      notifier.setBookingRange(range);
      notifier.setRoomQuantity('rt-1', 1);

      expect(container.read(bookingDraftProvider)!.canReview, isTrue);
      expect(container.read(bookingDraftProvider)!.canConfirm, isFalse);

      notifier.addBookingCard();
      expect(container.read(bookingDraftProvider)!.canConfirm, isTrue);

      final created = await notifier.confirmBooking();
      expect(created.length, 1);
      expect(created.first.confirmationCode, 'TZ-CONF-123');
      expect(container.read(bookingDraftProvider), isNull);
      expect(container.read(lastCreatedBookingsProvider).length, 1);
    },
  );
}
