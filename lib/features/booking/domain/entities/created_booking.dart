import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/guest_counts.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Represents a finalized booking created during the session.
class CreatedBooking {
  const CreatedBooking({
    required this.id,
    this.confirmationCode,
    required this.propertyId,
    required this.propertyName,
    required this.propertyPlace,
    required this.range,
    required this.guests,
    required this.picks,
    this.reservation,
  });

  final String id;
  final String? confirmationCode;
  final String propertyId;
  final String propertyName;
  final String propertyPlace;
  final BookingDateRange range;
  final GuestCounts guests;
  final List<RoomPick> picks;
  final Reservation? reservation;

  int get total => picks.fold(0, (sum, p) => sum + p.total);

  String get roomLine => picks
      .map((p) =>
          p.quantity == 1 ? p.type.name : '${p.type.name} × ${p.quantity}')
      .join(', ');

  String get dateAndGuests =>
      '${DateFormatter.dayMonth(range.from)} – ${DateFormatter.dayMonth(range.to)} · ${guests.summary}';
}
