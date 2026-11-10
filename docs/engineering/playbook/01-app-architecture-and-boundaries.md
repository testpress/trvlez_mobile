# App architecture and boundaries

This is a direction for incremental work, not a claim that every existing feature already conforms perfectly. Preserve the current feature-first Riverpod/GoRouter architecture unless an approved architecture decision says otherwise.

- Feature presentation owns rendering, interaction wiring, and view-state interpretation; it does not contain transport, persistence, or device-plugin policy.
- Domain contracts describe business operations without importing Flutter widgets or platform UI concerns.
- Data/infrastructure owns API, storage, serialization, and plugin adapters behind testable contracts.
- Routes compose feature entry points. A reusable UI component is shared only when it has a shared visual, semantic, and behavioural contract.
- Keep platform-specific Android/iOS behaviour behind a narrow adapter or documented widget boundary; do not distribute platform checks through unrelated screens.

For a UI issue, correct the responsible layer. Do not move layout decisions into a notifier, add network knowledge to a widget, or duplicate a component to avoid understanding an existing boundary.

