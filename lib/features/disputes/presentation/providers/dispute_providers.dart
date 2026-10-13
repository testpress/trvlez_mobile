import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/features/disputes/domain/entities/dispute.dart';

export 'package:trvlez_mobile/features/disputes/domain/entities/dispute.dart';

@immutable
class DisputeDraft {
  const DisputeDraft({
    this.reservationId = '',
    this.bookingReference = '',
    this.hotel = '',
    this.reason,
    this.words = '',
    this.photoCount = 0,
    this.window = DisputeWindow.open,
  });

  final String reservationId;
  final String bookingReference;
  final String hotel;
  final DisputeReason? reason;
  final String words;
  final int photoCount;
  final DisputeWindow window;

  DisputeDraft copyWith({
    String? reservationId,
    String? bookingReference,
    String? hotel,
    DisputeReason? reason,
    String? words,
    int? photoCount,
    DisputeWindow? window,
  }) {
    return DisputeDraft(
      reservationId: reservationId ?? this.reservationId,
      bookingReference: bookingReference ?? this.bookingReference,
      hotel: hotel ?? this.hotel,
      reason: reason ?? this.reason,
      words: words ?? this.words,
      photoCount: photoCount ?? this.photoCount,
      window: window ?? this.window,
    );
  }
}

final disputeDraftProvider =
    StateNotifierProvider<DisputeDraftNotifier, DisputeDraft>((ref) {
  return DisputeDraftNotifier();
});

class DisputeDraftNotifier extends StateNotifier<DisputeDraft> {
  DisputeDraftNotifier() : super(const DisputeDraft());

  void initDraft({
    required String reservationId,
    required String bookingReference,
    required String hotel,
    DisputeWindow window = DisputeWindow.open,
  }) {
    state = DisputeDraft(
      reservationId: reservationId,
      bookingReference: bookingReference,
      hotel: hotel,
      window: window,
    );
  }

  void setReason(DisputeReason reason) {
    state = state.copyWith(reason: reason);
  }

  void setWords(String words) {
    state = state.copyWith(words: words);
  }

  void addPhoto() {
    if (state.photoCount < 3) {
      state = state.copyWith(photoCount: state.photoCount + 1);
    }
  }

  void clearPhotos() {
    state = state.copyWith(photoCount: 0);
  }
}

final disputesProvider =
    StateNotifierProvider<DisputesNotifier, Map<String, DisputeRecord>>((ref) {
  return DisputesNotifier();
});

class DisputesNotifier extends StateNotifier<Map<String, DisputeRecord>> {
  DisputesNotifier() : super({});

  void raiseDispute(DisputeDraft draft) {
    final now = DateFormat('d MMM').format(DateTime.now());
    final record = DisputeRecord(
      reservationId: draft.reservationId,
      bookingReference: draft.bookingReference,
      hotel: draft.hotel,
      reason: draft.reason ?? DisputeReason.somethingElse,
      words: draft.words,
      photoCount: draft.photoCount,
      raisedAt: now,
      status: 'holding',
    );

    state = {
      ...state,
      draft.reservationId: record,
    };
  }

  void withdrawDispute(String reservationId) {
    final current = state[reservationId];
    if (current != null) {
      final updated = DisputeRecord(
        reservationId: current.reservationId,
        bookingReference: current.bookingReference,
        hotel: current.hotel,
        reason: current.reason,
        words: current.words,
        photoCount: current.photoCount,
        raisedAt: current.raisedAt,
        status: 'withdrawn',
      );
      state = {
        ...state,
        reservationId: updated,
      };
    }
  }
}
