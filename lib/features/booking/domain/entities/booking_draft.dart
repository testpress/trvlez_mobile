import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/guest_counts.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';

/// Holds the in-flight configuration of a reservation before confirmation.
class BookingDraft {
  const BookingDraft({
    required this.propertyId,
    required this.propertyName,
    required this.propertyPlace,
    this.propertyTag = 'Hotel',
    required this.propertyNightly,
    this.heroImageUrl = '',
    this.currencyCode = 'GBP',
    this.range,
    this.guests = const GuestCounts(),
    this.picks = const [],
    this.cardAdded = false,
  });

  final String propertyId;
  final String propertyName;
  final String propertyPlace;
  final String propertyTag;
  final int propertyNightly;
  final String heroImageUrl;
  final String currencyCode;

  final BookingDateRange? range;
  final GuestCounts guests;
  final List<RoomPick> picks;
  final bool cardAdded;

  BookingDraft copyWith({
    BookingDateRange? range,
    GuestCounts? guests,
    List<RoomPick>? picks,
    bool? cardAdded,
    String? heroImageUrl,
    String? currencyCode,
  }) => BookingDraft(
    propertyId: propertyId,
    propertyName: propertyName,
    propertyPlace: propertyPlace,
    propertyTag: propertyTag,
    propertyNightly: propertyNightly,
    heroImageUrl: heroImageUrl ?? this.heroImageUrl,
    currencyCode: currencyCode ?? this.currencyCode,
    range: range ?? this.range,
    guests: guests ?? this.guests,
    picks: picks ?? this.picks,
    cardAdded: cardAdded ?? this.cardAdded,
  );

  List<RoomPick> get chosen => picks.where((p) => p.quantity > 0).toList();

  int get roomCount => chosen.fold(0, (sum, p) => sum + p.quantity);

  int get sleeps => chosen.fold(0, (sum, p) => sum + p.sleeps);

  int get total => chosen.fold(0, (sum, p) => sum + p.total);

  bool get sleepsEveryone => sleeps >= guests.sleepingCount;

  bool get canReview => chosen.isNotEmpty && sleepsEveryone;

  bool get canConfirm => canReview && cardAdded;

  /// The distinct date ranges selected across chosen rooms.
  List<BookingDateRange> get ranges {
    final out = <BookingDateRange>[];
    for (final pick in chosen) {
      if (!out.any((r) => r.sameAs(pick.range))) {
        out.add(pick.range);
      }
    }
    return out;
  }

  bool get splits => ranges.length > 1;

  List<List<RoomPick>> split() => [
    for (final r in ranges) chosen.where((p) => p.range.sameAs(r)).toList(),
  ];
}
