import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Large translucent circle with centered icon (e.g. store icon on declined screen).
class CheckInBigRing extends StatelessWidget {
  const CheckInBigRing({super.key, required this.icon, this.marginTop});

  final IconData icon;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.only(top: marginTop ?? space.stackPageBottom),
      child: Center(
        child: Container(
          width: sizes.pulseIndicator,
          height: sizes.pulseIndicator,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.checkInRingPanel,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: sizes.iconXl, color: colors.brandOnSurface),
        ),
      ),
    );
  }
}
