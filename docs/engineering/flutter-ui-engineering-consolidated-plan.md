# TrvlEz Flutter UI Engineering Consolidation Plan

**Status:** proposed; research and audit complete, no application UI code changed
**Created:** 2026-11-10
**Owner:** mobile engineering
**Scope:** the engineering knowledge, agent tooling, validation capability, and repository documentation used to build Android and iOS phone UI. This is deliberately **not** a screen redesign plan or a dependency-upgrade proposal.

## 1. Outcome and non-goals

### 1.1 Outcome

Establish one reviewable, repository-owned Flutter UI engineering playbook that helps a developer or AI agent build the same intentional composition across Android and iOS phones with different logical sizes, aspect ratios, densities, display cut-outs, system-navigation/home-indicator modes, font scales, keyboard states, and platform system UI.

“Picture perfect” in this programme means the approved visual hierarchy, spacing relationships, readable content, touchability, and non-overlap behaviours are preserved in each supported configuration. It does **not** mean a bitmap is identical on every device: system bars, rasterization, font hinting, OEM fonts, GPU composition, and device-specific settings can legitimately differ.

### 1.2 Explicit non-goals

- Do not redesign, refactor, or migrate any existing application screen in this programme.
- Do not change Riverpod, GoRouter, networking, NFC/camera, API contracts, or Flutter/Dart dependency versions merely to establish the playbook.
- Do not install a scaling package such as `flutter_screenutil`, `sizer`, or `responsive_builder` as a default response to device differences.
- Do not claim physical-device verification when only a widget test or emulator ran.
- Do not delete existing instructions or skills until their replacement, discovery behaviour, ownership, and migration evidence have been reviewed.

## 2. Programme decisions

1. **Project-specific guidance will live as normal Markdown in `docs/engineering/playbook/`, not as a new collection of custom `SKILL.md` files or opaque IDE rule files.** Normal Markdown makes review and diffs straightforward.
2. **Official skills remain procedural aids, not the project source of truth.** They can teach an agent how to solve a task; the project playbook defines TrvlEz architecture, approved components, validation evidence, and exceptions.
3. **A small discovery bridge is still required.** A plain documentation directory is not automatically loaded by all IDEs. After compatibility testing, a short repository-root `AGENTS.md` (or supported IDE equivalent) will point agents to the playbook and name the task-to-skill mapping. It will link rather than duplicate rules.
4. **Constraint-led composition replaces viewport-led scaling.** A parent constraint, system inset, content size, and scroll policy are inspected before a child’s size is changed. Intentional logical dimensions remain allowed for component contracts such as icon size, avatar diameter, border thickness, and minimum tap targets.
5. **Phone-first is the target.** The supported layout matrix covers small, regular, and tall Android and iOS phones in portrait first. No tablet/desktop information architecture work is implied. Width breakpoints are introduced only when a phone UI requires a genuinely different composition.
6. **Verification evidence is part of completion.** Every later UI change records the tested logical viewport, text scale, navigation mode/inset state, keyboard condition where relevant, test command result, and any known rendering variance.

## 3. Baseline audit (read-only)

This audit is the factual starting point for consolidation. It must be refreshed before implementation because the working tree will change.

### 3.1 Repository and toolchain

- Root package: `pubspec.yaml`; Dart SDK constraint is `^3.12.0`.
- The app uses Flutter, Material 3, Riverpod (`flutter_riverpod`), GoRouter, Dio, and a local path dependency `../dmrtd`.
- Existing visual foundations are in `lib/app/theme/` and `lib/core/design_tokens/`. `AppSpace`, `AppSize`, and `AppShape` are `ThemeExtension`s exposed through `BuildContext` accessors.
- `analysis_options.yaml` includes `flutter_lints`, `strict-casts`, `prefer_const_constructors`, `avoid_print`, and `directives_ordering`.
- Executable evidence now records Flutter `3.44.4` stable, Dart `3.12.2`, and DevTools `2.57.0`; see `docs/engineering/evidence/phase-1-baseline-2026-11-10.md`. The initial restricted-environment limitation no longer applies to the recorded baseline.
- Node `v20.20.2` and npm `10.8.2` are available. `npx skills --help` did not produce usable help output in the restricted audit environment, so command flags and target paths must be verified immediately before any installation.

### 3.2 Existing instructions and skills

