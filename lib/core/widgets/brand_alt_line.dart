import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The alternative action line at the foot of brand screens
/// (e.g., "Already have an account? Log in").
class BrandAltLine extends StatelessWidget {
  const BrandAltLine({
    super.key,
    this.prefix,
    required this.linkText,
    required this.onTap,
    this.fontSize,
    this.underlineColor,
  });

  /// Optional prefix label like "Already have an account? "
  final String? prefix;

  /// Tappable link text like "Log in"
  final String linkText;

  /// Callback when the link is tapped
  final VoidCallback onTap;

  /// Optional font size override for the line. Defaults to [TextTheme.labelLarge].
  final double? fontSize;

  /// Optional underline color override
  final Color? underlineColor;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final shape = context.shape;

    final effectiveFontSize = fontSize ?? context.text.labelLarge?.fontSize;

    final prefixStyle = (context.text.labelLarge ?? const TextStyle()).copyWith(
      fontSize: effectiveFontSize,
      fontWeight: TypeScale.regular,
      color: context.colors.brandSecondaryBody,
    );

    final linkStyle = (context.text.labelLarge ?? const TextStyle()).copyWith(
      fontSize: effectiveFontSize,
      fontWeight: TypeScale.semiBold,
      color: context.colors.brandOnSurface,
    );

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix case final prefixText?) ...[
              Text(prefixText, style: prefixStyle),
              SizedBox(width: space.inlineMicro),
            ],
            Semantics(
              button: true,
              label: linkText,
              child: InkWell(
                onTap: onTap,
                borderRadius: shape.radiusSubtle,
                child: Padding(
                  padding: space.insetTagSm,
                  child: Container(
                    padding: EdgeInsets.only(bottom: shape.borderDefault),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              underlineColor ?? context.colors.brandUnderline,
                          width: shape.borderDefault,
                        ),
                      ),
                    ),
                    child: Text(linkText, style: linkStyle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
