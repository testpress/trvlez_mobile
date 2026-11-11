# Agent tooling and skill catalogue

Project policy lives in this playbook, not in a custom skill. External skills are optional procedural aids — they teach an agent how to perform a task. The playbook defines TrvlEz architecture, approved components, validation evidence, and exceptions. No skill may silently override the playbook.

---

## Discovery bridge

`AGENTS.md` at repository root is the single routing file for Codex, Antigravity, Cursor, Gemini CLI, and GitHub Copilot-compatible hosts. `CLAUDE.md` imports it for Claude Code. Both files link to this playbook rather than duplicate policy.

The bridge routes agents to the correct playbook chapter by task type. It does not contain engineering rules itself.

---

## Installed official skills

All official skills are installed under `.agents/skills/` via `npx skills add` using FNM Node 24.21.0. Provenance is tracked in `skills-lock.json` with computed hashes.

### Provenance ledger

| Skill | Source repo | Source URL | Licence | Lockfile hash (prefix) | Install date | Review date | Owner |
|---|---|---|---|---|---|---|---|
| `flutter-build-responsive-layout` | `flutter/agent-plugins` | https://github.com/flutter/agent-plugins | BSD-3-Clause | `f762ea2e` | pre-existing | 2026-11-10 | mobile engineering |
| `flutter-fix-layout-issues` | `flutter/agent-plugins` | https://github.com/flutter/agent-plugins | BSD-3-Clause | `1aaba922` | 2026-11-10 | 2026-11-10 | mobile engineering |
| `flutter-add-widget-test` | `flutter/agent-plugins` | https://github.com/flutter/agent-plugins | BSD-3-Clause | `c4f263c5` | 2026-11-10 | 2026-11-10 | mobile engineering |
| `dart-add-unit-test` | `dart-lang/skills` | https://github.com/dart-lang/skills | BSD-3-Clause | `55dabb37` | 2026-11-10 | 2026-11-10 | mobile engineering |
| `dart-run-static-analysis` | `dart-lang/skills` | https://github.com/dart-lang/skills | BSD-3-Clause | `e64ea092` | 2026-11-10 | 2026-11-10 | mobile engineering |
| `dart-collect-coverage` | `dart-lang/skills` | https://github.com/dart-lang/skills | BSD-3-Clause | `36d77c4e` | 2026-11-10 | 2026-11-10 | mobile engineering |

Upstream commit SHAs are not individually pinned by the `skills` CLI (it clones the default branch at install time). The `computedHash` in `skills-lock.json` is a content hash of the installed SKILL.md and references. When `npx skills update` changes a hash, review the diff before committing.

### Purpose and playbook relationship

| Skill | Source | Licence | Purpose | Playbook relationship |
|---|---|---|---|---|
| `flutter-build-responsive-layout` | `flutter/agent-plugins` | BSD-3-Clause | Constraint-based layout, LayoutBuilder, MediaQuery, SafeArea | Procedural aid for chapters 02 and 03. Includes tablet/desktop material outside phone-first scope — the playbook constrains its application. |
| `flutter-fix-layout-issues` | `flutter/agent-plugins` | BSD-3-Clause | Diagnosis of RenderFlex overflow, unbounded viewport, InputDecorator, and parent-data errors | Procedural aid for debugging. Supports chapter 03 diagnostics section. |
| `flutter-add-widget-test` | `flutter/agent-plugins` | BSD-3-Clause | Widget test creation workflow | Procedural aid for chapter 05 Layer 2 (widget tests). |
| `dart-add-unit-test` | `dart-lang/skills` | BSD-3-Clause | Dart unit test creation | General testing aid. |
| `dart-run-static-analysis` | `dart-lang/skills` | BSD-3-Clause | Static analysis execution and interpretation | Supports chapter 05 Layer 1 (static analysis). |
| `dart-collect-coverage` | `dart-lang/skills` | BSD-3-Clause | Test coverage collection and reporting | Supports chapter 08 item 5 (test coverage). |

### Installation commands used

