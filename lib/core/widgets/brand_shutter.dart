import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

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
            width: 58.0,
            height: 58.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandOnSurface,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: recording ? 24.0 : 44.0,
              height: recording ? 24.0 : 44.0,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(
                  recording ? 6.0 : (square ? 10.0 : AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
