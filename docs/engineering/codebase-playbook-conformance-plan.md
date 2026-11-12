# Codebase Playbook Conformance Remediation Plan

**Status:** proposed
**Created:** 2026-11-11
**Owner:** Mobile Engineering
**Scope:** bring the existing Flutter application into conformance with the accepted engineering playbook and ADRs.
**Primary outcome:** the same screen preserves hierarchy, readable content, touchability, and non-overlap across supported Android and iOS phone configurations without device-specific layout tuning.

---

## 1. How to use this plan

This is the single execution plan for the post-playbook codebase remediation. It is intentionally phased so that each phase solves one coherent problem, has independent acceptance criteria, and can be committed separately. A later agent must:

1. Read `docs/engineering/playbook/00-charter-and-precedence.md` and the chapters named for the phase before editing.
2. Complete phases in order unless a dependency is explicitly waived in a reviewed ADR.
3. Record deviations, unavailable device evidence, and design-reference limitations in the PR/task; do not silently weaken a phase's acceptance criteria.
4. Avoid opportunistic redesigns, dependency upgrades, and unrelated architecture rewrites.

This plan audits current implementation conformance. A passing analyzer, unit suite, or existing token guard is evidence of basic health, not evidence that a screen satisfies the cross-device UI contract.

### Non-goals

- Redesigning approved product screens or changing product copy merely to simplify remediation.
- Adding a global scaling package or device/OEM-specific layout branches.
- Changing API contracts, Riverpod/GoRouter versions, or platform plugins unless a phase proves they are the root cause.
- Claiming physical-device, screenshot-parity, or localization/RTL validation without the required evidence.

---

## 2. Audit baseline and evidence

### Commands run on 2026-11-11

| Check | Result | Interpretation |
| --- | --- | --- |
| `python3 scripts/verify_layout_tokens.py` | Pass; 308 Dart files scanned | Existing guard catches only a narrow set of dangerous patterns. |
| `dart format --output=none --set-exit-if-changed .` | Pass; 405 files unchanged | Formatting is clean. |
| `flutter analyze --fatal-infos` | Pass; no issues | Current analyzer configuration does not enforce all playbook rules. |
| `flutter test` | Pass | Behavioural tests exist; broad matrix/accessibility evidence does not. |

### What the baseline proves and does not prove

The build is healthy. It does **not** prove visual consistency, typography parity, token compliance, accessibility at large text scales, correct component ownership, or physical-device behaviour. The current guards do not detect most findings below.

### Confirmed finding inventory

