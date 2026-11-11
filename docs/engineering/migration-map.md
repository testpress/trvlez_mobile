# Legacy instruction migration map

This document records the migration status and retirement decisions for legacy agent instruction files and local skills.

## Migration & Retirement Status

All migrations below were approved by user decision (2026-11-11, Option c):

| Current source | Playbook counterpart | Status | Retirement details |
| --- | --- | --- | --- |
| `.agents/rules/ARCHITECTURE.md` | `playbook/01-app-architecture-and-boundaries.md` | **Retired** ✅ | Fully superseded by playbook chapter 01. Removed in commit `chore(migration)`. |
| `.agents/rules/DESIGN_SYSTEM.md` | `playbook/04-design-system-and-reference-intake.md` | **Retired** ✅ | Fully superseded by playbook chapter 04 and `docs/design_tokens.md`. Removed in commit `chore(migration)`. |
| `.agents/rules/flutter-responsive-layout.md` | Chapters 02, 03, 05, 06 | **Retired** ✅ | Fully superseded by playbook chapters 02, 03, 05, 06. Discovery verified in `evidence/phase-1-agent-discovery.md`. Removed in commit `chore(migration)`. |
| `.agents/skills/flutter-semantic-layout-tokens/` | `playbook/04-design-system-and-reference-intake.md` | **Retired** ✅ | Token workflow integrated into chapter 04; "zero raw numbers" absolutism replaced with nuanced dimension policy. Removed in commit `chore(migration)`. |
| `.agents/skills/flutter-anti-ui-slop/` | None (rejected as authority) | **Retired** ✅ | Rejected as subjective and prescriptive. Removed in commit `chore(migration)`. |
| `.agents/rules/CODE_STANDARDS.md` | `playbook/10-dart-clean-code-standards.md` | **Retired** ✅ | General Dart clean code, naming conventions, async safety, and PR checklists migrated to playbook chapter 10. Removed in commit `chore(playbook)`. |
| `.agents/skills/flutter-build-responsive-layout/` | Referenced by `playbook/09-agent-tooling-and-skill-catalog.md` | **Retained** — official skill | Tracked in `skills-lock.json`. Procedural aid for chapters 02 and 03. |

## Official skills active in repository

All active skills are tracked in `skills-lock.json` with computed SHA-256 hashes:

| Skill | Source | Scope |
| --- | --- | --- |
| `flutter-build-responsive-layout` | `flutter/agent-plugins` | Constraint-based layouts, LayoutBuilder, MediaQuery |
| `flutter-fix-layout-issues` | `flutter/agent-plugins` | Layout diagnostics (RenderFlex, unbounded viewports) |
| `flutter-add-widget-test` | `flutter/agent-plugins` | Widget test authoring |
| `dart-add-unit-test` | `dart-lang/skills` | Unit test authoring |
| `dart-run-static-analysis` | `dart-lang/skills` | Static analysis execution |
| `dart-collect-coverage` | `dart-lang/skills` | Coverage measurement |

## Contradiction resolution

| Contradiction | Resolution |
| --- | --- |
| Legacy rules say "never use raw numbers" ↔ Playbook says "intentional fixed dimensions OK when named" | **Playbook wins** (per precedence in chapter 00). The playbook's nuanced dimension policy governs all work. |
| Responsive layout guidance sources | **Playbook chapter 03 is the sole authority** for TrvlEz mobile layout policy. The official skill is a procedural aid. |
| Design system token guidance | **Playbook chapter 04 governs decisions**. `docs/design_tokens.md` is the implementation glossary. |
