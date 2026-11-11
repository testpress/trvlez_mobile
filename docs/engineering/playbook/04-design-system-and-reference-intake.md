# Design system and reference intake

This chapter governs how design references are interpreted, how the token system is used, and how theme ownership is maintained. The design system is the contract between the approved visual intent and the implementation. It is not a mechanical rule engine — it requires judgement about when a value is a reusable token and when it is a component-local constant.

---

## Design reference intake

### Before implementation

Every design reference used to build or validate a screen must be version-controlled or explicitly approved. Record:

- **Source:** HTML/CSS file, Figma export, screenshot, or annotated mockup.
- **Revision/date:** When it was produced or approved.
- **Target state:** Which screen, which dynamic states (loading, empty, error, long content, authenticated, denied).
- **Viewport:** The reference viewport dimensions and density. A browser CSS pixel is not a Flutter logical pixel — they are similar in concept but the reference environment's actual pixel ratio, font stack, and rendering engine differ.
- **Assets:** Which images, icons, and fonts are used and where they are sourced.
- **Known unknowns:** States, interactions, or edge cases not represented in the reference.

A static artboard is one state on one viewport. It does not define behaviour under text scaling, keyboard, different aspect ratios, error states, or localized content. Extract the design intent — hierarchy, spacing relationships, typography roles, colour semantics, and responsive behaviour — rather than pixel-copying a single screenshot.

### HTML/CSS to Flutter translation

When translating a web reference to Flutter:

| CSS concept | Flutter equivalent | Notes |
|---|---|---|
| `padding`, `margin` | `EdgeInsets` via semantic tokens | Use `context.space.insetCard`, `context.space.insetScreen`, etc. |
| `font-size`, `font-weight` | `TextTheme` slots | Map to `context.text.bodyMedium`, `context.text.titleLarge`, etc. |
| `border-radius` | `BorderRadius` via shape tokens | Use `context.shape.radiusControl`, `context.shape.radiusSurface`, etc. |
| `gap` (flexbox) | `spacing` parameter on `Column`/`Row`, or `SizedBox` | Use `context.space.stackItem`, `context.space.inlineIconLabel`, etc. |
| `max-width` | `ConstrainedBox(constraints: BoxConstraints(maxWidth: ...))` | Appropriate for readable text columns |
| `flex: 1` | `Expanded` or `Flexible` | Only in bounded-axis parents |
| `overflow: scroll` | `SingleChildScrollView`, `ListView`, `CustomScrollView` | One scroll owner per axis |
| `position: absolute` | `Positioned` inside `Stack` | With deliberate constraints and semantics |
| `display: none` | Conditional widget inclusion or `Visibility` | Prefer conditional inclusion for semantics |
| `box-shadow` | `BoxDecoration(boxShadow: ...)` or `Material(elevation: ...)` | Use component theme defaults |
| `opacity` | `Opacity` widget or `Color.withOpacity()` | `Opacity` widget affects entire subtree |

Do not blindly copy CSS pixel values. A CSS `padding: 16px` may map to `context.space.insetCard` if it represents a card's internal padding, or to `context.space.insetScreen` if it represents screen-edge padding. The token name captures intent; the CSS value is just one input.

---

## The three-tier token system

```
PRIMITIVE (Raw values)        SEMANTIC (Meaning)             COMPONENT (Specific usage)
─────────────────────         ──────────────────             ─────────────────────────
Palette.blue600      ───────▶ actionPrimary          ──────▶ button.primary.background
Palette.neutral900   ───────▶ textPrimary                    input.border.focused
Prim.s16             ───────▶ space.insetCard                card.padding
Prim.r12             ───────▶ shape.radiusControl            input.borderRadius
```

| Tier | Purpose | Allowed consumer |
|---|---|---|
| **Primitive** | Raw values: hex colours, dp numbers, font weights | Theme definitions and token declarations only |
| **Semantic** | Named design roles: `actionPrimary`, `space.stackFormField`, `shape.radiusControl` | Widgets and screens via `context.colors`, `context.space`, `context.sizes`, `context.shape` |
| **Component** | How a specific component renders | Component theme files in `app/theme/component_themes/` |

### Token access in code

Screens and widgets access tokens exclusively through `BuildContext` extensions:

