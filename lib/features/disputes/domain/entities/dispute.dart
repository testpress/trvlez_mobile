import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';

/// The window of time during which a payment can be held on a booking.
enum DisputeWindow {
  /// Booked, not yet arrived. Only billing reasons are available.
  beforeArrival,

  /// From scheduled check-in until 48 hours after scheduled check-out.
  open,

  /// Expired. Funds have been disbursed to the property.
  closed,
}

/// What the traveler reports went wrong with the stay or billing.
enum DisputeReason {
  notAsBooked,
  couldNotGetIn,
  wrongAmount,
  somethingElse,
}

extension DisputeReasonCopy on DisputeReason {
  IconData get icon => switch (this) {
        DisputeReason.notAsBooked => AppIcons.alertTriangle,
        DisputeReason.couldNotGetIn => AppIcons.doorEnter,
        DisputeReason.wrongAmount => AppIcons.receipt,
        DisputeReason.somethingElse => AppIcons.messageCircle,
      };

  String get title => switch (this) {
        DisputeReason.notAsBooked => 'Not what was booked',
        DisputeReason.couldNotGetIn => "Couldn't get in",
        DisputeReason.wrongAmount => 'Charged the wrong amount',
        DisputeReason.somethingElse => 'Something else',
      };

  String get subtitle => switch (this) {
        DisputeReason.notAsBooked =>
          'The room, the dates or the hotel was different',
        DisputeReason.couldNotGetIn =>
          'Turned away, or no room when you arrived',
        DisputeReason.wrongAmount => 'Charged twice, or more than you agreed',
        DisputeReason.somethingElse => 'Tell us in your own words',
      };

  String get prompt => switch (this) {
        DisputeReason.notAsBooked =>
          'What did you book, and what did you get?',
        DisputeReason.couldNotGetIn => 'What happened when you arrived?',
        DisputeReason.wrongAmount =>
          'What were you charged, and what did you agree?',
        DisputeReason.somethingElse => 'What happened, and when?',
      };

  bool get availableBeforeArrival =>
      this == DisputeReason.wrongAmount || this == DisputeReason.somethingElse;

  static List<DisputeReason> forWindow(DisputeWindow window) => [
        for (final r in DisputeReason.values)
          if (window != DisputeWindow.beforeArrival || r.availableBeforeArrival)
            r,
      ];
}

/// A complaint and payment hold on a reservation.
@immutable
class DisputeRecord {
  const DisputeRecord({
    required this.reservationId,
    required this.bookingReference,
    required this.hotel,
    required this.reason,
    required this.words,
    required this.photoCount,
    required this.raisedAt,
    this.status = 'holding',
  });

  final String reservationId;
  final String bookingReference;
  final String hotel;
  final DisputeReason reason;
  final String words;
  final int photoCount;
  final String raisedAt;
  final String status; // 'holding', 'withdrawn', 'settled'
}
