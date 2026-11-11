# Screen construction workflow

Use this workflow for a new phone screen or a material screen-layout change. It is intentionally a decision sequence, not a widget checklist.

## Scope guard

Layout and cross-device consistency work changes UI composition only: constraints, scroll ownership, insets, tokens, shared visual widgets, and the tests/evidence that prove them.

Do **not** change business logic, Riverpod notifiers, API contracts, GoRouter routes, platform plugins, or dependencies unless the measured defect proves those layers are the root cause. Unrelated refactors during a layout fix are how screens fragment across devices.

## 1. Establish the layout contract before coding

Read the approved reference and identify:

- the hierarchy and dynamic states (loading, empty, error, long content, authentication/permission denial);
- the one scroll owner and any intentionally pinned header, action, or bottom surface;
- content that can grow because of text scale, localization, server data, or user input;
- intended artwork/image aspect ratios and crop behaviour;
- system-bar, home-indicator, gesture-navigation, and keyboard interactions;
- fixed component contracts such as icon box, minimum hit target, border, avatar, or branded artwork ratio.

Copy the template below into the task or PR. Filling it avoids “fixing” a child when the actual fault is an ancestor with the wrong constraint or scroll model.

### Layout contract template

```markdown
## Layout contract — <ScreenName>

- **Available region:** (e.g. full scaffold body / sheet / nested navigator tab)
- **Inset owner:** (which widget owns SafeArea / system exclusion; background edge-to-edge? yes/no)
- **Scroll owner:** (single ListView / CustomScrollView / none — viewport-driven)
- **Growth policy:** (what grows with text scale, locale, or server data)
- **Overflow policy:** (scroll / wrap / ellipsis with detail destination / bounded clip — name which)
- **Keyboard policy:** (resizeToAvoidBottomInset, bottom action treatment, focused-field scroll)
- **Named fixed dimensions:** (token or private constant + why)
- **Adverse states to verify:** (loading, empty, error, long content, text 1.3 and 2.0, keyboard open, compact viewport)
- **Device pair (if discrepancy report):** (e.g. realme 8 vs Pixel 10a — MediaQuery captured before edit? yes/no)
```

## 2. Inspect before changing

Find the route/shell, existing screen, reusable widgets, token/theme extensions, and the direct parent layout. Determine whether the page is already inside `SafeArea`, a `Scaffold`, a sheet, a nested navigator, a scroll view, or a constrained component. Prefer existing shared shells such as `BrandScreen` / scaffold-body `SafeArea` over inventing a new per-screen inset scheme.

Check `BoxConstraints` in Flutter DevTools or with temporary layout diagnostics when behaviour is unclear. Do not use a device name or a screenshot dimension as proof of the constraints reaching a widget.

For a reported device discrepancy, capture paired `MediaQuery` data on both configurations **before** editing (see chapter 06 worksheet).

## 3. Choose the composition from the contract

| Need | Preferred approach | Avoid |
| --- | --- | --- |
| Variable vertical content | One `ListView`, `CustomScrollView`, or a `SingleChildScrollView` with bounded children | A non-scrollable `Column` whose total height assumes one device |
| A body and a bottom action sharing finite height | `Expanded`/`Flexible` inside a bounded `Column`, or slivers | `Expanded` inside an unbounded scrollable |
| Stable visual geometry | `AspectRatio`, `ConstrainedBox`, or a documented component dimension | Deriving the geometry from full-screen height |
| A component adapts to its allocated area | `LayoutBuilder` with a named, tested threshold | Reading global window width from a narrow parent |
| Layered visual content | `Stack` with constraints and deliberate hit-testing/semantics | Absolute coordinates chosen for one handset |
| Large or lazy collections | `ListView.builder` / slivers | Building a large list in a `Column` inside a scroll view |

## 4. Implement at the right layer

Keep feature state in the established Riverpod/feature architecture; the UI composes state and delegates actions. Place reusable visual contracts in their appropriate shared layer only after confirming at least two consumers truly share behaviour, semantics, and validation needs. A one-off screen detail should stay local.

Use existing semantic `AppSpace`, `AppSize`, `AppShape`, typography, and component-theme contracts where they fit. Add a token only for a recurring design concept, not to hide an arbitrary number. A fixed number that belongs only to a component may be a private named constant with an explanatory comment or test.

## 5. Verify adverse states, not just the artboard

Exercise long text, large text scale, empty/error/loading states, keyboard open, narrow/tall phones, and relevant Android/iOS inset states. Check for `RenderFlex` overflow, hidden taps, clipped text, duplicate safe padding, image distortion, and focus hidden behind a keyboard.

Use the deterministic helpers in `test/helpers/` for viewport, text-scale, and inset-profile widget matrices. Capture emulator/device screenshots with `scripts/device_matrix.sh` (see chapters 05 and 06). Do not claim device parity from a single emulator or declare a change finished because a static screenshot looks correct.

### Material layout / Phase 5 completion checklist

A material screen or layout change is **not complete** until all of the following are true:

- [ ] Layout contract template above is filled in the task/PR.
- [ ] Widget tests cover **compact** and **regular** logical viewports (`TestViewports`).
- [ ] Widget tests cover text scale **1.0**, **1.3**, and **2.0** (`TestTextScales`).
- [ ] If the screen has inputs: keyboard-open scenario exercised (helper inset profile and/or emulator).
- [ ] Emulator/simulator screenshot captured via `scripts/device_matrix.sh` with validated runtime `MediaQuery` metadata and the chapter 05 naming convention.
- [ ] If the change affects SafeArea ownership, keyboard avoidance, pinned footers, platform typography, or system UI: Android emulator **and** iOS simulator evidence captured.
- [ ] For a reported device pair (e.g. realme 8 / Pixel 10a): both devices’ `size`, `padding`, `viewPadding`, `viewInsets`, `devicePixelRatio`, `textScaler`, and navigation mode were recorded **before** the layout edit.
- [ ] No device-specific padding offsets, platform padding branches, or viewport-percentage spacing/fonts were introduced (see chapter 03 forbidden fixes).
