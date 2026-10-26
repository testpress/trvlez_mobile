import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final cardBg = backgroundColor ?? colors.redTint;
    final primary = accentColor ?? colors.brandPrimary;

    return Semantics(
      button: true,
      label: '$title. $detail.',
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: shape.radiusSurface,
          ),
          padding: space.insetCard,
          child: Row(
            children: [
              Container(
                width: sizes.iconXl,
                height: sizes.iconXl,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(icon, size: sizes.iconSm, color: colors.textOnAction),
              ),
              SizedBox(width: space.inlineIconLabel),
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
                    SizedBox(height: shape.borderDefault),
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
              Icon(AppIcons.chevronRight, size: sizes.iconSm, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
