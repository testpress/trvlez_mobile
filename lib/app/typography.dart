import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic typography tokens for TrvlEz app.
///
/// We use GoogleFonts.nunito for headings/labels and GoogleFonts.cabin for body text.
class AppTypography {
  const AppTypography._();

  static TextStyle get heading => GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
  );

  static TextStyle get body => GoogleFonts.cabin(
    fontWeight: FontWeight.w400,
  );

  static TextStyle get label => GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
  );

  /// Generates the standard TextTheme using the provided foreground color.
  static TextTheme createTextTheme(Color foregroundColor) {
    return GoogleFonts.cabinTextTheme().copyWith(
      // Headings — Nunito bold
      displayLarge: heading.copyWith(fontSize: 50, color: foregroundColor),
      displayMedium: heading.copyWith(fontSize: 36, color: foregroundColor),
      displaySmall: heading.copyWith(fontSize: 30, color: foregroundColor),
      headlineLarge: heading.copyWith(fontSize: 34, color: foregroundColor),
      headlineMedium: heading.copyWith(fontSize: 28, color: foregroundColor),
      headlineSmall: heading.copyWith(fontSize: 24, color: foregroundColor),
      titleLarge: heading.copyWith(fontSize: 20, color: foregroundColor),
      titleMedium: heading.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: foregroundColor),
      titleSmall: heading.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: foregroundColor),

      // Body — Cabin
      bodyLarge: body.copyWith(fontSize: 16, color: foregroundColor),
      bodyMedium: body.copyWith(fontSize: 14, color: foregroundColor),
      bodySmall: body.copyWith(fontSize: 12, color: foregroundColor),

      // Labels — Nunito bold
      labelLarge: label.copyWith(fontSize: 14, color: foregroundColor),
      labelMedium: label.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: foregroundColor),
      labelSmall: label.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: foregroundColor),
    );
  }
}
