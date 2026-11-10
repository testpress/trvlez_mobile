# Screen construction workflow

Use this workflow for a new phone screen or a material screen-layout change. It is intentionally a decision sequence, not a widget checklist.

## 1. Establish the layout contract before coding

Read the approved reference and identify:

- the hierarchy and dynamic states (loading, empty, error, long content, authentication/permission denial);
- the one scroll owner and any intentionally pinned header, action, or bottom surface;
- content that can grow because of text scale, localization, server data, or user input;
- intended artwork/image aspect ratios and crop behaviour;
- system-bar, home-indicator, gesture-navigation, and keyboard interactions;
- fixed component contracts such as icon box, minimum hit target, border, avatar, or branded artwork ratio.

Write a short task or PR note: available region, inset owner, scroll owner, growth policy, overflow policy, keyboard policy, and named intentional dimensions. This avoids “fixing” a child when the actual fault is an ancestor with the wrong constraint or scroll model.

## 2. Inspect before changing

Find the route/shell, existing screen, reusable widgets, token/theme extensions, and the direct parent layout. Determine whether the page is already inside `SafeArea`, a `Scaffold`, a sheet, a nested navigator, a scroll view, or a constrained component.

Check `BoxConstraints` in Flutter DevTools or with temporary layout diagnostics when behaviour is unclear. Do not use a device name or a screenshot dimension as proof of the constraints reaching a widget.

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

Run the checks and capture the evidence required by the visual-validation chapters. Do not claim device parity from a single emulator or declare a change finished because a static screenshot looks correct.

Exercise long text, large text scale, empty/error/loading states, keyboard open, narrow/tall phones, and relevant Android/iOS inset states. Check for `RenderFlex` overflow, hidden taps, clipped text, duplicate safe padding, image distortion, and focus hidden behind a keyboard.

