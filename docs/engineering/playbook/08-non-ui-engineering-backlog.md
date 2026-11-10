# Non-UI engineering backlog

These observations are separate from screen design and are not authorization for an opportunistic refactor.

1. **Reproducible bootstrap:** document ownership and revision policy for the sibling `../dmrtd` path dependency; evaluate a controlled workspace, git-pinned, or published alternative.
2. **Deterministic CI:** pin Flutter, Java, Gradle, and golden-rendering inputs rather than relying on a moving stable channel.
3. **Terminal test baseline:** diagnose why the current full suite did not reach a summary in the bounded Phase 1 run before declaring it green.
4. **Security and release assurance:** establish dependency review, secret scanning, signing/release provenance, and privacy-safe logging policy.
5. **Observability:** ensure network/device/plugin failures have structured, redacted diagnostics rather than broad catches or request logging that could expose sensitive values.
6. **Accessibility automation:** add semantics, contrast, text-scale, and navigation checks in proportion to critical flows.

Each item needs a separately owned proposal, risk assessment, and verification plan. None should be hidden inside a UI ticket.

