import 'package:flutter/foundation.dart';

import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';

/// Manages the state for reservation screens (list, create, cancel, QR token).
class ReservationsNotifier extends ChangeNotifier {
  final ReservationRepository repository;

  ReservationsNotifier({required this.repository});

  // ─── List State ──────────────────────────────────────────────────

  bool isLoading = false;
  String? error;
  List<Reservation> reservations = [];

  List<Reservation> get upcomingReservations =>
      reservations.where((r) => r.status.isUpcoming).toList();

  List<Reservation> get completedReservations =>
      reservations.where((r) => r.status.isCompleted).toList();

  List<Reservation> get cancelledReservations =>
      reservations.where((r) => r.status.isCancelled).toList();

  // ─── Create State ────────────────────────────────────────────────

  bool isCreating = false;
  String? createError;

  // ─── QR Token State ──────────────────────────────────────────────

  bool isGeneratingToken = false;
  CheckInToken? checkInToken;
  String? tokenError;

  // ─── Actions ─────────────────────────────────────────────────────

  Future<void> fetchReservations() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      reservations = await repository.getReservations();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Reservation?> createReservation({
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
    isCreating = true;
    createError = null;
    notifyListeners();

    try {
      final reservation = await repository.createReservation(
        propertyId: propertyId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guestName: guestName,
        guestEmail: guestEmail,
        guestPhone: guestPhone,
        numberOfGuests: numberOfGuests,
        roomTypeIds: roomTypeIds,
        specialRequests: specialRequests,
      );
      // Prepend to local list for immediate UI update
      reservations.insert(0, reservation);
      return reservation;
    } catch (e) {
      createError = e.toString();
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> cancelReservation(String id) async {
    try {
      final updated = await repository.cancelReservation(id);
      // Replace in local list
      final index = reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        reservations[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> generateCheckInToken(String reservationId) async {
    isGeneratingToken = true;
    tokenError = null;
    checkInToken = null;
    notifyListeners();

    try {
      checkInToken = await repository.generateCheckInToken(reservationId);
    } catch (e) {
      tokenError = e.toString();
    } finally {
      isGeneratingToken = false;
      notifyListeners();
    }
  }

  /// Clears the current token state (e.g., when leaving the QR screen).
  void clearToken() {
    checkInToken = null;
    tokenError = null;
    notifyListeners();
  }

  void reset() {
    reservations = [];
    isLoading = false;
    error = null;
    isCreating = false;
    createError = null;
    isGeneratingToken = false;
    checkInToken = null;
    tokenError = null;
    notifyListeners();
  }
}
