import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// The alternative action line at the foot of brand screens
/// (e.g., "Already have an account? Log in").
class BrandAltLine extends StatelessWidget {
  const BrandAltLine({
    super.key,
    this.prefix,
    required this.linkText,
    required this.onTap,
    this.fontSize = 12,
    this.underlineColor,
  });

  /// Optional prefix label like "Already have an account? "
  final String? prefix;

  /// Tappable link text like "Log in"
  final String linkText;

  /// Callback when the link is tapped
  final VoidCallback onTap;

  /// Font size for the line
  final double fontSize;

  /// Optional underline color override
  final Color? underlineColor;

  @override
  Widget build(BuildContext context) {
    final prefixStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: TypeScale.regular,
      color: context.colors.brandSecondaryBody,
    );

    final linkStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: TypeScale.semiBold,
      color: context.colors.brandOnSurface,
    );

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix != null) ...[
              Text(prefix!, style: prefixStyle),
              const SizedBox(width: 4),
            ],
            Semantics(
              button: true,
              label: linkText,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 1),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: underlineColor ?? context.colors.brandUnderline,
                          width: 1,
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
