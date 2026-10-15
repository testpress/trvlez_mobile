import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// A single bullet item inside an instruction card.
class BrandBullet {
  const BrandBullet({
    required this.icon,
    required this.text,
    this.emphasis = false,
  });

  final IconData icon;
  final String text;
  final bool emphasis;
}

/// Translucent guidance card with an optional heading and bulleted list.
class BrandInfoCard extends StatelessWidget {
  const BrandInfoCard({
    super.key,
    required this.bullets,
    this.heading,
    this.borderRadius = AppRadius.md14,
    this.paddingVertical = AppSpacing.md - 4,
    this.paddingHorizontal = AppSpacing.md - 3,
    this.itemGap = AppSpacing.sm + 1,
    this.iconSize = AppSpacing.md - 2,
  });

  final List<BrandBullet> bullets;
  final String? heading;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;
  final double itemGap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentHeading = heading;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: paddingVertical,
        horizontal: paddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentHeading != null) ...[
            Text(
              currentHeading,
              style: context.text.labelMedium?.copyWith(
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
              ),
            ),
            SizedBox(height: itemGap),
          ],
          for (int i = 0; i < bullets.length; i++) ...[
            if (i > 0) SizedBox(height: itemGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    bullets[i].icon,
                    size: iconSize,
                    color: colors.brandSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    bullets[i].text,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: bullets[i].emphasis
                          ? TypeScale.medium
                          : TypeScale.regular,
                      color: bullets[i].emphasis
                          ? colors.brandOnSurface
                          : colors.brandSecondaryBody,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
