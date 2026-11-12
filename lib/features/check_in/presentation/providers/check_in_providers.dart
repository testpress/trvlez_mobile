import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';
import 'package:trvlez_mobile/features/check_in/domain/entities/check_in_details.dart';
import 'package:trvlez_mobile/features/check_in/domain/entities/check_in_stage.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

export 'package:trvlez_mobile/features/check_in/domain/entities/check_in_details.dart';
export 'package:trvlez_mobile/features/check_in/domain/entities/check_in_stage.dart';

/// Provider family for checking in to a specific reservation.
final checkInNotifierProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      CheckInNotifier,
      CheckInDetails,
      String
    >(() => CheckInNotifier());

class CheckInNotifier
    extends AutoDisposeFamilyAsyncNotifier<CheckInDetails, String> {
  @override
  FutureOr<CheckInDetails> build(String arg) async {
    // Attempt to locate in cached list first
    final list = ref.read(reservationListProvider).valueOrNull;
    Reservation? matched = list?.where((r) => r.id == arg).firstOrNull;

    if (matched == null) {
      final repository = ref.read(reservationRepositoryProvider);
      matched = await repository.getReservation(arg);
    }

    final country = matched.propertySummary.countryCode?.toUpperCase() ?? '';
    final location = matched.propertySummary.locationString.toLowerCase();
    final name = matched.propertySummary.name.toLowerCase();

    final isSpain =
        country == 'ES' ||
        location.contains('spain') ||
        location.contains('barcelona') ||
        name.contains('gràcia') ||
        matched.propertySummary.requiresPrearrivalForm;

    final requirement = isSpain
        ? CheckInRequirement.disclosure
        : CheckInRequirement.visa;

    final isCheckedIn = matched.status == ReservationStatus.checkedIn;
    final isVerified = ref.watch(isKycVerifiedProvider);

    final defaultStage = isCheckedIn
        ? CheckInStage.key
        : (isVerified ? CheckInStage.requirement : CheckInStage.identity);

    final previous = state.valueOrNull;
    if (previous != null) {
      final updatedStage = (!isVerified)
          ? CheckInStage.identity
          : (previous.currentStage == CheckInStage.identity
                ? CheckInStage.requirement
                : previous.currentStage);
      return previous.copyWith(
        reservation: matched,
        requirement: requirement,
        currentStage: isCheckedIn ? CheckInStage.key : updatedStage,
        isDone: isCheckedIn || previous.isDone,
      );
    }

    return CheckInDetails(
      reservation: matched,
      requirement: requirement,
      numberOfGuests: matched.numberOfGuests > 0 ? matched.numberOfGuests : 2,
      isDone: isCheckedIn,
      currentStage: defaultStage,
    );
  }

  void setVisaSource(VisaSource source, [String? path]) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(visaSource: source, visaImagePath: path),
    );
  }

  void setDisclosureAgreed(bool agreed) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(disclosureAgreed: agreed));
  }

  void inviteGuest(int adultIndex) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = Set<int>.from(current.invitedAdults)..add(adultIndex);
    state = AsyncData(current.copyWith(invitedAdults: updated));
  }

  void updateQuestions({
    String? arrivalTime,
    int? numberOfGuests,
    String? note,
  }) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        arrivalTime: arrivalTime ?? current.arrivalTime,
        numberOfGuests: numberOfGuests ?? current.numberOfGuests,
        specialNotes: note ?? current.specialNotes,
      ),
    );
  }

  void completeStage(CheckInStage stage) {
    final current = state.valueOrNull;
    if (current == null) return;

    final nextStage = switch (stage) {
      CheckInStage.identity => CheckInStage.requirement,
      CheckInStage.requirement => CheckInStage.questions,
      CheckInStage.questions => CheckInStage.key,
      CheckInStage.key => CheckInStage.key,
    };

    state = AsyncData(current.copyWith(currentStage: nextStage));
  }

  void declineCheckIn() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isDeclined: true));
  }

  Future<void> finishCheckIn() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(isDone: true, currentStage: CheckInStage.key),
    );

    // Trigger token generation in the background
    try {
      await ref.read(checkInTokenProvider(arg).notifier).generateCheckInToken();
    } catch (error, stackTrace) {
      // Backend may fail if KYC not verified or offline;
      // state remains offline-capable per design specifications.
      AppLogger.warning(
        'Background check-in token generation failed',
        error,
        stackTrace,
      );
    }
  }
}
