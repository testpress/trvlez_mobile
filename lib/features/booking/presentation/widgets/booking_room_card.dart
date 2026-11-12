import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final chosen = pick.quantity > 0;

    return Container(
      margin: EdgeInsets.fromLTRB(
        space.insetCard.left,
        0,
        space.insetCard.right,
        space.stackItem,
      ),
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: chosen ? colors.brandPrimary : colors.cardBorderSoft,
          width: shape.borderDefault,
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
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.ink,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      'Sleeps ${pick.type.sleeps} · ${PriceFormatter.formatPrice(pick.type.nightly.toDouble(), currencyCode: currencyCode)} a night',
                      style: context.text.labelMedium?.copyWith(
                        color: colors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
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
              margin: EdgeInsets.only(top: space.stackItem),
              padding: EdgeInsets.only(top: space.stackText),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.line,
                    width: shape.borderDefault,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${DateFormatter.dayMonth(pick.range.from)} – ${DateFormatter.dayMonth(pick.range.to)} · ${pick.range.nights} ${pick.range.nights == 1 ? 'night' : 'nights'}',
                      style: context.text.labelMedium?.copyWith(
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
                        padding: space.insetTag,
                        child: Text(
                          'Change',
                          style: context.text.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: space.stackText),
            Text(
              '${PriceFormatter.formatPrice(pick.total.toDouble(), currencyCode: currencyCode)} · ${pick.quantity} ${pick.quantity == 1 ? 'room' : 'rooms'}',
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
