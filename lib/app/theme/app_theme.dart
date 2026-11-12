import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/component_themes/button_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/card_theme.dart';
import 'package:trvlez_mobile/app/theme/component_themes/input_theme.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/design_tokens/tokens.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';

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
        titleTextStyle: AppTypography.heading.copyWith(
          fontSize: 18,
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

/// Notifier to manage the application's [ThemeMode].
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    try {
      return ref.watch(settingsRepositoryProvider).getThemeMode();
    } catch (_) {
      return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(settingsRepositoryProvider).setThemeMode(mode);
    } catch (_) {}
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

/// Notifier managing the active [TextScalePreset].
class TextScaleNotifier extends Notifier<TextScalePreset> {
  @override
  TextScalePreset build() {
    try {
      return ref.watch(settingsRepositoryProvider).getTextScalePreset();
    } catch (_) {
      return TextScalePreset.followSystem;
    }
  }

  Future<void> setTextScalePreset(TextScalePreset preset) async {
    state = preset;
    try {
      await ref.read(settingsRepositoryProvider).setTextScalePreset(preset);
    } catch (_) {}
  }
}

/// Provider for the application's active [TextScalePreset].
final textScaleNotifierProvider =
    NotifierProvider<TextScaleNotifier, TextScalePreset>(() {
      return TextScaleNotifier();
    });
