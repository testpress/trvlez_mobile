/// The guest categories supported for a booking.
enum GuestKind {
  adults('Adults', '18 and over'),
  children('Children', '2 – 17'),
  infants('Infants', 'Under 2');

  const GuestKind(this.label, this.hint);

  final String label;
  final String hint;
}

/// The counts of guests attending a stay.
/// Adults verify identity in-app; children are checked in at reception.
class GuestCounts {
  const GuestCounts({
    this.adults = 2,
    this.children = 0,
    this.infants = 0,
  });

  final int adults;
  final int children;
  final int infants;

  int of(GuestKind kind) => switch (kind) {
        GuestKind.adults => adults,
        GuestKind.children => children,
        GuestKind.infants => infants,
      };

  GuestCounts withKind(GuestKind kind, int value) => switch (kind) {
        GuestKind.adults => GuestCounts(
            adults: value,
            children: children,
            infants: infants,
          ),
        GuestKind.children => GuestCounts(
            adults: adults,
            children: value,
            infants: infants,
          ),
        GuestKind.infants => GuestCounts(
            adults: adults,
            children: children,
            infants: value,
          ),
      };

  /// The minimum count allowed for each kind. At least 1 adult is required.
  int floorFor(GuestKind kind) => kind == GuestKind.adults ? 1 : 0;

  /// Sleeping occupancy required (adults + children; infants do not require a separate bed).
  int get sleepingCount => adults + children;

  /// Formatted string summary e.g. "2 adults, 1 child".
  String get summary {
    final parts = <String>[
      '$adults ${adults == 1 ? 'adult' : 'adults'}',
      if (children > 0) '$children ${children == 1 ? 'child' : 'children'}',
      if (infants > 0) '$infants ${infants == 1 ? 'infant' : 'infants'}',
    ];
    return parts.join(', ');
  }
}
