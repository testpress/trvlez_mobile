# Legacy instruction migration map

No legacy file is deleted or overwritten by this map. It defines the review required before any retirement.

## Migration status

| Current source | Playbook counterpart | Status | Required action before retirement |
| --- | --- | --- | --- |
| `.agents/rules/ARCHITECTURE.md` | `playbook/01-app-architecture-and-boundaries.md` | **Content drafted** | Line-by-line reconciliation against current feature structure. Verify no unique project-specific rules are lost. Named owner sign-off. |
| `.agents/rules/CODE_STANDARDS.md` | Chapters 00–04, 07 | **Partially drafted** | Layout/dimension direction covered in playbook. Pure Dart code standards (naming, async safety, git conventions) remain unique to this file and have not been drafted into a playbook chapter. |
| `.agents/rules/DESIGN_SYSTEM.md` | `playbook/04-design-system-and-reference-intake.md` | **Content drafted** | Compare line by line with `docs/design_tokens.md`. Verify token names, values, and tiers match current `ThemeExtension` contracts. Named owner sign-off. |
| `.agents/rules/flutter-responsive-layout.md` | Chapters 02, 03, 05, 06 | **Content drafted; discovery unverified** | Verify the `AGENTS.md` bridge is actually loaded by each active agent host (Antigravity, Codex, Cursor, Claude Code) before this file can be considered redundant. |
| `.agents/skills/flutter-build-responsive-layout/` | Referenced by `playbook/09-agent-tooling-and-skill-catalog.md` | **Retained** — official skill, updated lock provenance | No retirement action. Update with `npx skills update` when upstream changes. |
| `.agents/skills/flutter-semantic-layout-tokens/` | Token workflow reflected in chapter 04 | **Preserved; pending retirement decision** | Confirm no agent host depends exclusively on this skill. Named owner decides retain/retire. |
| `.agents/skills/flutter-anti-ui-slop/` | No authoritative migration | **Preserved; rejected as enterprise authority** | Remove when team owner approves. Do not expand or reference as policy. |

## New official skills installed

| Skill | Source | Installed via | `skills-lock.json` tracked |
| --- | --- | --- | --- |
| `flutter-fix-layout-issues` | `flutter/agent-plugins` | `npx skills add` | ✅ Yes |
| `flutter-add-widget-test` | `flutter/agent-plugins` | `npx skills add` | ✅ Yes |
| `dart-add-unit-test` | `dart-lang/skills` | `npx skills add` | ✅ Yes |
| `dart-run-static-analysis` | `dart-lang/skills` | `npx skills add` | ✅ Yes |
| `dart-collect-coverage` | `dart-lang/skills` | `npx skills add` | ✅ Yes |

## Contradiction resolution

| Contradiction | Resolution |
| --- | --- |
| Legacy rules say "never use raw numbers" ↔ Playbook says "intentional fixed dimensions OK when named" | **Playbook wins** (per precedence in chapter 00). Legacy rules are preserved for compatibility but the playbook's nuanced dimension policy governs new work. |
| Three responsive sources (rule + skill + playbook chapter 03) | **Playbook chapter 03 is the authority** for TrvlEz project policy. The official skill is a procedural aid. The legacy rule is compatibility material. |
| Design system in `.agents/rules/` ↔ `docs/design_tokens.md` ↔ playbook chapter 04 | **Playbook chapter 04 governs decisions**. `docs/design_tokens.md` is the implementation glossary (token names, values, categories). Legacy rule is compatibility material. |

No status may advance to **Migrated** until a named owner has signed the reconciliation, agent-host discovery has been demonstrated, and the corresponding legacy file has been confirmed redundant.
