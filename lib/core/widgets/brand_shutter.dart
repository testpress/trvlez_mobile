import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Large circular shutter button (square center for document, round for selfie).
class BrandShutter extends StatelessWidget {
  const BrandShutter({
    super.key,
    required this.onPressed,
    this.square = false,
    this.recording = false,
  });

  final VoidCallback? onPressed;
  final bool square;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;
    final shape = context.shape;
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: recording ? 'Recording' : 'Capture',
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Container(
            width: sizes.controlXl,
            height: sizes.controlXl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: recording ? sizes.iconDefault : sizes.controlMd,
              height: recording ? sizes.iconDefault : sizes.controlMd,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: recording
                    ? shape.radiusSubtle
                    : (square ? shape.radiusControlSm : shape.radiusPill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
