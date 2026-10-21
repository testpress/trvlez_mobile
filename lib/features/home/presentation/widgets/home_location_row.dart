import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

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
                size: sizes.iconXs,
                color: colors.brandPrimary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Text(
                location,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: TypeScale.medium,
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
    );
  }
}