| Location | Finding | Consolidation decision |
| --- | --- | --- |
| `.agents/rules/ARCHITECTURE.md` | Extensive feature-first / presentation-domain-data guidance. It is aspirational in places and is not a verified map of every current feature. | Preserve; extract the applicable architecture contract into the playbook, then replace only after a path-by-path reconciliation. |
| `.agents/rules/CODE_STANDARDS.md` | Broad Dart/widget rules, including absolute line-count guidance and a blanket “no raw layout numbers” rule. | Preserve; refine the latter into an intentional-dimension decision rule. |
| `.agents/rules/DESIGN_SYSTEM.md` | Three-tier token guidance, overlapping strongly with `docs/design_tokens.md` and the semantic-token skill. | Preserve; make `docs/design_tokens.md` the implementation glossary and the new playbook the decision guide. |
| `.agents/rules/flutter-responsive-layout.md` | The best existing TrvlEz responsive guidance: it rejects arbitrary `MediaQuery` scaling, addresses insets and keyboard, and requires multi-device evidence. It overlaps the official responsive skill and other rules. | Preserve; migrate its project-specific material to the playbook. It must not remain a second central source of truth after bridge validation. |
| `.agents/skills/flutter-build-responsive-layout/SKILL.md` | Official Flutter source according to `skills-lock.json`; its content matches the current upstream responsive skill. It is broadly correct but includes large-screen/tablet direction outside this programme. | Retain as an official procedural skill; constrain its use through the phone-first playbook. |
| `.agents/skills/flutter-semantic-layout-tokens/SKILL.md` | Locally authored and largely aligned with the current `ThemeExtension` implementation. Its “no raw number anywhere” absolute rule conflicts with the required distinction between intentional fixed dimensions and responsive behaviour. | Adapt or retire after its valuable token workflow is represented in the playbook. Do not treat it as mandatory forever. |
| `.agents/skills/flutter-anti-ui-slop/SKILL.md` | Locally authored aesthetic guard. It contains subjective, absolute, and sometimes unrelated prescriptions (for example image policy and mandatory interaction choices). | Reject as a central engineering authority; retain temporarily only if a team owner explicitly wants it. Its useful design-intent checks can be rephrased as non-absolute review prompts. |
| `.agent`, `.claude`, `.codex`, `.cursor`, `.gemini`, `.github`, `.opencode` OpenSpec skill trees | Duplicated OpenSpec skills and commands for multiple agent hosts. These are workflow tooling, not Flutter UI guidance. | Leave untouched. Inventory them separately if OpenSpec management is later consolidated. |
| `skills-lock.json` | Records only `flutter-build-responsive-layout` from `flutter/agent-plugins`; its stored source hash differs from the local file checksum observed in this audit. | Treat provenance as incomplete until the installer/version is re-run and the lock format is understood. Do not overwrite the skill blindly. |

### 3.3 Existing design system and responsive implementation

Strengths:

- `lib/core/design_tokens/` already separates primitive values from semantic `AppSpace`, `AppSize`, and `AppShape` extensions.
- `lib/app/theme/app_theme.dart` registers the extensions and component themes.
- `docs/design_tokens.md` documents the token vocabulary and has an explicit “propose a token; do not invent a raw number” workflow.
- The application has meaningful use of safe areas, flexible layout, scroll views, and keyboard insets: audit counts were 25 `SafeArea`, 91 `Expanded`, 12 `Flexible`, 22 `SingleChildScrollView`, 17 `MediaQuery`, and 6 `viewInsets` references.
- Android manifest configuration includes `windowSoftInputMode="adjustResize"` and declares configuration changes including font scale, density, and screen size. The iOS runtime and project configuration still require a separate baseline inspection in Phase 1; no iOS behaviour is inferred from Android settings.

Risks to address later:

- Counts are not correctness proof. A screen can use `SafeArea` and still double-apply an inset, use `Expanded` in an unbounded parent, or use a `MediaQuery` width in a component whose parent is narrower.
- The current token guard rejects selected raw literals but does not validate all layout APIs, all fixed `Container` dimensions, semantic intent, inset ownership, typography clipping, or real-device rendering.
- The current documentation and rules say “zero magic numbers” more absolutely than the product requirement permits. A 48 dp minimum target, a 1 dp border, a fixed artwork aspect ratio, and a component’s approved logical height are legitimate when named, owned, and tested.
- `AppTheme` uses hard-coded `AppBarTheme` text values while other documents state that screens should never decide typography. This is acceptable only if it is explicitly component-theme ownership; document the boundary rather than label it a violation.

### 3.4 Validation baseline

