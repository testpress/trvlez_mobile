# Non-UI engineering backlog

These observations cover code-health, delivery, and infrastructure concerns outside the scope of screen design. They are not authorization for an opportunistic refactor bundled into a UI ticket. Each item requires a separately owned proposal, risk assessment, and verification plan.

---

## Enterprise engineering gaps

### 1. Reproducible dependency bootstrap

**Current state:** The `dmrtd` NFC passport-reading library is a sibling path dependency (`../dmrtd`). This means:

- A new developer clone will fail `flutter pub get` unless the sibling directory exists at the expected path.
- CI depends on the directory being pre-provisioned; there is no pinned version or hash.
- There is no documented ownership, revision history, or update policy for this dependency.

**Enterprise approach:**
- Publish `dmrtd` as a private package (e.g. via a private pub server, Git dependency with a pinned commit, or a Dart workspace).
- At minimum, pin to a Git ref: `dmrtd: { git: { url: ..., ref: <commit-sha> } }`.
- Document ownership, changelog, and the upgrade process.
- Ensure CI can reproduce the dependency without local filesystem assumptions.

### 2. Deterministic CI toolchain

**Updated status:** Flutter is pinned to 3.44.4 for CI and golden validation by ADR 0001. Java, Gradle, Android SDK, and the controlled upgrade cadence still need an explicit, repository-owned toolchain policy.

**Risks:**
- An uncontrolled Flutter stable update can change rendering behaviour, breaking golden tests.
- A Gradle/AGP update can break the Android build.
- Non-deterministic builds make bug reproduction unreliable.

**Enterprise approach:**
- Pin Java and Gradle versions in CI.
- Use a lockfile or version manifest that is committed and reviewed.
- Establish a controlled upgrade cadence (e.g. monthly) with a dedicated PR, test run, and golden baseline update.

### 3. Error handling and observability

**Current state:** Several files contain broad catches (`catch (e)`) or empty catches (`catch (_) {}`) without structured logging or error classification. No crash reporting or structured logging service is configured.

**Enterprise approach:**
- **Crash reporting:** Integrate a crash reporting service (Sentry, Firebase Crashlytics, or equivalent). Every unhandled exception and every `AppException` that reaches the UI should be reported with context.
- **Structured logging:** Replace `print()` with a structured logger (`core/utils/app_logger.dart`) that supports log levels, context tags, and redaction of sensitive values.
- **Error policy per catch:** Inventory each broad/empty catch and classify:
  - **Expected best-effort fallback:** Document why the error is safe to swallow and what the user sees.
  - **Recoverable user error:** Show a user-friendly message via `AppException`.
  - **Defect requiring investigation:** Log with full context to the crash reporting service.
- **Privacy:** Never log auth tokens, passwords, personal identification data, passport details, or NFC chip contents. Use structured redaction.

### 4. Static analysis rigor

**Current state:** Analyzer-policy coverage beyond the existing baseline should be assessed deliberately. Keep this section current when the analyzer configuration changes; do not rely on a historical list of enabled rules.

**Enterprise approach:**
- Baseline current analyzer output (warnings, infos, ignores).
- Evaluate enabling incrementally:
  - `strict-inference: true` — catches implicit `dynamic` returns.
  - `no_raw_types` — catches unparameterized generics; use this current lint rather than the replaced `strict-raw-types` analysis option.
  - `unawaited_futures` — catches fire-and-forget async calls.
  - `cancel_subscriptions` — catches un-cancelled stream subscriptions.
  - `close_sinks` — catches un-closed sinks.
  - `always_declare_return_types` — catches missing return types.
  - `avoid_dynamic_calls` — catches calls on `dynamic` values.
- Add lints with a migration plan: enable, fix violations, then make the rule enforced in CI.
- Do not enable all lints at once — it creates a massive, unreviewable change.

### 5. Test infrastructure and coverage

**Updated status:** Deterministic widget-test helpers, a golden-test pilot, and an `integration_test` workflow are now documented in chapters 05–06. Coverage measurement, critical-flow integration coverage, and any required mocking strategy remain deliberate backlog work. The historical Phase 1 test-run limitation is not a statement of the current suite state.

