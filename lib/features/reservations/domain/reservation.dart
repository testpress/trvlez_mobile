/// Status lifecycle for a reservation.
enum ReservationStatus {
  pending,
  confirmed,
  checkedIn,
  checkedOut,
  cancelled,
  noShow;

  /// Maps the snake_case backend value to this enum.
  static ReservationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReservationStatus.pending;
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'checked_in':
        return ReservationStatus.checkedIn;
      case 'checked_out':
        return ReservationStatus.checkedOut;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'no_show':
        return ReservationStatus.noShow;
      default:
        return ReservationStatus.pending;
    }
  }

  String get displayLabel {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.checkedIn:
        return 'Checked In';
      case ReservationStatus.checkedOut:
        return 'Checked Out';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.noShow:
        return 'No Show';
    }
  }

  bool get isUpcoming =>
      this == ReservationStatus.pending || this == ReservationStatus.confirmed;

  bool get isCompleted =>
      this == ReservationStatus.checkedIn ||
      this == ReservationStatus.checkedOut;

  bool get isCancelled =>
      this == ReservationStatus.cancelled || this == ReservationStatus.noShow;

  /// Whether the traveler can generate a QR token for this reservation.
  bool get canGenerateQr => this == ReservationStatus.confirmed;

  /// Whether the traveler can cancel this reservation.
  bool get canCancel => isUpcoming;
}

/// Embedded property summary within a reservation response.
class ReservationPropertySummary {
  final String id;
  final String name;
  final String? city;
  final String? countryCode;
  final String? heroImageUrl;

  const ReservationPropertySummary({
    required this.id,
    required this.name,
    this.city,
    this.countryCode,
    this.heroImageUrl,
  });

  String get locationString {
    if ((city ?? '').isNotEmpty && (countryCode ?? '').isNotEmpty) {
      return '$city, $countryCode';
    } else if ((city ?? '').isNotEmpty) {
      return city!;
    } else if ((countryCode ?? '').isNotEmpty) {
      return countryCode!;
    }
    return '';
  }
}

/// Embedded room summary within a reservation response.
class RoomSummary {
  final String id;
  final String roomNumber;
  final String roomTypeId;

  const RoomSummary({
    required this.id,
    required this.roomNumber,
    required this.roomTypeId,
  });
}

/// Domain model for a traveler's reservation.
class Reservation {
  final String id;
  final String confirmationCode;
  final ReservationStatus status;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int numberOfGuests;
  final List<RoomSummary> rooms;
  final String? specialRequests;
  final ReservationPropertySummary propertySummary;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;

  const Reservation({
    required this.id,
    required this.confirmationCode,
    required this.status,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.numberOfGuests,
    required this.rooms,
    this.specialRequests,
    required this.propertySummary,
    required this.createdAt,
    this.cancelledAt,
    this.checkedInAt,
    this.checkedOutAt,
  });

  /// Number of nights for the stay.
  int get nights => checkOutDate.difference(checkInDate).inDays;
}

/// Response from the check-in token generation endpoint.
class CheckInToken {
  final String token;
  final String reservationId;
  final DateTime expiresAt;

  const CheckInToken({
    required this.token,
    required this.reservationId,
    required this.expiresAt,
  });
}