- `golden_toolkit` is declared in `dev_dependencies`, but no checked-in golden assertions or golden baseline directory was found.
- There are many unit and widget tests under `test/`, including theme and screen tests. Their purpose is behaviour and structure, not a documented visual regression matrix.
- `integration_test/` is absent; `integration_test` is not declared.
- `scripts/quality_gates.sh` provides useful style, import-boundary, formatting, analysis, token-guard, and unit/widget-test checks. GitHub Actions repeats most of those checks.
- CI uses Flutter `stable` without pinning the exact Flutter version. That makes visual test baselines unsafe until the SDK version is fixed for the golden job.
- No repository HTML/CSS design-reference files were found. The only design-reference pointer is the external local path in `docs/UI_REDESIGN_PLAN.md`: `/home/kumaraguhan/Downloads/trvlez_app`. Build artefacts beneath `.dart_tool/` are not product design references.
- Therefore, a later design-intake step must ask for the supplied HTML/CSS (or an approved, versioned reference export) before any screen-comparison claim is made.

### 3.5 Non-UI enterprise engineering observations

This section intentionally covers code-health and delivery concerns rather than visual design. These are audit signals, not authorization to refactor now.

| Area | Evidence | Follow-up decision |
| --- | --- | --- |
| Reproducible dependencies | `dmrtd` is a sibling path dependency (`../dmrtd`). | Document source, revision/ownership, and bootstrap contract; evaluate a published, git-pinned, or workspace-managed alternative before CI or new-clone failures occur. |
| Deterministic CI | CI selects Flutter `stable`, not a pinned version. | Pin Flutter/Java/Gradle inputs or use a version manager and document a controlled upgrade process before introducing golden baselines. |
| Error observability | Read-only scan found broad or empty catches in several app, provider, presentation, and domain files. | Inventory each catch by policy: expected best-effort fallback, recoverable user error, or defect requiring structured logging. Do not mechanically replace them. |
| Static analysis | `strict-casts` is enabled, but strict inference/raw types and project-specific lint policy are not evident. | Baseline analyzer output first; evaluate incremental stricter lints only with a migration plan and CI owner. |
| Test doubles | Tests exist but no mocking package is declared. | Keep hand-written fakes if they are clear; select a tool only after test-maintenance review. Do not add a mock package because an external skill mentions one. |
| Accessibility governance | Token/touch-target guidance exists, but no documented automated accessibility audit or assistive-technology acceptance protocol was found. | Add semantics, font-scale, contrast, focus, and TalkBack checks to the quality plan. |
| Build and release assurance | The current CI is a quality gate, not a documented Android/iOS build, signing, simulator/emulator/integration, dependency audit, or release pipeline. | Create a separate non-UI engineering roadmap after this UI programme; it must cover Android and iOS build reproducibility, secrets, signing, SBOM/dependency security, crash reporting, and observability. |

### 3.6 Cortex comparison

`/home/kumaraguhan/workspace/cortex` was inspected as a reference only. Its useful patterns are: a root `AGENTS.md` that delegates detailed context, central and distributed architecture documentation, and numbered ADRs under `packages/core/docs/decisions/`.

Do **not** copy Cortex’s SDK-first monorepo boundaries, its ban on Material widgets, its custom neutral primitives, its offline-first Drift architecture, or its OpenSpec-only implementation policy into TrvlEz. They solve a different product and repository topology. The transferable principle is **thin discoverability plus reviewed, versioned, well-owned documentation**.

## 4. Research conclusions

### 4.1 Official guidance used as the technical baseline

