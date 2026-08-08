import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';

/// Maps the backend reservation JSON to the domain [Reservation] model.
class ReservationDto {
  final String id;
  final String confirmationCode;
  final String status;
  final String checkInDate;
  final String checkOutDate;
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int numberOfGuests;
  final int numberOfRooms;
  final String? specialRequests;
  final Map<String, dynamic> propertySummary;
  final String createdAt;
  final String? cancelledAt;
  final String? checkedInAt;
  final String? checkedOutAt;

  const ReservationDto({
    required this.id,
    required this.confirmationCode,
    required this.status,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.numberOfGuests,
    required this.numberOfRooms,
    this.specialRequests,
    required this.propertySummary,
    required this.createdAt,
    this.cancelledAt,
    this.checkedInAt,
    this.checkedOutAt,
  });

  factory ReservationDto.fromJson(Map<String, dynamic> json) {
    return ReservationDto(
      id: json['id'] as String,
      confirmationCode: json['confirmation_code'] as String,
      status: json['status'] as String,
      checkInDate: json['check_in_date'] as String,
      checkOutDate: json['check_out_date'] as String,
      guestName: json['guest_name'] as String,
      guestEmail: json['guest_email'] as String?,
      guestPhone: json['guest_phone'] as String?,
      numberOfGuests: json['number_of_guests'] as int? ?? 1,
      numberOfRooms: json['number_of_rooms'] as int? ?? 1,
      specialRequests: json['special_requests'] as String?,
      propertySummary:
          json['property_summary'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] as String,
      cancelledAt: json['cancelled_at'] as String?,
      checkedInAt: json['checked_in_at'] as String?,
      checkedOutAt: json['checked_out_at'] as String?,
    );
  }

  Reservation toDomain() {
    return Reservation(
      id: id,
      confirmationCode: confirmationCode,
      status: ReservationStatus.fromString(status),
      checkInDate: DateTime.parse(checkInDate),
      checkOutDate: DateTime.parse(checkOutDate),
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      numberOfGuests: numberOfGuests,
      numberOfRooms: numberOfRooms,
      specialRequests: specialRequests,
      propertySummary: ReservationPropertySummary(
        id: propertySummary['id'] as String? ?? '',
        name: propertySummary['name'] as String? ?? '',
        city: propertySummary['city'] as String?,
        countryCode: propertySummary['country_code'] as String?,
        heroImageUrl: propertySummary['hero_image_url'] as String?,
      ),
      createdAt: DateTime.parse(createdAt),
      cancelledAt:
          cancelledAt != null ? DateTime.parse(cancelledAt!) : null,
      checkedInAt:
          checkedInAt != null ? DateTime.parse(checkedInAt!) : null,
      checkedOutAt:
          checkedOutAt != null ? DateTime.parse(checkedOutAt!) : null,
    );
  }
}

/// Wraps the paginated reservation list response.
class ReservationListResponseDto {
  final List<ReservationDto> items;
  final int total;

  const ReservationListResponseDto({required this.items, required this.total});

  factory ReservationListResponseDto.fromJson(Map<String, dynamic> json) {
    return ReservationListResponseDto(
      items: (json['data'] as List<dynamic>?)
              ?.map(
                  (e) => ReservationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['count'] as int? ?? 0,
    );
  }
}

/// Maps the check-in token response.
class CheckInTokenDto {
  final String token;
  final String reservationId;
  final String expiresAt;

  const CheckInTokenDto({
    required this.token,
    required this.reservationId,
    required this.expiresAt,
  });

  factory CheckInTokenDto.fromJson(Map<String, dynamic> json) {
    return CheckInTokenDto(
      token: json['token'] as String,
      reservationId: json['reservation_id'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }

  CheckInToken toDomain() {
    return CheckInToken(
      token: token,
      reservationId: reservationId,
      expiresAt: DateTime.parse(expiresAt),
    );
  }
}
