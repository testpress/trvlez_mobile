import 'package:meta/meta.dart';

/// How the check-in message reaches the property.
enum AnywhereRoute {
  /// The hotel uses TRVLez and receives the check-in via their hotel dashboard.
  onTrvlez,

  /// The hotel is not on TRVLez, so we transmit the verified details via email.
  byEmail,
}

/// The state of an anywhere check-in request.
enum AnywhereStatus {
  /// Delivered to hotel dashboard or inbox. Awaiting staff review.
  sent,

  /// A named staff member has acknowledged receipt of the verified pass.
  noted,

  /// The hotel requests standard physical verification at reception.
  desk,
}

extension AnywhereStatusCopy on AnywhereStatus {
  String get pill => switch (this) {
    AnywhereStatus.sent => 'Sent',
    AnywhereStatus.noted => 'Noted',
    AnywhereStatus.desk => 'Desk',
  };

  String get stripTitle => switch (this) {
    AnywhereStatus.sent => 'Your verified pass',
    AnywhereStatus.noted => 'They are expecting you',
    AnywhereStatus.desk => 'Your verified pass',
  };

  String get stripBody => switch (this) {
    AnywhereStatus.sent => 'Show it at the desk',
    AnywhereStatus.noted => 'Show your pass at the desk',
    AnywhereStatus.desk => 'Show it if they ask',
  };
}

/// A directory hotel entry that can be searched or selected.
@immutable
class HotelDirectoryItem {
  const HotelDirectoryItem({required this.name, required this.place});

  final String name;
  final String place;
}

/// A stay at a property booked outside ezStays, registered for identity
/// pre-clearance and verification transmission.
@immutable
class AnywhereStay {
  const AnywhereStay({
    required this.id,
    required this.hotel,
    required this.place,
    required this.dates,
    required this.guests,
    required this.route,
    required this.status,
    this.hotelEmail = '',
    this.sentOn = '',
    this.notedBy = '',
    this.notedOn = '',
  });

  final String id;
  final String hotel;
  final String place;
  final String dates;
  final int guests;
  final AnywhereRoute route;
  final AnywhereStatus status;
  final String hotelEmail;
  final String sentOn;
  final String notedBy;
  final String notedOn;

  String get dateAndGuests =>
      '$dates · $guests ${guests == 1 ? 'guest' : 'guests'}';

  String get note => switch (status) {
    AnywhereStatus.sent =>
      route == AnywhereRoute.onTrvlez
          ? 'Waiting in their TRVLez dashboard.'
          : 'Emailed $sentOn. They have not replied.',
    AnywhereStatus.noted =>
      'Noted by $notedBy, $notedOn. Your booking is still with the hotel.',
    AnywhereStatus.desk =>
      'Hotel requested in-person check-in. Show your passport at the desk.',
  };
}
