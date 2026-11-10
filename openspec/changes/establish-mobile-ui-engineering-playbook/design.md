    ## Context

The repository currently has useful but overlapping `.agents/rules` files, three local Flutter skills, duplicated multi-IDE OpenSpec skills, semantic theme extensions, broad widget tests, and no visual baseline/device-matrix workflow. The approved programme plan is `docs/engineering/flutter-ui-engineering-consolidated-plan.md`.

The user requires the same visual engineering discipline for Android and iOS phones. Project-specific policy must be reviewable as normal Markdown rather than duplicated across custom skills or opaque rule formats. Existing application UI and dependencies are out of scope.

## Goals / Non-Goals

**Goals:**

- Create one canonical, repository-owned mobile UI engineering playbook for Android and iOS phones.
- Preserve the useful content and compatibility of existing guidance until a tested discovery bridge and migration map exist.
- Curate verified official skills as task procedures, with source/revision/licence/compatibility evidence.
- Create a repeatable validation contract that distinguishes static, widget, golden, emulator/simulator, and physical-device evidence.

**Non-Goals:**

- Screen redesign, source refactor, Flutter/Dart upgrade, or addition of UI scaling packages.
- Automatic deletion of any existing instructions or skill directories.
- A tablet/desktop redesign, an assertion of universal pixel-identical raster output, or unsupported claims about physical-device testing.

## Decisions

### Canonical project policy is normal documentation

`docs/engineering/playbook/` will own TrvlEz project policy. It is versioned, reviewable, and organised by engineering concern. A short repository-root discovery bridge will point agents to the playbook; it will not duplicate the rules.

**Alternative rejected:** encode the full policy in `.agents/rules` or custom `SKILL.md` files. Those formats make policy harder to compare, multiply sources of truth, and do not reliably serve every IDE.

### Official skills are curated procedures, not policy

Verified official Flutter/Dart skills remain under `.agents/skills/` only when their task scope is relevant. The skill ledger records upstream URL, commit SHA, licence, file hash, installation command, review date, compatible toolchain, and discovery result.

**Alternative rejected:** install either official repository using `--skill '*'`. The catalog contains unrelated CLI, FFI, migration, and experimental language workflows that add maintenance without serving the approved scope.

### Constraint-led mobile composition

The playbook requires a layout contract before a UI change: parent constraints, inset owner, content growth, scroll model, keyboard policy, and intentionally fixed component dimensions. `LayoutBuilder` is used only for decisions based on a child’s allocated space; `MediaQuery` is used for window/system/accessibility state. Fixed logical dimensions remain valid when they are named component or asset contracts.

**Alternative rejected:** scale all numbers from screen width/height. It obscures design intent and fails under text scaling, keyboard, aspect-ratio, and inset variation.

### Validation evidence is tiered and truthful

The programme defines test evidence by confidence: static checks, widget tests, controlled goldens, emulator/simulator integration, and physical devices. A golden baseline is introduced only after the Flutter environment, fonts, state, locale, time, and images are deterministic. Android/iOS emulator/simulator results are never labelled physical-device results.

**Alternative rejected:** rely on screenshots from a single reference phone or raw screenshot comparison across unpinned environments.

### Existing guidance is migrated, then retired by approval

Every old rules/skill document receives a migration-map entry with canonical destination, retained compatibility reason, and removal decision. Existing files are only removed after the user approves the map and discovery checks demonstrate the replacement works.

**Alternative rejected:** delete duplicates immediately. That risks breaking active IDE workflows and loses useful project history.

## Risks / Trade-offs

- [Discovery differs by IDE] → Validate the bridge in each active IDE and keep legacy files until the result is documented.
- [Mutable upstream skills] → Pin recorded revisions/hashes and review updates rather than trusting the default branch.
- [Golden flakiness] → Pilot one stable component in a pinned environment before CI rollout.
- [Design references remain external] → Do not claim visual parity until versioned/approved HTML/CSS or equivalent screen references are available.
- [Toolchain commands write SDK caches] → Run evidence commands in a writable developer/CI environment and retain outputs.
- [Documentation becomes stale] → Require an owner and review trigger for every playbook chapter and ADR.

## Migration Plan

1. Record the current toolchain, repository, skill provenance, instruction discovery, test, AVD, simulator, and design-reference baseline.
2. Create the playbook, skill ledger, and minimal discovery bridge; validate discovery before changing legacy files.
3. Install only approved official skills after CLI/catalog/target verification.
4. Pilot deterministic visual validation, then extend CI/device coverage in small, reviewable changes.
5. Migrate or retire legacy material only with the approved migration map.

Rollback is documentation and tooling only: restore a previous commit, retain original files until deletion is approved, and uninstall a skill by removing only its known installed directory and corresponding ledger entry.

## Open Questions

- Which IDEs beyond Codex desktop and Antigravity are active and must pass discovery validation?
- Where will the approved versioned HTML/CSS design references and their assets live?
- Which macOS/Xcode environment and iOS physical device are available for the iOS half of the validation matrix?
- What CI platform, artifact retention policy, and branch protections should own future visual-diff results?
