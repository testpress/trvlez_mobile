import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

InputDecorationTheme buildInputTheme(AppColors colors) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.surfaceSubtle,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: GoogleFonts.cabin(fontSize: 15, color: colors.textDisabled),
    labelStyle: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    ),
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
      borderSide: BorderSide(color: colors.borderFocused, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.feedbackError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: colors.feedbackError, width: 2),
    ),
    errorStyle: GoogleFonts.cabin(fontSize: 12, color: colors.feedbackError),
  );
}
