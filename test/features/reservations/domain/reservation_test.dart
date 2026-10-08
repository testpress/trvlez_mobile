import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

void main() {
  group('ReservationStatus Enum', () {
    test('fromString parses all standard backend statuses', () {
      expect(
        ReservationStatus.fromString('pending'),
        ReservationStatus.pending,
      );
      expect(
        ReservationStatus.fromString('confirmed'),
        ReservationStatus.confirmed,
      );
      expect(
        ReservationStatus.fromString('checked_in'),
        ReservationStatus.checkedIn,
      );
      expect(
        ReservationStatus.fromString('checked_out'),
        ReservationStatus.checkedOut,
      );
      expect(
        ReservationStatus.fromString('cancelled'),
        ReservationStatus.cancelled,
      );
      expect(ReservationStatus.fromString('no_show'), ReservationStatus.noShow);
      expect(
        ReservationStatus.fromString('unknown_status'),
        ReservationStatus.pending,
      );
    });

    test('displayLabel formats status correctly for UI display', () {
      expect(ReservationStatus.pending.displayLabel, 'Pending');
      expect(ReservationStatus.confirmed.displayLabel, 'Confirmed');
      expect(ReservationStatus.checkedIn.displayLabel, 'Checked In');
      expect(ReservationStatus.checkedOut.displayLabel, 'Checked Out');
      expect(ReservationStatus.cancelled.displayLabel, 'Cancelled');
      expect(ReservationStatus.noShow.displayLabel, 'No Show');
    });

    test('lifecycle helpers categorize reservation status correctly', () {
      expect(ReservationStatus.pending.isUpcoming, isTrue);
      expect(ReservationStatus.confirmed.isUpcoming, isTrue);
      expect(ReservationStatus.checkedIn.isUpcoming, isFalse);

      expect(ReservationStatus.checkedIn.isCompleted, isTrue);
      expect(ReservationStatus.checkedOut.isCompleted, isTrue);
      expect(ReservationStatus.confirmed.isCompleted, isFalse);

      expect(ReservationStatus.cancelled.isCancelled, isTrue);
      expect(ReservationStatus.noShow.isCancelled, isTrue);
      expect(ReservationStatus.confirmed.isCancelled, isFalse);
    });

    test('canGenerateQr is true only for confirmed reservations', () {
      expect(ReservationStatus.confirmed.canGenerateQr, isTrue);
      expect(ReservationStatus.pending.canGenerateQr, isFalse);
      expect(ReservationStatus.checkedIn.canGenerateQr, isFalse);
      expect(ReservationStatus.cancelled.canGenerateQr, isFalse);
    });

    test('canCancel is true only for upcoming reservations', () {
      expect(ReservationStatus.pending.canCancel, isTrue);
      expect(ReservationStatus.confirmed.canCancel, isTrue);
      expect(ReservationStatus.checkedIn.canCancel, isFalse);
      expect(ReservationStatus.cancelled.canCancel, isFalse);
    });
  });

  group('Reservation Entity', () {
    test('calculates nights correctly between dates', () {
      final reservation = Reservation(
        id: 'res-1',
        confirmationCode: 'CONF123',
        status: ReservationStatus.confirmed,
        checkInDate: DateTime.utc(2026, 10, 10),
        checkOutDate: DateTime.utc(2026, 10, 15),
        guestName: 'Alex Smith',
        numberOfGuests: 2,
        rooms: const [],
        propertySummary: const ReservationPropertySummary(
          id: 'prop-1',
          name: 'Grand Hyatt',
        ),
        createdAt: DateTime.utc(2026, 10, 1),
      );

      expect(reservation.nights, 5);
    });

    test('copyWith updates specified fields correctly', () {
      final reservation = Reservation(
        id: 'res-1',
        confirmationCode: 'CONF123',
        status: ReservationStatus.pending,
        checkInDate: DateTime.utc(2026, 10, 10),
        checkOutDate: DateTime.utc(2026, 10, 12),
        guestName: 'Alex Smith',
        numberOfGuests: 1,
        rooms: const [],
        propertySummary: const ReservationPropertySummary(
          id: 'prop-1',
          name: 'Grand Hyatt',
        ),
        createdAt: DateTime.utc(2026, 10, 1),
      );

      final updated = reservation.copyWith(
        status: ReservationStatus.confirmed,
        numberOfGuests: 3,
      );

      expect(updated.status, ReservationStatus.confirmed);
      expect(updated.numberOfGuests, 3);
      expect(updated.id, reservation.id);
    });
  });

  group('CheckInToken Entity', () {
    test('evaluates isExpired and isValid relative to expiry timestamp', () {
      final validToken = CheckInToken(
        token: 'token-valid',
        reservationId: 'res-1',
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      expect(validToken.isExpired, isFalse);
      expect(validToken.isValid, isTrue);

      final expiredToken = CheckInToken(
        token: 'token-expired',
        reservationId: 'res-1',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );
      expect(expiredToken.isExpired, isTrue);
      expect(expiredToken.isValid, isFalse);
    });
  });
}