| ID | Priority | Violation | Evidence | Governing policy |
| --- | --- | --- | --- | --- |
| TYP-01 | P0 | Root app caps the system scaler at 2.0 and turns non-default preferences into `TextScaler.linear(systemBase * factor)`. This discards platform nonlinear scaling and makes a named preference a false cross-device baseline. | `lib/app/app.dart:81-93`; `lib/core/design_tokens/text_scale_preset.dart`; `lib/features/profile/presentation/widgets/text_size_selector.dart:151` | ADR 0002; chapters 00, 03, 05, 06, 07 |
| TYP-02 | P1 | Presentation code bypasses semantic `TextTheme` and primitive-access rules. Audit found 120 presentation/core-widget imports of `tokens/primitives` and 260 inline `TextStyle` calls in 67 presentation files. | Representative: `booking_light_field.dart:3-4, 43-47`; `anywhere_sent_screen.dart:57-76`; `my_trips_screen.dart:60-91` | Chapter 04; chapter 10 §4.5 |
| TOK-01 | P1 | Shared buttons, fields, cards, sheets, and status surfaces are frequently restyled locally rather than being governed by a named component contract. | 101 button constructions and 13 local `*.styleFrom`/`ButtonStyle` constructions in presentation/core widgets; `my_trips_screen.dart:194+` is representative | Chapter 04 shared-component and screen-state contracts |
| LAY-01 | P1 | Four sheets derive maximum height from global window height, rather than their allocated constraints and keyboard/inset contract. | `room_dates_sheet.dart:47`; `check_in_option_picker_sheet.dart:25`; `notifications_sheet.dart:70`; `refer_hotel_bottom_sheet.dart:122` | Chapters 02–03 |
| LAY-02 | P1 | Text-bearing UI uses `FittedBox(BoxFit.scaleDown)`, which can reduce accessibility text rather than wrap, scroll, or use an approved truncation policy. | `brand_alt_line.dart:52`; `brand_verify_screen.dart:262`; `two_step_code_screen.dart:251`; plus welcome/verification capture paths | Chapter 03 forbidden fixes; chapter 07 |
| LAY-03 | P1 | Shared verification shell has a likely axis-token defect: its default bottom padding reads `space.insetScreen.left`; its pinned foot and `resizeToAvoidBottomInset: false` need a large-text/keyboard contract test. | `lib/core/widgets/brand_verify_screen.dart:92-128` | Chapters 02–03 |
| ARC-01 | P1 | Presentation providers instantiate or export data-layer implementations. The existing CI guard deliberately excludes `presentation/providers`, so this boundary bypass is unchecked. | `auth_providers.dart:5`; `properties_providers.dart:4-5`; `reservations_providers.dart:6-9`; `verification_providers.dart:3`; `finder_providers.dart:4`; `profile_providers.dart:4` | Chapter 01 dependency rule |
| ERR-01 | P1 | UI/notifier code surfaces raw exception strings and uses broad/empty catches. This can expose transport/internal details and produces inconsistent error states. | `my_trips_screen.dart:126`; `findr_*` screens/widgets; `refer_hotel_*`; `profile_setup_screen.dart:118`; 22 empty catches across `lib/` | Chapters 01, 04, 10 |
| SEC-01 | P0 | Debug networking logs full request/response bodies; attribution logs click-reference and referral identifiers. Tokens and personal data can therefore reach debug logs. | `core/network/dio_provider.dart:50-54`; `core/attribution/attribution_service.dart:92,106`; test output confirms headers are logged | Chapter 10 §6; chapter 08 privacy policy |
| A11Y-01 | P1 | No Flutter accessibility Guideline API assertions exist despite the playbook requiring them for shared interactive components and material interactive-screen changes. | No `meetsGuideline`, tap-target, label, or contrast guideline use under `test/` or `integration_test/` | Chapters 05 and 07 |
| VAL-01 | P1 | Matrix helpers exist but production adoption is almost absent: 85 test files, 29 direct `MaterialApp` test wrappers, four `TestApp` users, and only `LoginScreen` uses `testMaterialScreenMatrix`. | `test/helpers/*`; `test/features/auth/presentation/screens/login_screen_test.dart` | Chapters 02, 05, 06 |
| VAL-02 | P2 | One golden test protects `AppCard`; one login integration flow exists; no committed runtime capture sidecars or physical-device evidence exists. | `test/core/widgets/app_card_golden_test.dart`; `integration_test/auth_login_flow_test.dart`; `docs/engineering/evidence/` | Chapters 05–06; ADR 0001 |
| MNT-01 | P2 | Several presentation files exceed the chapter 10 review signal of ~300 lines; `my_trips_screen.dart` is 980 lines. This is a review queue, not an automatic split order. | 13 cited presentation files are 312–980 lines; see phase 7 | Chapter 10 §1, §4.1 |

---

## 3. Execution rules common to every phase

- Use `context.colors`, `context.text`, `context.space`, `context.sizes`, and `context.shape` from the established extensions. Do not import `Prim`, `Palette`, `TypeScale`, or other primitive token classes in feature presentation code.
- Do not replace an issue with `TextScaler.noScaling`, `FittedBox`, guessed inset offsets, or OS/model checks.
- Preserve the approved visual intent. If a reference and accessibility requirement conflict, record the conflict and resolve it through product/design and the playbook precedence order.
- Test changed material screens at compact and regular phone viewports, scales 1.0/1.3/2.0, and applicable keyboard/inset profiles. Check the target-platform maximum scale at runtime when it exceeds 2.0.
- Use a layout contract for every material screen change. If a shared component changes, update its contract and its validation owner.
- Keep commits phase-local and reversible. Do not combine a policy change with a broad mechanical migration.

---

## Phase 0 — Correct global typography scaling and preference semantics

**Solves:** TYP-01. This is the first phase because no screen-level typography validation is meaningful while the root app changes the platform scaler.

**Required reading:** chapters 00, 03, 05, 06, 07; ADR 0002.

### Work items

- [x] Add regression tests for `TrvlEzApp` proving that the default setting preserves the inherited platform `TextScaler` strategy and does not cap a supported system maximum at 2.0.
- [x] Replace `TextScalePreset.normal` with an explicit `followSystem` semantic value. Migrate stored settings compatibly so existing users do not lose their selection.
- [x] Remove the `scale(1.0)` → `TextScaler.linear(...)` derivation. If optional relative reading adjustments remain a product requirement, implement a documented strategy that delegates to the platform scaler at each input size; otherwise retain only Follow system until an ADR-approved composition mechanism exists.
- [x] Remove the global 2.0 cap. The app must preserve the platform strategy by default; validation supports 2.0 as a widget-test floor, not as a runtime accessibility ceiling.
- [x] Update the text-size selector labels and preview so it cannot imply that “Normal” is a cross-device baseline. The preview must use the same strategy semantics as production or explicitly say it is illustrative only.
- [x] Add an ADR 0002 evidence fixture/test utility that records 12/16/20/24 `TextScaler` probes without modifying production layout.

