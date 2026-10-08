import 'package:trvlez_mobile/features/reservations/domain/entities/form.dart';

/// Domain contract for pre-arrival forms.
abstract interface class FormRepository {
  /// Fetches the pre-arrival form template and existing submission for a reservation.
  Future<ReservationFormResponse> getReservationForm(String reservationId);

  /// Saves or submits a form responses payload for a reservation.
  Future<FormSubmission> submitReservationForm({
    required String reservationId,
    required Map<String, dynamic> responses,
    bool isSubmit = false,
  });
}
