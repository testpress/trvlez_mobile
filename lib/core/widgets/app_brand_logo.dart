import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Standard brand logo icon and title used in top app bars and auth headers.
class AppBrandLogo extends StatelessWidget {
  final double? iconSize;
  final double fontSize;
  final Color? textColor;

  const AppBrandLogo({
    super.key,
    this.iconSize,
    this.fontSize = 22,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;
    final colorScheme = Theme.of(context).colorScheme;

    final effectiveIconSize = iconSize ?? sizes.iconXl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: effectiveIconSize,
          height: effectiveIconSize,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: shape.radiusControlSm,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: effectiveIconSize * 0.56,
              height: effectiveIconSize * 0.56,
              colorFilter: ColorFilter.mode(
                colors.textOnAction,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: space.inlineIconLabel),
        Text.rich(
          TextSpan(
            text: 'Trvl',
            style: context.text.headlineSmall?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor ?? colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Ez',
                style: context.text.titleMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
