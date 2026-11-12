import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Location selector row displaying current city and opening the location sheet.
class HomeLocationRow extends StatelessWidget {
  const HomeLocationRow({super.key, required this.location, this.onTap});

  final String location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label: 'Selected location: $location',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizes.touchTargetMin),
        child: InkWell(
          borderRadius: shape.radiusControlSm,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: space.stackText,
              horizontal: space.inlineMicro,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.mapPinFilled,
                  size: sizes.iconCompact,
                  color: colors.brandPrimary,
                ),
                SizedBox(width: space.inlineIconLabel),
                Text(
                  location,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(width: space.inlineMicro),
                Icon(
                  AppIcons.chevronDown,
                  size: sizes.iconXs,
                  color: colors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
