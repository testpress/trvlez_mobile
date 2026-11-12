import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/component_themes/button_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/card_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/input_theme.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/design_tokens/tokens.dart';

export 'package:trvlez_mobile/app/theme/text_scale_notifier.dart';
export 'package:trvlez_mobile/app/theme/theme_mode_notifier.dart';

/// TrvlEz centralized theme system.
///
/// Builds Material 3 [ThemeData] with registered semantic extensions:
/// [AppColors], [AppSpace], [AppSize], [AppShape], typography, and component themes.
class AppTheme {
  const AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────

  static ThemeData get lightTheme {
    const colors = AppColors.light;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.actionPrimary,
      onPrimary: colors.textOnAction,
      secondary: colors.actionSecondary,
      onSecondary: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: colors.feedbackError,
      onError: AppColors.white,
      outline: colors.borderDefault,
      outlineVariant: colors.borderSubtle,
      surfaceContainerHighest: colors.surfaceSubtle,
    );

    return buildTheme(colorScheme, colors);
  }

  // ─── Dark Theme ────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const colors = AppColors.dark;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.actionPrimary,
      onPrimary: colors.textOnAction,
      secondary: colors.actionSecondary,
      onSecondary: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: colors.feedbackError,
      onError: AppColors.white,
      outline: colors.borderDefault,
      outlineVariant: colors.borderSubtle,
      surfaceContainerHighest: colors.surfaceSubtle,
    );

    return buildTheme(colorScheme, colors);
  }

  // ─── Shared Theme Builder ─────────────────────────────────────────

  static ThemeData buildTheme(
    ColorScheme colorScheme,
    AppColors colors, {
    AppSpace space = AppSpace.comfortable,
    AppSize size = AppSize.regular,
    AppShape shape = AppShape.standard,
  }) {
    final textTheme = AppTypography.createTextTheme(colors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors, space, size, shape],
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),

      // ── Input Fields ──────────────────────────────────────────────
      inputDecorationTheme: buildInputTheme(colors, space: space, shape: shape),

      // ── Buttons ───────────────────────────────────────────────────
      filledButtonTheme: buildFilledButtonTheme(
        colors,
        space: space,
        size: size,
        shape: shape,
      ),
      elevatedButtonTheme: buildElevatedButtonTheme(
        colors,
        space: space,
        size: size,
        shape: shape,
      ),
      outlinedButtonTheme: buildOutlinedButtonTheme(
        colors,
        space: space,
        size: size,
        shape: shape,
      ),
      textButtonTheme: buildTextButtonTheme(
        colors,
        space: space,
        size: size,
        shape: shape,
      ),

      // ── Cards ─────────────────────────────────────────────────────
      cardTheme: buildCardTheme(colors, shape: shape),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: shape.dividerDefault,
        space: 0,
      ),
    );
  }
}
