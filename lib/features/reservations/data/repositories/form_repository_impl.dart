import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/reservations/data/datasources/form_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/form.dart';
import 'package:trvlez_mobile/features/reservations/domain/repositories/form_repository.dart';

/// Concrete implementation of [FormRepository] interfacing with remote data source.
class FormRepositoryImpl implements FormRepository {
  final FormRemoteDataSource remoteDataSource;

  const FormRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReservationFormResponse> getReservationForm(
    String reservationId,
  ) async {
    try {
      final dto = await remoteDataSource.getReservationForm(reservationId);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<FormSubmission> submitReservationForm({
    required String reservationId,
    required Map<String, dynamic> responses,
    bool isSubmit = false,
  }) async {
    try {
      final dto = await remoteDataSource.submitReservationForm(
        reservationId: reservationId,
        responses: responses,
        isSubmit: isSubmit,
      );
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
