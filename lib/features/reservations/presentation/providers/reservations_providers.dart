import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/form_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/data/repositories/form_repository_impl.dart';
import 'package:trvlez_mobile/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/form_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/reservation_repository.dart';

export 'package:trvlez_mobile/features/reservations/domain/entities/form.dart';
export 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';
export 'package:trvlez_mobile/features/reservations/domain/repositories/form_repository.dart';
export 'package:trvlez_mobile/features/reservations/domain/repositories/reservation_repository.dart';

// ─── Repositories ────────────────────────────────────────────────

/// Provider for the domain [ReservationRepository] interface.
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepositoryImpl(
    remoteDataSource: ref.watch(reservationRemoteDataSourceProvider),
  );
});

/// Provider for the domain [FormRepository] interface.
final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl(
    remoteDataSource: ref.watch(formRemoteDataSourceProvider),
  );
});

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

// ─── Detail State ────────────────────────────────────────────────

/// Asynchronous state notifier for observing and managing a single reservation detail.
class ReservationDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Reservation, String> {
  @override
  FutureOr<Reservation> build(String arg) {
    final repository = ref.read(reservationRepositoryProvider);
    return repository.getReservation(arg);
  }

  /// Refreshes the reservation detail.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(reservationRepositoryProvider).getReservation(arg);
    });
  }

  /// Sets local state directly (e.g. when seeded from a parent view).
  void setReservation(Reservation reservation) {
    state = AsyncData(reservation);
  }
}

final reservationDetailNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ReservationDetailNotifier, Reservation, String>(
      ReservationDetailNotifier.new,
    );

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
      final isVerified = ref.read(isKycVerifiedProvider);
      if (!isVerified) {
        throw const ApiException(
          'Identity verification (KYC) is required to generate a check-in pass.',
          statusCode: 403,
        );
      }
      final repository = ref.read(reservationRepositoryProvider);
      return repository.generateCheckInToken(arg);
    });
  }
}
