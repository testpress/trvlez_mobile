import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Label above a pill-shaped picker field or multiline note input.
class CheckInField extends StatelessWidget {
  const CheckInField({
    super.key,
    required this.label,
    required this.value,
    this.filled = true,
    this.tall = false,
    this.onTap,
    this.controller,
    this.hint,
  });

  final String label;
  final String value;
  final bool filled;
  final bool tall;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md - 2,
            bottom: AppSpacing.xs + 2,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.semiBold,
              color: colors.brandSecondary,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: tall ? 64 : 40,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md - 3,
              vertical: tall ? AppSpacing.sm : 0,
            ),
            alignment: tall ? Alignment.topLeft : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: colors.brandFieldBackground,
              borderRadius: BorderRadius.circular(
                tall ? AppRadius.md : AppRadius.pill,
              ),
            ),
            child: Row(
              crossAxisAlignment: tall
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: tall && controller != null
                      ? TextField(
                          controller: controller,
                          maxLines: 3,
                          minLines: 3,
                          cursorColor: colors.brandOnSurface,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: colors.brandOnSurface,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: hint,
                            hintStyle: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: colors.brandSecondaryPlaceholder,
                            ),
                          ),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: filled
                                ? colors.brandOnSurface
                                : colors.brandSecondaryPlaceholder,
                          ),
                        ),
                ),
                if (!tall) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    AppIcons.chevronDown,
                    size: 13,
                    color: colors.brandSecondaryPlaceholder,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
