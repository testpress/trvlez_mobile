# TrvlEz engineering playbook

This directory is the repository-owned source of truth for engineering decisions that affect the mobile application. It is intentionally normal Markdown: reviews show meaningful diffs, links are stable, and the guidance remains useful even when an IDE or AI-agent product changes.

## Scope

The playbook governs Android and iOS **phone** engineering: app architecture boundaries, screen construction, layout, adaptability, design-system use, validation, accessibility, performance, and related delivery standards. It does not authorize a product redesign, a framework upgrade, or a screen refactor by itself.

Use it with the approved client reference, the current code contracts, and current official Flutter/Dart documentation. It does not replace any of those inputs.

## Read the right chapters

| Work | Required reading |
| --- | --- |
| Any mobile change | `playbook/00-charter-and-precedence.md` |
| New screen or substantive screen edit | `02`, `03`, `04`, `05`, and `06` (layout contract + tokens + evidence minimum) |
| Token, typography, theme, or shared-component edit | `04-design-system-and-reference-intake.md` |
| Widget, golden, integration, emulator, or device validation | `05-visual-validation-standard.md`, `06-testing-device-matrix.md` |
| Accessibility or performance work | `07-accessibility-and-performance.md` |
| Architecture or non-UI reliability work | `01-app-architecture-and-boundaries.md`, `08-non-ui-engineering-backlog.md` |
| Clean code, Dart standards, or PR review | `playbook/10-dart-clean-code-standards.md` |
| Agent skill selection or instruction discovery | `09-agent-tooling-and-skill-catalog.md` |

## Authority and change control

`playbook/00-charter-and-precedence.md` defines precedence. A document in this directory is changed through ordinary review: state the reason, affected platforms/screens, validation evidence, and any migration required. Do not copy its rules into IDE-specific files; the discovery bridge in `AGENTS.md` links here instead.

**Cross-device layout change control:** Chapters `02`, `03`, `05`, and `06` are stable policy. Changes to their behavioural requirements, supported-window envelope, or evidence minimum require a measured need and an ADR. Factual corrections, examples, official-link updates, and clarifications that do not change those requirements use ordinary review. Do not rewrite these chapters opportunistically while implementing screens.

## Supporting documents

| Document | Purpose |
| --- | --- |
| [flutter-ui-engineering-consolidated-plan.md](flutter-ui-engineering-consolidated-plan.md) | Programme plan — research, audit, roadmap (non-authoritative) |
| [migration-map.md](migration-map.md) | Legacy instruction migration tracking and contradiction resolution |
| [decisions/](decisions/) | Architecture Decision Records for durable choices |
| [evidence/](evidence/) | Dated audit baselines and validation evidence |

## Current integration state

- The playbook is established with comprehensive chapters covering architecture, screen construction, layout, design system, validation, device matrix, accessibility, performance, and non-UI engineering.
- 6 official skills installed from `flutter/agent-plugins` and `dart-lang/skills`, tracked in `skills-lock.json`.
- Legacy rules and local skills retired per `migration-map.md` (user approval 2026-11-11); the playbook is the single authority.
- Deterministic test helpers in `test/helpers/` cover the required material-screen viewport, text-scale, and system-inset profile matrix; `LoginScreen` is the representative real-screen adoption.
- Installation requires FNM Node ≥ 22.20.0 for skill CLI operations (default host Node 20.20.2 is insufficient).
