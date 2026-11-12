import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Callout banner indicating whether currently chosen rooms sleep all guests.
class BookingOccupancyNote extends StatelessWidget {
  const BookingOccupancyNote({
    super.key,
    required this.rooms,
    required this.sleeps,
    required this.needed,
  });

  final int rooms;
  final int sleeps;
  final int needed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final ok = sleeps >= needed && rooms > 0;

    final text = rooms == 0
        ? 'Pick a room. You have $needed to sleep.'
        : ok
        ? '$rooms ${rooms == 1 ? 'room' : 'rooms'} · sleep $sleeps · you have $needed'
        : '$rooms ${rooms == 1 ? 'room' : 'rooms'} sleep $sleeps. You have $needed.';

    return Container(
      margin: EdgeInsets.fromLTRB(
        space.insetCard.left,
        space.stackItem,
        space.insetCard.right,
        0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: space.insetCard.left,
        vertical: space.stackItem,
      ),
      decoration: BoxDecoration(
        color: ok ? colors.okFill : colors.waitFill,
        borderRadius: shape.radiusSurface,
      ),
      child: Row(
        children: [
          Icon(
            ok ? AppIcons.check : AppIcons.infoCircle,
            size: sizes.iconSm,
            color: ok ? colors.okInk : colors.waitInk,
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Text(
              text,
              style: context.text.labelMedium?.copyWith(
                color: ok ? colors.okInk : colors.waitInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
