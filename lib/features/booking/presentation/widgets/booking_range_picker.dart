import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_month_grid.dart';

/// Vertical column of scrollable months for selecting a date range.
class BookingRangePicker extends StatefulWidget {
  const BookingRangePicker({
    super.key,
    required this.initial,
    required this.onChanged,
    this.months = 6,
  });

  final BookingDateRange? initial;
  final ValueChanged<BookingDateRange?> onChanged;
  final int months;

  @override
  State<BookingRangePicker> createState() => _BookingRangePickerState();
}

class _BookingRangePickerState extends State<BookingRangePicker> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initial?.from;
    _to = widget.initial?.to;
  }

  DateTime get _earliest {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _onTapDay(DateTime date) {
    setState(() {
      final currentFrom = _from;
      if (currentFrom == null || _to != null || !date.isAfter(currentFrom)) {
        _from = date;
        _to = null;
      } else {
        _to = date;
      }
    });

    final fromDate = _from;
    final toDate = _to;
    if (fromDate != null && toDate != null) {
      widget.onChanged(BookingDateRange(fromDate, toDate));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = _earliest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.months; i++)
          BookingMonthGrid(
            month: DateTime(first.year, first.month + i, 1),
            from: _from,
            to: _to,
            earliest: first,
            onTapDay: _onTapDay,
          ),
      ],
    );
  }
}
