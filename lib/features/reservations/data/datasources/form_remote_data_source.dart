import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/reservations/data/models/form_dto.dart';

class FormRemoteDataSource {
  final Dio dio;

  const FormRemoteDataSource({required this.dio});

  Future<ReservationFormResponseDto> getReservationForm(
    String reservationId,
  ) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/traveler/reservations/$reservationId/form',
    );
    return ReservationFormResponseDto.fromJson(response.data!);
  }

  Future<FormSubmissionDto> submitReservationForm({
    required String reservationId,
    required Map<String, dynamic> responses,
    bool isSubmit = false,
  }) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/traveler/reservations/$reservationId/form',
      queryParameters: {'is_submit': isSubmit},
      data: {'responses': responses},
    );
    return FormSubmissionDto.fromJson(response.data!);
  }
}

final formRemoteDataSourceProvider = Provider<FormRemoteDataSource>((ref) {
  return FormRemoteDataSource(dio: ref.watch(dioProvider));
});
