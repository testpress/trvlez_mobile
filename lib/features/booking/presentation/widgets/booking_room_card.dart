import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_stepper.dart';

/// Card displaying a room type, its quantity stepper, per-room dates, and total.
class BookingRoomCard extends StatelessWidget {
  const BookingRoomCard({
    super.key,
    required this.pick,
    required this.onQuantity,
    required this.onChangeDates,
    required this.differs,
    this.currencyCode = 'GBP',
  });

  final RoomPick pick;
  final ValueChanged<int> onQuantity;
  final VoidCallback onChangeDates;
  final bool differs;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chosen = pick.quantity > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: chosen ? colors.brandPrimary : colors.cardBorderSoft,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pick.type.name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15.0,
                        fontWeight: TypeScale.bold,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sleeps ${pick.type.sleeps} · ${PriceFormatter.formatPrice(pick.type.nightly.toDouble(), currencyCode: currencyCode)} a night',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.0,
                        color: colors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              BookingStepper(
                value: pick.quantity,
                onChanged: onQuantity,
                label: pick.type.name,
                max: 9,
              ),
            ],
          ),
          if (chosen) ...[
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${DateFormatter.dayMonth(pick.range.from)} – ${DateFormatter.dayMonth(pick.range.to)} · ${pick.range.nights} ${pick.range.nights == 1 ? 'night' : 'nights'}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12.0,
                        color: differs ? colors.waitInk : colors.inkSecondary,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Change dates for ${pick.type.name}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onChangeDates,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12.0,
                            fontWeight: TypeScale.bold,
                            color: colors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${PriceFormatter.formatPrice(pick.total.toDouble(), currencyCode: currencyCode)} · ${pick.quantity} ${pick.quantity == 1 ? 'room' : 'rooms'}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.0,
                fontWeight: TypeScale.bold,
                color: colors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
