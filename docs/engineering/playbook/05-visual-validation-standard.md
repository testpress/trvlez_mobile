# Visual validation standard

Visual validation is a layered evidence process. Widget tests establish deterministic structure/behaviour; goldens detect controlled pixel regressions; integration tests exercise real app flows; emulators and physical devices expose platform/window/system UI behaviour. No one layer replaces the others.

## Required evidence by change type

| Change | Minimum evidence |
| --- | --- |
| Pure shared-widget styling | Widget test plus stable golden where deterministic |
| Screen layout or inset/keyboard change | Widget tests, logical viewport screenshots, relevant emulator/device evidence |
| Navigation/input/device-plugin flow | Integration test where feasible plus platform runtime evidence |
| Token/theme-wide change | Targeted component goldens, affected widget tests, and documented baseline update review |

Golden tests use a pinned Flutter/renderer/font environment and deterministic assets/data. They are not trustworthy while CI uses an unpinned moving `stable` SDK. A golden update is a reviewed visual change, never an automatic acceptance action.

Capture screenshots with a stable naming pattern: `<feature>__<state>__<platform>__<logical-width>x<logical-height>__text-<scale>__<inset-state>.png`. Store only approved non-sensitive fixtures; never commit user data, credentials, or device identifiers.

When a mismatch occurs, inspect constraints, insets, text metrics, asset crop, and platform rendering before changing a dimension. Record legitimate platform variance rather than normalizing it with fragile per-device offsets.

