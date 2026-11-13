## Issue

<!-- What problem did users or the application face? Focus on behavior and user impact. -->

## Cause

<!-- Why did the issue happen? Root cause at architecture, layout, or data boundary. -->

## Fix

<!-- How is the issue resolved? Behavior and outcomes after the change. -->

---

## Conformance & Validation Checklist

Refer to `docs/engineering/playbook/00-charter-and-precedence.md` for governing policies.

- [ ] **Layout Contract:** Follows [02-screen-construction-workflow.md](file:///docs/engineering/playbook/02-screen-construction-workflow.md); uses parent constraints and content-driven sizing (no unapproved window-height scaling).
- [ ] **Design Tokens:** Consumes semantic tokens via `context.colors`, `context.text`, `context.space`, `context.sizes`, `context.shape` per [04-design-system-and-reference-intake.md](file:///docs/engineering/playbook/04-design-system-and-reference-intake.md).
- [ ] **Architecture Boundary:** Domain remains pure; presentation does not import `data/` per [01-app-architecture-and-boundaries.md](file:///docs/engineering/playbook/01-app-architecture-and-boundaries.md).
- [ ] **Scaling & Accessibility:** Verified across 1.0x, 1.3x, and 2.0x text scale (and platform-max where applicable); tap targets ≥ 48×48 dp per [07-accessibility-and-performance.md](file:///docs/engineering/playbook/07-accessibility-and-performance.md).
- [ ] **Evidence Minimum:** Verified on compact (360×800) and regular (390×844) viewports with keyboard and system insets tested per [05-visual-validation-standard.md](file:///docs/engineering/playbook/05-visual-validation-standard.md) and [06-testing-device-matrix.md](file:///docs/engineering/playbook/06-testing-device-matrix.md).
- [ ] **Quality Gates:** `bash scripts/quality_gates.sh` passes (formatting, analyzer, token guards, unit & widget tests).

