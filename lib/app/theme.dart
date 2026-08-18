import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/core/storage/settings_repository.dart';

import 'package:trvlez_mobile/app/colors.dart';
import 'package:trvlez_mobile/app/typography.dart';
/// TrvlEz app theme ported from the Next.js design system.
///
/// Fonts: Nunito (headings/bold), Cabin (body), Inter (brand).
/// Colors: Red primary, slate neutral scale, semantic status colors.
class AppTheme {
  const AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colors = AppColors.light;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      surface: colors.surface,
      onSurface: colors.foreground,
      error: colors.error,
      onError: AppColors.white,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      surfaceContainerHighest: colors.backgroundMuted,
    );

    return buildTheme(colorScheme, colors);
  }

  // ─── Dark Theme ────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final colors = AppColors.dark;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      surface: colors.surface,
      onSurface: colors.foreground,
      error: colors.error,
      onError: AppColors.white,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      surfaceContainerHighest: colors.backgroundMuted,
    );

    return buildTheme(colorScheme, colors);
  }

  // ─── Shared Theme Builder ─────────────────────────────────────────

  static ThemeData buildTheme(ColorScheme colorScheme, dynamic colors) {
    // Generate TextTheme via typography layer
    final textTheme = AppTypography.createTextTheme(colors.foregroundStrong);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.foregroundStrong,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.foregroundStrong,
        ),
      ),

      // ── Input fields (54px height, rounded-xl, subtle border) ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.cabin(
          fontSize: 15,
          color: colors.foregroundPlaceholder,
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.foregroundStrong,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        errorStyle: GoogleFonts.cabin(fontSize: 12, color: colors.error),
      ),

      // ── Primary filled button (56px height, rounded-xl) ────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ── Elevated button (same as filled for consistency) ───────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ── Outlined button (secondary style) ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          foregroundColor: colors.foregroundStrong,
          side: BorderSide(color: colors.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.cabin(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────
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
