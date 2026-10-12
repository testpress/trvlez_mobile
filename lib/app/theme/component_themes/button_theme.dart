import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

FilledButtonThemeData buildFilledButtonTheme(AppColors colors) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 15,
        fontWeight: TypeScale.semiBold,
      ),
      elevation: 0,
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(AppColors colors) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 15,
        fontWeight: TypeScale.semiBold,
      ),
      elevation: 0,
    ),
  );
}

OutlinedButtonThemeData buildOutlinedButtonTheme(AppColors colors) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48),
      foregroundColor: colors.textPrimary,
      side: BorderSide(color: colors.borderSubtle),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: TypeScale.semiBold,
      ),
    ),
  );
}

TextButtonThemeData buildTextButtonTheme(AppColors colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colors.actionPrimary,
      textStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: TypeScale.semiBold,
      ),
    ),
  );
}
