import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Heart save button supporting on-card and on-photo presentation.
///
/// **Contract:**
/// - **Owner:** Core property favorite toggle (`lib/core/widgets/heart_button.dart`).
/// - **Variants:** On-surface (`onPhoto: false`) and translucent photo overlay (`onPhoto: true`).
/// - **States:** Unsaved ([saved] = false), saved ([saved] = true), disabled ([onTap] == null).
/// - **Accessibility:** Button semantics with dynamic action label; [Material] circular ink ripple;
///   guarantees minimum [sizes.touchTargetMin] (48x48dp) touch target.
/// - **Validation Owner:** `test/core/widgets/heart_button_test.dart`.
class HeartButton extends StatelessWidget {
  const HeartButton({
    super.key,
    required this.saved,
    this.onTap,
    this.size,
    this.onPhoto = false,
  });

  final bool saved;
  final VoidCallback? onTap;
  final double? size;
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;

    final effectiveSize = size ?? sizes.controlSm;

    final background = onPhoto
        ? colors.photoChip
        : (saved ? colors.redTint : colors.page);

    final iconColor = saved ? colors.brandPrimary : colors.inkTertiary;

    return Semantics(
      button: true,
      label: saved ? 'Remove from saved' : 'Save property',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: sizes.touchTargetMin,
          minHeight: sizes.touchTargetMin,
        ),
        child: Center(
          child: Material(
            color: background,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: effectiveSize,
                height: effectiveSize,
                child: Center(
                  child: Icon(
                    AppIcons.heart,
                    size: effectiveSize * 0.52,
                    color: iconColor,
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
