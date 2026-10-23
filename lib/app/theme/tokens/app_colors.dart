import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/palette.dart';

/// Semantic color tokens implementing [ThemeExtension] for dynamic theme switching.
///
/// Features consume these tokens via `context.colors.<token>`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    // Standard Surfaces
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSubtle,
    this.background,

    // Typography & Foregrounds
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnAction,

    // Borders
    required this.borderDefault,
    required this.borderFocused,
    required this.borderSubtle,

    // Actions
    required this.actionPrimary,
    required this.actionSecondary,

    // Feedback & Status
    required this.feedbackSuccess,
    required this.feedbackError,
    required this.feedbackWarning,
    required this.feedbackInfo,

    // Brand / Red Screen Specific Tokens
    required this.brandPrimary,
    required this.brandSurface,
    required this.brandOnSurface,
    required this.brandSecondary,
    required this.brandSecondaryBody,
    required this.brandSecondarySmall,
    required this.brandSecondaryNote,
    required this.brandSecondaryPlaceholder,
    required this.brandActionLabel,
    required this.brandFieldBackground,
    required this.brandButtonDisabledBackground,
    required this.brandButtonDisabledForeground,
    required this.brandCardBackground,
    required this.brandUnderline,
    required this.brandKeyBackground,
    required this.brandDotOutline,
    required this.brandCodeBoxBackground,

    // Verification & Stepper Tokens
    required this.verificationStepActiveText,
    required this.verificationStepInactiveText,
    required this.verificationStepRing,
    required this.verificationStepTrack,
    required this.verificationCardLockedTitle,
    required this.verificationCardLockedSubtitle,
    required this.verificationCardActiveFill,
    required this.verificationCardIconFill,
    required this.verificationProgressTrack,
    required this.verificationChipBackground,
    required this.verificationOutlineButton,
    required this.verificationDivider,

    // Main App Polish & Surfaces
    required this.pageBackground,
    required this.cardBorder,
    required this.cardShadow,
    required this.statusSuccessBackground,
    required this.statusSuccessForeground,
    required this.statusWarningBackground,
    required this.statusWarningForeground,
    required this.statusVerifiedForeground,
    required this.statusVerifiedSubForeground,
    required this.surfaceRedTint,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.line,

    // Paper Palette (Findr)
    required this.paper,
    required this.paperLine,
    required this.paperInk,
    required this.paperInk2,
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

  // ─── Brand / Red Screen Specific Tokens ──────────────────────────────
  final Color brandPrimary;
  final Color brandSurface;
  final Color brandOnSurface;
  final Color brandSecondary; // Cream
  final Color brandSecondaryBody; // Cream body
  final Color brandSecondarySmall; // Cream small
  final Color brandSecondaryNote; // Security note cream
  final Color brandSecondaryPlaceholder; // Placeholder cream
  final Color brandActionLabel; // Red label on white button
  final Color brandFieldBackground; // Pill field fill on red
  final Color brandButtonDisabledBackground; // Inactive button fill on red
  final Color brandButtonDisabledForeground; // Inactive button label on red
  final Color brandCardBackground; // Instruction card fill on red
  final Color brandUnderline; // Link underline on red
  final Color brandKeyBackground; // Keypad key background
  final Color brandDotOutline; // Empty passcode dot outline
  final Color brandCodeBoxBackground; // 2FA code box fill

  // ─── Verification & Stepper Tokens ───────────────────────────────────
  final Color verificationStepActiveText;
  final Color verificationStepInactiveText;
  final Color verificationStepRing;
  final Color verificationStepTrack;
  final Color verificationCardLockedTitle;
  final Color verificationCardLockedSubtitle;
  final Color verificationCardActiveFill;
  final Color verificationCardIconFill;
  final Color verificationProgressTrack;
  final Color verificationChipBackground;
  final Color verificationOutlineButton;
  final Color verificationDivider;

  // ─── Brand Screen Convenience Getters ───────────────────────────────
  Color get brandShotBackdrop => const Color(0x59000000);
  Color get brandScrubTrack => const Color(0x40FFFFFF);
  Color get brandBorderSubtle => const Color(0x59FFFFFF);
  Color get brandDivider => verificationDivider;
  Color get brandCardIconBackground => verificationCardIconFill;

  // ─── Check-in & Hotel Preview Getters (Section 05) ───────────────────
  Color get checkInStepPanel => Palette.stepPanel;
  Color get checkInStepPanelNow => Palette.stepPanelNow;
  Color get checkInFlagPanel => Palette.flagPanel;
  Color get checkInRingPanel => Palette.ringPanel;
  Color get checkInGuestAvatar => Palette.guestAvatar;
  Color get checkInConsentBox => Palette.consentBox;
  Color get checkInDisclosureDimIcon => Palette.disclosureDimIcon;
  Color get checkInDisclosureDimText => Palette.disclosureDimText;
  Color get checkInPassRef => Palette.passRef;

  Color get hotelScreen => Palette.hotelScreen;
  Color get hotelLabel => Palette.hotelLabel;
  Color get hotelMeta => Palette.hotelMeta;
  Color get hotelLine => Palette.hotelLine;
  Color get hotelOkFill => Palette.hotelOkFill;
  Color get hotelOkInk => Palette.hotelOkInk;

  // ─── Main App Polish & Surfaces ──────────────────────────────────────
  final Color pageBackground;
  final Color cardBorder;
  final Color cardShadow;
  final Color statusSuccessBackground;
  final Color statusSuccessForeground;
  final Color statusWarningBackground;
  final Color statusWarningForeground;
  final Color statusVerifiedForeground;
  final Color statusVerifiedSubForeground;
  final Color surfaceRedTint;
  final Color ink;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color line;

  // ─── Paper Palette (Findr) ──────────────────────────────────────────
  final Color paper;
  final Color paperLine;
  final Color paperInk;
  final Color paperInk2;

  // ─── Legacy Compatibility & Convenience Getters ─────────────────────────
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

  bool get isDark => surface == Palette.surfaceDark;

  Color get page => pageBackground;
  Color get redTint => surfaceRedTint;
  Color get okFill => statusSuccessBackground;
  Color get okInk => statusSuccessForeground;
  Color get waitFill => statusWarningBackground;
  Color get waitInk => statusWarningForeground;
  Color get photoChip => isDark ? Palette.neutral800 : Palette.photoChip;
  Color get buttonIdle => isDark ? Palette.neutral800 : Palette.buttonIdle;
  Color get buttonIdleLabel =>
      isDark ? Palette.inkDark : Palette.buttonIdleLabel;
  Color get chipBorder => isDark ? Palette.neutral700 : Palette.chipBorder;
  Color get chevron => isDark ? Palette.neutral600 : Palette.chevron;
  Color get scrim => Palette.scrim;
  Color get cardBorderSoft => cardBorder;

  // ─── Static Feature Gradients & Constants ────────────────────────────
  static const Color white = Palette.neutral0;
  static const Color red500 = Palette.red500;
  static const Color red600 = Palette.brandRed;
  static const Color successColor = Palette.green600;
  static const Color errorColor = Palette.brandRed;
  static const Color warningColor = Palette.orange500;
  static const Color infoColor = Palette.blue700;

  static const Color success = Palette.green600;
  static const Color warning = Palette.orange500;
  static const Color error = Palette.brandRed;
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
    textPrimary: Palette.ink,
    textSecondary: Palette.ink2,
    textDisabled: Palette.neutral300,
    textOnAction: Palette.neutral0,
    borderDefault: Palette.line,
    borderFocused: Palette.brandRed,
    borderSubtle: Palette.cardBorderSoft,
    actionPrimary: Palette.brandRed,
    actionSecondary: Palette.neutral150,
    feedbackSuccess: Palette.green600,
    feedbackError: Palette.brandRed,
    feedbackWarning: Palette.orange500,
    feedbackInfo: Palette.blue700,
    background: Palette.page,

    // Brand tokens
    brandPrimary: Palette.brandRed,
    brandSurface: Palette.brandRed,
    brandOnSurface: Palette.neutral0,
    brandSecondary: Palette.cream,
    brandSecondaryBody: Palette.creamBody,
    brandSecondarySmall: Palette.creamSmall,
    brandSecondaryNote: Palette.creamNote,
    brandSecondaryPlaceholder: Palette.creamPlaceholder,
    brandActionLabel: Palette.brandRedLabel,
    brandFieldBackground: Palette.fieldFill,
    brandButtonDisabledBackground: Palette.buttonOff,
    brandButtonDisabledForeground: Palette.buttonOffLabel,
    brandCardBackground: Palette.cardFill,
    brandUnderline: Palette.underline,
    brandKeyBackground: Palette.keyFill,
    brandDotOutline: Palette.dotOutline,
    brandCodeBoxBackground: Palette.codeBoxFill,

    // Verification
    verificationStepActiveText: Palette.brandRed,
    verificationStepInactiveText: Palette.stepInactiveText,
    verificationStepRing: Palette.stepRing,
    verificationStepTrack: Palette.stepTrack,
    verificationCardLockedTitle: Palette.cardTitleLocked,
    verificationCardLockedSubtitle: Palette.cardSubtitleLocked,
    verificationCardActiveFill: Palette.cardFillNow,
    verificationCardIconFill: Palette.cardIconFill,
    verificationProgressTrack: Palette.progressTrack,
    verificationChipBackground: Palette.chipFill,
    verificationOutlineButton: Palette.outlineButton,
    verificationDivider: Palette.divider,

    // App polish
    pageBackground: Palette.page,
    cardBorder: Palette.cardBorderSoft,
    cardShadow: Palette.cardShadow,
    statusSuccessBackground: Palette.okFill,
    statusSuccessForeground: Palette.okInk,
    statusWarningBackground: Palette.waitFill,
    statusWarningForeground: Palette.waitInk,
    statusVerifiedForeground: Palette.verifiedInk,
    statusVerifiedSubForeground: Palette.verifiedInk2,
    surfaceRedTint: Palette.redTint,
    ink: Palette.ink,
    inkSecondary: Palette.ink2,
    inkTertiary: Palette.ink3,
    line: Palette.line,

    // Paper Palette (Findr)
    paper: Palette.paper,
    paperLine: Palette.paperLine,
    paperInk: Palette.paperInk,
    paperInk2: Palette.paperInk2,
  );

  // ─── Dark Preset ────────────────────────────────────────────────────
  static const dark = AppColors(
    surface: Palette.surfaceDark,
    surfaceRaised: Palette.surfaceDark2,
    surfaceSubtle: Palette.neutral950,
    textPrimary: Palette.inkDark,
    textSecondary: Palette.ink2Dark,
    textDisabled: Palette.neutral600,
    textOnAction: Palette.neutral0,
    borderDefault: Palette.neutral700,
    borderFocused: Palette.brandRedDark,
    borderSubtle: Palette.neutral800,
    actionPrimary: Palette.brandRedDark,
    actionSecondary: Palette.neutral700,
    feedbackSuccess: Palette.green500,
    feedbackError: Palette.brandRedDark,
    feedbackWarning: Palette.amber500,
    feedbackInfo: Palette.blue400,
    background: Palette.pageDark,

    // Brand tokens
    brandPrimary: Palette.brandRed,
    brandSurface: Palette.brandRed,
    brandOnSurface: Palette.neutral0,
    brandSecondary: Palette.cream,
    brandSecondaryBody: Palette.creamBody,
    brandSecondarySmall: Palette.creamSmall,
    brandSecondaryNote: Palette.creamNote,
    brandSecondaryPlaceholder: Palette.creamPlaceholder,
    brandActionLabel: Palette.brandRedLabel,
    brandFieldBackground: Palette.fieldFill,
    brandButtonDisabledBackground: Palette.buttonOff,
    brandButtonDisabledForeground: Palette.buttonOffLabel,
    brandCardBackground: Palette.cardFill,
    brandUnderline: Palette.underline,
    brandKeyBackground: Palette.keyFill,
    brandDotOutline: Palette.dotOutline,
    brandCodeBoxBackground: Palette.codeBoxFill,

    // Verification
    verificationStepActiveText: Palette.brandRedDark,
    verificationStepInactiveText: Palette.stepInactiveText,
    verificationStepRing: Palette.stepRing,
    verificationStepTrack: Palette.stepTrack,
    verificationCardLockedTitle: Palette.cardTitleLocked,
    verificationCardLockedSubtitle: Palette.cardSubtitleLocked,
    verificationCardActiveFill: Palette.cardFillNow,
    verificationCardIconFill: Palette.cardIconFill,
    verificationProgressTrack: Palette.progressTrack,
    verificationChipBackground: Palette.chipFill,
    verificationOutlineButton: Palette.outlineButton,
    verificationDivider: Palette.divider,

    // App polish
    pageBackground: Palette.pageDark,
    cardBorder: Palette.neutral800,
    cardShadow: Colors.transparent,
    statusSuccessBackground: Palette.okFill,
    statusSuccessForeground: Palette.okInk,
    statusWarningBackground: Palette.waitFill,
    statusWarningForeground: Palette.waitInk,
    statusVerifiedForeground: Palette.verifiedInk,
    statusVerifiedSubForeground: Palette.verifiedInk2,
    surfaceRedTint: Palette.redTint,
    ink: Palette.inkDark,
    inkSecondary: Palette.ink2Dark,
    inkTertiary: Palette.ink3Dark,
    line: Palette.line,

    // Paper Palette (Findr)
    paper: Palette.paperDark,
    paperLine: Palette.paperLineDark,
    paperInk: Palette.paperInkDark,
    paperInk2: Palette.paperInk2Dark,
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
    Color? brandPrimary,
    Color? brandSurface,
    Color? brandOnSurface,
    Color? brandSecondary,
    Color? brandSecondaryBody,
    Color? brandSecondarySmall,
    Color? brandSecondaryNote,
    Color? brandSecondaryPlaceholder,
    Color? brandActionLabel,
    Color? brandFieldBackground,
    Color? brandButtonDisabledBackground,
    Color? brandButtonDisabledForeground,
    Color? brandCardBackground,
    Color? brandUnderline,
    Color? brandKeyBackground,
    Color? brandDotOutline,
    Color? brandCodeBoxBackground,
    Color? verificationStepActiveText,
    Color? verificationStepInactiveText,
    Color? verificationStepRing,
    Color? verificationStepTrack,
    Color? verificationCardLockedTitle,
    Color? verificationCardLockedSubtitle,
    Color? verificationCardActiveFill,
    Color? verificationCardIconFill,
    Color? verificationProgressTrack,
    Color? verificationChipBackground,
    Color? verificationOutlineButton,
    Color? verificationDivider,
    Color? pageBackground,
    Color? cardBorder,
    Color? cardShadow,
    Color? statusSuccessBackground,
    Color? statusSuccessForeground,
    Color? statusWarningBackground,
    Color? statusWarningForeground,
    Color? statusVerifiedForeground,
    Color? statusVerifiedSubForeground,
    Color? surfaceRedTint,
    Color? ink,
    Color? inkSecondary,
    Color? inkTertiary,
    Color? line,
    Color? paper,
    Color? paperLine,
    Color? paperInk,
    Color? paperInk2,
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
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSurface: brandSurface ?? this.brandSurface,
      brandOnSurface: brandOnSurface ?? this.brandOnSurface,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandSecondaryBody: brandSecondaryBody ?? this.brandSecondaryBody,
      brandSecondarySmall: brandSecondarySmall ?? this.brandSecondarySmall,
      brandSecondaryNote: brandSecondaryNote ?? this.brandSecondaryNote,
      brandSecondaryPlaceholder:
          brandSecondaryPlaceholder ?? this.brandSecondaryPlaceholder,
      brandActionLabel: brandActionLabel ?? this.brandActionLabel,
      brandFieldBackground: brandFieldBackground ?? this.brandFieldBackground,
      brandButtonDisabledBackground:
          brandButtonDisabledBackground ?? this.brandButtonDisabledBackground,
      brandButtonDisabledForeground:
          brandButtonDisabledForeground ?? this.brandButtonDisabledForeground,
      brandCardBackground: brandCardBackground ?? this.brandCardBackground,
      brandUnderline: brandUnderline ?? this.brandUnderline,
      brandKeyBackground: brandKeyBackground ?? this.brandKeyBackground,
      brandDotOutline: brandDotOutline ?? this.brandDotOutline,
      brandCodeBoxBackground:
          brandCodeBoxBackground ?? this.brandCodeBoxBackground,
      verificationStepActiveText:
          verificationStepActiveText ?? this.verificationStepActiveText,
      verificationStepInactiveText:
          verificationStepInactiveText ?? this.verificationStepInactiveText,
      verificationStepRing: verificationStepRing ?? this.verificationStepRing,
      verificationStepTrack:
          verificationStepTrack ?? this.verificationStepTrack,
      verificationCardLockedTitle:
          verificationCardLockedTitle ?? this.verificationCardLockedTitle,
      verificationCardLockedSubtitle:
          verificationCardLockedSubtitle ?? this.verificationCardLockedSubtitle,
      verificationCardActiveFill:
          verificationCardActiveFill ?? this.verificationCardActiveFill,
      verificationCardIconFill:
          verificationCardIconFill ?? this.verificationCardIconFill,
      verificationProgressTrack:
          verificationProgressTrack ?? this.verificationProgressTrack,
      verificationChipBackground:
          verificationChipBackground ?? this.verificationChipBackground,
      verificationOutlineButton:
          verificationOutlineButton ?? this.verificationOutlineButton,
      verificationDivider: verificationDivider ?? this.verificationDivider,
      pageBackground: pageBackground ?? this.pageBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      statusSuccessBackground:
          statusSuccessBackground ?? this.statusSuccessBackground,
      statusSuccessForeground:
          statusSuccessForeground ?? this.statusSuccessForeground,
      statusWarningBackground:
          statusWarningBackground ?? this.statusWarningBackground,
      statusWarningForeground:
          statusWarningForeground ?? this.statusWarningForeground,
      statusVerifiedForeground:
          statusVerifiedForeground ?? this.statusVerifiedForeground,
      statusVerifiedSubForeground:
          statusVerifiedSubForeground ?? this.statusVerifiedSubForeground,
      surfaceRedTint: surfaceRedTint ?? this.surfaceRedTint,
      ink: ink ?? this.ink,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      inkTertiary: inkTertiary ?? this.inkTertiary,
      line: line ?? this.line,
      paper: paper ?? this.paper,
      paperLine: paperLine ?? this.paperLine,
      paperInk: paperInk ?? this.paperInk,
      paperInk2: paperInk2 ?? this.paperInk2,
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
      brandPrimary:
          Color.lerp(brandPrimary, other.brandPrimary, t) ?? brandPrimary,
      brandSurface:
          Color.lerp(brandSurface, other.brandSurface, t) ?? brandSurface,
      brandOnSurface:
          Color.lerp(brandOnSurface, other.brandOnSurface, t) ?? brandOnSurface,
      brandSecondary:
          Color.lerp(brandSecondary, other.brandSecondary, t) ?? brandSecondary,
      brandSecondaryBody:
          Color.lerp(brandSecondaryBody, other.brandSecondaryBody, t) ??
          brandSecondaryBody,
      brandSecondarySmall:
          Color.lerp(brandSecondarySmall, other.brandSecondarySmall, t) ??
          brandSecondarySmall,
      brandSecondaryNote:
          Color.lerp(brandSecondaryNote, other.brandSecondaryNote, t) ??
          brandSecondaryNote,
      brandSecondaryPlaceholder:
          Color.lerp(
            brandSecondaryPlaceholder,
            other.brandSecondaryPlaceholder,
            t,
          ) ??
          brandSecondaryPlaceholder,
      brandActionLabel:
          Color.lerp(brandActionLabel, other.brandActionLabel, t) ??
          brandActionLabel,
      brandFieldBackground:
          Color.lerp(brandFieldBackground, other.brandFieldBackground, t) ??
          brandFieldBackground,
      brandButtonDisabledBackground:
          Color.lerp(
            brandButtonDisabledBackground,
            other.brandButtonDisabledBackground,
            t,
          ) ??
          brandButtonDisabledBackground,
      brandButtonDisabledForeground:
          Color.lerp(
            brandButtonDisabledForeground,
            other.brandButtonDisabledForeground,
            t,
          ) ??
          brandButtonDisabledForeground,
      brandCardBackground:
          Color.lerp(brandCardBackground, other.brandCardBackground, t) ??
          brandCardBackground,
      brandUnderline:
          Color.lerp(brandUnderline, other.brandUnderline, t) ?? brandUnderline,
      brandKeyBackground:
          Color.lerp(brandKeyBackground, other.brandKeyBackground, t) ??
          brandKeyBackground,
      brandDotOutline:
          Color.lerp(brandDotOutline, other.brandDotOutline, t) ??
          brandDotOutline,
      brandCodeBoxBackground:
          Color.lerp(brandCodeBoxBackground, other.brandCodeBoxBackground, t) ??
          brandCodeBoxBackground,
      verificationStepActiveText:
          Color.lerp(
            verificationStepActiveText,
            other.verificationStepActiveText,
            t,
          ) ??
          verificationStepActiveText,
      verificationStepInactiveText:
          Color.lerp(
            verificationStepInactiveText,
            other.verificationStepInactiveText,
            t,
          ) ??
          verificationStepInactiveText,
      verificationStepRing:
          Color.lerp(verificationStepRing, other.verificationStepRing, t) ??
          verificationStepRing,
      verificationStepTrack:
          Color.lerp(verificationStepTrack, other.verificationStepTrack, t) ??
          verificationStepTrack,
      verificationCardLockedTitle:
          Color.lerp(
            verificationCardLockedTitle,
            other.verificationCardLockedTitle,
            t,
          ) ??
          verificationCardLockedTitle,
      verificationCardLockedSubtitle:
          Color.lerp(
            verificationCardLockedSubtitle,
            other.verificationCardLockedSubtitle,
            t,
          ) ??
          verificationCardLockedSubtitle,
      verificationCardActiveFill:
          Color.lerp(
            verificationCardActiveFill,
            other.verificationCardActiveFill,
            t,
          ) ??
          verificationCardActiveFill,
      verificationCardIconFill:
          Color.lerp(
            verificationCardIconFill,
            other.verificationCardIconFill,
            t,
          ) ??
          verificationCardIconFill,
      verificationProgressTrack:
          Color.lerp(
            verificationProgressTrack,
            other.verificationProgressTrack,
            t,
          ) ??
          verificationProgressTrack,
      verificationChipBackground:
          Color.lerp(
            verificationChipBackground,
            other.verificationChipBackground,
            t,
          ) ??
          verificationChipBackground,
      verificationOutlineButton:
          Color.lerp(
            verificationOutlineButton,
            other.verificationOutlineButton,
            t,
          ) ??
          verificationOutlineButton,
      verificationDivider:
          Color.lerp(verificationDivider, other.verificationDivider, t) ??
          verificationDivider,
      pageBackground:
          Color.lerp(pageBackground, other.pageBackground, t) ?? pageBackground,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t) ?? cardShadow,
      statusSuccessBackground:
          Color.lerp(
            statusSuccessBackground,
            other.statusSuccessBackground,
            t,
          ) ??
          statusSuccessBackground,
      statusSuccessForeground:
          Color.lerp(
            statusSuccessForeground,
            other.statusSuccessForeground,
            t,
          ) ??
          statusSuccessForeground,
      statusWarningBackground:
          Color.lerp(
            statusWarningBackground,
            other.statusWarningBackground,
            t,
          ) ??
          statusWarningBackground,
      statusWarningForeground:
          Color.lerp(
            statusWarningForeground,
            other.statusWarningForeground,
            t,
          ) ??
          statusWarningForeground,
      statusVerifiedForeground:
          Color.lerp(
            statusVerifiedForeground,
            other.statusVerifiedForeground,
            t,
          ) ??
          statusVerifiedForeground,
      statusVerifiedSubForeground:
          Color.lerp(
            statusVerifiedSubForeground,
            other.statusVerifiedSubForeground,
            t,
          ) ??
          statusVerifiedSubForeground,
      surfaceRedTint:
          Color.lerp(surfaceRedTint, other.surfaceRedTint, t) ?? surfaceRedTint,
      ink: Color.lerp(ink, other.ink, t) ?? ink,
      inkSecondary:
          Color.lerp(inkSecondary, other.inkSecondary, t) ?? inkSecondary,
      inkTertiary: Color.lerp(inkTertiary, other.inkTertiary, t) ?? inkTertiary,
      line: Color.lerp(line, other.line, t) ?? line,
      paper: Color.lerp(paper, other.paper, t) ?? paper,
      paperLine: Color.lerp(paperLine, other.paperLine, t) ?? paperLine,
      paperInk: Color.lerp(paperInk, other.paperInk, t) ?? paperInk,
      paperInk2: Color.lerp(paperInk2, other.paperInk2, t) ?? paperInk2,
    );
  }
}
