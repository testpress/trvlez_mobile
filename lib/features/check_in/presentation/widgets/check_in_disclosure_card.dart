import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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
    this.marginTop = AppSpacing.sm + 3,
  });

  final String title;
  final List<CheckInDisclosureLine> lines;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(top: marginTop),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 3,
        vertical: AppSpacing.sm + 3,
      ),
      decoration: BoxDecoration(
        color: colors.checkInStepPanel,
        borderRadius: BorderRadius.circular(AppRadius.md + 1),
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
          const SizedBox(height: AppSpacing.sm + 1),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm - 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1.5),
                  child: Icon(
                    lines[i].shared ? AppIcons.check : AppIcons.eyeOff,
                    size: 13,
                    color: lines[i].shared
                        ? colors.brandOnSurface
                        : colors.checkInDisclosureDimIcon,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
