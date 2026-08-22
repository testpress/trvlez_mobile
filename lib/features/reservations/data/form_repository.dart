import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/reservations/data/form_remote_data_source.dart';
import 'package:trvlez_mobile/features/reservations/domain/form.dart';

class FormRepository {
  final FormRemoteDataSource remoteDataSource;

  const FormRepository({required this.remoteDataSource});

  Future<ReservationFormResponse> getReservationForm(String reservationId) async {
    final dto = await remoteDataSource.getReservationForm(reservationId);
    return dto.toDomain();
  }

  Future<FormSubmission> submitReservationForm({
    required String reservationId,
    required Map<String, dynamic> responses,
    bool isSubmit = false,
  }) async {
    final dto = await remoteDataSource.submitReservationForm(
      reservationId: reservationId,
      responses: responses,
      isSubmit: isSubmit,
    );
    return dto.toDomain();
  }
}

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepository(
    remoteDataSource: ref.watch(formRemoteDataSourceProvider),
  );
});
