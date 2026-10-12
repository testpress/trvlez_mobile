import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/reservations/data/dto/reservation_dto.dart';

/// Handles all reservation-related API calls for the traveler.
///
/// Auth token injection is handled by the Dio [AuthInterceptor].
/// Errors are mapped to [ApiException] by the Dio [ErrorInterceptor].
class ReservationRemoteDataSource {
  final Dio dio;

  const ReservationRemoteDataSource({required this.dio});

  /// POST /traveler/reservations
  Future<ReservationDto> createReservation({
    required Map<String, dynamic> body,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/reservations',
      data: body,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from reservation creation',
      );
    }
    return ReservationDto.fromJson(data);
  }

  /// GET /traveler/reservations
  Future<ReservationListResponseDto> getReservations({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    final queryParameters = <String, dynamic>{'skip': skip, 'limit': limit};
    if (status != null) {
      queryParameters['status'] = status;
    }

    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/reservations',
      queryParameters: queryParameters,
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from reservations list',
      );
    }
    return ReservationListResponseDto.fromJson(data);
  }

  /// GET /traveler/reservations/{id}
  Future<ReservationDto> getReservation(String id) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/reservations/$id',
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from reservation detail',
      );
    }
    return ReservationDto.fromJson(data);
  }

  /// DELETE /traveler/reservations/{id}
  Future<ReservationDto> cancelReservation(String id) async {
    final response = await dio.delete<Map<String, dynamic>>(
      '/traveler/reservations/$id',
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException(
        'Empty response received from reservation cancellation',
      );
    }
    return ReservationDto.fromJson(data);
  }

  /// POST /traveler/reservations/{id}/checkin-token
  Future<CheckInTokenDto> generateCheckInToken(String reservationId) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/reservations/$reservationId/checkin-token',
      data: {},
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty response received from checkin token');
    }
    return CheckInTokenDto.fromJson(data);
  }
}

/// Provider for the [ReservationRemoteDataSource].
final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
      return ReservationRemoteDataSource(dio: ref.watch(dioProvider));
    });
