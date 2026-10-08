import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/reservation_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/reservation_repository.dart';

/// Concrete implementation of [ReservationRepository] interfacing with remote data source.
///
/// Maps network exceptions into the sealed [AppException] hierarchy.
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  const ReservationRepositoryImpl({required this.remoteDataSource});

  @override
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

    try {
      final dto = await remoteDataSource.createReservation(body: body);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<List<Reservation>> getReservations({String? status}) async {
    try {
      final dto = await remoteDataSource.getReservations(status: status);
      return dto.items.map((e) => e.toDomain()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Reservation> getReservation(String id) async {
    try {
      final dto = await remoteDataSource.getReservation(id);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Reservation> cancelReservation(String id) async {
    try {
      final dto = await remoteDataSource.cancelReservation(id);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<CheckInToken> generateCheckInToken(String reservationId) async {
    try {
      final dto = await remoteDataSource.generateCheckInToken(reservationId);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
