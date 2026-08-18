import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/reservations/data/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';

/// Abstraction over the remote data source that returns domain models.
class ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  const ReservationRepository({required this.remoteDataSource});

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
    final body = <String, dynamic>{
      'property_id': propertyId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'guest_name': guestName,
      'number_of_guests': numberOfGuests,
      'room_type_ids': roomTypeIds,
    };
    if (guestEmail != null) body['guest_email'] = guestEmail;
    if (guestPhone != null) body['guest_phone'] = guestPhone;
    if (specialRequests != null) body['special_requests'] = specialRequests;

    final dto = await remoteDataSource.createReservation(body: body);
    return dto.toDomain();
  }

  Future<List<Reservation>> getReservations({String? status}) async {
    final dto = await remoteDataSource.getReservations(status: status);
    return dto.items.map((e) => e.toDomain()).toList();
  }

  Future<Reservation> getReservation(String id) async {
    final dto = await remoteDataSource.getReservation(id);
    return dto.toDomain();
  }

  Future<Reservation> cancelReservation(String id) async {
    final dto = await remoteDataSource.cancelReservation(id);
    return dto.toDomain();
  }

  Future<CheckInToken> generateCheckInToken(String reservationId) async {
    final dto = await remoteDataSource.generateCheckInToken(reservationId);
    return dto.toDomain();
  }
}

/// Provider for the [ReservationRepository].
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(
    remoteDataSource: ref.watch(reservationRemoteDataSourceProvider),
  );
});
