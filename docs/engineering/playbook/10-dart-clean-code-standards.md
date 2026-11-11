# Dart clean code and craftsmanship standards

This chapter defines language-level clean code standards, naming conventions, modern Dart 3 idioms, widget craftsmanship, and git conventions. It complements the architecture boundaries in chapter 01 and the layout/token standards in chapters 02–04.

Base reference: [Effective Dart](https://dart.dev/effective-dart).

---

## 1. General clean code principles

1. **Readable over clever:** Code is read 10x more often than it is written. Write obvious code.
2. **Single responsibility:** One function = one job. If you need "and" to explain what a function does, split it.
3. **Unit sizing review signals:**
   - Functions approaching ~30 lines should be reviewed for a distinct responsibility.
   - Widget `build()` methods approaching ~80 lines should be reviewed for an extractable semantic subtree.
   - Files approaching ~300 lines should be reviewed for clearer ownership or testability.

   These are not automatic split limits. Keep a cohesive unit together when splitting would hide the layout contract, duplicate state wiring, or reduce readability.
4. **Intentional naming:** `isEmailValid` rather than `flag`; `fetchBookings()` rather than `getData()`.
5. **No dead code:** Never leave commented-out code blocks; version control preserves history.
6. **Boy Scout rule:** Leave touched files cleaner than you found them.

---

## 2. Naming conventions

| Target | Rule | Good | Bad |
|---|---|---|---|
| Booleans | Question phrase (`is`, `has`, `can`, `should`) | `isLoading`, `hasError`, `canSubmit` | `loading`, `flag`, `status` |
| Methods | Verb + noun | `loadBookings()`, `submitForm()` | `bookings()`, `doStuff()` |
| Handlers | `on` prefix for parameters, `_handle` for private callbacks | `onPressed`, `_handleSubmit` | `submit1`, `buttonClick` |
| Collections | Plural nouns | `orders`, `userIds` | `orderList`, `data` |
| Avoid | Abbreviations & single letters | `customer` | `cust`, `c` |
| Avoid | Generic naming | `OrderSummary` | `Helper`, `Manager`, `Utils` |

- Name files after their main class in `snake_case`: `order_card.dart` → `OrderCard`.

---

## 3. Dart 3.x language standards

### 3.1 Prefer `final` and `const`
- Declare all local variables, parameters, and fields as `final` unless reassignment is explicitly required.
- Use `const` constructors everywhere possible to enable Flutter engine compile-time widget caching.

### 3.2 Null safety: Avoid the bang operator `!`
Never force-unwrap with `!`. Handle nullable types safely with type promotion, early returns, or fallback defaults:
```dart
// ❌ Dangerous:
final city = user.address!.city!;

// ✅ Safe:
final city = user.address?.city ?? 'Unknown';
final address = user.address;
if (address == null) return;
print(address.city);
```

### 3.3 Guard clauses and early returns
Avoid deep nesting. Validate preconditions at the top of functions and exit early:
```dart
void submit() {
  if (!isValid || isLoading) return;
  final u = currentUser;
  if (u == null) return;
  // Proceed with clean, un-nested execution
}
```

### 3.4 No nested ternaries
Avoid `a ? 'A' : b ? 'B' : 'C'`. Use explicit getter methods, `if/else` statements, or Dart 3 switch expressions.

### 3.5 Modern Dart 3 features
- **Sealed classes + pattern matching** for exhaustive state handling:
```dart
sealed class AuthStatus {}
class Authenticated extends AuthStatus { Authenticated(this.user); final User user; }
class Unauthenticated extends AuthStatus {}

final label = switch (status) {
  Authenticated(:final user) => 'Welcome ${user.name}',
  Unauthenticated() => 'Sign In',
};
```
- **Records** for simple multi-value returns without creating temporary tuple classes.
- **Named parameters with `required`** for functions with 2 or more arguments.

### 3.6 Collections and strings
- Use collection-if, collection-for, and spread operators (`[if (showBanner) const PromoBanner(), ...items]`).
- Use `.isEmpty` and `.isNotEmpty`; never compare `.length == 0`.
- Use string interpolation (`'Hello $name'`), never string concatenation with `+`. Use single quotes by default.

### 3.7 Async safety
- Always use `async/await`; never chain raw `.then()` calls.
- **Check mounted state after await:** `if (!context.mounted) return;` before using `BuildContext` across an async gap.
- Never fire-and-forget silently; wrap intentional background futures with `unawaited(...)`.
- Parallelize independent asynchronous tasks: `await Future.wait([fetchProfile(), fetchTrips()])`.

### 3.8 Typing
- Explicit return types on all public functions and methods.
- Avoid `dynamic`. Only permissible at raw JSON boundaries (`Map<String, dynamic>`).
- Parse API data safely once in DTOs; never scatter `as` casts throughout widgets.

---

## 4. Flutter widget standards

### 4.1 Meaningful widget extraction
Extract reusable, state-selecting, independently testable, or performance-sensitive subtrees into dedicated `StatelessWidget`, `ConsumerWidget`, or `HookConsumerWidget` classes. A short private helper is acceptable for a local, stateless fragment when it makes the enclosing layout contract easier to read. Do not extract solely to satisfy a line count.

### 4.2 Build methods
Keep `build()` fast, declarative, and pure. Never trigger API calls, timers, or state modifications inside `build()`.

### 4.3 Performance and lists
- Unknown or long lists must use `ListView.builder` or `SliverList`, never a `Column` with `.map()`.
- Provide `ValueKey(item.id)` for dynamic list elements to preserve widget state across reorders.
- Never instantiate controllers, formatters, or heavy objects inside `build()`.
- Use Riverpod `select` (`ref.watch(provider.select(...))`) to rebuild only when the relevant slice of state changes.

### 4.4 Resource disposal
Always dispose every controller, focus node, animation controller, and subscription in `dispose()`:
```dart
@override
void dispose() {
  _textController.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

### 4.5 Styling and layout token consumption
- Consume colors via `context.colors.*` and typography via `context.text.*`.
- Consume spacing and sizing from `context.space.*`, `context.sizes.*`, and `context.shape.*` (e.g., `context.space.insetScreen`, `context.sizes.iconDefault`). Deprecated static classes `AppSpacing` and `AppRadius` are banned.
- Prefer `SizedBox`, `Padding`, and `Align` over generic `Container` widgets.

---

## 5. UI craftsmanship and anti-defect checklist

*(Derived from craftsmanship principles to prevent common AI layout defects without violating client design references)*

1. **Operational edge states:** Every data-driven screen must handle all 4 states:
   - **Loading:** Skeleton placeholder or indicator.
   - **Error:** User-friendly message with retry action (never raw `e.toString()`).
   - **Empty:** Helpful empty state illustration/text (never a blank white screen).
   - **Data:** Populated view.
2. **Interactive feedback:** Actionable rows, cards, or custom buttons must provide visual touch feedback (use `InkWell` or button widgets, not silent `GestureDetector` widgets).
3. **Touch targets:** Minimum interactive tap target of 48×48 dp.
4. **Image fail-safes:** Network images must supply an `errorBuilder` and placeholder/loading shim. Never leave broken image icons on failure.
5. **Form and keyboard UX:** Assign logical `TextInputAction` (`next`, `done`) and include appropriate `autofillHints` for credentials and personal data.
6. **Font-scale resilience:** Verify layouts at 1.0×, 1.3×, and 2.0× in widget tests, plus the platform maximum at runtime when it exceeds 2.0×. Do not accept a screen merely because it avoids overflow; critical controls must remain visible and usable.

---

## 6. Error handling and security standards

1. **Specific catches:** Catch specific errors (`on DioException catch (e)`), never empty `catch (_) {}`.
2. **Convert at boundary:** Repositories map transport exceptions to `AppException` subtypes; UI displays user-friendly copy.
3. **No `print`:** Use structured logging (`AppLogger` in `core/utils/app_logger.dart`).
4. **Token security:** Store auth tokens and sensitive credentials in `flutter_secure_storage`, never in `shared_preferences`.
5. **No secrets in repository:** Environment secrets must be passed via `--dart-define` or `.env` configurations.

---

## 7. Git and PR standards

### Conventional commits
```
feat(orders): add cancel order action
fix(auth): handle token refresh expiration
refactor(core): extract dio error mapper
test(orders): cover repository error mapping
chore: bump dependencies
```
- Imperative mood, ≤ 72 characters, one logical change per commit.

---

## 8. Definition of Done checklist

Before marking any change complete:
- [ ] Code is formatted (`dart format .`) and passes analyzer (`flutter analyze --fatal-infos`).
- [ ] No `!`, no `dynamic` outside JSON parsing, no hardcoded colors/magic numbers.
- [ ] All 4 async states (loading / error / empty / data) handled.
- [ ] Resources cleanly disposed in `dispose()`.
- [ ] `if (!context.mounted) return;` checked after every `await` using `BuildContext`.
- [ ] `const` constructors applied wherever possible.
- [ ] Unit/widget tests added and passing (`flutter test`).
