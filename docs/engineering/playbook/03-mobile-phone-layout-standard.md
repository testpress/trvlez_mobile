# Android and iOS phone layout standard

## Rendering model

Flutter layout values are logical pixels. `devicePixelRatio` maps logical pixels to physical display pixels; it is **not** a multiplier for padding, fonts, radii, or component heights. A 48 logical-pixel target is intentionally 48 logical pixels on both a dense Android display and an iPhone display.

`MediaQuery.sizeOf(context)` describes the Flutter window. It does not promise that a descendant owns that entire rectangle. A widget in a bottom sheet, a card, an `Expanded` region, or a nested navigator must make size decisions from its parent `BoxConstraints` when its available space matters.

```dart
// Incorrect: card content changes because of the whole window, even when the
// card is allocated a smaller width.
final cardWidth = MediaQuery.sizeOf(context).width * 0.9;

// Correct when the card's own allocation controls its layout.
LayoutBuilder(
  builder: (context, constraints) {
    final isCompactCard = constraints.maxWidth < 320;
    return isCompactCard ? const CompactCardBody() : const StandardCardBody();
  },
)
```

Do not add `LayoutBuilder` merely because a widget is visual. If a `Text`, `Row`, `Column`, or image can size naturally under its existing constraints, the simpler tree is usually clearer.

## Insets and edge-to-edge ownership

Android cut-outs, status/navigation modes, gesture navigation, iOS status/home-indicator regions, and keyboard visibility create different kinds of insets:

- `viewPadding` is the stable system-area padding, including areas that can remain obscured when a keyboard appears.
- `padding` is the safe padding after the current view state is applied.
- `viewInsets` is obscured space, notably the on-screen keyboard.

### Ownership policy (locked)

1. **One surface boundary owns system exclusion.** Prefer an existing shared shell (`BrandScreen`, scaffold body `SafeArea`, or sheet `useSafeArea` / wrapping `SafeArea`) rather than inventing a new per-screen inset scheme.
2. **Decorative backgrounds may paint edge-to-edge** behind status/navigation bars while interactive content remains inside the owned `SafeArea`.
3. **Nested duplicate safe padding is a defect.** A page whose scaffold body is already protected must not add identical top/bottom system padding inside each section.
4. **Never write a guessed device offset** such as `24`, `34`, or `48` to account for a status bar, home indicator, or gesture area. Use framework insets.

```dart
// A page chooses the content boundary once. The decorative background may
// extend edge-to-edge; the interactive content remains protected.
Scaffold(
  body: Stack(
    children: [
      const Positioned.fill(child: BrandedBackground()),
      SafeArea(
        child: ListView(
          padding: context.space.insetScreen,
          children: const [ProfileHeader(), ProfileForm()],
        ),
      ),
    ],
  ),
)
```

## Fixed, bounded, and proportional dimensions

Fixed logical dimensions are appropriate for deliberate component contracts: icon boxes, avatar diameter, stroke width, minimum target size, and an approved button height. Name or theme them at the layer that owns the contract, and verify them under text scale and platform insets.

Use a ratio or proportional space only when the intended design is genuinely proportional. Images and camera guides often have a stable aspect ratio; a page’s arbitrary `screenHeight * 0.42` rarely has a stable product meaning.

```dart
// Incorrect: content competes with a viewport-derived height and will fail on
// short screens, with a keyboard, or with large text.
SizedBox(height: MediaQuery.sizeOf(context).height * 0.72, child: form);

// Correct: content drives height and a single scroll owner handles shortage.
SingleChildScrollView(
  padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
  child: Padding(
    padding: context.space.insetScreen,
    child: form,
  ),
)
```

Use `ConstrainedBox` to express a legitimate minimum or maximum. For example, a readable text column may have a maximum width, or a branded control may have a minimum touch target. Constraints communicate intent more clearly than calculating a percentage for every device.

## Vertical space: content versus viewport

First decide whether the content is content-driven or viewport-driven.

- Content-driven forms, lists, and localized text should grow and scroll when needed.
- Viewport-driven visualizations can distribute a bounded remaining region using `Expanded`, `Flexible`, `Spacer`, or slivers.

