import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';

class PreArrivalFormState {
  final bool isLoading;
  final String? error;
  final ReservationFormResponse? formResponse;
  final Map<String, dynamic> currentResponses;

  const PreArrivalFormState({
    this.isLoading = true,
    this.error,
    this.formResponse,
    this.currentResponses = const {},
  });

  PreArrivalFormState copyWith({
    bool? isLoading,
    String? error,
    ReservationFormResponse? formResponse,
    Map<String, dynamic>? currentResponses,
  }) {
    return PreArrivalFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      formResponse: formResponse ?? this.formResponse,
      currentResponses: currentResponses ?? this.currentResponses,
    );
  }
}

class PreArrivalFormNotifier extends StateNotifier<PreArrivalFormState> {
  final String reservationId;
  final FormRepository repository;

  PreArrivalFormNotifier({
    required this.reservationId,
    required this.repository,
  }) : super(const PreArrivalFormState()) {
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final response = await repository.getReservationForm(reservationId);
      
      // Initialize responses with submission data OR pre_fill_data
      final initialResponses = <String, dynamic>{};
      
      if (response.submission != null) {
        initialResponses.addAll(response.submission!.responses);
      } else {
        // Pre-fill from alias mapping
        for (final section in response.template.formDefinition.sections) {
          for (final field in section.fields) {
            if (field.preFillAlias != null && response.preFillData.containsKey(field.preFillAlias)) {
              initialResponses[field.id] = response.preFillData[field.preFillAlias];
            }
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        formResponse: response,
        currentResponses: initialResponses,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateField(String fieldId, dynamic value) {
    final updated = Map<String, dynamic>.from(state.currentResponses);
    if (value == null || (value is String && value.isEmpty)) {
      updated.remove(fieldId);
    } else {
      updated[fieldId] = value;
    }
    state = state.copyWith(currentResponses: updated);
  }

  Future<bool> saveDraft() async {
    return _submit(isSubmit: false);
  }

  Future<bool> submitForm() async {
    return _submit(isSubmit: true);
  }

  Future<bool> _submit({required bool isSubmit}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final submission = await repository.submitReservationForm(
        reservationId: reservationId,
        responses: state.currentResponses,
        isSubmit: isSubmit,
      );
      
      final updatedResponse = ReservationFormResponse(
        template: state.formResponse!.template,
        submission: submission,
        preFillData: state.formResponse!.preFillData,
      );

      state = state.copyWith(
        isLoading: false,
        formResponse: updatedResponse,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final preArrivalFormProvider = StateNotifierProvider.family<PreArrivalFormNotifier, PreArrivalFormState, String>((ref, reservationId) {
  return PreArrivalFormNotifier(
    reservationId: reservationId,
    repository: ref.watch(formRepositoryProvider),
  );
});
