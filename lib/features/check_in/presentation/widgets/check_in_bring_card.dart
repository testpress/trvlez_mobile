import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Single item in "Take with you" list.
class CheckInBringLine {
  const CheckInBringLine({
    required this.icon,
    required this.lead,
    required this.strong,
  });

  final IconData icon;
  final String lead;
  final String strong;
}

/// What to bring to the reception desk if online check-in is declined.
class CheckInBringCard extends StatelessWidget {
  const CheckInBringCard({
    super.key,
    required this.title,
    required this.lines,
    this.marginTop = AppSpacing.md,
  });

  final String title;
  final List<CheckInBringLine> lines;
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
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  lines[i].icon,
                  size: 14,
                  color: colors.brandSecondary,
                ),
                const SizedBox(width: AppSpacing.sm + 1),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: lines[i].lead,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            color: colors.brandSecondaryBody,
                          ),
                        ),
                        TextSpan(
                          text: lines[i].strong,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: TypeScale.bold,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      ],
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
