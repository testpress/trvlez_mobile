## ADDED Requirements

### Requirement: Canonical mobile UI engineering policy
The repository SHALL maintain its project-specific Android and iOS phone UI engineering policy as reviewable Markdown under `docs/engineering/`, with a documented precedence order and owner.

#### Scenario: Agent begins a mobile UI task
- **WHEN** an agent is asked to create, redesign, or fix a mobile UI screen or component
- **THEN** the discovery bridge SHALL direct it to the relevant playbook chapters and any applicable verified official skill

### Requirement: Constraint-led screen construction
The playbook SHALL require a screen/layout contract that identifies parent constraints, system-inset ownership, content growth, scroll policy, keyboard policy, and intentionally fixed component or asset dimensions before responsive UI changes are implemented.

#### Scenario: Layout differs between phones
- **WHEN** a layout looks different on two Android or iOS phone configurations
- **THEN** the investigation SHALL inspect available constraints and system/accessibility insets before introducing a screen-wide scaling formula or device-specific offset

### Requirement: Preserved legacy guidance
The repository SHALL retain existing instruction and skill files until a migration map names their canonical replacement, discovery behaviour is verified for supported IDEs, and removal is explicitly approved.

#### Scenario: Legacy guidance overlaps the playbook
- **WHEN** a playbook chapter replaces overlapping legacy content
- **THEN** the migration map SHALL identify the original path, the canonical destination, the compatibility rationale, and the removal decision

### Requirement: Verified external skill provenance
The repository SHALL maintain a skill ledger for each installed external skill with original source, pinned revision or hash, licence, compatibility evidence, installation target, discovery result, and update/uninstall procedure.

#### Scenario: Proposed skill installation
- **WHEN** an external Flutter or Dart skill is proposed for installation
- **THEN** the source files and catalogue SHALL be inspected before installation and the skill SHALL be rejected if it is irrelevant, redundant, incompatible, unmaintained, or not discoverable in an active IDE
