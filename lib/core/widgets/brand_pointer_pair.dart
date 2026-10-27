import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Numbered pointer cards under diagrams (e.g., 1. Whole visa, 2. The dates).
class BrandPointerPair extends StatelessWidget {
  const BrandPointerPair({
    super.key,
    required this.items,
    this.padding,
    this.badgeSize,
    this.titleStyle,
    this.descriptionStyle,
    this.gapBadgeToTitle,
    this.gapTitleToDescription,
  });

  /// Triples of (badgeNumber, title, description).
  final List<(String, String, String)> items;

  /// Optional padding inside each pointer card. Defaults to [AppSpace.insetCard].
  final EdgeInsetsGeometry? padding;

  /// Optional diameter of the numbered badge circle. Defaults to [AppSize.iconDefault].
  final double? badgeSize;

  /// Optional text style for item title. Defaults to [TextTheme.titleSmall].
  final TextStyle? titleStyle;

  /// Optional text style for item description. Defaults to [TextTheme.bodySmall].
  final TextStyle? descriptionStyle;

  /// Optional gap between badge and title. Defaults to [AppSpace.stackItem].
  final double? gapBadgeToTitle;

  /// Optional gap between title and description. Defaults to [AppSpace.stackTight].
  final double? gapTitleToDescription;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    final effectiveBadgeSize = badgeSize ?? sizes.iconDefault;
    final effectiveTitleGap = gapBadgeToTitle ?? space.stackItem;
    final effectiveDescGap = gapTitleToDescription ?? space.stackTight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: space.inlineItem),
            Expanded(
              child: Container(
                padding: padding ?? space.insetCard,
                decoration: BoxDecoration(
                  color: colors.brandCardBackground,
                  borderRadius: shape.radiusSurface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: effectiveBadgeSize,
                      height: effectiveBadgeSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.brandOnSurface,
                      ),
                      child: Text(
                        items[i].$1,
                        style: context.text.labelSmall?.copyWith(
                          fontSize: effectiveBadgeSize * 0.5,
                          fontWeight: TypeScale.bold,
                          color: colors.brandPrimary,
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: effectiveTitleGap),
                    Text(
                      items[i].$2,
                      style: (titleStyle ?? context.text.titleSmall)?.copyWith(
                        fontWeight: TypeScale.bold,
                        color: colors.brandOnSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: effectiveDescGap),
                    Text(
                      items[i].$3,
                      style: (descriptionStyle ?? context.text.bodySmall)?.copyWith(
                        color: colors.brandSecondaryBody,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
