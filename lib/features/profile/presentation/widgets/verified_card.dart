import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Card displayed on the Account screen when identity verification is active, in review, or needs attention.
class VerifiedCard extends StatelessWidget {
  const VerifiedCard({
    super.key,
    required this.detail,
    this.title = 'Identity verified',
    this.icon = AppIcons.rosetteDiscountCheck,
    this.backgroundColor,
    this.accentColor,
    this.onTap,
  });

  final String detail;
  final String title;
  final IconData icon;
  final Color? backgroundColor;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cardBg = backgroundColor ?? colors.redTint;
    final primary = accentColor ?? colors.brandPrimary;

    return Semantics(
      button: true,
      label: '$title. $detail.',
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppRadius.cardRadius,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      detail,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: primary.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, size: 16, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
