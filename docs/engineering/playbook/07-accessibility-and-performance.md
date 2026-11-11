# Accessibility and performance

Accessibility is not a separate phase or an optional polish layer. It is a structural requirement that affects widget selection, layout constraints, colour tokens, interaction design, and testing from the start. Performance is not speculative optimization — it is measured diagnosis of real bottlenecks under real conditions.

---

## Accessibility

### Semantic structure

Every interactive or meaningful visual element must carry a `Semantics` widget or use a widget that produces semantics automatically (`Text`, `ElevatedButton`, `TextField`, `Checkbox`, etc.). Decorative artwork, background gradients, and ornamental dividers are excluded from the semantics tree using `ExcludeSemantics` or `Semantics(excludeSemantics: true)`.

```dart
// ✅ Correct: meaningful image has a semantic label.
Semantics(
  label: 'Passport photo of the traveller',
  child: Image.file(passportPhoto, fit: BoxFit.cover),
)

// ✅ Correct: decorative artwork excluded.
ExcludeSemantics(
  child: SvgPicture.asset('assets/art/brand_pattern.svg'),
)

// ❌ Incorrect: interactive element without semantics.
GestureDetector(
  onTap: _handleTap,
  child: Container(color: colors.actionPrimary, child: icon),
)

// ✅ Correct: use a semantically meaningful widget instead.
IconButton(
  onPressed: _handleTap,
  icon: icon,
  tooltip: 'Close dialog',
)
```

### Focus and traversal order

Ensure logical tab/swipe traversal order matches visual reading order. When custom layouts (e.g. `Stack`, `Row` with reordered children) produce a confusing traversal, use `FocusTraversalGroup` and `FocusTraversalOrder` to correct it.

Every focusable element must have a visible focus indicator. Do not remove focus rings or highlight colours to match a design comp that omits them — the comp shows one state, not all states.

### Interaction targets

All tappable elements must have a minimum interaction area of 48 × 48 logical pixels. This includes icon buttons, list item actions, close buttons, and custom gesture detectors.

```dart
// ❌ Incorrect: tap target too small.
GestureDetector(
  onTap: onClose,
  child: Icon(Icons.close, size: 16),
)

// ✅ Correct: icon is small but the tap target meets minimum.
IconButton(
  onPressed: onClose,
  icon: const Icon(Icons.close, size: 16),
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
)
```

When two targets are adjacent, ensure at least 8 logical pixels of separation or use `padding`/`SizedBox` to prevent accidental activation.

### Text scaling

The application must remain usable when the system text scale factor is set to the platform's maximum. Automated widget tests must cover 2.0× at minimum; where a supported platform exposes a larger accessibility range, validate that maximum on the platform runtime. "Usable" means:

- All text remains readable (not clipped, overlapped, or hidden behind another element).
- All interactive elements remain tappable.
- Scrollable content remains scrollable.
- Layout does not produce `RenderFlex` overflow.

```dart
// ❌ Incorrect: fixed-height container clips text at large scale.
SizedBox(
  height: 40,
  child: Text('Welcome back', style: context.text.titleMedium),
)

// ✅ Correct: minimum height with flexible growth.
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 40),
  child: Text('Welcome back', style: context.text.titleMedium),
)
```

Do not disable text scaling (`MediaQuery(data: data.copyWith(textScaler: TextScaler.noScaling), ...)`) to fix a layout problem. Fix the layout instead.

### Colour contrast

Text and interactive elements must meet WCAG 2.1 AA contrast ratios:

- Normal text (< 18sp or < 14sp bold): ≥ 4.5:1 against background.
- Large text (≥ 18sp or ≥ 14sp bold): ≥ 3:1 against background.
- Non-text controls and graphical objects: ≥ 3:1 against adjacent colours.

Use semantic colour tokens (`context.colors.*`) which are designed to meet these ratios in both light and dark themes. If a design reference uses a colour combination that fails contrast, flag it as an accessibility defect — do not silently implement it.

### Screen reader support

Test critical flows with TalkBack (Android) and VoiceOver (iOS). Verify:

- Every screen has a meaningful heading announced on entry.
- Form fields announce their labels, current values, and error states.
- Loading, error, and success states are announced via `Semantics(liveRegion: true)` or equivalent.
- Custom animations or transitions do not trap focus.
- Dismissible elements (bottom sheets, dialogs, snackbars) announce their appearance and can be dismissed.

### Reduced motion

Respect the user's reduced-motion preference:

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);

