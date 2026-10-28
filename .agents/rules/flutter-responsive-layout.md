---
trigger: always_on
description: Mandatory Flutter responsive layout, constraints, system UI safe-area, and cross-device consistency rules.
---

# Flutter Responsive Layout Rule

> Companion to `ARCHITECTURE.md`, `CODE_STANDARDS.md`, and `DESIGN_SYSTEM.md`.
> Read and apply the **`flutter-build-responsive-layout`** skill when building or redesigning any screen.

---

## A. Layout and Constraints

- Use Flutter logical pixels. Never assume a physical pixel ratio or fixed screen density.
- Prefer `LayoutBuilder` and its `constraints` when layout decisions depend on **available parent space**.
- Use `MediaQuery.sizeOf(context)` only when **window-level** dimensions are genuinely needed.
- Do not scale spacing or font sizes with arbitrary `screenWidth * factor` or `screenHeight * factor` formulas. Use the project's semantic tokens (`context.space`, `context.sizes`) instead (see `DESIGN_SYSTEM.md`).
- Use `Expanded`, `Flexible`, and `FractionallySizedBox` to distribute space proportionally within `Row`, `Column`, and `Flex`.
- Wrap unbounded vertical content in `SingleChildScrollView`, `ListView.builder`, or `CustomScrollView` to prevent bottom-overflow errors.
- Avoid unnecessary fixed-height containers. Use `IntrinsicHeight` sparingly and prefer constraint-based sizing.

---

## B. System UI and Safe Areas

- Follow the application's existing edge-to-edge and system-bar policy as defined in the app theme.
- Use `SafeArea` at top-level scaffold bodies when content must avoid system overlaps. Do not nest redundant `SafeArea` widgets.
- Distinguish between `MediaQuery.paddingOf` (static insets from notch/status bar), `MediaQuery.viewPaddingOf` (always includes system bars), and `MediaQuery.viewInsetsOf` (keyboard). Use the correct one for each purpose.
- Never add device-specific hardcoded offsets (e.g. `SizedBox(height: 34)` for a notch). Rely on the framework-provided insets.
- Validate that layouts remain usable when the software keyboard is visible: scrollable content should not be obscured, and input fields should remain accessible.

---

## C. Typography and Accessibility

- Use the project's typography system (`context.text.*`) and font definitions from `DESIGN_SYSTEM.md`. Do not introduce inline `TextStyle` with hardcoded sizes.
- Allow text to wrap naturally via `Expanded`, `Flexible`, or unconstrained `Text` widgets with appropriate `maxLines` and `TextOverflow`.
- Respect `MediaQuery.textScalerOf(context)`. Use `minHeight` constraints instead of fixed heights on text-containing controls so large accessibility fonts do not clip.
- Do not set `textScaleFactor: 1.0` or disable accessibility scaling merely to match a static design comp or force golden tests to pass.

---

## D. Design Consistency

- Follow the approved client design and existing reference implementations within this codebase.
- Reuse semantic design tokens (`context.colors`, `context.text`, `context.space`, `context.sizes`, `context.shape`) as specified in `DESIGN_SYSTEM.md`. Do not introduce raw numbers (see the anti-patterns in `CODE_STANDARDS.md § 4.5` and the `flutter-semantic-layout-tokens` skill).
- Use fixed dimensions where the design explicitly requires them (e.g. avatar diameters, icon sizes from `context.sizes`). Use flexible constraints where content must adapt.
- Reuse shared components from `core/widgets/` for UI elements used in two or more features.
- Do not introduce responsive-layout packages (`responsive_builder`, `flutter_screenutil`, etc.), new abstraction layers, or device-type checks unless explicitly approved. The installed `flutter-build-responsive-layout` skill covers the required patterns using framework widgets.

---

## E. Cross-Device Validation

- Validate important screens on the project's reference device **and** at least one additional Android device configuration with a different logical viewport size.
- Test at the default text scale **and** at an elevated scale (e.g. 1.3× or the device's largest setting).
- Use golden tests for stable shared widgets and components where the project already maintains them. Do not add golden tests for screens that are still iterating.
- Distinguish genuine layout defects (overflow, clipping, misalignment) from expected differences in system UI chrome, font rendering, and device configuration. Document the distinction when reporting results.
- Never claim universal pixel-perfect rendering based on testing a single device or emulator.

---

## F. AI Implementation Workflow

For every new or redesigned screen:

1. **Inspect** the existing implementation, this rule, and related project rules (`ARCHITECTURE.md`, `CODE_STANDARDS.md`, `DESIGN_SYSTEM.md`).
2. **Read and apply** the `flutter-build-responsive-layout` skill when the screen requires adaptive or constraint-based layout decisions.
3. **Identify** layout constraints, safe-area requirements, and device-dependent edge cases before writing code.
4. **Implement** the smallest maintainable change. Prefer modifying existing widgets over creating parallel implementations.
5. **Validate** at the reference viewport and at least one additional configuration (different device size or text scale).
6. **Run** `flutter analyze` and relevant tests. Report any remaining visual differences with context.

> **Scope guard:** Do not modify business logic, navigation, state management, or verification functionality when the task is limited to visual or layout consistency.

---

## Conflict Resolution

- If this rule and the installed skill diverge, follow this project rule — it reflects the approved design and architecture.
- If this rule and `DESIGN_SYSTEM.md` overlap on token usage, defer to `DESIGN_SYSTEM.md` for token names and values.
- If this rule and `CODE_STANDARDS.md` overlap on widget standards, defer to `CODE_STANDARDS.md` for coding patterns.
