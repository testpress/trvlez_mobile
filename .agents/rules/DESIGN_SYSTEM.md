---
trigger: always_on
description: Three-tier semantic design tokens (primitives, semantic, component), color tokens, spacing, sizing, shape, and typography guide.
---

# Design System & Semantic Tokens Guide

> Companion to `ARCHITECTURE.md` and `CODE_STANDARDS.md`.
> **Core Rule:** Screens never decide colors, spacing, or text styles directly. They only express semantic intent (e.g., `context.colors.textPrimary`, `context.space.insetCard`, `context.shape.radiusControl`).

---

## 1. The Three Token Tiers

```
PRIMITIVE (Raw values)        SEMANTIC (Meaning)             COMPONENT (Specific usage)
─────────────────────         ──────────────────             ─────────────────────────
Palette.blue600      ───────▶ actionPrimary          ──────▶ button.primary.background
Palette.neutral900   ───────▶ textPrimary                    input.border.focused
Palette.red600       ───────▶ feedbackError                  card.background
Prim.s16             ───────▶ space.insetCard / stackFormField
Prim.r12             ───────▶ shape.radiusControl
```

| Tier | Answers | Allowed Consumer |
|---|---|---|
| **Primitive** | "What values exist?" (`Palette.blue600`, `Prim.s16`) | Theme definitions only |
| **Semantic** | "What does it mean?" (`actionPrimary`, `space.stackFormField`) | Widgets & screens (`context.colors`, `context.space`, `context.sizes`, `context.shape`) |
| **Component** | "How does this component render?" | Dedicated component themes |

---

## 2. Directory Structure

```
lib/
├── core/
│   └── design_tokens/
│       ├── primitives.dart        # Private scale primitives (Prim.s16, etc.)
│       ├── space_tokens.dart      # AppSpace ThemeExtension (context.space.*)
│       ├── size_tokens.dart       # AppSize ThemeExtension (context.sizes.*)
│       ├── shape_tokens.dart      # AppShape ThemeExtension (context.shape.*)
│       ├── tokens_context.dart    # context.space, context.sizes, context.shape
│       └── tokens.dart            # Public barrel file
├── app/theme/
│   ├── app_theme.dart             # buildTheme(): light & dark ThemeData
│   ├── theme_extensions.dart      # Re-exports tokens & context.colors, context.text
│   ├── tokens/
│   │   ├── primitives/
│   │   │   ├── palette.dart       # Raw hex colors (never imported in features)
│   │   │   └── type_scale.dart    # Font families & weights
│   │   ├── app_colors.dart        # Semantic colors (ThemeExtension)
│   │   ├── app_motion.dart        # Durations & animation curves
│   │   └── app_typography.dart    # Semantic TextTheme
│   └── component_themes/
│       ├── button_theme.dart
│       ├── input_theme.dart
│       └── card_theme.dart
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

## 4. Layout, Sizing, Shape, Motion & Typography

### 4.1 Spacing (`core/design_tokens/space_tokens.dart` via `context.space.*`)
- **Insets (`EdgeInsets`)**: `context.space.insetScreen`, `context.space.insetCard`, `context.space.insetDialog`, `context.space.insetControlLg`, `context.space.insetInput`, `context.space.insetTag`.
- **Stack Gaps (`double`)**: `context.space.stackText` (4), `context.space.stackTight` (6), `context.space.stackItem` (8), `context.space.stackFormField` (16), `context.space.stackSection` (24), `context.space.stackHero` (32).
- **Inline Gaps (`double`)**: `context.space.inlineMicro` (4), `context.space.inlineIconLabel` (8), `context.space.inlineButtonGroup` (12), `context.space.inlineItem` (16).

### 4.2 Sizing & Shape (`core/design_tokens/` via `context.sizes.*` & `context.shape.*`)
- **Sizes (`double`)**: Controls (`sizes.controlSm` 36, `controlMd` 44, `controlLg` 48, `controlXl` 56, `touchTargetMin` 48), Icons (`sizes.iconXs` 14, `iconSm` 18, `iconDefault` 24, `iconHero` 48), Avatars (`sizes.avatarSm` 28, `avatarLg` 48, `avatarXl` 80).
- **Radii (`BorderRadius`)**: `shape.radiusMicro` (r2), `shape.radiusSubtle` (r4), `shape.radiusControlSm` (r8), `shape.radiusControl` (r12), `shape.radiusSurface` (r16), `shape.radiusOverlay` (r20), `shape.radiusPill` (r9999).
- **Borders (`double`)**: `shape.borderHairline` (0.5), `shape.borderDefault` (1.0), `shape.borderMedium` (1.5), `shape.borderFocus` (2.0), `shape.dividerDefault` (1.0).

### 4.3 Motion (`tokens/app_motion.dart`)
```dart
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;
}
```

### 4.4 Typography (`tokens/app_typography.dart`)
Map text styles to standard Material `TextTheme` slots (`headlineLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelLarge`) using `GoogleFonts.nunito` and `GoogleFonts.cabin`.

---

## 5. Theme Integration & Components

### 5.1 Wiring ThemeData (`app_theme.dart`)
```dart
ThemeData buildTheme(
  ColorScheme colorScheme,
  AppColors colors, {
  AppSpace space = AppSpace.comfortable,
  AppSize size = AppSize.regular,
  AppShape shape = AppShape.standard,
}) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    extensions: [colors, space, size, shape],
    textTheme: buildTextTheme(colors.textPrimary),
    elevatedButtonTheme: buildElevatedButtonTheme(colors, space: space, size: size, shape: shape),
    inputDecorationTheme: buildInputTheme(colors, space: space, shape: shape),
    cardTheme: buildCardTheme(colors, shape: shape),
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
| `SizedBox(height: 16)` magic number | `SizedBox(height: context.space.stackFormField)` |
| `BorderRadius.circular(12)` inline | `context.shape.radiusControl` |
| `EdgeInsets.all(16)` inline | `context.space.insetCard` |
| `Icon(Icons.star, size: 24)` inline | `Icon(Icons.star, size: context.sizes.iconDefault)` |
| `Theme.of(context).brightness == isDark` | Use semantic token mapping |
| Import `Palette` or `Prim` in features | Access tokens via `context.colors`, `context.space`, `context.sizes`, `context.shape` |

---

## 7. Accessibility & Validation Checklist

- **Contrast:** Text vs background ratio ≥ 4.5:1 (3:1 for large text).
- **Tap Targets:** Interactive targets ≥ 48×48 dp.
- **Text Scaling:** Support 200% text scale without overflow (use `Expanded`, `Flexible`, `maxLines`).
- **Zero Raw Styles:** Verify no `Color(0x...)` or `TextStyle(` exist in `lib/features/`.
