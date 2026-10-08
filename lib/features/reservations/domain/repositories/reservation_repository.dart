import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Domain contract for managing traveler reservations and check-in passes.
abstract interface class ReservationRepository {
  /// Creates a new reservation for the specified property and room types.
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
  });

  /// Fetches a list of reservations for the authenticated traveler, optionally filtered by status.
  Future<List<Reservation>> getReservations({String? status});

  /// Fetches a single reservation by ID.
  Future<Reservation> getReservation(String id);

  /// Cancels an existing reservation by ID.
  Future<Reservation> cancelReservation(String id);

  /// Generates a temporary QR check-in token for a confirmed reservation.
  Future<CheckInToken> generateCheckInToken(String reservationId);
}
