# Flutter / Dart Clean Code Standards

> Companion to `ARCHITECTURE.md` and `DESIGN_SYSTEM.md`.
> Architecture defines **where** code goes; this guide defines **how to write it**.
> Base reference: [Effective Dart](https://dart.dev/effective-dart).

---

## 1. General Principles

1. **Readable over clever:** Code is read 10x more than written.
2. **One function = one job:** If you need "and" to describe it, split it.
3. **Small units:** Functions ≤ ~30 lines, `build()` ≤ ~80 lines, files ≤ ~300 lines.
4. **Intentional names:** `isEmailValid` not `flag`; `fetchOrders` not `getData`.
5. **No dead code:** Delete commented-out code; git remembers history.
6. **Boy scout rule:** Leave touched files cleaner than you found them.

---

## 2. Naming Conventions

| Target | Rule | Good | Bad |
|---|---|---|---|
| Booleans | Question phrase | `isLoading`, `hasError`, `canSubmit` | `loading`, `flag` |
| Methods | Verb + noun | `loadOrders()`, `submitForm()` | `orders()`, `doStuff()` |
| Handlers | `on` prefix (param), `_handle` (private) | `onPressed`, `_handleSubmit` | `submit1` |
| Collections | Plural | `orders`, `userIds` | `orderList`, `data` |
| Avoid | Abbreviations & single letters | `customer` | `cust`, `c` |
| Avoid | Generic naming | `OrderSummary` | `Helper`, `Manager`, `Utils` |

- Name files after their main class in `snake_case`: `order_tile.dart` → `OrderTile`.

---

## 3. Dart Language Standards

### 3.1 Prefer `final` and `const`
Always declare variables as `final` unless reassignment is required. Use `const` constructors everywhere possible.

### 3.2 Null Safety: Avoid the Bang Operator `!`
Never force-unwrap with `!`. Handle null safely with promotion, early returns, or defaults:
```dart
// ❌ final city = user.address!.city!;
// ✅
final city = user.address?.city ?? 'Unknown';
final address = user.address;
if (address == null) return;
print(address.city);
```

### 3.3 Guard Clauses & Early Returns
Avoid deep nesting. Check preconditions first and exit early:
```dart
void submit() {
  if (!isValid || isLoading) return;
  final u = user;
  if (u == null) return;
  // proceed with valid state
}
```

### 3.4 No Nested Ternaries
Avoid `a ? 'A' : b ? 'B' : 'C'`. Use explicit getter methods or modern `switch` expressions.

### 3.5 Modern Dart 3.x Features
- **Sealed classes + pattern matching** for exhaustive state handling:
```dart
sealed class AuthStatus {}
class Authenticated extends AuthStatus { Authenticated(this.user); final User user; }
class Unauthenticated extends AuthStatus {}

final label = switch (status) {
  Authenticated(:final user) => 'Hi ${user.name}',
  Unauthenticated() => 'Sign In',
};
```
- **Records** for simple multi-value returns.
- **Named parameters with `required`** for functions with 2+ arguments.

### 3.6 Collections & Strings
- Use collection-if, collection-for, and spreads (`[if (show) const Banner(), ...items]`).
- Use `.isEmpty` / `.isNotEmpty`, never `.length == 0`.
- String interpolation: `'Hello $name'` (never `+` concatenation). Single quotes by default.

### 3.7 Async Safety
- Use `async/await`, never raw `.then()` chains.
- **Always check mounted state after await:** `if (!context.mounted) return;` before using `BuildContext`.
- Never fire-and-forget silently; use `unawaited(...)` if intentional.
- Parallelize independent calls: `await Future.wait([callA(), callB()])`.

### 3.8 Typing
- Explicit return types on all public functions.
- Avoid `dynamic`. Only permissible at raw JSON boundaries (`Map<String, dynamic>`).
- Parse API data safely once in DTOs; never scatter `as` casts throughout the codebase.

---

## 4. Flutter Widget Standards

### 4.1 Widget Classes Over Helper Methods
Extract sub-widgets into dedicated `StatelessWidget` / `ConsumerWidget` classes, not private `_buildX()` methods. Classes provide isolated rebuild boundaries and support `const`.

### 4.2 Build Methods
Keep `build()` fast and pure. Never trigger API calls, timers, or state modifications inside `build()`.

### 4.3 Performance & Lists
- Unknown or long lists must use `ListView.builder` or `SliverList`, never `Column` with `.map()`.
- Provide `ValueKey(item.id)` for dynamic list elements.
- Never instantiate controllers, formatters, or heavy objects inside `build()`.
- Use Riverpod `select` (`ref.watch(provider.select(...))`) to prevent unnecessary rebuilds.

### 4.4 Resource Disposal
Always dispose every controller, focus node, animation controller, and subscription:
```dart
@override
void dispose() {
  _textController.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

### 4.5 Styling & Responsiveness
- Consume colors via `context.colors.*` and typography via `context.text.*`.
- Spacing from `AppSpacing` (e.g. `SizedBox(height: AppSpacing.md)`).
- Prefer `SizedBox`, `Padding`, and `Align` over generic `Container` widgets.
- Use `MediaQuery.sizeOf(context)` or `LayoutBuilder` for screen-size adaptivity.

### 4.6 UX & Accessibility
- Minimum interactive tap targets of 48×48 dp.
- Always handle all 4 states for async views: **Loading, Error, Empty, and Data**.
- Disable action buttons while loading to prevent duplicate requests.

---

## 5. Error Handling & Security

1. **Specific Catches:** Catch specific errors (`on DioException`), never empty `catch (_) {}`.
2. **Convert at Boundary:** Repositories map exceptions to `AppException`; UI displays friendly messages, never raw `e.toString()`.
3. **No `print`:** Use a structured logger (`core/utils/app_logger.dart`).
4. **Token Security:** Store auth tokens in `flutter_secure_storage`, never in `shared_preferences`.
5. **No Secrets in Repo:** Environment secrets passed via `--dart-define` / `.env`.

---

## 6. Git & PR Standards

### Conventional Commits
```
feat(orders): add cancel order action
fix(auth): handle token refresh expiration
refactor(core): extract dio error mapper
test(orders): cover repository error mapping
chore: bump dependencies
```
- Imperative mood, ≤ 72 characters, one logical change per commit.

---

## 7. Definition of Done Checklist

- [ ] Code is formatted (`dart format .`) and passes analyzer (`flutter analyze`).
- [ ] No `!`, no `dynamic` outside JSON parsing, no hardcoded colors/strings/spacing.
- [ ] All 4 async states (loading / error / empty / data) handled.
- [ ] Resources cleanly disposed in `dispose()`.
- [ ] `if (!context.mounted) return;` checked after every `await` using `context`.
- [ ] `const` constructors applied wherever possible.
- [ ] Unit/widget tests added and passing (`flutter test`).
