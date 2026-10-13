import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Red-surface consent checkbox.
class CheckInConsentTick extends StatelessWidget {
  const CheckInConsentTick({
    super.key,
    required this.agreed,
    required this.label,
    required this.onTap,
    this.marginTop = AppSpacing.md - 2,
  });

  final bool agreed;
  final String label;
  final VoidCallback onTap;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      checked: agreed,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: marginTop),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 19,
                height: 19,
                margin: const EdgeInsets.only(top: 1.5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: agreed ? colors.brandOnSurface : null,
                  border: Border.all(
                    color: agreed ? colors.brandOnSurface : colors.checkInConsentBox,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xs + 1),
                ),
                child: agreed
                    ? Icon(
                        AppIcons.check,
                        size: 13,
                        color: colors.brandActionLabel,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: TypeScale.regular,
                    color: colors.brandSecondary,
                    height: 1.35,
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
