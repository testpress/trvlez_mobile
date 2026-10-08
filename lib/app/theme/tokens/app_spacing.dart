/// 4-point grid spacing system and semantic aliases.
abstract final class AppSpacing {
  // ─── Base 4-pt scale ──────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ─── Semantic Aliases ─────────────────────────────────────────────────
  static const double screenPadding = md;
  static const double cardPadding = md;
  static const double itemGap = sm;
}
