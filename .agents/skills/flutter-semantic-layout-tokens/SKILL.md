---
name: flutter-semantic-layout-tokens
description: Design and migrate a Flutter app to semantic spacing, sizing and shape (radius, border) tokens named by structural intent. Use when raw numbers appear in EdgeInsets, SizedBox, BorderRadius, Size, Icon size, width/height, or when asked to create, audit, or enforce a spacing/sizing/radius token system in Dart.
---

# Flutter Semantic Spacing, Sizing & Shape Tokens

Goal: no widget contains a raw layout number. Every spacing, size, and corner value comes from
a token whose NAME says what it is for, not how big it is.

Bad:  `EdgeInsets.all(15)`, `SizedBox(height: 24)`, `BorderRadius.circular(10)`, `Size(120, 42)`
Good: `context.space.insetCard`, `context.space.stackFormField`, `context.shape.radiusSurface`, `context.size.controlMd`

## 1. Token architecture (3 tiers)

1. **Primitive** (library-private): raw scale. Lives in one file, `_Primitives`/private constants.
   Nothing outside `design_tokens/` may import or reference it.
2. **Semantic** (public API): intent names that alias primitives. This is what widgets use.
3. **Component** (optional): put component defaults into `ThemeData` component themes
   (`ElevatedButtonThemeData`, `InputDecorationTheme`, `CardThemeData`, `DialogThemeData`, ...)
   built from semantic tokens, so most widgets need no token reference at all.

Units are Flutter logical pixels (`double`). Never hardcode a number outside the token files.

## 2. Folder structure

```
lib/core/design_tokens/
  primitives.dart          // private scale, not exported
  space_tokens.dart        // AppSpace ThemeExtension
  size_tokens.dart         // AppSize ThemeExtension
  shape_tokens.dart        // AppShape ThemeExtension
  tokens_context.dart      // BuildContext accessors (context.space / size / shape)
  tokens.dart              // barrel: exports only the public pieces
lib/core/theme/app_theme.dart   // ThemeData assembled from tokens
```

## 3. Naming grammar (camelCase)

`{role}{Context}{Scale?}`, grouped by category object. Context = WHERE it is used,
never the value. Scale (`Sm Md Lg`) only as the last part, to rank variants of one role.

### Spacing (`context.space.*`)
| Role prefix | Meaning | Examples |
|---|---|---|
| `inset*` | padding inside a container (returns `EdgeInsets`) | `insetControlMd`, `insetCard`, `insetDialog`, `insetSection`, `insetScreen` |
| `stack*` | vertical gap between siblings (`double`) | `stackFormField`, `stackSection`, `stackListItem`, `stackText` |
| `inline*` | horizontal gap between siblings (`double`) | `inlineIconLabel`, `inlineButtonGroup`, `inlineToolbar` |
| `gutter*` | grid / layout gaps | `gutterGrid`, `gutterScreen` |

Spacing tokens are for padding, margin and gaps only; never for width/height/offset.
Prefer `Column/Row(spacing: ...)` (Flutter 3.27+) or a `Gap`-style widget over scattered `SizedBox`.
Check the project's Flutter SDK version before using `spacing:`.

### Sizing (`context.size.*`)
| Role | Examples |
|---|---|
| `control{Sm,Md,Lg}` | height of buttons, text fields, chips |
| `icon{Sm,Md,Lg}` | icon size |
| `avatar{Sm,Md,Lg,Xl}` | avatar diameter |
| `touchTargetMin` | `kMinInteractiveDimension` (48) |
| `container{Prose,Page,DialogSm,DialogMd}` | max widths (tablet/web) |
| `appBarHeight`, `navRailWidth`, `drawerWidth` | app shell dimensions |

### Shape (`context.shape.*`)
| Role | Examples |
|---|---|
| `radiusControl` | buttons, inputs (`BorderRadius`) |
| `radiusSurface` | cards, panels |
| `radiusOverlay` | dialogs, bottom sheets, menus |
| `radiusTag`, `radiusPill`, `radiusAvatar` | chips, pills, avatars |
| `borderHairline`, `borderDefault`, `borderFocus` | border/outline widths |

Nested radius rule: inner radius = outer radius minus padding, floored at 0.
Provide a helper (`shape.inner(outer, padding)`) instead of recomputing by hand.

## 4. Implementation pattern

Use `ThemeExtension` so tokens are part of `Theme`, swappable per theme/density, and testable.

