import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Heart save button supporting on-card and on-photo presentation.
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
    final space = context.space;
    final sizes = context.sizes;

    final effectiveSize = size ?? sizes.controlSm;

    final background = onPhoto
        ? colors.photoChip
        : (saved ? colors.redTint : colors.page);

    final iconColor = saved ? colors.brandPrimary : colors.inkTertiary;

    return Semantics(
      button: true,
      label: saved ? 'Remove from saved' : 'Save property',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: space.insetControlSm, // Ensures minimum 48dp hit area
          child: Container(
            width: effectiveSize,
            height: effectiveSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.heart,
              size: effectiveSize * 0.52,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