```dart
// Colours
final bg = context.colors.surface;
final textColor = context.colors.textPrimary;
final error = context.colors.feedbackError;

// Typography
final titleStyle = context.text.titleMedium;
final bodyStyle = context.text.bodyLarge;

// Spacing
final screenPadding = context.space.insetScreen;     // EdgeInsets
final cardPadding = context.space.insetCard;          // EdgeInsets
final sectionGap = context.space.stackSection;        // double
final iconGap = context.space.inlineIconLabel;        // double

// Sizing
final iconSize = context.sizes.iconDefault;           // double
final touchTarget = context.sizes.touchTargetMin;     // double
final avatarSize = context.sizes.avatarLg;            // double

// Shape
final cardRadius = context.shape.radiusSurface;       // BorderRadius
final controlRadius = context.shape.radiusControl;    // BorderRadius
final borderWidth = context.shape.borderDefault;      // double
```

Never import `Palette`, `Prim`, or other primitive classes in feature code. Primitives exist only for theme definitions.

---

## Token decisions: when to add, when not to

### Add a token when:

- The value represents a **repeated design role** with a stable, meaningful name.
- It has **two or more credible consumers** across different screens or components.
- It needs to **respond to theme changes** (light/dark, density, accessibility).
- It represents a **deliberate design decision** that should be reviewed when changed.

### Do not add a token when:

- The value is **unique to one component** and has no cross-product meaning. Use a private named constant with a comment instead.
- The value exists only to **silence a lint check** or a "no raw numbers" rule. A `const _logoAspectRatio = 2.5` with a comment is clearer than inventing `context.sizes.brandLogoAspectRatio`.
- The value is **derived from another token** through simple arithmetic. `context.space.stackItem` is a token; `context.space.stackItem / 2` is not a new token — it is a documented derivation.

### The raw-number policy (nuanced)

This playbook does not enforce a blanket "zero raw numbers" policy. Instead:

**Acceptable raw/named constants:**
- A component-private dimension with a clear comment: `const _trackHeight = 2.0; // Progress indicator track`
- An `AspectRatio` value derived from a design spec: `AspectRatio(aspectRatio: 16 / 9)`
- A framework-required value: `const BoxConstraints(minWidth: 48, minHeight: 48)` for touch targets
- Mathematical operations on existing tokens: `space.stackItem * 2`

**Not acceptable:**
- Unexplained magic numbers: `SizedBox(height: 137)` with no comment or token
- Viewport-derived formulas: `MediaQuery.sizeOf(context).height * 0.42`
- Inline hex colours: `Color(0xFF2563EB)` — always use `context.colors.*`
- Inline text styles: `TextStyle(fontSize: 14, fontWeight: FontWeight.w600)` — always use `context.text.*`
- Scattered spacing values: `EdgeInsets.all(16)` without using a token — unless it is a documented one-off with a comment

```dart
// ❌ Incorrect: unexplained number.
SizedBox(height: 72)

// ✅ Correct: semantic token.
SizedBox(height: context.sizes.controlXl)

// ✅ Also correct: component-private named constant with reason.
/// Height of the passport camera overlay frame.
/// Derived from the camera preview aspect ratio at minimum phone width.
static const _overlayFrameHeight = 280.0;
```

---

## Theme and component-theme ownership

### Global theme ownership

`app/theme/app_theme.dart` builds `ThemeData` and registers all `ThemeExtension`s. It owns:

- Material component defaults (buttons, inputs, cards, dialogs, app bars).
- Typography mapping via `TextTheme`.
- Colour scheme and custom `AppColors`.
- Layout token extensions (`AppSpace`, `AppSize`, `AppShape`).

### Component theme ownership

Component themes in `app/theme/component_themes/` define how specific Material components render:

```dart
// button_theme.dart — owns button styling globally.
ElevatedButtonThemeData buildElevatedButtonTheme(AppColors colors, {
  required AppSpace space,
  required AppSize size,
  required AppShape shape,
}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colors.actionPrimary,
      foregroundColor: colors.textOnAction,
      minimumSize: Size(0, size.controlLg),
      padding: space.insetControlLg,
      shape: RoundedRectangleBorder(borderRadius: shape.radiusControl),
    ),
  );
}
```

