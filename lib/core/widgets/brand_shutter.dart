import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Large circular shutter button (square center for document, round for selfie).
///
/// **Contract:**
/// - **Owner:** Verification camera capture shutter (`lib/core/widgets/brand_shutter.dart`).
/// - **Variants:** Document capture ([square] = true), selfie capture ([square] = false), video ([recording] = true).
/// - **States:** Idle, active recording, disabled ([onPressed] == null).
/// - **Accessibility:** Button semantics, dynamic label ('Capture' / 'Recording'), circular ink feedback,
///   guarantees target dimension [sizes.controlXl] (>48dp).
/// - **Validation Owner:** `test/core/widgets/brand_shutter_test.dart`.
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
        child: Material(
          shape: const CircleBorder(),
          color: colors.brandOnSurface,
          child: InkResponse(
            containedInkWell: true,
            highlightShape: BoxShape.circle,
            onTap: onPressed,
            child: SizedBox(
              width: sizes.controlXl,
              height: sizes.controlXl,
              child: Center(
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
        ),
      ),
    );
  }
}
