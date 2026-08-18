import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/core/network/dio_provider.dart';

import 'package:trvlez_mobile/features/reservations/data/reservation_dto.dart';

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
    return ReservationDto.fromJson(response.data!);
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
    return ReservationListResponseDto.fromJson(response.data!);
  }

  /// GET /traveler/reservations/{id}
  Future<ReservationDto> getReservation(String id) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/reservations/$id',
    );
    return ReservationDto.fromJson(response.data!);
  }

  /// DELETE /traveler/reservations/{id}
  Future<ReservationDto> cancelReservation(String id) async {
    final response = await dio.delete<Map<String, dynamic>>(
      '/traveler/reservations/$id',
    );
    return ReservationDto.fromJson(response.data!);
  }

  /// POST /traveler/reservations/{id}/checkin-token
  Future<CheckInTokenDto> generateCheckInToken(String reservationId) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/traveler/reservations/$reservationId/checkin-token',
      data: {},
    );
    return CheckInTokenDto.fromJson(response.data!);
  }
}

/// Provider for the [ReservationRemoteDataSource].
final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
      return ReservationRemoteDataSource(dio: ref.watch(dioProvider));
    });