AnimatedContainer(
  duration: reduceMotion ? Duration.zero : AppMotion.normal,
  curve: AppMotion.curve,
  // ...
)
```

Purely decorative animations (background patterns, shimmer effects) should be suppressed when reduced motion is active. Functional animations (screen transitions, progress indicators) may use shorter durations or simpler curves.

---

## Performance

### Diagnosis before optimization

Do not make speculative performance changes. Measure first using Flutter DevTools:

- **Performance Overlay:** identify dropped frames and jank.
- **Timeline:** trace build, layout, and paint phases to find the bottleneck.
- **Widget Rebuild Tracker:** identify widgets rebuilding unnecessarily.

A performance change that is not backed by measurement evidence is not an optimization — it is a guess that adds complexity.

### Build method discipline

`build()` must be fast and pure. Never perform these inside `build()`:

- API calls, database queries, or file I/O.
- Object allocation for controllers, formatters, or heavy computation.
- `Future` or `Stream` creation.
- State mutations or side effects.

```dart
// ❌ Incorrect: allocating a formatter on every build.
@override
Widget build(BuildContext context) {
  final formatter = DateFormat('yyyy-MM-dd');
  return Text(formatter.format(date));
}

// ✅ Correct: formatter is stable.
static final _formatter = DateFormat('yyyy-MM-dd');

@override
Widget build(BuildContext context) {
  return Text(_formatter.format(date));
}
```

### Rebuild scope minimization

Use Riverpod `select` to watch only the specific value a widget needs:

```dart
// ❌ Incorrect: rebuilds when any property of the booking changes.
final booking = ref.watch(bookingProvider);

// ✅ Correct: rebuilds only when the status changes.
final status = ref.watch(bookingProvider.select((b) => b.status));
```

Extract subtrees into separate `ConsumerWidget` or `StatelessWidget` classes so that state changes rebuild only the affected subtree, not the entire screen.

### List and collection performance

- Use `ListView.builder`, `GridView.builder`, or `SliverList` for any list that can exceed ~20 items. Never build an entire large list eagerly in a `Column` with `.map()`.
- Provide `ValueKey(item.id)` for dynamic list items to enable efficient diffing.
- Use `const` constructors for static list items and separators.
- For heterogeneous scrollable content, prefer `CustomScrollView` with typed slivers over nested scroll views.

```dart
// ❌ Incorrect: builds all items eagerly, even those off-screen.
Column(
  children: reservations.map((r) => ReservationCard(reservation: r)).toList(),
)

// ✅ Correct: builds items lazily as they scroll into view.
ListView.builder(
  itemCount: reservations.length,
  itemBuilder: (context, index) => ReservationCard(
    key: ValueKey(reservations[index].id),
    reservation: reservations[index],
  ),
)
```

### Image performance

- Use `cacheWidth` and `cacheHeight` on `Image` widgets to decode images at the display size rather than full resolution.
- Provide `errorBuilder` on every `Image.network` and `Image.file` to handle load failures gracefully.
- Use `FadeInImage` or equivalent for network images to prevent layout jumps.
- SVG assets used at small sizes may benefit from pre-rasterized PNG alternatives in performance-critical scroll lists.

### Resource disposal

Every controller, focus node, animation controller, stream subscription, and `ScrollController` created in a `State` must be disposed in `dispose()`:

```dart
@override
void dispose() {
  _textController.dispose();
  _focusNode.dispose();
  _scrollController.dispose();
  _animationController.dispose();
  super.dispose();
}
```

Failure to dispose resources causes memory leaks, lingering listeners, and stale state. Riverpod `autoDispose` providers handle their own lifecycle — do not manually dispose a provider's resources from a widget.

### Async and isolate usage

- Use `compute()` or `Isolate.run()` for CPU-intensive work (image processing, large JSON parsing) that blocks the UI thread for more than 16ms.
- Parallelize independent network calls with `Future.wait([callA(), callB()])` rather than sequential `await`.
- Never fire-and-forget an async operation silently. Use `unawaited()` from `dart:async` when intentional, and always handle errors.

---

## Anti-patterns

| ❌ Anti-pattern | ✅ Correct approach |
|---|---|
| Disabling text scaling to fix layout | Fix the layout to accommodate scaled text |
| `GestureDetector` on a 24×24 icon | `IconButton` with 48×48 minimum constraints |
| No `Semantics` on custom interactive widgets | Wrap in `Semantics` or use Material widgets |
| Speculative `const` or `RepaintBoundary` everywhere | Measure first, optimize the measured bottleneck |
| `Column` with `.map()` for 100+ items | `ListView.builder` or slivers |
| Allocating objects inside `build()` | Static or `late final` fields, or `initState()` |
| Ignoring `dispose()` for controllers | Always dispose; verify with leak tracking in tests |
| Removing focus indicators for aesthetics | Keep focus indicators; style them if needed |

