import 'package:flutter/widgets.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';

/// Which of the four steps the traveller is currently on.
///
/// Step 1 (Identity) is already done for a verified traveler.
enum CheckInStage { requirement, questions, key }

/// What this destination needs before online check-in completes.
enum CheckInRequirement {
  /// A visa is collected and forwarded to the hotel. It is never verified.
  visa,

  /// Legal disclosure requirement (e.g. Spanish law requires sending guest details).
  disclosure,
}

extension CheckInRequirementDetails on CheckInRequirement {
  IconData get flagIcon => switch (this) {
        CheckInRequirement.visa => AppIcons.fileText,
        CheckInRequirement.disclosure => AppIcons.scale,
      };

  String get flagLead => switch (this) {
        CheckInRequirement.visa => 'A visa is needed for this trip. ',
        CheckInRequirement.disclosure => 'Spain asks for more. ',
      };

  String get flagBody => switch (this) {
        CheckInRequirement.visa =>
          'London to Honolulu requires one for your passport.',
        CheckInRequirement.disclosure =>
          'Hotels there must send guest details to the authorities within 24 hours. '
              "It's the law, not the hotel's choice.",
      };

  String get stepTitle => switch (this) {
        CheckInRequirement.visa => 'Upload your visa',
        CheckInRequirement.disclosure => 'What Spain needs',
      };

  String get stepSubtitle => switch (this) {
        CheckInRequirement.visa => 'Photograph the visa page',
        CheckInRequirement.disclosure =>
          'Review and approve before we send anything',
      };

  String get notice => switch (this) {
        CheckInRequirement.visa =>
          'Your documents go to the hotel only after you finish.',
        CheckInRequirement.disclosure =>
          'Nothing leaves your phone until you approve it.',
      };
}

/// How the visa page arrived.
enum VisaSource { camera, file, pdf }

/// When check-in opens for a booking.
enum CheckInWindow { open, waiting, done, closed }