`Expanded` and `Flexible` require finite main-axis constraints. They are invalid as a cure for an overflow inside a vertical scroll view because that scroll view deliberately provides unbounded height.

```dart
// Correct: bounded page body splits its remaining finite space.
Column(
  children: [
    const ScreenHeader(),
    Expanded(child: ResultsList()),
    const PersistentActionBar(),
  ],
)
```

When a header needs to scroll with content, a `CustomScrollView` with slivers is normally clearer than nesting a `ListView` inside a `SingleChildScrollView`. Give each axis one owner; nested scrolling requires an explicit product need and deliberate coordination.

## Text and font metrics

Text is not a fixed-height rectangle. Font ascent/descent, locale, fallback fonts, bold weight, and system text scale change its occupied region. Use `Text` wrapping and a container/scroll policy that preserves readable content. Choose ellipsis only where truncation is an approved product behaviour (for example a one-line row label with a full detail destination).

Prefer a minimum height with flexible growth over a fixed height that clips when text scale grows:

```dart
// Incorrect: fixed height clips at large text scale.
SizedBox(
  height: 40,
  child: Text('Welcome back', style: context.text.titleMedium),
)

// Correct: minimum height; content may grow.
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 40),
  child: Text('Welcome back', style: context.text.titleMedium),
)
```

Do not globally use `TextScaler.noScaling`, fixed `TextStyle.height`, `FittedBox`, or tiny font sizes merely to reproduce a baseline screenshot. If a compact component truly has a bounded label contract, document its overflow behaviour and test it at supported text scales. See also chapter 07.

## Keyboard and input flows

For every input page, decide who owns:

1. `Scaffold.resizeToAvoidBottomInset`;
2. safe-area treatment of any persistent bottom action;
3. the scroll owner and focused-field visibility;
4. bottom padding derived from `MediaQuery.viewInsetsOf(context).bottom` where content can be obscured.

The keyboard is transient. Do not bake its height into design tokens or infer it from an Android/iOS model name. Test both a focused low field and an unfocused form, on Android navigation modes and iOS home-indicator devices where relevant. Use the platform-appropriate `TestInsetProfiles.androidKeyboardOpen` or `.iOSKeyboardOpen` in widget tests (see chapter 05).

## Forbidden device-difference fixes

These patterns produce fragmented UI across phones. Do not introduce them to “make it look right” on one device:

| Forbidden | Why | Do instead |
| --- | --- | --- |
| `Platform.isAndroid` / `Platform.isIOS` branches that change padding, gaps, or font sizes | Couples layout to OS label, not constraints/insets | Use `SafeArea`, `MediaQuery` insets, and shared tokens |
| Device-name or model checks (`realme`, `Pixel`, etc.) for layout | Untestable; fails on the next OEM | Measure constraints/insets; fix ownership |
| Guessed notch/home-indicator offsets (`SizedBox(height: 34)`) | Wrong on other inset modes | Framework `padding` / `viewPadding` |
| `MediaQuery.sizeOf(context).width * factor` for spacing or fonts | Breaks nested parents and density-independent contracts | Semantic tokens; parent `BoxConstraints` |
| `TextScaler.noScaling` / forced scale 1.0 to match one screenshot | Breaks accessibility and other devices | Flexible containers and scroll |
| Installing `flutter_screenutil`, `sizer`, `responsive_builder`, or similar for phone consistency | Global scaling fights tokens and insets | Constraint-led composition in this chapter |

## Diagnostics and acceptance

Use Flutter DevTools layout inspection and debug paint/overflow diagnostics while resolving a constraint issue. The diagnostic question is: *what constraints and insets reach this widget?*—not *what number looked right on the first phone?*

Before acceptance, complete the chapter 02 material-layout checklist: compact + regular viewports, text scale 1.0, 1.3, and 2.0, plus platform-maximum runtime validation when it exceeds 2.0; keyboard when inputs exist; and paired `MediaQuery` capture for reported device pairs. Record exact logical viewport and evidence per chapters 05 and 06.
