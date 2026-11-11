# Phase 6 — Static Analysis & Stricter Linter Audit

**Date:** 2026-11-11  
**Scope:** Feasibility evaluation of enabling stricter Dart/Flutter analysis rules in `analysis_options.yaml`  

---

## 1. Current Analyzer Baseline

- **Current configuration:**
  - `include: package:flutter_lints/flutter.yaml`
  - `strict-casts: true`
  - `prefer_const_constructors: true`
  - `avoid_print: true`
  - `directives_ordering: true`
- **Output:** 0 errors, 0 warnings, 0 infos.

---

## 2. Experimental Stricter Rules Evaluation

A test run evaluating the 7 high-value rules recommended in playbook chapter 08:
- `strict-inference: true`
- `strict-raw-types: true`
- `unawaited_futures: true`
- `cancel_subscriptions: true`
- `close_sinks: true`
- `always_declare_return_types: true`
- `avoid_dynamic_calls: true`

### Findings

Only **15 issues** were reported across the entire repository (5 in `lib/`, 10 in `test/`):

| Rule | Location | Count | Description |
|---|---|---|---|
| `unawaited_futures` | `lib/features/verification/data/services/nfc_passport_service_impl.dart` | 3 | Background polling/delayed futures called without `unawaited()` |
| `unawaited_futures` | `lib/features/verification/presentation/screens/*.dart` | 3 | Background futures in screen init |
| `strict-inference` | `lib/features/verification/domain/verification_polling_service.dart` | 2 | `Future<void>.delayed` type argument inference |
| `strict-raw-types` | `test/features/findr/presentation/finder_notifier_test.dart` | 1 | `AsyncLoading<dynamic>()` needs type argument |
| `strict-inference` | `test/features/verification/data/verification_remote_data_source_test.dart` | 4 | Untyped `Map` literals in mock responses |
| `avoid_dynamic_calls` | `test/features/verification/presentation/screens/verification_final_check_screen_test.dart` | 2 | Dynamic property access on mock results |

---

## 3. Migration Roadmap for Stricter Lints

Because only 5 minor instances exist in production code, this hardening can be achieved in a focused, low-risk PR:

1. **Phase 6.1 (Immediate safe addition):**
   - Enable `cancel_subscriptions: true`, `close_sinks: true`, `always_declare_return_types: true` (0 violations currently).
2. **Phase 6.2 (Next PR):**
   - Wrap the 5 fire-and-forget futures with `unawaited()` in `nfc_passport_service_impl.dart`.
   - Enable `unawaited_futures: true`.
3. **Phase 6.3 (Future PR):**
   - Type the test fixtures in verification data source tests.
   - Enable `strict-inference: true` and `strict-raw-types: true`.
