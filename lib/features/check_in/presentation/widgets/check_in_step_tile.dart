import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Where a step in the check-in list has progressed to.
enum CheckInStepState {
  /// Step is completed: white circle with check mark.
  done,

  /// Step is currently active: highlighted panel with border and chevron.
  now,

  /// Step is pending: translucent styling.
  todo,
}

/// One actionable or informational row in the check-in 4-step sequence.
class CheckInStepTile extends StatelessWidget {
  const CheckInStepTile({
    super.key,
    required this.number,
    required this.state,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final int number;
  final CheckInStepState state;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNow = state == CheckInStepState.now;
    final isDone = state == CheckInStepState.done;

    return Semantics(
      button: isNow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isNow ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: isNow ? colors.checkInStepPanelNow : colors.checkInStepPanel,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: isNow
                ? Border.all(color: colors.brandOnSurface, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isDone || isNow)
                      ? colors.brandOnSurface
                      : colors.checkInStepPanelNow,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? Icon(AppIcons.check, size: 14, color: colors.brandPrimary)
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: TypeScale.bold,
                          color: isNow
                              ? colors.brandActionLabel
                              : colors.brandOnSurface,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
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
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNow) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  AppIcons.chevronRight,
                  size: 15,
                  color: colors.brandOnSurface,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
