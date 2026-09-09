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
  final bool requiresPrearrivalForm;

  const ReservationPropertySummary({
    required this.id,
    required this.name,
    this.city,
    this.countryCode,
    this.heroImageUrl,
    this.requiresPrearrivalForm = false,
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
  final String? roomTypeName;
  final double? pricePerNight;
  final String? currencyCode;
  final int? numberOfNights;
  final double? lineTotal;

  const RoomSummary({
    required this.id,
    required this.roomNumber,
    required this.roomTypeId,
    this.roomTypeName,
    this.pricePerNight,
    this.currencyCode,
    this.numberOfNights,
    this.lineTotal,
  });
}

/// Domain model for a traveler's reservation.
class Reservation {
  final String id;
  final String confirmationCode;
  final ReservationStatus status;
  final String? formStatus;
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
  final double? totalAmount;
  final String? currencyCode;

  const Reservation({
    required this.id,
    required this.confirmationCode,
    required this.status,
    this.formStatus,
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
    this.totalAmount,
    this.currencyCode,
  });

  /// Number of nights for the stay based on calendar dates.
  int get nights {
    final start = DateTime.utc(checkInDate.year, checkInDate.month, checkInDate.day);
    final end = DateTime.utc(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    return end.difference(start).inDays;
  }

  Reservation copyWith({
    String? id,
    String? confirmationCode,
    ReservationStatus? status,
    String? formStatus,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    int? numberOfGuests,
    List<RoomSummary>? rooms,
    String? specialRequests,
    ReservationPropertySummary? propertySummary,
    DateTime? createdAt,
    DateTime? cancelledAt,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    double? totalAmount,
    String? currencyCode,
  }) {
    return Reservation(
      id: id ?? this.id,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      status: status ?? this.status,
      formStatus: formStatus ?? this.formStatus,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      rooms: rooms ?? this.rooms,
      specialRequests: specialRequests ?? this.specialRequests,
      propertySummary: propertySummary ?? this.propertySummary,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      totalAmount: totalAmount ?? this.totalAmount,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
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

  /// Whether the token is expired relative to current time.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the token is currently active and valid.
  bool get isValid => !isExpired;
}
