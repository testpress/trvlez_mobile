import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final isNow = state == CheckInStepState.now;
    final isDone = state == CheckInStepState.done;

    return Semantics(
      button: isNow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isNow ? onTap : null,
        child: Container(
          margin: EdgeInsets.only(top: space.stackItem),
          padding: space.insetCardCompact,
          decoration: BoxDecoration(
            color: isNow ? colors.checkInStepPanelNow : colors.checkInStepPanel,
            borderRadius: shape.radiusControl,
            border: isNow
                ? Border.all(
                    color: colors.brandOnSurface,
                    width: shape.borderMedium,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: sizes.avatarSm,
                height: sizes.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isDone || isNow)
                      ? colors.brandOnSurface
                      : colors.checkInStepPanelNow,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? Icon(
                        AppIcons.check,
                        size: sizes.iconXs,
                        color: colors.brandPrimary,
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: TypeScale.bold,
                          color: isNow
                              ? colors.brandActionLabel
                              : colors.brandOnSurface,
                        ),
                      ),
              ),
              SizedBox(width: space.inlineButtonGroup),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNow) ...[
                SizedBox(width: space.inlineMicro),
                Icon(
                  AppIcons.chevronRight,
                  size: sizes.iconSm,
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