- Flutter distinguishes responsive fitting from adaptive usability and recommends reacting to available space rather than hardware labels. [Adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)
- `SafeArea` is the default way to protect selected content from cut-outs and system UI; it adjusts inherited `MediaQuery` values so nested safe areas do not blindly compound padding. [SafeArea and MediaQuery](https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery)
- Flutter’s Inspector exposes the live widget tree, size, and constraints; inspecting the parent constraints is the correct first diagnostic for layout failures. [Flutter Inspector](https://docs.flutter.dev/tools/devtools/inspector)
- Flutter’s own guidance separates unit, widget, and integration tests. Integration tests run on an emulator or real device and can be run through Firebase Test Lab; they are the appropriate basis for device-flow verification, not a substitute for visual baselines. [Testing overview](https://docs.flutter.dev/testing/overview) and [integration tests](https://docs.flutter.dev/testing/integration-tests)
- Flutter’s AI guide defines skills as procedural guides and rules as persistent instructions, with a Dart/Flutter MCP server supplying diagnostics and runtime inspection. This supports the programme decision to keep project policy in reviewable documentation and use official skills only for procedures. [Flutter AI integration](https://docs.flutter.dev/ai/get-started)

### 4.2 Candidate selection matrix

Maintenance must be re-checked against a pinned commit immediately before installation because all listed repositories use mutable default branches. “Current” below means inspected on 2026-11-10, not a perpetual support guarantee.

| Candidate | Classification and licence | Actual purpose and quality | TrvlEz overlap / compatibility | Decision |
| --- | --- | --- | --- | --- |
| `flutter/agent-plugins` — `flutter-build-responsive-layout` | Official Flutter; BSD-3-Clause repository licence. | Correctly teaches constraints, `LayoutBuilder` where parent-space decisions are needed, `MediaQuery.sizeOf` for window data, `Expanded`/`Flexible`, and lazy lists. It also includes tablet/desktop material not in scope. | Already installed locally and recorded in `skills-lock.json`; compatible in principle with the recorded Flutter 3.44.4 / Dart 3.12.2 toolchain. | **Retain; verify provenance and update intentionally.** |
| `flutter/agent-plugins` — `flutter-fix-layout-issues` | Official Flutter; BSD-3-Clause. | Useful diagnosis of unbounded viewport, `InputDecorator`, `RenderFlex`, and parent-data errors. Its automatic-looking fixes must still be checked against the scrolling and content model. | Missing locally; directly supports constraint debugging. | **Install after CLI/catalog verification.** |
| `flutter/agent-plugins` — `flutter-add-widget-test` | Official Flutter; BSD-3-Clause. | Provides a sound widget-test workflow. It is not a golden-testing strategy by itself. | `flutter_test` and many widget tests exist. | **Install after verification.** |
| `flutter/agent-plugins` — `flutter-add-integration-test` | Official Flutter; BSD-3-Clause. | Relevant to adding Android and iOS integration flows and device execution. Its legacy Flutter Driver instructions must be ignored in favour of the current `integration_test` approach in the official Flutter docs. | `integration_test/` is absent; no dependency currently. | **Adapt via project playbook; install only after reviewing the installed revision.** |
| `flutter/agent-plugins` — `flutter-apply-architecture-best-practices` | Official Flutter; BSD-3-Clause. | Potentially useful, but must be compared line by line with TrvlEz’s current feature layout before use. | Existing architecture documents already overlap strongly. | **Defer; inspect source before approving.** |
| `dart-lang/skills` — `dart-add-unit-test`, `dart-run-static-analysis`, `dart-collect-coverage` | Official Dart; BSD-3-Clause. | Purpose-built, maintained by Dart team; source catalog shows testing, static analysis, and coverage guidance. | Complements existing tests and CI; does not dictate UI architecture. | **Install only these relevant skills after catalog verification.** |
| `dart-lang/skills` remaining catalog | Official Dart; BSD-3-Clause. | Includes CLI, FFI, ffigen, primary constructors, mock generation, and migration workflows. | Most are unrelated to current UI-engineering scope; some would create dependency or language-version policy decisions. | **Reject for this programme; do not install `*`.** |
| `thienqo/flutter-skills` | Community; BSD-3-Clause. | Licence is clear. The repository description promises broad delivery guidance, but no unique, reviewed UI capability has yet been demonstrated beyond official coverage. | Would overlap architecture, testing, and UI policy and add a second maintenance source. | **Reject by default; reconsider only a named skill after source/revision review proves a gap.** |
| `zakariaf/Flutter-Skills` | Community; MIT. | Licence is clear. It advertises architecture, Riverpod 3.x, persistence, localisation, accessibility, navigation, and testing; its Riverpod 3 focus is not an automatic fit for the project’s Riverpod 2.x dependency. | High overlap and a credible risk of version/policy conflict. | **Reject by default; no bulk installation.** |
| Existing `flutter-semantic-layout-tokens` | Local, no separately recorded licence/provenance. | Strong implementation-oriented token architecture, but too absolute about raw numbers and overlaps project docs. | Mirrors existing `ThemeExtension` implementation. | **Adapt or retire after documentation migration.** |
| Existing `flutter-anti-ui-slop` | Local, no separately recorded licence/provenance. | Subjective and overly prescriptive; not an auditable enterprise standard. | Conflicts with client-design fidelity and conditional engineering choices. | **Reject as authority; do not expand.** |

Official source catalogues and licences: [Flutter agent plugins](https://github.com/flutter/agent-plugins), [Dart skills](https://github.com/dart-lang/skills), [Dart skills README and universal install command](https://raw.githubusercontent.com/dart-lang/skills/main/README.md), [ThienQo licence](https://raw.githubusercontent.com/thienqo/flutter-skills/main/LICENSE), and [Zakaria Fatahi licence](https://raw.githubusercontent.com/zakariaf/Flutter-Skills/main/LICENSE).

## 5. Target information architecture

The target is deliberately documentation-first.

```text
docs/engineering/
  README.md                              # index, owners, precedence, change process
  playbook/
    00-charter-and-precedence.md          # scope, authority, exceptions, terminology
    01-app-architecture-and-boundaries.md # TrvlEz folder/dependency guidance
    02-screen-construction-workflow.md    # required investigation and composition workflow
    03-mobile-phone-layout-standard.md    # Android/iOS constraints, insets, keyboard, typography
    04-design-system-and-reference-intake.md
    05-visual-validation-standard.md      # goldens, emulators, devices, evidence
    06-testing-device-matrix.md           # named configurations and reporting template
    07-accessibility-and-performance.md
    08-non-ui-engineering-backlog.md
    09-agent-tooling-and-skill-catalog.md # source, revision, licence, task mapping
  decisions/
    README.md
    NNNN-short-decision.md                # only for durable architecture decisions
  evidence/
    README.md                             # retained screenshots/baselines policy; no device PII
```

`docs/engineering/README.md` becomes the human landing page. `docs/engineering/playbook/00-charter-and-precedence.md` becomes the content authority. No document is duplicated solely to satisfy an agent format.

### 5.1 Planned precedence

When two directions conflict, use this order:

1. Product requirements, approved client design references, security/privacy requirements, and platform/framework correctness.
2. Explicit approved TrvlEz architecture decisions in `docs/engineering/decisions/`.
3. The TrvlEz engineering playbook and the current source code contracts it references.
4. Official Flutter/Dart documentation and official skills.
5. Community guidance and aesthetic heuristics.

The higher authority does not remove the obligation to explain the trade-off. A one-off exception must name the affected screen/component, why the standard does not apply, the test matrix used, and its removal/revisit condition.

### 5.2 Discovery bridge design

After user approval, create a small, durable bridge rather than a large rules file:

- `AGENTS.md` at repository root: links to `docs/engineering/README.md`, requires the appropriate playbook chapters before UI work, and names the official skill to load by task.
- Keep `.agents/skills/` exclusively for verified official/third-party skills that need a `SKILL.md` for discovery. Do not put TrvlEz policy copies there.
- Keep every external skill’s source URL, commit SHA, licence, installation command, installed location, review date, and owner in `09-agent-tooling-and-skill-catalog.md`.
- Test actual discovery in each supported host (Codex desktop, Antigravity, Claude/Cursor only if they are actively used). A path existing on disk is not proof that a host loads it.
- Until that test passes, preserve the existing `.agents/rules/*` files as legacy compatibility documents. Migration deletes nothing automatically.

## 6. Engineering standard to be written in Phase 3

### 6.1 Android and iOS phone rendering model

The standard will teach these concepts with small, project-relevant Dart examples:

- **Physical pixels vs logical pixels:** Flutter layout dimensions are logical pixels. `devicePixelRatio` maps them to physical pixels; it is not a scale factor to apply to paddings and font sizes.
- **Window vs parent constraint:** `MediaQuery.sizeOf(context)` describes the current Flutter window. A child inside a sheet, card, `Expanded`, or nested navigator must use its parent `BoxConstraints` when its decision depends on its allocated space.
- **Insets:** `SafeArea` protects selected content from cut-outs/system UI. `padding`, `viewPadding`, and `viewInsets` have different meanings; keyboard visibility is not a status-bar inset.
- **Edge-to-edge:** an app must explicitly decide which surfaces may draw behind Android system bars and iOS status/home-indicator regions, and which content must remain safe. It must never use a guessed 24/34/48-pixel device offset.
- **Text metrics:** text needs room for font ascent/descent, locale and system text scaling. Text containers choose wrapping, ellipsis, min height, or scrolling deliberately; they must not force `TextScaler.noScaling` to satisfy a screenshot.
- **Keyboard:** input flows establish an owner for `resizeToAvoidBottomInset`, safe area, bottom action bar, scroll position, and focused-field visibility. Android gesture/three-button navigation and the iOS home indicator are represented through actual inset values, not device names.

### 6.2 Dimension decision guide

Before changing a dimension, the agent/developer records the role:

1. Is this an invariant **component contract**? Examples: icon box, avatar diameter, 48 dp touch-target minimum, border thickness, progress track height. Use a semantic token or component theme; fixed logical values are appropriate.
2. Is this an **artwork geometry** requirement? Examples: camera frame, logo aspect ratio, image crop. Use `AspectRatio`, bounded `BoxConstraints`, or an explicitly documented ratio; do not derive it from the entire screen height.
3. Is this **content-driven**? Examples: text, a form, an error banner, a dynamic list. Let the child size itself within constraints and give the page a correct scroll model.
4. Is this **remaining-space distribution**? Examples: a persistent footer beneath a flexible page body. Use `Expanded`, `Flexible`, `Spacer`, or slivers only when the parent has finite space.
5. Is this a **true composition switch**? Use a named, centrally documented parent-constraint breakpoint only when the phone layout cannot remain usable through wrapping/scrolling/constraints. Do not introduce a breakpoint just to reproduce an artboard.

The standard will prohibit global formulas such as `screenWidth * 0.04` for every padding/font/button. Proportional fractions are allowed where the visual contract is truly proportional (for example a map image crop or a bounded split), and their ownership/test cases must be documented.

### 6.3 Screen-construction workflow

For each later screen task:

1. Read the client reference and identify content hierarchy, dynamic states, scroll owner, fixed/pinned regions, interactions, and intended art/image ratios.
2. Inspect the existing screen, reusable core widgets, token/component themes, parent constraints, and route/shell ownership before editing a child widget.
3. Write a short layout contract in the task/PR: available region, inset owner, content that may grow, overflow policy, keyboard policy, and named fixed dimensions.
4. Select `Column`, `ListView`, `CustomScrollView`/slivers, `Stack`, `Expanded`/`Flexible`, `ConstrainedBox`, `AspectRatio`, or `LayoutBuilder` based on that contract. Explain the parent constraint when using `LayoutBuilder`.
5. Implement the smallest scoped change. Reuse shared widgets only when the visual/behavioural contract is genuinely shared by at least two features.
6. Run static, behavioural, visual, and runtime-inspection checks from the validation standard. Attach evidence and state what was not tested.

## 7. Visual validation strategy

### 7.1 Test layers and claims

- **Static analysis and token guard:** catches style/boundary patterns. It cannot prove a screenshot matches design or a keyboard does not obscure content.
- **Widget tests:** test layout-relevant structural states, dynamic text, overflow assertions where practical, scrolling, semantic labels, and state transitions. Use fixed test window/text-scale inputs deliberately.
- **Golden tests:** compare deterministic component/screen render output in a pinned environment. They are appropriate for stable shared widgets and selected high-value reference states. They are sensitive to Flutter version, fonts, raster platform, locale, images, and clock/network randomness.
- **Integration tests:** prove critical flows on an Android emulator, iOS simulator, or physical device. Use `integration_test`, not obsolete Flutter Driver setup, and keep native permission/platform-view flows separately scoped.
- **Manual device inspection:** validates real system bars/home indicators, Android gesture navigation, OEM/platform fonts, keyboard, animation, camera/NFC/platform views, and physical-device behavior. Record device/model/OS version without personal data.
- **DevTools Inspector:** while reproducing a defect, inspect the selected widget’s `constraints` and `size`, show baselines/guidelines where helpful, and retain the diagnosis in the task note rather than adding random offsets.

### 7.2 Initial Android and iOS phone matrix

The exact AVD profiles must be recorded from available SDK images in the implementation phase; these are logical test categories, not claims that a named device is already provisioned.

| Category | Representative logical viewport target | Required scenarios |
| --- | --- | --- |
| Compact/narrow phone | approximately 360 × 640 logical px | default font, large font, keyboard, scroll-to-bottom, both navigation inset modes where emulator supports them |
| Regular phone | approximately 393 × 852 logical px | default font, client-reference comparison, dark/light as applicable, keyboard on forms |
| Tall phone | approximately 412 × 915 logical px | default font, bottom action/pinned footer, gesture navigation, tall content |
| Large phone | approximately 432 × 932 logical px | default and large font, dynamic long/translated-like strings, no unexpected stretching |
| Physical realme 8 | capture actual `MediaQuery` size, DPR, text scale, Android version, navigation mode | baseline reproduction and regression confirmation |
| Physical Pixel 10a | capture actual `MediaQuery` size, DPR, text scale, Android version, navigation mode | baseline reproduction and regression confirmation |
| iOS compact/regular simulator | choose an available iPhone profile and record its actual logical viewport | default and large text, keyboard, safe-area/home-indicator behaviour, client-reference comparison |
| iOS physical device (when available) | capture actual `MediaQuery` size, DPR, text scale, iOS version, display settings | confirm simulator findings; do not report this as completed until a physical device runs it |

No device class is declared complete until the actual observed logical size, text scaling, navigation/system inset state, and pass/fail evidence are stored.

### 7.3 Golden-test feasibility gate

Before adding a visual baseline, perform this gate:

1. Pin Flutter SDK and font assets for the golden job.
2. Make time, locale, network images, animation, image decoding, and asynchronous data deterministic.
3. Choose stable component/screen states; do not golden-test live maps/camera/platform views until a controlled test surface exists.
4. Define the reference viewport, device pixel ratio, text scale, brightness, locale, and captured state.
5. Store baselines under a documented path, require deliberate review for updates, and add a diff artifact to CI.
6. Run the same baseline in the supported CI image. If rendering varies by OS, use a controlled Docker/CI environment or keep it as manual screenshot review; never normalize unexpected differences away.

Potential tools are evaluated only after this gate. `golden_toolkit` is already available and should be proven on one representative core widget before any new package is proposed. Device/cloud matrices such as Firebase Test Lab are optional later infrastructure, not an immediate package dependency.

## 8. Implementation roadmap and acceptance criteria

### Phase 0 — approve this plan (current deliverable)

- [x] Read-only inventory of repository, instructions, skills, responsive foundations, docs, tests, scripts, and design references.
- [x] Reference comparison with Cortex without importing its architecture.
- [x] Official and named-community research; source/licence/overlap decisions recorded.
- [x] Create this consolidated plan only.
- [x] Product/engineering owner approves the target documentation architecture, discovery bridge, and staged removal policy.

**Exit criterion:** approval to create documentation and tooling changes described below. No app source is changed in this phase.

### Phase 1 — evidence and compatibility baseline

- [x] Record `flutter --version`, `dart --version`, Java/Gradle/Xcode versions, Android SDK/AVD and iOS simulator inventory, and `npx skills --help` output in a dated evidence note. Unavailable Apple/AVD tooling is explicitly recorded as a host limitation.
- [ ] Run `flutter pub get`, `flutter analyze --fatal-infos`, the existing token guard, and `flutter test`; save failures as baseline findings rather than hiding them. Analyzer and token guard pass; formatter reports 75 files would change; the bounded full test run did not reach a terminal result. `flutter pub get` remains to be recorded separately.
- [x] Verify current source and actual installation path/revision for each existing skill; reconcile `skills-lock.json` hash mismatch.
- [ ] Confirm whether Codex desktop and Antigravity discover `.agents/skills`, root `AGENTS.md`, and/or `.agents/rules` in this repository.
- [ ] Obtain version-controlled or explicitly approved HTML/CSS design references; record source, revision/date, screen mapping, licence/usage permission, and assets. No approved source is present; the external-reference blocker is recorded and parity claims remain prohibited.

**Exit criterion:** reproducible, dated baseline; no reliance on guesses about SDK, skills CLI, or design inputs.

### Phase 2 — official skill installation (only after Phase 1)

- [x] Inspect the installed `skills` CLI version/help, then list the exact catalog and target path for each command from repository root. CLI `1.7.6` and reviewed Flutter/Dart catalog names were verified using FNM Node `24.21.0`.
- [ ] Verify no duplicate skill directory will be overwritten; back up/commit the pre-install state rather than relying on an installer rollback.
- [ ] Install the approved Flutter subset, not `*`: responsive layout, fix layout issues, widget test, and the reviewed integration-test skill. Re-evaluate architecture skill before adding it.
- [ ] Install the approved Dart subset, not `*`: unit test, static analysis, and coverage.
- [ ] Use a command equivalent to `npx skills add <source> --skill <named-skill> --agent universal --yes` only after the exact current CLI syntax is verified. Run from this repository and inspect that files land under repository `.agents/skills/`, never user-global configuration.
- [ ] Record upstream URLs, commit SHAs, licences, install commands, file hashes, review date, and update procedure in the catalog. Source revisions and local hash evidence are recorded; the full per-installed-skill ledger remains pending because no new installation is approved.
- [x] Do not execute any community installation script. No community catalogue is approved for bulk installation.

**Exit criterion:** each installed skill has a valid frontmatter/name, known provenance, current licence, non-conflicting scope, and demonstrated discovery in the supported IDEs.

### Phase 3 — create the engineering playbook and discovery bridge

- [x] Create the target `docs/engineering/` structure in Section 5 and write the Android/iOS mobile-phone standard with correct/incorrect Dart examples.
- [x] Preserve the useful current content by mapping it to one playbook chapter at a time. The plan identifies original sources and migration decisions in `docs/engineering/migration-map.md`.
- [x] Add the minimal root discovery bridge after the playbook index exists. `AGENTS.md` names the required playbook chapter and optional verified procedure for each task; `CLAUDE.md` imports it for Claude Code. Prompt-time host acceptance testing remains open before legacy material can be retired.
- [x] Add an ADR template and use it only for durable decisions such as edge-to-edge policy, token density policy, or golden baseline environment.
- [ ] Remove duplicate/contradictory content only after review and explicit approval. Preserve git history and add a migration map from each old instruction to its canonical replacement.

**Exit criterion:** one canonical project policy location, a discovery test for each active IDE, no new custom skills unless a documented gap cannot be solved by official skills plus the playbook.

### Phase 4 — validation capability

- [ ] Create deterministic widget-test helpers for window size, text scale, theme, locale, and app wrappers without changing production UI.
- [ ] Pilot one stable core component golden test using existing `golden_toolkit`; establish baseline-update/review policy before adding more.
- [ ] Add `integration_test` only when a named critical flow and Android/iOS execution target are approved; do not add patrol or another package unless native-dialog coverage is a demonstrated gap.
- [ ] Add scripts/docs for Android emulator and iOS simulator capture, test matrix execution, screenshot naming, diff retention, and physical-device evidence.
- [ ] Update CI only after local proof and SDK pinning; make screenshots/diffs downloadable artifacts where the CI provider permits.

**Exit criterion:** one end-to-end example can be reproduced locally and in CI, and its evidence honestly distinguishes widget/golden/emulator/physical-device validation.

### Phase 5 — controlled screen adoption (future, outside this request)

- [ ] Prioritise the reported realme 8 / Pixel 10a discrepancy using measured runtime data, not device reputation or guessed dimensions.
- [ ] Create a screen-specific layout contract, reproduce on both devices/configurations, and inspect parent constraints/insets before editing.
- [ ] Make the smallest UI-only change, run the matrix, and compare against the approved design reference.
- [ ] Add durable component/screen visual regression coverage only after the state is stable.

**Exit criterion:** a measured defect is resolved with evidence and without unrelated state/architecture/dependency changes.

### Phase 6 — non-UI enterprise hardening (separate backlog)

- [ ] Make dependency/source bootstrap reproducible, especially the `dmrtd` path dependency.
- [ ] Pin CI toolchain and introduce a controlled upgrade cadence.
- [ ] Establish error/logging policy and remediate broad/empty catches according to risk.
- [ ] Review analyser/lint rigor, dependency vulnerability/SBOM reporting, Android/iOS signing and secrets, release gates, observability, and accessibility automation.

**Exit criterion:** a separately approved architecture/security/release plan; this phase must not be silently bundled with UI work.

## 9. Change controls

- Each documentation/skill change is a small reviewable commit with source links and a migration note.
- No external source is copied without retaining required attribution/licence text and an upstream revision reference.
- No tool is declared “enterprise” based on popularity, stars, or an agent-generated description. It must have a named owner, reproducible setup, licence, update policy, supported-version evidence, and a removal path.
- Every automated guard has a documented false-positive/false-negative boundary. A regex check is never described as visual verification.
- If a custom skill or folder cannot pass the provenance, usefulness, discovery, maintenance, and conflict tests above, it is removed from the proposed target rather than kept out of habit.

## 10. Completion report template for the future implementation

The final implementation report must include:

1. Existing-instruction migration map with preserved originals and deletions approved by whom.
2. Installed-skill ledger: original repository, pinned revision, licence, purpose, dependencies, destination, discovery result, and update command.
3. Current playbook file tree and the precedence/discovery bridge.
4. The Android/iOS mobile layout standard and its examples, including fixed-vs-responsive decisions, insets, keyboard, text scaling, and edge-to-edge policy.
5. Visual validation matrix with exact AVD/device measurements and evidence links.
6. CI/golden limitations and any manual setup still required.
7. Separate non-UI enterprise backlog with risk, owner, priority, and non-goal boundaries.

## Appendix A — source inspection checklist for any later candidate

For every new skill, plugin, library, or guide:

- Inspect the original repository, `SKILL.md`/source files, licence, commit history, release/tag practice, issue activity, and dependencies.
- Check compatibility against the recorded Flutter, Dart, Android Gradle Plugin, Java, Xcode/iOS deployment target, Riverpod, GoRouter, and CI versions—not just the package’s README.
- Identify exactly which existing playbook chapter, official skill, test, or library it duplicates.
- Test installation in a disposable branch/worktree, inspect every written file, and validate IDE discovery.
- Add only if it closes a documented gap at lower total maintenance cost than documentation plus existing framework APIs.
- Record attribution and an uninstall/migration plan before merging.

## Appendix B — useful official references

- [Flutter adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)
- [SafeArea and MediaQuery](https://docs.flutter.dev/ui/adaptive-responsive/safearea-mediaquery)
- [Adaptive design best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)
- [Flutter Inspector](https://docs.flutter.dev/tools/devtools/inspector)
- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter integration tests](https://docs.flutter.dev/testing/integration-tests)
- [Flutter AI integration](https://docs.flutter.dev/ai/get-started)
- [Official Flutter agent plugins](https://github.com/flutter/agent-plugins)
- [Official Dart skills](https://github.com/dart-lang/skills)
