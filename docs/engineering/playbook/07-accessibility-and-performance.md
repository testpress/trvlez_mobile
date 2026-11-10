# Accessibility and performance

Every visual component must retain semantic labels, logical traversal order, visible focus/tap affordance, readable contrast, and usable text scaling. Decorative artwork is excluded from semantics; meaningful imagery receives useful labels. A small visual adjustment that breaks a 48 logical-pixel interaction target, hides focus, or clips large text is not acceptable.

Prefer lazy lists/slivers for unbounded collections, avoid rebuilding expensive/immutable objects unnecessarily, and profile scroll/jank with Flutter tooling before making speculative performance changes. A performance optimization that caches stale layout information or ignores accessibility settings is a defect, not an optimization.

Every visual component must retain semantic labels, logical traversal order, visible focus/tap affordance, readable contrast, and usable text scaling. Decorative artwork is excluded from semantics; meaningful imagery receives useful labels. A small visual adjustment that breaks a 48 logical-pixel interaction target, hides focus, or clips large text is not acceptable.