### Acceptance criteria

- Default app behaviour is demonstrably Follow system.
- A nonlinear/scaled test double remains nonlinear/scaled after the app builder executes.
- No production code derives a global text scaler from `textScaler.scale(1.0)` or unconditionally creates a linear replacement.
- Preferences screen and app-root tests cover migration, Follow system, and any retained adjustment semantics.
- Android and iOS runtime evidence records the paired typography worksheet before claiming Realme/Pixel parity.

### Do not do in this phase

- Do not retune individual screen font sizes to compensate for the current cap.
- Do not remove the user preference without product approval; ADR 0002 deliberately did not choose removal as the default solution.

---

## Phase 1 — Restore semantic typography and token ownership

**Solves:** TYP-02 and the token half of TOK-01.

**Required reading:** chapters 00, 04, 10.

### Work items

- [ ] Define the missing semantic text roles in `TextTheme` or a documented component-theme contract before migrating callers. Do not create one token per existing literal.
- [ ] Migrate feature presentation and core visual widgets away from `AppTypography`, `TypeScale`, and primitive imports. Use `context.text.<role>` and semantic colour tokens, with `copyWith` only for a documented component variant.
- [ ] Prioritize shared/high-fan-out components first: `AppButton`, text fields, brand shells, cards, status pills, sheet headers, and reusable error/empty states.
- [ ] Replace local `TextStyle(...)` definitions with semantic roles or named component variants. Preserve a component-private constant only when chapter 04 permits it and the reason is documented.
- [ ] Replace direct `Colors.*` use in presentation with token-backed values. Treat framework transparency as a named component-level exception only where the framework requires it.
- [ ] Add a focused static guard that fails feature presentation imports of token primitives and bans inline `TextStyle`/raw colour use except for reviewed allowlisted component-theme files.

### Migration sequence

1. Establish/verify semantic typography roles and component-theme ownership.
2. Migrate `core/widgets/` and app component themes with widget/golden coverage.
3. Migrate feature families one at a time: auth/profile, booking/reservations, check-in/anywhere/verification, findr/properties/home/saved/disputes.
4. Tighten the guard only after the affected family is clean.

### Acceptance criteria

- Feature presentation code has no imports of `app/theme/tokens/primitives/*`, `Prim`, `Palette`, or `TypeScale`.
- Inline `TextStyle` and direct `Colors.*` are absent from feature presentation unless an allowlisted, documented framework exception exists.
- Shared component visual states are protected by widget tests and goldens when feasible.
- The token guard reports both old and new policy failures with actionable file/line output.

---

## Phase 2 — Repair constraint, scrolling, and accessibility-scale layout behaviour

**Solves:** LAY-01, LAY-02, and LAY-03.

**Required reading:** chapters 00, 02, 03, 05, 06, 07; ADR 0002.

### Work items

- [ ] Replace all global-height sheet caps with a documented sheet contract: parent constraints, a single scroll owner, `isScrollControlled` behaviour, keyboard insets, and maximum height only when it represents an approved component constraint.
- [ ] Refactor `room_dates_sheet`, `check_in_option_picker_sheet`, `notifications_sheet`, and `refer_hotel_bottom_sheet` first; then scan for equivalent formulas outside the original four files.
- [ ] Remove `FittedBox(BoxFit.scaleDown)` from text-bearing controls/links unless an approved bounded-label contract explicitly requires it. Prefer wrapping, a scrollable content region, or deliberate ellipsis with a detail destination.
- [ ] Correct `BrandVerifyScreen` bottom-padding ownership and verify its footer remains reachable with keyboard and maximum text scale. Decide whether `resizeToAvoidBottomInset: false` is truly required per screen contract; do not use it as a blanket default.
- [ ] Audit shared shells (`BrandScreen`, `BrandVerifyScreen`, pinned headers, modal sheets) for one SafeArea owner and no duplicate system padding.
- [ ] Add matrix tests for every repaired shared shell before applying screen-family migrations.

### Acceptance criteria

- No `MediaQuery.sizeOf(context).height * <factor>` remains in production layout code unless a documented approved visualisation contract and tests justify it.
- No text-bearing `FittedBox.scaleDown` remains without a documented overflow contract and scale test.
- Changed sheets and shells pass compact/regular, 1.0/1.3/2.0, Android navigation, iOS home-indicator, and keyboard scenarios as applicable.
- Runtime Android and iOS captures exist for the changed shells; no device-specific offsets are introduced.

