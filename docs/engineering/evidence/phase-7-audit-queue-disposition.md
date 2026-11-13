# Phase 7 Audit Queue & Regression Prevention Evidence

**Date:** 2026-11-13  
**Status:** Completed  
**Scope:** Conformance Plan Phase 7 — Prevent regression and retire the audit queue (MNT-01)

---

## 1. Regression Prevention Guards & Automation

### 1.1 Extended Guards (`scripts/verify_layout_tokens.py`)
The automated static guard was extended from basic token name deprecation to a comprehensive multi-policy guardian:
- **Presentation Primitive Imports & References:** Blocks `tokens/primitives/*`, `Palette`, `Prim`, `TypeScale`, and `AppTypography` in presentation code.
- **Inline Styling:** Blocks raw `TextStyle(...)` and raw Material `Colors.*` in presentation widgets.
- **Unsafe Viewport-Height Formulas (LAY-01):** Blocks `MediaQuery.sizeOf(context).height * <factor>` and `MediaQuery.of(context).size.height * <factor>` in presentation code, enforcing content-driven and constraint-driven sizing.
- **Disabled / Replaced Text Scaling (TYP-01):** Blocks `TextScaler.noScaling` and `TextScaler.linear(...)` in presentation code to preserve platform nonlinear text scaling.
- **Architecture Boundaries (ARC-01):** Blocks data imports and exports in presentation code (`/presentation/`) and everywhere outside `data/` and the approved composition boundary (`lib/core/providers/repository_providers.dart`).
- **Component-Theme & Documented Exceptions:** Preserves component-private constants (e.g., aspect ratios, hit regions) and allows documented inline exemptions (`// allow-guard-exception`).

### 1.2 Targeted Guard Regression Tests (`scripts/test_verify_layout_tokens.py`)
Full unit test suite covering:
1. `test_allows_documented_component_constant` — passes
2. `test_rejects_device_specific_presentation_branch` — passes
3. `test_rejects_disabled_text_scaling` — passes
4. `test_rejects_linear_text_scaling_in_presentation` — passes
5. `test_rejects_unsafe_viewport_height_formula` — passes
6. `test_rejects_presentation_data_import` — passes
7. `test_allows_approved_composition_boundary_data_import` — passes
8. `test_allows_documented_guard_exception` — passes

### 1.3 PR Template Checklist (`.github/pull_request_template.md`)
Added `.github/pull_request_template.md` providing a lightweight, actionable checklist linking directly to playbook chapters:
- Layout contract ([02-screen-construction-workflow.md](file:///docs/engineering/playbook/02-screen-construction-workflow.md))
- Design tokens ([04-design-system-and-reference-intake.md](file:///docs/engineering/playbook/04-design-system-and-reference-intake.md))
- Architecture boundaries ([01-app-architecture-and-boundaries.md](file:///docs/engineering/playbook/01-app-architecture-and-boundaries.md))
- Scaling and accessibility ([07-accessibility-and-performance.md](file:///docs/engineering/playbook/07-accessibility-and-performance.md))
- Evidence minimum ([05-visual-validation-standard.md](file:///docs/engineering/playbook/05-visual-validation-standard.md) & [06-testing-device-matrix.md](file:///docs/engineering/playbook/06-testing-device-matrix.md))
- Quality gates execution (`scripts/quality_gates.sh`)

---

## 2. High-Size File Queue Disposition (MNT-01)

| File | Initial Lines | Current Lines | Disposition | Extracted Components / Rationale |
|---|---|---|---|---|
| `my_trips_screen.dart` | 858 | 232 | **Extracted** | Extracted `MyTripsReservationCard` (280 lines), `MyTripsAnywhereCard` (124 lines), and `MyTripsAddStayRow` (67 lines) into `features/reservations/presentation/widgets/`. |
| `welcome_screen.dart` | 437 | 301 | **Extracted** | Extracted `WelcomeMotifLayer` (137 lines) into `features/auth/presentation/widgets/welcome_motif_layer.dart`. |
| `hotel_view_screen.dart` | 415 | 156 | **Extracted** | Extracted `HotelScreenTerminalCard` (108 lines), `HotelViewPrivacyCard` (62 lines), and `HotelViewRegistrationFormCard` (56 lines) into `features/check_in/presentation/widgets/`. |
| `verification_landing_screen.dart` | 398 | 282 | **Extracted** | Extracted `VerificationStepCard` (116 lines) into `features/verification/presentation/widgets/verification_step_card.dart`. |
| `properties_listing_screen.dart` | 400 | 400 | **Retained as Cohesive** | Orchestrates catalog search, filter chips, horizontal popular rail, and vertical catalog. Sub-cards already delegated to `PropertyCard`. |
| `finder_onboarding_sheet.dart` | 348 | 348 | **Retained as Cohesive** | Modal coordinator for 2-step onboarding. All sub-steps already decomposed into `FinderTermsStepView`, `FinderAddressStepView`, and `FinderBlockedView`. |
| `verification_final_check_screen.dart` | 384 | 384 | **Retained as Cohesive** | Verification polling lifecycle coordinator. Uses shared `VerificationStepper`, `VerifyHourglass`, `VerifyStatusRows`, `BrandSecurityNote`. |
| `reservation_detail_screen.dart` | 365 | 365 | **Retained as Cohesive** | Reservation detail view. Subtrees already extracted into `ReservationPropertyCard`, `ReservationInfoCard`, `ReservationActionsCard`, and `ReservationStatusBadge`. |
| `property_card.dart` | 310 | 310 | **Retained as Cohesive** | Component-private contract implementing the dual presentation variants (horizontal popular card and vertical recommended card). |
| `property_screen.dart` | 303 | 303 | **Retained as Cohesive** | Booking orchestrator screen, already fully broken into 10 sub-widgets in `features/booking/presentation/widgets/`. |

---

## 3. Verification & CI Health

- `python3 scripts/test_verify_layout_tokens.py`: 8/8 tests pass.
- `python3 scripts/verify_layout_tokens.py`: 314 files scanned, 0 violations.
- `dart format --output=none --set-exit-if-changed .`: 448 files formatted, 0 changes needed.
- `flutter analyze --fatal-infos`: 0 issues found.
- `flutter test`: 659/659 tests pass.

