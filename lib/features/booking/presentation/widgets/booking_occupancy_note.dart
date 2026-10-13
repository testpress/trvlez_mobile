import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

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
    final ok = sleeps >= needed && rooms > 0;

    final text = rooms == 0
        ? 'Pick a room. You have $needed to sleep.'
        : ok
        ? '$rooms ${rooms == 1 ? 'room' : 'rooms'} · sleep $sleeps · you have $needed'
        : '$rooms ${rooms == 1 ? 'room' : 'rooms'} sleep $sleeps. You have $needed.';

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: ok ? colors.okFill : colors.waitFill,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          Icon(
            ok ? AppIcons.check : AppIcons.infoCircle,
            size: 16.0,
            color: ok ? colors.okInk : colors.waitInk,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12.0,
                fontWeight: TypeScale.medium,
                color: ok ? colors.okInk : colors.waitInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
