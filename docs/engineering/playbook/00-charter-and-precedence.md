# Charter, scope, and precedence

## Intended outcome

TrvlEz phone UI must preserve the approved hierarchy, spacing relationships, content readability, touchability, and non-overlap behaviour across supported Android and iOS configurations. It is not an objective to make every physical-pixel screenshot identical: system bars, OEM rendering, fonts, GPU composition, and accessibility settings legitimately vary.

### Supported-window envelope

The product target is Android and iOS **phone** UI in portrait, across the phone configurations in chapter 06. There is no separate tablet, foldable, or landscape design system in this playbook.

- On a supported phone window, preserve hierarchy, readability, touchability, and non-overlap at the system's maximum text scale.
- In split-screen, freeform, landscape, foldable, or tablet windows, an alternate layout is not implied. The existing phone composition must still fail safely: use constraints and scrolling, avoid device/OS branches, and do not overlap system UI or crash. Pixel parity and optimal use of the larger form factor are not promised.
- A product decision to support an alternate form factor, orientation, or window class requires an approved reference, a layout contract, and an extension of the device matrix before implementation.

## Precedence

Resolve a conflict in this order:

1. Product requirements, approved client references, privacy/security obligations, accessibility obligations, and platform/framework correctness.
2. A documented TrvlEz architecture decision in `docs/engineering/decisions/`.
3. This playbook and established source-code contracts.
4. Current official Flutter/Dart documentation and a verified official procedural skill.
5. Community guidance, generic AI advice, or aesthetic heuristics.

Higher authority does not excuse an unexplained trade-off. When the implementation deliberately diverges from a reference or playbook rule, record the affected component or screen, why it is necessary, what configurations were checked, and when it should be reconsidered.

## Non-negotiable engineering principles

- Build from constraints and content behaviour, not a formula that scales every value from window width or height.
- Treat a fixed logical dimension as a legitimate component contract only when it has an owner, semantic reason, and validation coverage. Do not label every number “magic”; do not leave unexplained screen-relative numbers either.
- Inspect the parent’s constraints, scroll owner, and system-inset ownership before changing a child’s `width`, `height`, `Expanded`, `Flexible`, `Positioned`, or `MediaQuery` calculation.
- Preserve design intent, but never suppress system text scaling, safe-area handling, overflow, or keyboard behaviour solely to match one screenshot.
- Support the platform's maximum text scale on supported phone configurations. The automated widget-test floor is 2.0x; where a platform exposes a larger accessibility range, validate that maximum on the platform runtime as described in chapters 05–07.
- Treat a named text-size choice as user preference, not evidence of a common cross-device baseline. Use the recorded typography baseline from ADR 0002 when comparing an approved reference or diagnosing a device pair.
- Make one layer own each concern: route/shell, page scroll, system insets, keyboard avoidance, theme/token lookup, and feature state must not be independently reimplemented by descendants.
- Evidence is part of completion. State what was tested and what was not possible to test; emulator evidence and physical-device evidence are different claims.

## Conditional choices, not blanket rules

`LayoutBuilder` is appropriate when a component must choose based on the space actually allocated by its parent. It is not required for ordinary content that naturally sizes itself.

`MediaQuery.sizeOf(context)` is appropriate for window-level decisions such as full-screen composition or platform insets. It is not a substitute for parent constraints inside a card, sheet, tab body, split view, or nested navigator.

`SafeArea` is appropriate at the boundary that owns system exclusion. It is not automatically correct on every nested widget, and nested safe areas can double-count protection.

Scrolling is the preferred answer when content is inherently variable or can exceed available vertical space. Shrinking, clipping, or hard height caps require an explicit content and accessibility rationale.

## Completion contract for future UI work

A screen or shared-component change is complete only after the implementation has a short layout contract, applicable automated checks have run, and the validation record names the logical viewport, platform/inset state, text scale, and keyboard state where relevant. If a required check cannot run, report the limitation rather than inferring success.

