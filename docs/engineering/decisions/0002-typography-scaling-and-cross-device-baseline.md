# ADR 0002: Typography Scaling and Cross-Device Baseline Policy

- **Status:** accepted
- **Date:** 2026-11-11
- **Owner:** Mobile Engineering / Design
- **Decision scope:** Android and iOS phone typography, in-app reading preferences, visual validation, and device-discrepancy diagnosis

---

## Context

The same nominal operating-system text-size setting can produce different effective Flutter typography on different phones. Causes include system font-size and display-size settings, OEM configuration, logical window geometry, font fallback, and Android's nonlinear text scaling. An in-app preference can also be relative to the platform setting, or can replace it, depending on its implementation.

An approved design reference needs a reproducible comparison baseline. At the same time, the default application experience must respect the user's accessibility preference. Treating a label such as "Normal" as proof of a common scale across devices is not sufficient.

## Decision

1. The default text-size behaviour is **Follow system**. It preserves the platform `TextScaler`, including nonlinear scaling where supplied by the platform. It must not silently reset the user to a fixed linear scale merely to reproduce a design screenshot.
2. A named in-app value such as "Normal" must not be used as a synonym for a cross-device design baseline if it inherits the system setting. Prefer the label **Follow system**. Any alternative must state whether it is a user-selected absolute override or a relative accessibility adjustment.
3. If an app offers relative reading-size adjustments, it must preserve the platform strategy as far as the Flutter API permits. It must not derive all text sizes from `textScaler.scale(1.0)` and assume that result represents larger text sizes; Android nonlinear scaling makes that assumption false.
4. Visual reference parity is evaluated only against a recorded **reference typography baseline**: app version and font assets, locale, OS font size, OS display size, in-app text preference, logical window/insets, and effective `TextScaler` probes at 12, 16, 20, and 24 logical pixels.
5. Under the reference baseline, devices must preserve the approved hierarchy, wrapping intent, spacing relationships, readability, touchability, and non-overlap. Exact physical-pixel identity and identical glyph rasterization are not required.
6. Outside the reference baseline, the application must remain accessible and usable at the platform maximum scale. A user-selected accessible scale is not a visual-parity defect.

The detailed workflow and evidence are defined by playbook chapters 02, 03, 05, 06, and 07.

## Alternatives considered

- **Remove the in-app reading preference:** rejected. This removes one user control but does not normalize system font size, display size, OEM font behaviour, or nonlinear scaling.
- **Force all devices to `TextScaler.linear(1.0)`:** rejected. It creates a baseline screenshot at the cost of overriding accessibility preferences.
- **Treat same setting labels as equal typography:** rejected. Labels such as "Normal" are not measured values and cannot prove comparable effective scaling across platforms or OEMs.

## Consequences

- Design review gains a repeatable, cross-device baseline rather than compensating for one handset with a different in-app preference.
- Product and implementation work must make the default preference semantics explicit and preserve the platform scaling strategy.
- Reported device discrepancies require measured typography provenance before a layout, token, or device-specific change is considered.
- Existing preferences and screens are not changed by this ADR alone; implementation changes require a separately scoped proposal and validation against this decision.

## Rollback and review

Review when the in-app reading-preference model changes, a new Flutter `TextScaler` capability changes composition options, or a verified device discrepancy cannot be explained by the recorded baseline. Mobile Engineering and Design jointly own the review.
