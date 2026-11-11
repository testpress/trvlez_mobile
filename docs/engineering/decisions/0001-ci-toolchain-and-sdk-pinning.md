# ADR 0001: CI Toolchain and Flutter SDK Pinning Policy

- **Status:** accepted
- **Date:** 2026-11-11
- **Owner:** Mobile Engineering / DevOps
- **Decision scope:** CI workflows (`.github/workflows/ci.yml`), golden validation, and local development toolchain

---

## Context

The TrvlEz mobile application currently runs on Flutter `3.44.4` (Dart `3.12.2`). CI pins `subosito/flutter-action@v2` to Flutter `3.44.4` on the stable channel.

While an unpinned channel ensures the repository tracks ongoing security updates from the Flutter team, floating channels introduce non-deterministic risks:
1. Flutter stable updates can alter text rasterization, font ascent/descent metrics, or Skia/Impeller anti-aliasing, causing false failures in visual regression or golden tests.
2. Breaking toolchain changes in dependencies may cause CI builds to fail unexpectedly without any changes to repository source code.
3. Troubleshooting discrepancies between developer machines and CI is hindered when the exact engine version differs.

---

## Decision

The team adopted exact CI pinning with intentional upgrade reviews:

1. **CI Quality Gates Workflow (`ci.yml`):** Pins Flutter `3.44.4` for analysis, linting, unit/widget tests, and deterministic golden tests.
2. **Visual & Golden Testing Feasibility Gate:** Golden regression baselines run only with the pinned SDK and deterministic fonts loaded by `test/flutter_test_config.dart`.
3. **Release & Staging Pipelines:** Production releases and release candidate tags must record the exact `flutter --version` output in their release manifests.
4. **Upgrade Cadence:** When Flutter stable increments, an intentional upgrade PR will be opened that verifies:
   - `flutter analyze --fatal-infos` passes cleanly
   - All unit, widget, and integration tests pass
   - Baseline golden screenshots are reviewed and updated deliberately if pixel shifts occur.

---

## Alternatives Considered

- **Tracking an unpinned Flutter channel (Option A):** Rejected because it creates non-deterministic visual output and false golden failures.
- **Skipping CI validation for visual changes (Option C):** Rejected because continuous automated testing is required to maintain architectural boundaries and test suites.

---

## Consequences

- Continuous integration checks stay active and fast without brittle golden mismatches.
- Golden tests (`test/core/widgets/app_card_golden_test.dart`) run in CI against committed baselines and upload failure diffs as artifacts.
- All non-visual quality gates (analysis, token guard, layer imports, unit/widget/integration tests) run with zero flakiness.

---

## Rollback and Review

- Review trigger: Next Flutter minor/major stable release, or upon implementation of a dedicated golden test runner in CI.
- Owner: Mobile Engineering.
