import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Large translucent circle with centered icon (e.g. store icon on declined screen).
class CheckInBigRing extends StatelessWidget {
  const CheckInBigRing({super.key, required this.icon, this.marginTop = 48.0});

  final IconData icon;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(top: marginTop),
      child: Center(
        child: Container(
          width: 72.0,
          height: 72.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.checkInRingPanel,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34.0, color: colors.brandOnSurface),
        ),
      ),
    );
  }
}
