import 'package:flutter/material.dart';

/// Raw color palette and semantic tokens ported from the TrvlEz Next.js
/// design system ([globals.css] `:root` and `[data-theme="dark"]`).
///
/// Usage: reference via `AppColors.light.*` or `AppColors.dark.*`, or let
/// [AppTheme] wire them into `ColorScheme` automatically.
class AppColors {
  const AppColors._();

  // ─── Feature Grid Gradients ──────────────────────────────────────────
  static const List<Color> exploreGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  static const List<Color> tripsGradient = [
    Color(0xFF0EA5E9),
    Color(0xFF38BDF8),
  ];
  static const List<Color> dealsGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
  static const List<Color> supportGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  // ─── Raw Palette (Primitives) ──────────────────────────────────────

  // Reds
  static const Color red500 = Color(0xFFE42C3A);
  static const Color red600 = Color(0xFFD61F26);

  // Slates (light mode)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF6F6F6);
  static const Color slate150 = Color(0xFFF2F2F2);
  static const Color slate200 = Color(0xFFE6E6E6);
  static const Color slate300 = Color(0xFFC9C8C8);
  static const Color slate800 = Color(0xFF3A3A3A);
  static const Color slate900 = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0277BD);

  // ─── Light Theme Semantic Tokens ───────────────────────────────────

  static const LightColors light = LightColors();

  // ─── Dark Theme Semantic Tokens ────────────────────────────────────

  static const DarkColors dark = DarkColors();
}

/// Semantic color tokens for the **light** theme.
class LightColors {
  const LightColors();

  // Core
  Color get primary => AppColors.red600;
  Color get primaryHover => AppColors.red500;
  Color get primaryForeground => AppColors.white;

  // Secondary
  Color get secondary => AppColors.slate150;
  Color get secondaryForeground => AppColors.slate800;

  // Background
  Color get background => AppColors.slate50;
  Color get backgroundSubtle => AppColors.slate100;
  Color get backgroundMuted => AppColors.slate150;
  Color get backgroundInverse => AppColors.slate900;

  // Foreground (text)
  Color get foreground => AppColors.slate800;
  Color get foregroundStrong => AppColors.slate900;
  Color get foregroundMuted => AppColors.slate800;
  Color get foregroundInverse => AppColors.white;
  Color get foregroundDisabled => AppColors.slate300;
  Color get foregroundPlaceholder => AppColors.slate300;

  // Surface
  Color get surface => AppColors.white;
  Color get surfaceHover => AppColors.slate50;
  Color get surfaceElevated => AppColors.white;

  // Border
  Color get border => AppColors.slate300;
  Color get borderSubtle => AppColors.slate200;
  Color get borderStrong => AppColors.slate800;
  Color get borderFocus => AppColors.red600;
  Color get borderMuted => AppColors.slate100;

  // Status
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get error => AppColors.error;
  Color get info => AppColors.info;
}

/// Semantic color tokens for the **dark** theme.
class DarkColors {
  const DarkColors();

  // Core
  Color get primary => const Color(0xFFEF4444);
  Color get primaryHover => const Color(0xFFF87171);
  Color get primaryForeground => AppColors.white;

  // Secondary
  Color get secondary => const Color(0xFF334155);
  Color get secondaryForeground => const Color(0xFFCBD5E1);

  // Background
  Color get background => const Color(0xFF0F172A);
  Color get backgroundSubtle => const Color(0xFF1E293B);
  Color get backgroundMuted => const Color(0xFF334155);
  Color get backgroundInverse => const Color(0xFF020617);

  // Foreground (text)
  Color get foreground => const Color(0xFFCBD5E1);
  Color get foregroundStrong => const Color(0xFFF1F5F9);
  Color get foregroundMuted => const Color(0xFFCBD5E1);
  Color get foregroundInverse => const Color(0xFFF1F5F9);
  Color get foregroundDisabled => const Color(0xFF475569);
  Color get foregroundPlaceholder => const Color(0xFF475569);

  // Surface
  Color get surface => const Color(0xFF0F172A);
  Color get surfaceHover => const Color(0xFF1E293B);
  Color get surfaceElevated => const Color(0xFF0F172A);

  // Border
  Color get border => const Color(0xFF475569);
  Color get borderSubtle => const Color(0xFF3E4C5E);
  Color get borderStrong => const Color(0xFFCBD5E1);
  Color get borderFocus => const Color(0xFFEF4444);
  Color get borderMuted => const Color(0xFF1E293B);

  // Status
  Color get success => const Color(0xFF4CAF50);
  Color get warning => const Color(0xFFFF9800);
  Color get error => const Color(0xFFEF5350);
  Color get info => const Color(0xFF29B6F6);
}
