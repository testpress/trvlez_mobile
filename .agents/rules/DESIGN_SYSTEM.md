# Design System & Semantic Tokens Guide

> Companion to `ARCHITECTURE.md` and `CODE_STANDARDS.md`.
> **Core Rule:** Screens never decide colors, spacing, or text styles directly. They only express semantic intent (e.g., `context.colors.textPrimary`, `AppSpacing.md`).

---

## 1. The Three Token Tiers

```
PRIMITIVE (Raw values)        SEMANTIC (Meaning)             COMPONENT (Specific usage)
─────────────────────         ──────────────────             ─────────────────────────
Palette.blue600      ───────▶ actionPrimary          ──────▶ button.primary.background
Palette.neutral900   ───────▶ textPrimary                    input.border.focused
Palette.red600       ───────▶ feedbackError                  card.background
space 16             ───────▶ AppSpacing.md / screenPadding
```

| Tier | Answers | Allowed Consumer |
|---|---|---|
| **Primitive** | "What values exist?" (`Palette.blue600`) | Theme definitions only |
| **Semantic** | "What does it mean?" (`actionPrimary`, `feedbackError`) | Widgets & screens (`context.colors`) |
| **Component** | "How does this component render?" | Dedicated component themes |

---

## 2. Directory Structure

```
lib/app/theme/
├── app_theme.dart                 # buildTheme(): light & dark ThemeData
├── theme_extensions.dart          # context.colors, context.text helpers
├── tokens/
│   ├── primitives/
│   │   ├── palette.dart           # Raw hex colors (never imported in features)
│   │   └── type_scale.dart        # Font families & weights
│   ├── app_colors.dart            # Semantic colors (ThemeExtension)
│   ├── app_spacing.dart           # 4-pt grid & semantic spacing aliases
│   ├── app_radius.dart            # Border radius constants
│   ├── app_motion.dart            # Durations & animation curves
│   └── app_typography.dart        # Semantic TextTheme
└── component_themes/
    ├── button_theme.dart
    ├── input_theme.dart
    └── card_theme.dart
```

---

## 3. Primitives & Semantic Color Tokens

### 3.1 Raw Primitives (`tokens/primitives/palette.dart`)
```dart
abstract final class Palette {
  static const blue600 = Color(0xFF2563EB);
  static const blue500 = Color(0xFF3B82F6);
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral500 = Color(0xFF64748B);
  static const neutral900 = Color(0xFF0F172A);
  static const red600 = Color(0xFFDC2626);
  static const green600 = Color(0xFF16A34A);
  static const amber500 = Color(0xFFF59E0B);
}
```

### 3.2 Semantic Tokens via ThemeExtension (`tokens/app_colors.dart`)
Semantic naming follows: `<category><Role><State?>` (e.g. `surface`, `textPrimary`, `actionPrimary`, `feedbackError`).

```dart
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
    required this.actionPrimary,
    required this.feedbackSuccess,
    required this.feedbackError,
  });

  final Color surface, surfaceRaised, surfaceSubtle;
  final Color textPrimary, textSecondary, textDisabled, textOnAction;
  final Color borderDefault, borderFocused, actionPrimary;
  final Color feedbackSuccess, feedbackError;

  static const light = AppColors(
    surface: Palette.neutral0,
    surfaceRaised: Palette.neutral0,
    surfaceSubtle: Palette.neutral50,
    textPrimary: Palette.neutral900,
    textSecondary: Palette.neutral500,
    textDisabled: Palette.neutral200,
    textOnAction: Palette.neutral0,
    borderDefault: Palette.neutral200,
    borderFocused: Palette.blue600,
    actionPrimary: Palette.blue600,
    feedbackSuccess: Palette.green600,
    feedbackError: Palette.red600,
  );

  static const dark = AppColors(
    surface: Palette.neutral900,
    surfaceRaised: Color(0xFF1E293B),
    surfaceSubtle: Color(0xFF111827),
    textPrimary: Palette.neutral50,
    textSecondary: Palette.neutral200,
    textDisabled: Palette.neutral500,
    textOnAction: Palette.neutral0,
    borderDefault: Color(0xFF334155),
    borderFocused: Palette.blue500,
    actionPrimary: Palette.blue500,
    feedbackSuccess: Palette.green600,
    feedbackError: Palette.red600,
  );

  @override
  AppColors copyWith({...}) { /* standard copyWith */ }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) { /* lerp colors */ }
}
```

### 3.3 Context Extensions (`theme_extensions.dart`)
```dart
extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
```

---

## 4. Spacing, Radius, Motion & Typography

### 4.1 Spacing (`tokens/app_spacing.dart`)
```dart
abstract final class AppSpacing {
  static const double xs = 4, sm = 8, md = 16, lg = 24, xl = 32, xxl = 48;
  static const double screenPadding = md;
  static const double cardPadding = md;
  static const double itemGap = sm;
}
```

### 4.2 Radius & Motion (`tokens/app_radius.dart`, `app_motion.dart`)
```dart
abstract final class AppRadius {
  static const double sm = 8, md = 12, lg = 16, pill = 999;
  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(sm);
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;
}
```

### 4.3 Typography (`tokens/app_typography.dart`)
Map text styles to standard Material `TextTheme` slots (`headlineLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelLarge`) using `GoogleFonts.nunito` and `GoogleFonts.cabin`.

---

## 5. Theme Integration & Components

### 5.1 Wiring ThemeData (`app_theme.dart`)
```dart
ThemeData buildTheme(AppColors c, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.surface,
    extensions: [c],
    textTheme: buildTextTheme(c),
    elevatedButtonTheme: buildElevatedButtonTheme(c),
    inputDecorationTheme: buildInputTheme(c),
    cardTheme: buildCardTheme(c),
  );
}
```

### 5.2 Reusable Shared Components (`core/widgets/`)
Screens use shared components (e.g. `AppButton`, `AppTextField`, `AppCard`) that consume semantic tokens internally:

```dart
class AppButton extends StatelessWidget {
  const AppButton({required this.label, required this.onPressed, this.isLoading = false, super.key});
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.actionPrimary,
        foregroundColor: context.colors.textOnAction,
      ),
      child: isLoading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator()) : Text(label),
    );
  }
}
```

---

## 6. Design Rules: Do's and Don'ts

| ❌ Don't | ✅ Do |
|---|---|
| `Color(0xFF2563EB)` in widgets | `context.colors.actionPrimary` |
| `Colors.red` or `Colors.white` | `context.colors.feedbackError`, `context.colors.surface` |
| `TextStyle(fontSize: 14)` inline | `context.text.bodyMedium` |
| `SizedBox(height: 16)` magic number | `SizedBox(height: AppSpacing.md)` |
| `BorderRadius.circular(12)` inline | `AppRadius.card` |
| `Theme.of(context).brightness == isDark` | Use semantic token mapping |
| Import `Palette` in features | Import `context.colors` |

---

## 7. Accessibility & Validation Checklist

- **Contrast:** Text vs background ratio ≥ 4.5:1 (3:1 for large text).
- **Tap Targets:** Interactive targets ≥ 48×48 dp.
- **Text Scaling:** Support 200% text scale without overflow (use `Expanded`, `Flexible`, `maxLines`).
- **Zero Raw Styles:** Verify no `Color(0x...)` or `TextStyle(` exist in `lib/features/`.
