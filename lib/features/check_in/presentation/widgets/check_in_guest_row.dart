import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// One guest on the "Who's staying" check-in screen.
class CheckInGuestRow extends StatelessWidget {
  const CheckInGuestRow({
    super.key,
    required this.initials,
    required this.name,
    required this.detail,
    required this.chip,
    required this.ready,
    this.onTap,
  });

  /// Null displays generic user icon (for uninvited guests).
  final String? initials;
  final String name;
  final String detail;
  final String chip;
  final bool ready;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm + 1),
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: colors.checkInStepPanel,
            borderRadius: BorderRadius.circular(AppRadius.md + 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ready ? colors.brandOnSurface : colors.checkInGuestAvatar,
                  shape: BoxShape.circle,
                ),
                child: initials == null
                    ? Icon(
                        AppIcons.user,
                        size: 16,
                        color: ready ? colors.brandPrimary : colors.brandOnSurface,
                      )
                    : Text(
                        initials!,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: TypeScale.bold,
                          color: ready ? colors.brandActionLabel : colors.brandOnSurface,
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
                      name,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: ready ? colors.brandOnSurface : colors.checkInGuestAvatar,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  chip,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: TypeScale.bold,
                    color: ready ? colors.brandActionLabel : colors.brandOnSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
