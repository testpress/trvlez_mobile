# TrvlEz agent entry point

Project-specific engineering policy lives in [docs/engineering/README.md](docs/engineering/README.md). This file is a discovery bridge only; do not duplicate the playbook here or create competing rule sets.

Before work, load the applicable playbook chapter:

| Task | Required documentation | Optional verified procedure |
| --- | --- | --- |
| New screen or material UI edit | `playbook/00-charter-and-precedence.md`, `02-screen-construction-workflow.md`, `03-mobile-phone-layout-standard.md`, `04-design-system-and-reference-intake.md`, `05-visual-validation-standard.md`, `06-testing-device-matrix.md` | Official `flutter-build-responsive-layout` skill, if relevant |
| Layout defect or device inconsistency | `playbook/00-charter-and-precedence.md`, `03-mobile-phone-layout-standard.md`, `05-visual-validation-standard.md`, `06-testing-device-matrix.md` | Official `flutter-fix-layout-issues` skill |
| Theme, token, or shared component | `playbook/00-charter-and-precedence.md`, `04-design-system-and-reference-intake.md` | — |
| Widget test creation | `playbook/00-charter-and-precedence.md`, `05-visual-validation-standard.md` | Official `flutter-add-widget-test` skill |
| Unit test or static analysis | `playbook/00-charter-and-precedence.md` | Official `dart-add-unit-test`, `dart-run-static-analysis`, or `dart-collect-coverage` skill |
| Clean code, Dart standards, or PR review | `playbook/00-charter-and-precedence.md`, `10-dart-clean-code-standards.md` | — |
| Widget, golden, emulator, simulator, or device validation | `playbook/00-charter-and-precedence.md`, `05-visual-validation-standard.md`, `06-testing-device-matrix.md` | — |
| Accessibility or performance work | `playbook/00-charter-and-precedence.md`, `07-accessibility-and-performance.md` | — |
| Architecture or non-UI reliability work | `playbook/00-charter-and-precedence.md`, `01-app-architecture-and-boundaries.md`, `08-non-ui-engineering-backlog.md` | — |

Phase 5 / material screen work is incomplete without the chapter 02 layout contract and the chapter 05/06 evidence minimum: compact + regular viewports, text scale 1.0, 1.3, and 2.0, platform-maximum runtime validation when it exceeds 2.0, keyboard when inputs exist, and measured `MediaQuery` metadata for every emulator/simulator capture. Safe-area, keyboard, pinned-footer, platform-typography, or system-UI changes require both Android emulator and iOS simulator evidence; paired `MediaQuery` capture is required for reported device discrepancies.

Use `docs/engineering/playbook/00-charter-and-precedence.md` to resolve conflicts. Legacy rules and local skills have been retired per `docs/engineering/migration-map.md`. Do not redesign application UI, upgrade dependencies, or install packages/skills solely because this guidance exists.
