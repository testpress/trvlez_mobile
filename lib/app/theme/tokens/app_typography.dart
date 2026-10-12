import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Semantic typography tokens and text theme builders.
///
/// Typography uses the client design font (Poppins) loaded locally.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = TypeScale.fontFamily;

  static TextStyle get heading =>
      const TextStyle(fontFamily: fontFamily, fontWeight: TypeScale.bold);

  static TextStyle get body =>
      const TextStyle(fontFamily: fontFamily, fontWeight: TypeScale.regular);

  static TextStyle get label =>
      const TextStyle(fontFamily: fontFamily, fontWeight: TypeScale.semiBold);

  /// Generates the standard [TextTheme] bound to [AppColors.textPrimary].
  static TextTheme buildTextTheme(AppColors colors) {
    return createTextTheme(colors.textPrimary);
  }

  /// Generates the standard [TextTheme] using the provided [foregroundColor].
  static TextTheme createTextTheme(Color foregroundColor) {
    return TextTheme(
      // Headings & Displays
      displayLarge: heading.copyWith(
        fontSize: 36,
        color: foregroundColor,
        letterSpacing: -0.5,
      ),
      displayMedium: heading.copyWith(
        fontSize: 30,
        color: foregroundColor,
        letterSpacing: -0.25,
      ),
      displaySmall: heading.copyWith(fontSize: 24, color: foregroundColor),
      headlineLarge: heading.copyWith(
        fontSize: 22,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      headlineMedium: heading.copyWith(
        fontSize: 20,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      headlineSmall: heading.copyWith(
        fontSize: 18,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),

      // Titles
      titleLarge: heading.copyWith(
        fontSize: 16,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      titleMedium: heading.copyWith(
        fontSize: 15,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      titleSmall: heading.copyWith(
        fontSize: 13,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),

      // Body
      bodyLarge: body.copyWith(
        fontSize: 15,
        color: foregroundColor,
        height: 1.45,
      ),
      bodyMedium: body.copyWith(
        fontSize: 13,
        color: foregroundColor,
        height: 1.4,
      ),
      bodySmall: body.copyWith(
        fontSize: 11,
        color: foregroundColor,
        height: 1.35,
      ),

      // Labels
      labelLarge: label.copyWith(
        fontSize: 14,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
        letterSpacing: 0.2,
      ),
      labelMedium: label.copyWith(
        fontSize: 12,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),
      labelSmall: label.copyWith(
        fontSize: 10,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),
    );
  }
}
