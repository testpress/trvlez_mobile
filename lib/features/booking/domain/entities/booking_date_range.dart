/// An arrival and departure date range for a booking or room.
class BookingDateRange {
  const BookingDateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;

  int get nights => to.difference(from).inDays;

  bool get isValid => nights > 0;

  bool sameAs(BookingDateRange other) =>
      from.year == other.from.year &&
      from.month == other.from.month &&
      from.day == other.from.day &&
      to.year == other.to.year &&
      to.month == other.to.month &&
      to.day == other.to.day;

  /// When free cancellation ends (2 days prior to arrival),
  /// or null when the stay begins too soon for there to be a cancellation window.
  DateTime? get freeCancellationUntil {
    final deadline = from.subtract(const Duration(days: 2));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return deadline.isBefore(today) ? null : deadline;
  }
}
