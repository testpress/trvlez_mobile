## Why

TrvlEz needs a durable, reviewable engineering environment for Android and iOS phone UI. Current guidance is spread across overlapping rules and locally authored skills, while validation has no documented device matrix or visual-regression baseline; this makes cross-device layout outcomes difficult to reproduce and govern.

## What Changes

- Establish a repository-owned mobile UI engineering playbook under `docs/engineering/` as the canonical project policy.
- Add a deliberately minimal agent-discovery bridge that links to the playbook rather than duplicating it in IDE rule files.
- Curate official Flutter/Dart procedural skills after recording their provenance, licence, revision, compatibility, and actual discovery behaviour.
- Define Android and iOS phone layout, design-system, reference-intake, accessibility, and visual-validation standards.
- Establish a repeatable baseline for analyzer/test/toolchain evidence and a staged golden, emulator/simulator, and physical-device validation capability.
- Preserve existing instructions until their content has a reviewed migration destination; reject or retire skills that fail the project’s quality, provenance, or overlap gate.

## Capabilities

### New Capabilities

- `mobile-ui-engineering-playbook`: Canonical, versioned architecture and construction guidance for Flutter Android and iOS phone UI, with defined precedence and agent discovery.
- `mobile-visual-validation`: Repeatable evidence, deterministic visual-test, emulator/simulator, and physical-device validation practices for mobile UI work.

### Modified Capabilities

None.

## Impact

This change affects engineering documentation, agent instructions/skills, validation scripts and CI only after individual approval gates. It must not alter application UI source, domain behaviour, dependencies, routes, or platform integrations as part of its initial phases.
