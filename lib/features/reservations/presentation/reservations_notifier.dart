import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';

// ─── List State ──────────────────────────────────────────────────

final reservationListProvider =
    AsyncNotifierProvider<ReservationListNotifier, List<Reservation>>(
      () => ReservationListNotifier(),
    );

class ReservationListNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  FutureOr<List<Reservation>> build() async {
    final repository = ref.read(reservationRepositoryProvider);
    return repository.getReservations();
  }

  Future<void> fetchReservations() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reservationRepositoryProvider);
      return repository.getReservations();
    });
  }

  Future<bool> cancelReservation(String id) async {
    try {
      final repository = ref.read(reservationRepositoryProvider);
      final updated = await repository.cancelReservation(id);

      // Update local state if we currently have data
      if (state.hasValue && state.value != null) {
        final currentList = state.value!;
        final index = currentList.indexWhere((r) => r.id == id);
        if (index != -1) {
          final newList = List<Reservation>.from(currentList);
          newList[index] = updated;
          state = AsyncData(newList);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void addReservation(Reservation reservation) {
    if (state.hasValue && state.value != null) {
      final newList = List<Reservation>.from(state.value!);
      newList.insert(0, reservation);
      state = AsyncData(newList);
    } else {
      state = AsyncData([reservation]);
    }
  }
}

// ─── Create State ────────────────────────────────────────────────

final createReservationProvider =
    AutoDisposeAsyncNotifierProvider<CreateReservationNotifier, void>(
      () => CreateReservationNotifier(),
    );

class CreateReservationNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

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
    state = const AsyncLoading();

    try {
      final repository = ref.read(reservationRepositoryProvider);
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

      // Update the list provider with the new reservation
      ref.read(reservationListProvider.notifier).addReservation(reservation);

      state = const AsyncData(null);
      return reservation;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

// ─── QR Token State ──────────────────────────────────────────────

final checkInTokenProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      CheckInTokenNotifier,
      CheckInToken?,
      String
    >(() => CheckInTokenNotifier());

class CheckInTokenNotifier
    extends AutoDisposeFamilyAsyncNotifier<CheckInToken?, String> {
  @override
  FutureOr<CheckInToken?> build(String arg) {
    return null; // Initially null until generate is called
  }

  Future<void> generateCheckInToken() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(reservationRepositoryProvider);
      return repository.generateCheckInToken(arg);
    });
  }
}
