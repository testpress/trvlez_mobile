/// Date formatting utilities adhering to the TrvlEz design system.
class DateFormatter {
  const DateFormatter._();

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _monthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Formats date as `12 Oct`
  static String dayMonth(DateTime date) =>
      '${date.day} ${_monthsShort[date.month - 1]}';

  /// Formats date as `22 Aug 2031`
  static String dayMonthYear(DateTime date) =>
      '${date.day} ${_monthsShort[date.month - 1]} ${date.year}';

  /// Formats date as `October 2026`
  static String monthNameYear(DateTime date) =>
      '${_monthsLong[date.month - 1]} ${date.year}';

  /// Formats date as `Aug 2031`
  static String monthYear(DateTime date) =>
      '${_monthsShort[date.month - 1]} ${date.year}';
}
