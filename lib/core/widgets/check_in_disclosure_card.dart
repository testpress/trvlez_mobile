import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Single item in the disclosure card detailing what is sent or withheld.
class CheckInDisclosureLine {
  const CheckInDisclosureLine(this.text, {this.shared = true});

  final String text;
  final bool shared;
}

/// Translucent card showing sent vs withheld traveler data.
class CheckInDisclosureCard extends StatelessWidget {
  const CheckInDisclosureCard({
    super.key,
    required this.title,
    required this.lines,
    this.marginTop,
  });

  final String title;
  final List<CheckInDisclosureLine> lines;
  final double? marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      margin: EdgeInsets.only(top: marginTop ?? space.stackTight),
      padding: space.insetCardCompact,
      decoration: BoxDecoration(
        color: colors.checkInStepPanel,
        borderRadius: shape.radiusControl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
            ),
          ),
          SizedBox(height: space.stackItem),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) SizedBox(height: space.stackTight),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: shape.borderMedium),
                  child: Icon(
                    lines[i].shared ? AppIcons.check : AppIcons.eyeOff,
                    size: sizes.iconXs,
                    color: lines[i].shared
                        ? colors.brandOnSurface
                        : colors.checkInDisclosureDimIcon,
                  ),
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    lines[i].text,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: TypeScale.regular,
                      color: lines[i].shared
                          ? colors.brandOnSurface
                          : colors.checkInDisclosureDimText,
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