---

## Phase 3 — Restore architecture boundaries and provider composition

**Solves:** ARC-01.

**Required reading:** chapters 00, 01, 08, 10.

### Work items

- [ ] Define one dependency-composition location per feature or at app/core composition level. That location may import data implementations; presentation providers/screens may only depend on domain interfaces and approved provider contracts.
- [ ] Move data implementation construction/export out of the affected presentation provider files: auth, properties, reservations, verification, findr, and profile.
- [ ] Preserve test override ergonomics by exposing interface-typed providers from the approved composition boundary.
- [ ] Extend the layer-import guard to include `presentation/providers` after the migration. Add explicit allowlisting only for the approved composition location, not a broad directory exemption.
- [ ] Add provider/repository contract tests proving each notifier still receives the domain interface and preserves loading/error/data transitions.

### Acceptance criteria

- No presentation file imports or re-exports a feature `data/` implementation.
- Data implementation construction is discoverable in one documented composition boundary.
- CI rejects future data imports from every presentation subdirectory, including providers.
- Existing notifier behaviour and test overrides remain intact.

---

## Phase 4 — Make error handling and logging user-safe

**Solves:** ERR-01 and SEC-01.

**Required reading:** chapters 00, 01, 04, 08, 10.

### Work items

- [ ] Remove Dio `LogInterceptor` body/header logging or replace it with a redacting structured logger that never emits authorization headers, credentials, passport/NFC content, referral tokens, or personal data.
- [ ] Stop logging raw click references and referral identifiers in attribution flows. Log only event category/status and non-sensitive correlation metadata approved by the privacy policy.
- [ ] Inventory all broad and empty catches. For each, choose one explicit policy: harmless best-effort cleanup with comment, recoverable user error mapped to `AppException`, or defect logged through the approved logger.
- [ ] Replace every UI-facing `error.toString()`/`e.toString()` with a user-safe error mapper and a stable recovery action where meaningful.
- [ ] Consolidate repeated error surfaces into the chapter 04 state contract: loading, empty, error, success/data. Do not make a global error widget until at least two consumers share the same visual, semantic, and behavioural contract.
- [ ] Add tests for redaction, error mapping, retries, and the error/empty/loading states of migrated data-driven screens.

### Acceptance criteria

- Debug logs cannot emit authorization values, request/response bodies containing sensitive data, click references, referral IDs, passport data, or credentials.
- Presentation code has no raw exception-string rendering.
- Every retained empty catch has a documented harmless purpose; all other failures are classified and observable.
- Error states are user-safe, accessible, and include retry/recovery where the operation can be retried.

---

## Phase 5 — Conform shared interactive components and state surfaces

**Solves:** the component-contract half of TOK-01 and the UI consistency requirements of chapters 04 and 07.

**Required reading:** chapters 00, 04, 05, 07, 10.

### Work items

- [ ] Build an inventory of existing shared controls and surfaces: buttons, text fields, cards, dialogs, sheets, app/pinned headers, navigation, error banners, empty states, loading indicators, status pills, and destructive-action confirmations.
- [ ] For each real shared component, document adjacent to the public API its owner, intended role, named variants, applicable states, semantics, target size, overflow/directionality behaviour, and validation owner.
- [ ] Consolidate only genuine duplicates. Examples requiring comparison: booking-specific buttons/fields versus `AppButton`/`AppTextField`, duplicate referral screen/sheet submission forms, and feature-local error banners.
- [ ] Ensure interactive custom widgets use Material/Ink feedback or an equivalent accessible interaction treatment and meet target-size contracts.
- [ ] Standardize loading, empty, error, and success/data treatment per the screen-state presentation contract without forcing unrelated screens into identical layouts.

### Acceptance criteria

- Every retained shared component has the required contract and state coverage.
- A new screen cannot create a look-alike variant through local styling when an owned component contract exists.
- Shared interactive components pass semantic, enabled/disabled, focus, target-size, and large-text tests.
- Duplicate components are either consolidated or explicitly retained with a documented distinct contract.

---

## Phase 6 — Adopt the required validation evidence on real screens

**Solves:** A11Y-01, VAL-01, and VAL-02.

**Required reading:** chapters 00, 02, 05, 06, 07; ADRs 0001 and 0002.

### Work items

