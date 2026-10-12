import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Form text field with label and pill styling on a light surface.
class BookingLightField extends StatelessWidget {
  const BookingLightField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.0,
              fontWeight: TypeScale.medium,
              color: colors.inkSecondary,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 48.0),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: AppRadius.pillRadius,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            cursorColor: colors.brandPrimary,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.0,
              fontWeight: TypeScale.medium,
              color: colors.ink,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14.0,
                color: colors.textDisabled,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
