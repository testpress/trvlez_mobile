import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';

/// Grid displaying days of one month with selected date range highlights.
class BookingMonthGrid extends StatelessWidget {
  const BookingMonthGrid({
    super.key,
    required this.month,
    required this.from,
    required this.to,
    required this.onTapDay,
    required this.earliest,
  });

  final DateTime month;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime> onTapDay;
  final DateTime earliest;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final lead = first.weekday - 1;
    final cells = <Widget>[];

    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(_DayCell(
        date: DateTime(month.year, month.month, day),
        from: from,
        to: to,
        earliest: earliest,
        onTap: onTapDay,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            DateFormatter.monthNameYear(month),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15.0,
              fontWeight: TypeScale.bold,
              color: colors.ink,
            ),
          ),
        ),
        Row(
          children: [
            for (final w in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.0,
                      fontWeight: TypeScale.semiBold,
                      color: colors.inkTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.15,
          children: cells,
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.from,
    required this.to,
    required this.earliest,
    required this.onTap,
  });

  final DateTime date;
  final DateTime? from;
  final DateTime? to;
  final DateTime earliest;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final past = date.isBefore(earliest);

    final isFrom = from != null &&
        date.year == from?.year &&
        date.month == from?.month &&
        date.day == from?.day;

    final isTo = to != null &&
        date.year == to?.year &&
        date.month == to?.month &&
        date.day == to?.day;

    final fromDate = from;
    final toDate = to;
    final between = fromDate != null &&
        toDate != null &&
        date.isAfter(fromDate) &&
        date.isBefore(toDate);

    final end = isFrom || isTo;

    BorderRadius? tintRadius;
    if (isFrom && to != null) {
      tintRadius = const BorderRadius.horizontal(left: Radius.circular(999));
    } else if (isTo) {
      tintRadius = const BorderRadius.horizontal(right: Radius.circular(999));
    }

    return Semantics(
      button: !past,
      selected: end || between,
      label: DateFormatter.dayMonthYear(date),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: past ? null : () => onTap(date),
        child: Container(
          decoration: BoxDecoration(
            color: (between || (end && to != null && from != null))
                ? colors.redTint
                : null,
            borderRadius: tintRadius,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: end ? colors.brandPrimary : null,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13.0,
                fontWeight: end ? TypeScale.bold : TypeScale.regular,
                color: end
                    ? colors.brandOnSurface
                    : past
                        ? colors.textDisabled
                        : colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
