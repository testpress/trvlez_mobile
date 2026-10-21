import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Numbered pointer cards under diagrams (e.g., 1. Whole visa, 2. The dates).
class BrandPointerPair extends StatelessWidget {
  const BrandPointerPair({super.key, required this.items});

  /// Triples of (badgeNumber, title, description).
  final List<(String, String, String)> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: space.inlineIconLabel),
            Expanded(
              child: Container(
                padding: space.insetTag,
                decoration: BoxDecoration(
                  color: colors.brandCardBackground,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: sizes.iconSm,
                      height: sizes.iconSm,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.brandSecondary,
                      ),
                      child: Text(
                        items[i].$1,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 10.0,
                          fontWeight: TypeScale.bold,
                          color: colors.brandActionLabel,
                          height: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: space.stackTight),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      items[i].$3,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        color: colors.brandSecondaryBody,
                        height: 1.25,
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
