import 'package:trvlez_mobile/core/network/api_client.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_dto.dart';

/// Handles all reservation-related API calls for the traveler.
class ReservationRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  const ReservationRemoteDataSource({
    required this.apiClient,
    required this.tokenStorage,
  });

  /// POST /traveler/reservations
  Future<ReservationDto> createReservation({
    required Map<String, dynamic> body,
  }) async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.post(
      '/traveler/reservations',
      body: body,
      authToken: token,
    );
    return ReservationDto.fromJson(response);
  }

  /// GET /traveler/reservations
  Future<ReservationListResponseDto> getReservations({
    String? status,
    int skip = 0,
    int limit = 50,
  }) async {
    final token = await tokenStorage.getToken();
    final queryParts = <String>['skip=$skip', 'limit=$limit'];
    if (status != null) {
      queryParts.add('status=$status');
    }
    final query = queryParts.join('&');
    final response = await apiClient.get(
      '/traveler/reservations?$query',
      authToken: token,
    );
    return ReservationListResponseDto.fromJson(response);
  }

  /// GET /traveler/reservations/{id}
  Future<ReservationDto> getReservation(String id) async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.get(
      '/traveler/reservations/$id',
      authToken: token,
    );
    return ReservationDto.fromJson(response);
  }

  /// DELETE /traveler/reservations/{id}
  Future<ReservationDto> cancelReservation(String id) async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.delete(
      '/traveler/reservations/$id',
      authToken: token,
    );
    return ReservationDto.fromJson(response);
  }

  /// POST /traveler/reservations/{id}/checkin-token
  Future<CheckInTokenDto> generateCheckInToken(String reservationId) async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.post(
      '/traveler/reservations/$reservationId/checkin-token',
      body: {},
      authToken: token,
    );
    return CheckInTokenDto.fromJson(response);
  }
}
