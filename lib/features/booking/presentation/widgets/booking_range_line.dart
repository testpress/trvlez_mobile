import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';

/// Text widget displaying a selected date range and night count.
class BookingRangeLine extends StatelessWidget {
  const BookingRangeLine({super.key, required this.range});

  final BookingDateRange? range;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = range;

    if (r == null) {
      return Text(
        'Pick the day you arrive, then the day you leave.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13.0,
          color: colors.inkSecondary,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${DateFormatter.dayMonth(r.from)} – ${DateFormatter.dayMonth(r.to)} · ',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.0,
              color: colors.ink,
            ),
          ),
          TextSpan(
            text: '${r.nights} ${r.nights == 1 ? 'night' : 'nights'}',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.0,
              fontWeight: TypeScale.bold,
              color: colors.ink,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
