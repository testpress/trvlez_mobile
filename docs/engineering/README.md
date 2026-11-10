# TrvlEz engineering playbook

This directory is the repository-owned source of truth for engineering decisions that affect the mobile application. It is intentionally normal Markdown: reviews show meaningful diffs, links are stable, and the guidance remains useful even when an IDE or AI-agent product changes.

## Scope

The playbook governs Android and iOS **phone** engineering: app architecture boundaries, screen construction, layout, adaptability, design-system use, validation, accessibility, and related delivery standards. It does not authorize a product redesign, a framework upgrade, or a screen refactor by itself.

Use it with the approved client reference, the current code contracts, and current official Flutter/Dart documentation. It does not replace any of those inputs.

## Read the right chapters

| Work | Required reading |
| --- | --- |
| Any mobile change | `playbook/00-charter-and-precedence.md` |
| New screen or substantive screen edit | `playbook/02-screen-construction-workflow.md`, then `03-mobile-phone-layout-standard.md` |
| Token, typography, theme, or shared-component edit | `04-design-system-and-reference-intake.md` |
| Widget, golden, integration, emulator, or device validation | `05-visual-validation-standard.md`, `06-testing-device-matrix.md` |
| Agent skill selection or instruction discovery | `09-agent-tooling-and-skill-catalog.md` |
| Non-UI engineering reliability work | `08-non-ui-engineering-backlog.md` |

## Authority and change control

`playbook/00-charter-and-precedence.md` defines precedence. A document in this directory is changed through ordinary review: state the reason, affected platforms/screens, validation evidence, and any migration required. Do not copy its rules into IDE-specific files; a future discovery bridge links here instead.

The programme plan is retained at [flutter-ui-engineering-consolidated-plan.md](flutter-ui-engineering-consolidated-plan.md). Dated, non-authoritative command evidence belongs in `evidence/`.

## Current integration state

- The playbook is being established incrementally under the OpenSpec change `establish-mobile-ui-engineering-playbook`.
- Existing `.agents/rules/` and `.agents/skills/` content remains preserved pending a reviewed migration map and verified discovery behaviour.
- The default Node is `20.20.2`, but FNM Node `24.21.0` has verified the Skills CLI. No skills were installed by this programme because the playbook is the authority and duplicate skills are not useful.