### Screen composition rules

Screens compose existing theme defaults. A screen must not recreate typography, colour, shape, or control semantics that an existing component theme already owns — unless the approved design reference requires a documented variant for that specific screen.

```dart
// ❌ Incorrect: screen overrides button style inline.
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2563EB),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  onPressed: onSubmit,
  child: Text('Submit'),
)

// ✅ Correct: uses the global button theme. Variant via named component.
ElevatedButton(
  onPressed: onSubmit,
  child: const Text('Submit'),
)

// ✅ Correct when a documented variant is needed:
ElevatedButton(
  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
    backgroundColor: WidgetStatePropertyAll(context.colors.feedbackError),
  ),
  onPressed: onDelete,
  child: const Text('Delete'),
)
```

### Shared-component contract

The public shared-component API and its component theme are the canonical component catalogue. Before creating a control, surface, dialog, sheet, or navigation element, search the existing shared widgets and component themes. Do not create a look-alike local implementation merely because its first consumer is a new screen.

Every shared component must have a short contract in its public API documentation or adjacent source comment that names:

- **Owner and intended role:** the component/theme responsible for the visual and behavioural contract.
- **Supported variants:** named variants only; a variant represents a stable product meaning, not a one-screen colour or spacing override.
- **Applicable states:** default plus disabled, loading, error, focused, selected, pressed, or validation states where the component supports them.
- **Accessibility and content behaviour:** semantic role and label expectations, minimum target where interactive, directionality, and overflow/wrapping behaviour at supported text scales.
- **Validation owner:** the widget test, golden test when feasible, or documented runtime evidence that protects the contract.

Create a new shared component only when at least two credible consumers share the same visual, semantic, and behavioural contract. Otherwise keep the component local, consume the established tokens/themes, and promote it only when the contract becomes genuinely shared.

### Screen-state presentation contract

Data-driven screens must present loading, empty, error, and success/data states with a consistent intent. A feature may choose the composition appropriate to its content, but it must not invent contradictory behaviour:

- **Loading:** communicate progress without implying data that is not available; preserve stable geometry where practical.
- **Empty:** explain what is absent and provide the next meaningful action when one exists.
- **Error:** use user-safe language, preserve useful existing content when possible, and place retry/recovery with the failed content rather than as an unrelated global control.
- **Success/data:** confirm a completed destructive or high-consequence action when the result is not otherwise obvious; do not use transient confirmation as the only durable result when the user must verify it later.

When two or more screens need the same state presentation, extract or extend a shared state component with the contract above. A new visual treatment requires an approved reference or documented product reason and validation in its applicable states.

---

## Adding new tokens: the workflow

1. **Identify the role.** Name what the value represents in design terms, not its pixel value. `stackFormField` not `gap16`.
2. **Check existing tokens.** Is there already a token for this role? Can an existing token serve with a documented justification?
3. **Propose the token.** Name, purpose, value, affected themes (light/dark), and example consumers.
4. **Implement in the correct tier.** Primitive in `primitives.dart`, semantic in the appropriate `ThemeExtension`, component-level in the component theme.
5. **Validate.** Test at supported text scales and in both themes. Ensure the token works correctly in its consumers.
6. **Document.** Add to `docs/design_tokens.md` with category, name, value, and usage description.

---

## Anti-patterns

| ❌ Anti-pattern | ✅ Correct approach |
|---|---|
| `Color(0xFF2563EB)` in a widget | `context.colors.actionPrimary` |
| `TextStyle(fontSize: 14)` inline | `context.text.bodyMedium` |
| `SizedBox(height: 16)` without explanation | `SizedBox(height: context.space.stackFormField)` or a named constant with comment |
| `EdgeInsets.all(16)` scattered across screens | `context.space.insetCard` when it represents card padding |
| `BorderRadius.circular(12)` inline | `context.shape.radiusControl` |
| Importing `Palette` in a feature file | Access through `context.colors.*` |
| Creating a token to hide a one-off number | Use a private named constant with a comment |
| Copying CSS pixel values without interpretation | Map to semantic tokens by design role |
| `Theme.of(context).brightness == Brightness.dark` checks in widgets | Use semantic tokens that vary by theme automatically |
