import 'package:intl/intl.dart';
import 'package:trvlez_mobile/features/check_in/domain/entities/check_in_stage.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// Complete domain representation of an ongoing or completed check-in.
class CheckInDetails {
  final Reservation reservation;
  final CheckInRequirement requirement;
  final CheckInStage currentStage;
  final VisaSource? visaSource;
  final String? visaImagePath;
  final bool disclosureAgreed;
  final Set<int> invitedAdults;
  final String arrivalTime;
  final int numberOfGuests;
  final String specialNotes;
  final bool isDeclined;
  final bool isDone;

  const CheckInDetails({
    required this.reservation,
    required this.requirement,
    this.currentStage = CheckInStage.requirement,
    this.visaSource,
    this.visaImagePath,
    this.disclosureAgreed = false,
    this.invitedAdults = const {},
    this.arrivalTime = 'Around 6pm',
    required this.numberOfGuests,
    this.specialNotes = '',
    this.isDeclined = false,
    this.isDone = false,
  });

  String get hotel => reservation.propertySummary.name;
  String get location => reservation.propertySummary.locationString;

  String get datesFormatted {
    final format = DateFormat('d–d MMM');
    try {
      final startDay = DateFormat('d').format(reservation.checkInDate);
      final endDay = DateFormat('d MMM').format(reservation.checkOutDate);
      return '$startDay–$endDay';
    } catch (_) {
      return format.format(reservation.checkInDate);
    }
  }

  String get dateAndGuests =>
      '$datesFormatted · $numberOfGuests ${numberOfGuests == 1 ? 'guest' : 'guests'}';

  String get summary =>
      '$datesFormatted · $numberOfGuests ${numberOfGuests == 1 ? 'guest' : 'guests'}. '
      'Finish this and you can collect your keys and go straight up.';

  CheckInDetails copyWith({
    Reservation? reservation,
    CheckInRequirement? requirement,
    CheckInStage? currentStage,
    VisaSource? visaSource,
    String? visaImagePath,
    bool? disclosureAgreed,
    Set<int>? invitedAdults,
    String? arrivalTime,
    int? numberOfGuests,
    String? specialNotes,
    bool? isDeclined,
    bool? isDone,
  }) {
    return CheckInDetails(
      reservation: reservation ?? this.reservation,
      requirement: requirement ?? this.requirement,
      currentStage: currentStage ?? this.currentStage,
      visaSource: visaSource ?? this.visaSource,
      visaImagePath: visaImagePath ?? this.visaImagePath,
      disclosureAgreed: disclosureAgreed ?? this.disclosureAgreed,
      invitedAdults: invitedAdults ?? this.invitedAdults,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialNotes: specialNotes ?? this.specialNotes,
      isDeclined: isDeclined ?? this.isDeclined,
      isDone: isDone ?? this.isDone,
    );
  }
}
