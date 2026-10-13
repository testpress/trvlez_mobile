import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Interactive result or action row on red surface.
class AnywhereRow extends StatelessWidget {
  const AnywhereRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    this.chevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final bool chevron;
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
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: colors.checkInStepPanel,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.checkInRingPanel,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 14, color: colors.brandOnSurface),
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
                        fontWeight: TypeScale.bold,
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
              if (tag != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.checkInRingPanel,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: TypeScale.bold,
                      color: colors.brandOnSurface,
                    ),
                  ),
                ),
              ] else if (chevron) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  AppIcons.chevronRight,
                  size: 16,
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

/// Form field label on red surface.
class AnywhereLabel extends StatelessWidget {
  const AnywhereLabel({super.key, required this.text, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
              ),
            ),
            if (hint != null)
              TextSpan(
                text: ' · $hint',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  color: colors.brandSecondarySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Text input field on red surface with optional leading icon and clear button.
class AnywhereField extends StatelessWidget {
  const AnywhereField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.icon,
    this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final IconData? icon;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.brandFieldBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.brandBorderSubtle, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 13,
          fontWeight: TypeScale.medium,
          color: colors.brandOnSurface,
        ),
        cursorColor: colors.brandOnSurface,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            color: colors.brandSecondaryPlaceholder,
          ),
          prefixIcon: icon != null
              ? Icon(icon, size: 16, color: colors.brandSecondaryBody)
              : null,
          suffixIcon: onClear != null && controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    AppIcons.x,
                    size: 14,
                    color: colors.brandSecondaryBody,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4,
          ),
        ),
      ),
    );
  }
}
