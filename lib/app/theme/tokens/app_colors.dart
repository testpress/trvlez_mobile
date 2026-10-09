import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/palette.dart';

/// Semantic color tokens implementing [ThemeExtension] for dynamic theme switching.
///
/// Features consume these tokens via `context.colors.<token>`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnAction,
    required this.borderDefault,
    required this.borderFocused,
    required this.borderSubtle,
    required this.actionPrimary,
    required this.actionSecondary,
    required this.feedbackSuccess,
    required this.feedbackError,
    required this.feedbackWarning,
    required this.feedbackInfo,
    this.background,
  });

  // ─── Surfaces ────────────────────────────────────────────────────────
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSubtle;
  final Color? background;

  // ─── Typography & Foregrounds ─────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnAction;

  // ─── Borders ─────────────────────────────────────────────────────────
  final Color borderDefault;
  final Color borderFocused;
  final Color borderSubtle;

  // ─── Actions ─────────────────────────────────────────────────────────
  final Color actionPrimary;
  final Color actionSecondary;

  // ─── Feedback & Status ───────────────────────────────────────────────
  final Color feedbackSuccess;
  final Color feedbackError;
  final Color feedbackWarning;
  final Color feedbackInfo;

  // ─── Legacy Compatibility Getters ────────────────────────────────────
  Color get primary => actionPrimary;
  Color get primaryForeground => textOnAction;
  Color get secondary => actionSecondary;
  Color get secondaryForeground => textPrimary;
  Color get foreground => textPrimary;
  Color get foregroundStrong => textPrimary;
  Color get foregroundMuted => textSecondary;
  Color get foregroundDisabled => textDisabled;
  Color get foregroundPlaceholder => textDisabled;
  Color get border => borderDefault;
  Color get borderFocus => borderFocused;
  Color get backgroundMuted => surfaceSubtle;

  // ─── Static Feature Gradients & Constants ────────────────────────────
  static const Color white = Palette.neutral0;
  static const Color red500 = Palette.red500;
  static const Color red600 = Palette.red600;
  static const Color successColor = Palette.green600;
  static const Color errorColor = Palette.red600;
  static const Color warningColor = Palette.orange500;
  static const Color infoColor = Palette.blue700;

  // Kept for direct static references during migration
  static const Color success = Palette.green600;
  static const Color warning = Palette.orange500;
  static const Color error = Palette.red600;
  static const Color info = Palette.blue700;

  static const List<Color> exploreGradient = [
    Palette.indigo500,
    Palette.purple500,
  ];
  static const List<Color> tripsGradient = [Palette.sky500, Palette.blue400];
  static const List<Color> dealsGradient = [Palette.amber500, Palette.amber400];
  static const List<Color> supportGradient = [
    Palette.emerald500,
    Palette.emerald400,
  ];

  // ─── Light Preset ───────────────────────────────────────────────────
  static const light = AppColors(
    surface: Palette.neutral0,
    surfaceRaised: Palette.neutral0,
    surfaceSubtle: Palette.neutral50,
    textPrimary: Palette.neutral900,
    textSecondary: Palette.neutral500,
    textDisabled: Palette.neutral300,
    textOnAction: Palette.neutral0,
    borderDefault: Palette.neutral200,
    borderFocused: Palette.red600,
    borderSubtle: Palette.neutral150,
    actionPrimary: Palette.red600,
    actionSecondary: Palette.neutral150,
    feedbackSuccess: Palette.green600,
    feedbackError: Palette.red600,
    feedbackWarning: Palette.orange500,
    feedbackInfo: Palette.blue700,
    background: Palette.neutral50,
  );

  // ─── Dark Preset ────────────────────────────────────────────────────
  static const dark = AppColors(
    surface: Palette.neutral900,
    surfaceRaised: Palette.neutral800,
    surfaceSubtle: Palette.neutral950,
    textPrimary: Palette.neutral50,
    textSecondary: Palette.neutral300,
    textDisabled: Palette.neutral600,
    textOnAction: Palette.neutral0,
    borderDefault: Palette.neutral700,
    borderFocused: Palette.red400,
    borderSubtle: Palette.neutral800,
    actionPrimary: Palette.red500,
    actionSecondary: Palette.neutral700,
    feedbackSuccess: Palette.green500,
    feedbackError: Palette.red400,
    feedbackWarning: Palette.amber500,
    feedbackInfo: Palette.blue400,
    background: Palette.neutral900,
  );

  @override
  AppColors copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnAction,
    Color? borderDefault,
    Color? borderFocused,
    Color? borderSubtle,
    Color? actionPrimary,
    Color? actionSecondary,
    Color? feedbackSuccess,
    Color? feedbackError,
    Color? feedbackWarning,
    Color? feedbackInfo,
    Color? background,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnAction: textOnAction ?? this.textOnAction,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocused: borderFocused ?? this.borderFocused,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionSecondary: actionSecondary ?? this.actionSecondary,
      feedbackSuccess: feedbackSuccess ?? this.feedbackSuccess,
      feedbackError: feedbackError ?? this.feedbackError,
      feedbackWarning: feedbackWarning ?? this.feedbackWarning,
      feedbackInfo: feedbackInfo ?? this.feedbackInfo,
      background: background ?? this.background,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceRaised:
          Color.lerp(surfaceRaised, other.surfaceRaised, t) ?? surfaceRaised,
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textDisabled:
          Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      textOnAction:
          Color.lerp(textOnAction, other.textOnAction, t) ?? textOnAction,
      borderDefault:
          Color.lerp(borderDefault, other.borderDefault, t) ?? borderDefault,
      borderFocused:
          Color.lerp(borderFocused, other.borderFocused, t) ?? borderFocused,
      borderSubtle:
          Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      actionPrimary:
          Color.lerp(actionPrimary, other.actionPrimary, t) ?? actionPrimary,
      actionSecondary:
          Color.lerp(actionSecondary, other.actionSecondary, t) ??
          actionSecondary,
      feedbackSuccess:
          Color.lerp(feedbackSuccess, other.feedbackSuccess, t) ??
          feedbackSuccess,
      feedbackError:
          Color.lerp(feedbackError, other.feedbackError, t) ?? feedbackError,
      feedbackWarning:
          Color.lerp(feedbackWarning, other.feedbackWarning, t) ??
          feedbackWarning,
      feedbackInfo:
          Color.lerp(feedbackInfo, other.feedbackInfo, t) ?? feedbackInfo,
      background: Color.lerp(background, other.background, t) ?? background,
    );
  }
}
