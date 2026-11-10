# Agent tooling and skill catalogue

Project policy lives in this playbook, not in a custom skill. External skills are optional procedures and must never silently override the playbook.

## Current candidates

| Task | Candidate | Status |
| --- | --- | --- |
| Constraint/responsive diagnosis | Official Flutter `flutter-build-responsive-layout` | Present locally; source/provenance remediation pending |
| Layout-error diagnosis | Official Flutter `flutter-fix-layout-issues` | Candidate after supported CLI/runtime verification |
| Widget tests | Official Flutter `flutter-add-widget-test` | Candidate after supported CLI/runtime verification |
| Dart unit test/static analysis/coverage | Focused official Dart skills | Candidate after supported CLI/runtime verification |
| Integration-test setup | Official Flutter `flutter-add-integration-test` | Do not install at inspected revision: it contains legacy Flutter Driver setup guidance |

The inspected `skills` CLI package requires Node `>=22.20.0`. The default host runtime is Node `20.20.2`, but FNM Node `24.21.0` successfully verified CLI `1.7.6` and the official catalogues. If installation is approved later, run it through `fnm exec --using 24.21.0 -- npx skills …`, select only the reviewed subset, and record source URL, immutable commit, licence, checksum, review date, command, target path, and owner before installation.

Community bulk catalogs from `thienqo/flutter-skills` and `zakariaf/Flutter-Skills` are not approved: their overlap and opinionated architecture/version assumptions would create a second authority. A specific future skill may be reconsidered only with source-level review.