```bash
# Requires FNM Node >= 22.20.0 (default host Node 20.20.2 is insufficient)
fnm exec --using 24 -- npx skills add flutter/agent-plugins \
  --skill flutter-fix-layout-issues --agent universal --yes

fnm exec --using 24 -- npx skills add flutter/agent-plugins \
  --skill flutter-add-widget-test --agent universal --yes

fnm exec --using 24 -- npx skills add dart-lang/skills \
  --skill dart-add-unit-test dart-run-static-analysis dart-collect-coverage \
  --agent universal --yes
```

### Update procedure

```bash
# Update all installed skills to latest upstream
fnm exec --using 24 -- npx skills update --project --yes

# Or update a specific skill
fnm exec --using 24 -- npx skills update flutter-fix-layout-issues
```

After updating, review the diff in `.agents/skills/`, verify `skills-lock.json` hash changes, and test that the updated skill does not conflict with the playbook.

---

## Retired local skills

These locally authored skills were retired per user approval (Option c) once their useful guidance was integrated into the playbook:

| Skill | Status | Reason |
|---|---|---|
| `flutter-semantic-layout-tokens` | **Retired** | Token workflow integrated into chapter 04. "Zero raw numbers" absolutism replaced with nuanced dimension policy. |
| `flutter-anti-ui-slop` | **Retired** | Subjective aesthetic guard; not an enterprise standard. Client design references govern visual presentation. |

---

## Rejected skill catalogues

| Candidate | Decision | Rationale |
|---|---|---|
| `flutter/agent-plugins` — `flutter-add-integration-test` | **Deferred** | Inspected revision contains legacy Flutter Driver setup guidance, not the current `integration_test` package approach. Install only after a revision that uses `IntegrationTestWidgetsFlutterBinding`. |
| `flutter/agent-plugins` — `flutter-apply-architecture-best-practices` | **Deferred** | Must be compared line-by-line with TrvlEz's current architecture rules before adoption. Risk of conflicting architectural direction. |
| `flutter/agent-plugins` — remaining catalogue | **Not installed** | Routing, localization, JSON serialization, HTTP, and other skills are unrelated to the UI engineering scope of this programme. Install individually only when a specific task requires them. |
| `dart-lang/skills` — remaining catalogue | **Not installed** | CLI, FFI, primary constructors, mock generation, and migration workflows are unrelated to current scope. Do not install `*`. |
| `thienqo/flutter-skills` | **Rejected** | High overlap with official skills and project rules. No unique, reviewed capability beyond official coverage. Would create a second maintenance source. |
| `zakariaf/Flutter-Skills` | **Rejected** | Riverpod 3.x focus conflicts with project's Riverpod 2.x dependency. High risk of version and policy conflict. |

---

## Skill-to-task mapping

When an agent is activated for a task, it should load the playbook chapter(s) first, then optionally use the indicated official skill as a procedural guide. This table is identical to the routing in `AGENTS.md`; keep them in sync.

| Task | Required playbook chapters | Optional official skill |
|---|---|---|
| New screen or material UI edit | 00, 02, 03, 04, 05, 06 | `flutter-build-responsive-layout` |
| Layout defect or device inconsistency | 00, 03, 05, 06 | `flutter-fix-layout-issues` |
| Theme, token, or shared component | 00, 04 | — |
| Widget test creation | 00, 05 | `flutter-add-widget-test` |
| Unit test or static analysis | 00 | `dart-add-unit-test`, `dart-run-static-analysis`, `dart-collect-coverage` |
| Visual validation (golden, emulator, device) | 00, 05, 06 | — |
| Accessibility or performance | 00, 07 | — |
| Architecture or non-UI reliability | 00, 01, 08 | — |

Phase 5 / material screen work is incomplete without the chapter 02 layout contract and the chapter 05/06 evidence minimum: compact + regular viewports, text scale 1.0/1.3/2.0, platform-maximum runtime validation when it exceeds 2.0, keyboard when inputs exist, and measured `MediaQuery` metadata for captures. Safe-area, keyboard, pinned-footer, platform-typography, or system-UI work requires Android emulator and iOS simulator evidence; paired `MediaQuery` capture is required for reported device discrepancies.

The playbook is always the authority. The skill is a procedural helper. If they conflict, the playbook wins.
