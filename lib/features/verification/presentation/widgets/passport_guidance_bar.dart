import 'package:flutter/material.dart';

/// Guidance text positioned directly below the passport viewfinder frame.
class PassportGuidanceBar extends StatelessWidget {
  final Rect cutoutRect;
  final Size screenSize;

  const PassportGuidanceBar({
    super.key,
    required this.cutoutRect,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: cutoutRect.bottom + 8,
      left: cutoutRect.left,
      right: screenSize.width - cutoutRect.right,
      child: Text(
        'Hold steady • ~20 cm away • Keep bottom 2 lines in frame',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}
