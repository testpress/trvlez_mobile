import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/component_themes/button_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/card_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/input_theme.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';

/// TrvlEz centralized theme system.
///
/// Builds Material 3 [ThemeData] with registered [AppColors] extension,
/// semantic typography, and component themes.
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

  static ThemeData buildTheme(ColorScheme colorScheme, AppColors colors) {
    final textTheme = AppTypography.createTextTheme(colors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),

      // ── Input Fields ──────────────────────────────────────────────
      inputDecorationTheme: buildInputTheme(colors),

      // ── Buttons ───────────────────────────────────────────────────
      filledButtonTheme: buildFilledButtonTheme(colors),
      elevatedButtonTheme: buildElevatedButtonTheme(colors),
      outlinedButtonTheme: buildOutlinedButtonTheme(colors),
      textButtonTheme: buildTextButtonTheme(colors),

      // ── Cards ─────────────────────────────────────────────────────
      cardTheme: buildCardTheme(colors),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

/// Notifier to manage the application's [ThemeMode].
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(settingsRepositoryProvider).getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

/// Provider for the application's [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
