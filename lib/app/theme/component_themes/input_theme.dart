import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

InputDecorationTheme buildInputTheme(AppColors colors) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.surfaceSubtle,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 14,
      fontWeight: TypeScale.regular,
    ).copyWith(color: colors.textDisabled),
    labelStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 13,
      fontWeight: TypeScale.medium,
    ).copyWith(color: colors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.borderSubtle),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.borderSubtle),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.borderFocused, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.feedbackError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.feedbackError, width: 1.5),
    ),
    errorStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: TypeScale.regular,
    ).copyWith(color: colors.feedbackError),
  );
}
