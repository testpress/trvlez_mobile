import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

FilledButtonThemeData buildFilledButtonTheme(AppColors colors) {
  return FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      elevation: 0,
    ),
  );
}

ElevatedButtonThemeData buildElevatedButtonTheme(AppColors colors) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      elevation: 0,
    ),
  );
}

OutlinedButtonThemeData buildOutlinedButtonTheme(AppColors colors) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      foregroundColor: colors.textPrimary,
      side: BorderSide(color: colors.borderSubtle),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );
}

TextButtonThemeData buildTextButtonTheme(AppColors colors) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: colors.actionPrimary,
      textStyle: GoogleFonts.cabin(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
}
