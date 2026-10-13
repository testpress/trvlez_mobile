import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';

/// Standard brand logo icon and title used in top app bars and auth headers.
class AppBrandLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? textColor;

  const AppBrandLogo({
    super.key,
    this.iconSize = 32,
    this.fontSize = 22,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: AppRadius.smRadius,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: iconSize * 0.56,
              height: iconSize * 0.56,
              colorFilter: ColorFilter.mode(
                colors.textOnAction,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text.rich(
          TextSpan(
            text: 'Trvl',
            style: AppTypography.heading.copyWith(
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
