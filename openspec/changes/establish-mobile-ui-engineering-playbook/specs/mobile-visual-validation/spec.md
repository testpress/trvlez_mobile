## ADDED Requirements

### Requirement: Mobile validation evidence
The repository SHALL define and require evidence appropriate to each mobile UI change, distinguishing static checks, widget tests, golden tests, Android emulator/iOS simulator tests, and physical-device tests.

#### Scenario: UI work is reported complete
- **WHEN** a mobile UI task is declared complete
- **THEN** its report SHALL state the executed checks, exact logical viewport and text-scale configurations, remaining variances, and whether the evidence came from a test environment or a physical device

### Requirement: Android and iOS phone matrix
The validation playbook SHALL include compact, regular, tall, and large phone categories plus actual-device entries for the reported realme 8, Pixel 10a, and an iOS simulator/physical device when available.

#### Scenario: A cross-device layout defect is reproduced
- **WHEN** a layout defect is reported on a specific device
- **THEN** the validation record SHALL capture that device's observed logical window size, device-pixel ratio, text scale, OS version, and relevant navigation/safe-area/keyboard state

### Requirement: Deterministic golden baselines
The repository SHALL add golden baselines only for deterministic states with a pinned rendering environment, available fonts/assets, fixed viewport and text scale, controlled locale/time/data, and an explicit review process for baseline updates.

#### Scenario: A visual baseline is proposed
- **WHEN** a widget or screen is selected for golden coverage
- **THEN** the golden feasibility gate SHALL be completed before a baseline is committed or CI enforcement is enabled

### Requirement: Reference-design intake
The repository SHALL record the approved source, revision/date, asset usage, and screen mapping for any HTML/CSS or other client design reference used to assert visual fidelity.

#### Scenario: Design parity is claimed
- **WHEN** a change report claims alignment with a client design
- **THEN** it SHALL identify the approved versioned reference and the tested state/configuration rather than relying on an unversioned external local path