**Enterprise approach:**
- **Coverage measurement:** Add `flutter test --coverage` to CI. Establish a baseline, not a mandated percentage. Track trends, not absolutes.
- **Mocking strategy:** Evaluate whether hand-written fakes are sufficient or whether `mocktail` would reduce maintenance. Do not add a mocking package just because an external guide mentions one — assess actual test-maintenance burden.
- **Integration tests:** Establish or expand critical-flow coverage using `integration_test`, starting with one flow (e.g. login). Do not attempt to cover all flows at once.
- **Test helpers:** Create deterministic test wrappers for widget tests (fixed viewport, theme, locale, text scale).

### 6. Dependency security and SBOM

**Current state:** No dependency vulnerability scanning, software bill of materials (SBOM), or licence audit is configured.

**Enterprise approach:**
- Run `dart pub outdated` regularly. Flag security-relevant updates.
- Evaluate `dart pub audit` or a third-party dependency scanner for known vulnerabilities.
- Maintain an SBOM or at least a dependency review log for production dependencies.
- Review licence compatibility for all production dependencies. Some licences have attribution or distribution requirements.

### 7. Build, signing, and release pipeline

**Current state:** CI is a quality gate (analysis, tests). There is no documented Android or iOS build, signing, artefact, or release pipeline.

**Enterprise approach:**
- **Android:** Document keystore management, signing configuration, Gradle build types (debug/staging/release), and APK/AAB generation.
- **iOS:** Document certificate management, provisioning profiles, Xcode configuration, and IPA generation.
- **Secrets management:** Store signing keys and API credentials in CI secrets (not in the repository). Use `--dart-define` for build-time configuration.
- **Release process:** Define release branches, version bumping, changelog generation, and app store submission steps.
- **Environment configuration:** Separate dev/staging/production API endpoints, feature flags, and logging levels using build-time configuration.

### 8. Accessibility automation

**Updated status:** Chapters 05 and 07 require applicable Flutter accessibility Guideline API checks for shared interactive components and materially changed interactive UI. CI adoption and broad baseline coverage remain delivery work.

**Enterprise approach:**
- **Semantic tests:** Add widget test assertions for `Semantics` labels on interactive elements.
- **Contrast checks:** Validate colour token contrast ratios against WCAG 2.1 AA as part of theme tests.
- **Text scale tests:** Include text scale 2.0× in widget matrices for critical screens and validate the platform maximum at runtime when it exceeds 2.0×.
- **Screen reader testing:** Document a manual TalkBack/VoiceOver test protocol for release-critical flows.
- **Focus traversal:** Test keyboard/switch navigation order in widget tests.

### 9. Internationalization and localization readiness

**Current state:** `intl` package is included but the extent of localization infrastructure (ARB files, generated messages, locale switching) is not documented.

**Enterprise approach:**
- Audit current localization coverage: which strings are localized, which are hardcoded.
- Establish a string extraction workflow if localization is a product requirement.
- Test layouts with a locale that produces longer strings (e.g. German, Arabic) to expose truncation and overflow.
- If RTL support is a future requirement, verify that layout widgets use `Directionality`-aware properties.

### 10. Deep linking and navigation robustness

**Current state:** GoRouter is configured but deep linking behaviour, auth-guard edge cases, and back-stack management are not documented.

**Enterprise approach:**
- Document supported deep link patterns and their expected behaviour.
- Test deep links that arrive when the app is cold (not running), warm (backgrounded), and hot (foregrounded).
- Verify auth guards handle expired tokens, pending verification states, and navigation race conditions.
- Test Android back button behaviour at every navigation depth.

---

## Priority and ownership

These items are listed in rough priority order based on risk, but actual priority depends on product roadmap and team capacity. Each item should be:

1. Assessed for risk and impact.
2. Assigned an owner.
3. Scoped as a separate proposal (not bundled into a UI ticket).
4. Implemented incrementally with its own review and verification.

None of these should be silently bundled with UI work or deferred indefinitely without a conscious decision.