- [ ] Convert material-screen tests from ad hoc `MaterialApp` wrappers to `TestApp`/`testAppWithProviders` where the screen requires theme, locale, text-scale, inset, or provider control.
- [ ] Add `testMaterialScreenMatrix` coverage screen-family by screen-family. Start with shared shells and high-risk inputs/pinned-footers: auth, profile, booking, Findr forms, verification capture/review, and reservations.
- [ ] Add usability assertions in each matrix: critical action/field visible and reachable, keyboard visibility, semantics, no overflow, and target-size contract when custom.
- [ ] Add applicable `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` assertions for shared interactive components and materially changed interactive screens.
- [ ] Expand goldens only for stable shared components that meet the feasibility gate. Record the documented fallback when they do not.
- [ ] Expand integration coverage from the login flow to one representative critical flow involving a form and one platform/system-UI flow where feasible.
- [ ] Collect validated `scripts/device_matrix.sh` sidecars for each material migration. For release-critical changes, collect one supported Android and one supported iOS physical-device evidence set. For typography discrepancies, complete the ADR 0002 paired worksheet before editing.

### Acceptance criteria

- Matrix adoption is tracked by screen family; each completed family has compact + regular, 1.0/1.3/2.0, and applicable inset/keyboard coverage.
- Accessibility guideline assertions exist where chapter 07 requires them.
- Golden and integration tests are intentional and stable, not merely count-driven.
- Evidence distinguishes widget, emulator/simulator, and physical-device claims.

---

## Phase 7 — Prevent regression and retire the audit queue

**Solves:** MNT-01 and prevents recurrence of phases 0–6.

**Required reading:** chapters 00, 01, 04, 05, 08, 10.

### Work items

- [ ] Extend `scripts/verify_layout_tokens.py` or add focused sibling guards for: presentation primitive imports, inline visual values, unsafe viewport-height formulas, disabled/replaced text scaling, and presentation-to-data imports. Guards must allow documented component-theme exceptions rather than reintroducing “zero raw numbers.”
- [ ] Add targeted tests for every guard and make CI run them.
- [ ] Add a PR checklist/template reference to the layout contract and evidence minimum; do not duplicate the playbook rules.
- [ ] Review high-size files as a queue, beginning with `my_trips_screen.dart` (980 lines), then properties listing, welcome, hotel view, referral/onboarding, verification landing/final check, reservation detail, property card, and property screen (312–451 lines). Extract only semantic, reusable, or independently testable subtrees.
- [ ] Remove completed rows from this plan only when the stated acceptance evidence is linked in a dated evidence note or PR.

### Acceptance criteria

- CI blocks recurrence of the audited rule violations without blocking documented component-local constants or component-theme ownership.
- Review-signal files have a documented disposition: extracted, retained as cohesive with rationale, or scheduled with an owner.
- The plan's finding inventory is updated to show completed phases and remaining exceptions.

---

## 4. Recommended execution order and dependencies

| Order | Phase | Depends on | Why this order matters |
| --- | --- | --- | --- |
| 1 | Phase 0 — Typography | None | Establishes a truthful platform-scale baseline before any screen tuning. |
| 2 | Phase 1 — Tokens | Phase 0 | Prevents new typography drift while component work begins. |
| 3 | Phase 2 — Layout | Phase 0 | Fixes the cross-device and keyboard hazards exposed by true scaling. |
| 4 | Phase 3 — Architecture | None; may run after Phase 0 in a separate PR | Removes a structural bypass without changing visual design. |
| 5 | Phase 4 — Errors/logging | None; start immediately for SEC-01 | Removes sensitive logging risk and makes state behaviour safe. |
| 6 | Phase 5 — Components | Phases 1–2 | Consolidation must target the repaired token and layout contracts. |
| 7 | Phase 6 — Validation | Phases 0–5 per screen family | Tests validate the corrected behaviour, not current defects. |
| 8 | Phase 7 — Prevention | Phases 1–6 | Gates must encode proven migration rules and approved exceptions. |

Phases 3 and 4 may be executed in parallel with visual phases after their own required reading, but do not merge conflicting provider or error-state changes into the same screen migration PR.

---

## 5. Completion definition

The codebase is conformant only when:

- ADR 0002 is implemented faithfully at the app root and verified on representative Android/iOS configurations.
- Feature presentation consumes semantic tokens and named component contracts rather than primitive typography or scattered local styling.
- Shared shells, sheets, and forms have a constraint/scroll/inset/keyboard contract proven across the required matrix.
- Presentation depends on domain/provider contracts, not data implementations.
- User-facing errors are safe and logs are redacted.
- Shared interactive components meet semantic, target-size, contrast, and text-scale requirements.
- Validation evidence exists by screen family and CI prevents the validated classes of regression.

Passing `flutter analyze`, `flutter test`, and the static guards remains necessary, but is not by itself the completion definition.
