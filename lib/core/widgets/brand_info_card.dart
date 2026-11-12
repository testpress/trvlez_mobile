import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

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
    this.headingStyle,
    this.borderRadius,
    this.paddingVertical,
    this.paddingHorizontal,
    this.itemGap,
    this.iconSize,
    this.textStyle,
  });

  final List<BrandBullet> bullets;
  final String? heading;
  final TextStyle? headingStyle;
  final double? borderRadius;
  final double? paddingVertical;
  final double? paddingHorizontal;
  final double? itemGap;
  final double? iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    final radius = borderRadius;
    final effectiveRadius = radius != null
        ? BorderRadius.circular(radius)
        : shape.radiusSurface;
    final effectivePaddingV = paddingVertical ?? space.insetCard.top;
    final effectivePaddingH = paddingHorizontal ?? space.insetCard.left;
    final effectiveItemGap = itemGap ?? space.stackFormField;
    final effectiveIconSize = iconSize ?? sizes.iconSm;

    final currentHeading = heading;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: effectivePaddingV,
        horizontal: effectivePaddingH,
      ),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: effectiveRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentHeading != null) ...[
            Text(
              currentHeading,
              style:
                  headingStyle ??
                  context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.brandOnSurface,
                  ),
            ),
            SizedBox(height: effectiveItemGap),
          ],
          for (int i = 0; i < bullets.length; i++) ...[
            if (i > 0) SizedBox(height: effectiveItemGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: shape.borderFocus),
                  child: Icon(
                    bullets[i].icon,
                    size: effectiveIconSize,
                    color: colors.brandSecondary,
                  ),
                ),
                SizedBox(width: space.inlineButtonGroup),
                Expanded(
                  child: Text(
                    bullets[i].text,
                    style: (textStyle ?? context.text.bodyMedium)?.copyWith(
                      fontWeight: bullets[i].emphasis
                          ? FontWeight.w500
                          : FontWeight.normal,
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
