# Legacy instruction migration map

No legacy file is deleted or overwritten by this map. It defines the review required before any retirement.

| Current source | Content retained in playbook | Required action before retirement |
| --- | --- | --- |
| `.agents/rules/ARCHITECTURE.md` | Architecture direction in `playbook/01-app-architecture-and-boundaries.md` | Reconcile every project-specific rule with current feature structure; preserve unique material |
| `.agents/rules/CODE_STANDARDS.md` | Conditional layout/dimension direction in chapters 00–03 | Review non-UI Dart standards separately; remove no rules by implication |
| `.agents/rules/DESIGN_SYSTEM.md` | Token/theme direction in `playbook/04-design-system-and-reference-intake.md` | Compare with `docs/design_tokens.md` and retain detailed implementation glossary |
| `.agents/rules/flutter-responsive-layout.md` | Phone constraints/insets/keyboard/validation direction in chapters 02, 03, 05, and 06 | Verify the agent discovery bridge and preserve any project-specific scenarios |
| `.agents/skills/flutter-build-responsive-layout/` | Procedural aid referenced by `playbook/09-agent-tooling-and-skill-catalog.md` | Repair lock provenance and confirm supported-host discovery |
| `.agents/skills/flutter-semantic-layout-tokens/` | Valuable token workflow reflected in chapter 04 | Decide retain/adapt/retire only after source/licence and absolute-rule review |
| `.agents/skills/flutter-anti-ui-slop/` | No authoritative migration | Keep unchanged until owner decision; do not expand or treat as enterprise policy |

The documentation becomes authoritative immediately for new work. Legacy files remain compatibility material until a named owner approves a migration and host discovery has been demonstrated.