```dart
// primitives.dart  (private to the package folder)
abstract final class Prim {
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s24 = 24, s32 = 32;
  static const double r4 = 4, r8 = 8, r12 = 12, r16 = 16, rFull = 999;
}

// space_tokens.dart
@immutable
class AppSpace extends ThemeExtension<AppSpace> {
  const AppSpace({
    required this.insetCard,
    required this.insetScreen,
    required this.stackFormField,
    required this.inlineIconLabel,
  });

  final EdgeInsets insetCard;
  final EdgeInsets insetScreen;
  final double stackFormField;
  final double inlineIconLabel;

  static const comfortable = AppSpace(
    insetCard: EdgeInsets.all(Prim.s16),
    insetScreen: EdgeInsets.symmetric(horizontal: Prim.s16, vertical: Prim.s24),
    stackFormField: Prim.s16,
    inlineIconLabel: Prim.s8,
  );
  static const compact = AppSpace(
    insetCard: EdgeInsets.all(Prim.s12),
    insetScreen: EdgeInsets.symmetric(horizontal: Prim.s12, vertical: Prim.s16),
    stackFormField: Prim.s12,
    inlineIconLabel: Prim.s4,
  );

  @override
  AppSpace copyWith({/* all fields, nullable */}) => /* ... */;

  @override
  AppSpace lerp(ThemeExtension<AppSpace>? other, double t) {
    if (other is! AppSpace) return this;
    return AppSpace(
      insetCard: EdgeInsets.lerp(insetCard, other.insetCard, t)!,
      // ... lerp every field
    );
  }
}

// tokens_context.dart
extension TokensContext on BuildContext {
  AppSpace get space => Theme.of(this).extension<AppSpace>()!;
  AppSize get size => Theme.of(this).extension<AppSize>()!;
  AppShape get shape => Theme.of(this).extension<AppShape>()!;
}
```

Widget usage:

```dart
Padding(
  padding: context.space.insetCard,
  child: Column(
    spacing: context.space.stackFormField,
    children: [...],
  ),
)
```

Theme assembly: register the three extensions in `ThemeData(extensions: [...])` and configure
component themes from them (button `minimumSize`/`padding`/`shape`, input `contentPadding`/`border`,
card/dialog `shape`), so default widgets already conform.

Responsive and density: choose token sets by window size class (compact/medium/expanded) or a density
setting at the theme level, using `LayoutBuilder`/`MediaQuery.sizeOf`. Widgets never branch on pixel widths
to pick spacing. Breakpoints themselves live in one `breakpoints.dart` file.

Text scaling: sizes tied to text (control heights, icon sizes next to text) should use
`MediaQuery.textScalerOf(context)` or `minHeight` constraints instead of fixed heights, so large
accessibility fonts don't clip.

If `context` is unavailable (pure Dart, tests, `const` constructors), expose a `const` default
instance (`AppSpace.comfortable`) rather than literals. Do not widen `const` APIs by adding raw numbers.

## 5. Rules for widgets

- Use semantic tokens only. Never import primitives.
- Choose the token by the element's role, not by matching an existing number.
- If no token fits, STOP and propose a new one (name, role, value per mode, rationale).
  Do not fall back to a raw number or a generic scale name (`space8`, `s16`).
- Allowed raw values: `0`, `double.infinity`, `Alignment`/fractions (`widthFactor`, `flex`, `Expanded`),
  `Divider` indent only via tokens, values required by a third-party API (comment why),
  and platform constants like `kMinInteractiveDimension`, `kToolbarHeight` wrapped in a size token.
- Prefer layout widgets (`Expanded`, `Flexible`, `ConstrainedBox` with container tokens, `IntrinsicHeight`
  sparingly) over fixed `width`/`height` literals.
- Colors, typography and motion are out of scope here; do not touch them in these changes.

## 6. Migration workflow (existing messy codebase)

1. **Audit** (read-only). Search `lib/` (exclude generated files `*.g.dart`, `*.freezed.dart`, `l10n`) for:
   - `EdgeInsets\.(all|symmetric|only|fromLTRB)\(` with numeric args
   - `SizedBox\(` with `width:`/`height:` numbers, `Gap(` with numbers
   - `BorderRadius\.(circular|only|vertical|horizontal)\(`, `Radius\.circular\(`
   - `Size\(`, `fixedSize`, `minimumSize`, `maximumSize`, `BoxConstraints(` with numbers
   - `size:` on `Icon`, `CircleAvatar(radius:)`, `height:`/`width:` on `Container`
   - `Border.all(width:`, `thickness:`, `strokeWidth:`
   Produce a table: value, count, files, element role.
2. **Cluster by intent**, not by number. 14 and 16 on card padding are one token. Record each snapped value;
   flag any snap larger than 2 logical pixels for review.
3. **Define tokens first** (files in section 2, theme wiring, component themes). Get approval of the token list
   if the user asked for review.
4. **Replace in small batches** (one feature folder per batch). Keep diffs mechanical; do not refactor unrelated code.
5. **Verify** after each batch: `dart format`, `flutter analyze`, `flutter test`, and golden tests
   (`flutter test --update-goldens` only after reviewing intentional diffs). Report visual changes.
6. **Enforce**: add a CI check that fails on raw numbers in the patterns above outside `design_tokens/`
   (a small grep/script, or a `custom_lint` rule if the project already uses it). Wire it to `analysis_options.yaml`
   conventions or CI, whichever the project uses.
7. **Document**: short `docs/design_tokens.md` with the naming grammar, a "which token for what" table,
   and how to request a new token.

## 7. Anti-patterns to reject

- `AppSpace.s16`, `space8`, `gap16` used in widgets (scale leakage)
- Names that encode values: `padding16`, `radius8`
- One-off tokens for a single screen (`homeHeroTop3`)
- Semantic tokens defined from raw numbers instead of primitives
- Spacing tokens used for width/height, or sizing tokens used for padding
- Mixing token and raw values in the same widget
- Hardcoded heights that break at large text scale
- Silent visual changes during a "refactor"

## 8. Output expectations when finishing a task

State: tokens added/changed, files migrated, remaining raw values with reasons,
snapped values with visual impact, and checks run with results (`analyze`, tests, goldens).