import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_summary_row.dart';

/// Card summarizing room line items, guest count, and overall total price.
class BookingReviewBreakdownCard extends StatelessWidget {
  const BookingReviewBreakdownCard({
    super.key,
    required this.draft,
    required this.bookingRange,
  });

  final BookingDraft draft;
  final BookingDateRange? bookingRange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rooms = draft.chosen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final pick in rooms)
            BookingSummaryRow(
              label: pick.quantity == 1
                  ? pick.type.name
                  : '${pick.type.name} × ${pick.quantity}',
              note:
                  '${DateFormatter.dayMonth(pick.range.from)} – ${DateFormatter.dayMonth(pick.range.to)} · ${pick.range.nights} ${pick.range.nights == 1 ? 'night' : 'nights'}',
              noteAmber:
                  bookingRange != null && !pick.range.sameAs(bookingRange!),
              value: PriceFormatter.formatPrice(
                pick.total.toDouble(),
                currencyCode: draft.currencyCode,
              ),
            ),
          BookingSummaryRow(
            label: 'Guests',
            value: draft.guests.summary,
          ),
          BookingSummaryRow(
            label: 'Total',
            value: PriceFormatter.formatPrice(
              draft.total.toDouble(),
              currencyCode: draft.currencyCode,
            ),
            total: true,
            last: true,
          ),
        ],
      ),
    );
  }
}
