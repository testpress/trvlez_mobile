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

  /// Semantic typography token for button labels adhering to the typography scale.
  static TextStyle get buttonLabel => label.copyWith(
    fontSize: TypeScale.s15,
    fontWeight: TypeScale.semiBold,
    letterSpacing: 0.2,
  );

  /// Semantic typography token for brand screen main headings.
  static TextStyle get brandHeading => heading.copyWith(
    fontSize: TypeScale.s26,
    fontWeight: TypeScale.bold,
  );

  /// Semantic typography token for brand screen subheadings.
  static TextStyle get brandSubtitle => body.copyWith(
    fontSize: TypeScale.s16,
    fontWeight: TypeScale.medium,
    height: 1.45,
  );

  /// Generates the standard [TextTheme] bound to [AppColors.textPrimary].
  static TextTheme buildTextTheme(AppColors colors) {
    return createTextTheme(colors.textPrimary);
  }

  /// Generates the standard [TextTheme] using the provided [foregroundColor].
  static TextTheme createTextTheme(Color foregroundColor) {
    return TextTheme(
      // Headings & Displays
      displayLarge: heading.copyWith(
        fontSize: TypeScale.s36,
        color: foregroundColor,
        letterSpacing: -0.5,
      ),
      displayMedium: heading.copyWith(
        fontSize: TypeScale.s30,
        color: foregroundColor,
        letterSpacing: -0.25,
      ),
      displaySmall: heading.copyWith(
        fontSize: TypeScale.s24,
        color: foregroundColor,
      ),
      headlineLarge: heading.copyWith(
        fontSize: TypeScale.s26,
        fontWeight: TypeScale.bold,
        color: foregroundColor,
      ),
      headlineMedium: heading.copyWith(
        fontSize: TypeScale.s20,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      headlineSmall: heading.copyWith(
        fontSize: TypeScale.s18,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),

      // Titles
      titleLarge: heading.copyWith(
        fontSize: TypeScale.s16,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      titleMedium: heading.copyWith(
        fontSize: TypeScale.s15,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
      ),
      titleSmall: heading.copyWith(
        fontSize: TypeScale.s13,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),

      // Body
      bodyLarge: body.copyWith(
        fontSize: TypeScale.s16,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
        height: 1.45,
      ),
      bodyMedium: body.copyWith(
        fontSize: TypeScale.s13,
        color: foregroundColor,
        height: 1.4,
      ),
      bodySmall: body.copyWith(
        fontSize: TypeScale.s11,
        color: foregroundColor,
        height: 1.35,
      ),

      // Labels
      labelLarge: label.copyWith(
        fontSize: TypeScale.s14,
        fontWeight: TypeScale.semiBold,
        color: foregroundColor,
        letterSpacing: 0.2,
      ),
      labelMedium: label.copyWith(
        fontSize: TypeScale.s12,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),
      labelSmall: label.copyWith(
        fontSize: TypeScale.s10,
        fontWeight: TypeScale.medium,
        color: foregroundColor,
      ),
    );
  }
}
