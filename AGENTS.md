# TrvlEz agent entry point

Project-specific engineering policy lives in [docs/engineering/README.md](docs/engineering/README.md). This file is a discovery bridge only; do not duplicate the playbook here or create competing rule sets.

Before work, load the applicable playbook chapter:

| Task | Required documentation | Optional verified procedure |
| --- | --- | --- |
| New screen or material UI edit | `playbook/00-charter-and-precedence.md`, `02-screen-construction-workflow.md`, `03-mobile-phone-layout-standard.md` | Official `flutter-build-responsive-layout` skill, if relevant |
| Layout defect or device inconsistency | `playbook/00-charter-and-precedence.md`, `03-mobile-phone-layout-standard.md`, `05-visual-validation-standard.md`, `06-testing-device-matrix.md` | Official `flutter-fix-layout-issues` skill |
| Theme, token, or shared component | `playbook/00-charter-and-precedence.md`, `04-design-system-and-reference-intake.md` | — |
| Widget test creation | `playbook/00-charter-and-precedence.md`, `05-visual-validation-standard.md` | Official `flutter-add-widget-test` skill |
| Unit test or static analysis | `playbook/00-charter-and-precedence.md` | Official `dart-add-unit-test`, `dart-run-static-analysis`, or `dart-collect-coverage` skill |
| Widget, golden, emulator, simulator, or device validation | `playbook/00-charter-and-precedence.md`, `05-visual-validation-standard.md`, `06-testing-device-matrix.md` | — |
| Accessibility or performance work | `playbook/00-charter-and-precedence.md`, `07-accessibility-and-performance.md` | — |
| Architecture or non-UI reliability work | `playbook/00-charter-and-precedence.md`, `01-app-architecture-and-boundaries.md`, `08-non-ui-engineering-backlog.md` | — |

Use `docs/engineering/playbook/00-charter-and-precedence.md` to resolve conflicts. Preserve existing `.agents/rules/` and `.agents/skills/` files until `docs/engineering/migration-map.md` and explicit approval allow a change. Do not redesign application UI, upgrade dependencies, or install packages/skills solely because this guidance exists.
