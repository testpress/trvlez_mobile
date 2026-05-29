---
trigger: always_on
---

# Clean Code Rules (Dart / Flutter)

These rules govern how every line, function, class, and widget is written.
The goal is code that is **readable, maintainable, extensible, and production-grade**.

---

## Naming Conventions

### General Principles
- Names must be **descriptive, pronounceable, and searchable**
- Names should reveal **intent** — a reader should never need to guess what something does
- Avoid abbreviations unless universally understood (`id`, `url`, `db`, `ui` are fine; `htl`, `bkg`, `usr` are not)

### Variables
- Use `camelCase` for all variables and parameters
- Booleans must read as yes/no questions: `isActive`, `hasPermission`, `canEdit`, `shouldNotify`
- Avoid generic names: `data`, `result`, `info`, `temp`, `val`, `item`, `stuff`
- Collections should be **plural**: `hotels`, `bookingIds`, `activeUsers`
- Single items should be **singular**: `hotel`, `booking`, `user`
- Prefix private members with underscore: `_counter`, `_isLoading`

### Functions and Methods
- Use `camelCase` with a **verb prefix** that describes the action:
  - `getHotelById()`, `createBooking()`, `validateCheckoutDate()`, `sendConfirmationEmail()`
- Never: `hotelData()`, `process()`, `doStuff()`, `handle()`, `run()`
- Functions that return booleans should read as questions: `isAvailable()`, `hasActiveSubscription()`
- Event handlers should use `on` prefix: `onTap`, `onBookingCreated`, `onLoginPressed`
- Private methods use underscore prefix: `_buildHeader()`, `_handleSubmit()`

### Classes
- Use `PascalCase`: `BookingService`, `HotelResponse`, `PaymentProcessor`
- Widgets should describe what they render: `HotelCard`, `BookingForm`, `PriceBreakdown`
- Models should be the **domain noun**: `Hotel`, `Booking`, `User`
- State classes follow the pattern: `_HotelListScreenState`
- Never: `MyWidget`, `CustomWidget`, `NewScreen`, `TestPage`

### Constants
- Use `camelCase` for constants (Dart convention): `maxRetryCount`, `defaultPageSize`
- Top-level constants: `const kDefaultPadding = 16.0;` (use `k` prefix for app-wide constants)
- Never scatter raw numbers or strings — extract them to named constants

### Enums
- Use `PascalCase` for enum names, `camelCase` for values
- Prefer `enum` over raw strings or integers for fixed sets of values

```dart
// Good
enum BookingStatus { pending, confirmed, cancelled, completed }

// Bad
const STATUS_PENDING = 'pending';
const STATUS_CONFIRMED = 'confirmed';
```

### Files and Directories
- Use `snake_case` for all file names: `hotel_service.dart`, `booking_screen.dart`
- File name should reflect its primary content
- One primary class per file — the file name matches the class: `hotel_card.dart` → `HotelCard`

---

## Function Design

### Single Responsibility
- **Every function must do exactly ONE thing**
- If you can describe what a function does using "and" — split it
- Bad: `validateAndCreateBooking()` → Good: `validateBookingData()` + `createBooking()`

### Size
- Functions should be **short** — aim for 5–20 lines of logic
- If a function exceeds 30 lines, look for extraction opportunities
- If you need to scroll to read a function, it's too long
- `build()` methods are an exception but should still delegate to helper methods

### Parameters
- Maximum **3-4 parameters** per function
- If more are needed, group related parameters into a model or data class
- Avoid boolean flag parameters — they signal the function does more than one thing
- Use named parameters for clarity when a function has more than 2 parameters

```dart
// Bad
Widget buildCard(String title, String subtitle, bool showIcon, bool isCompact, Color color)

// Good
Widget buildCard({
  required String title,
  required String subtitle,
  bool showIcon = false,
  CardStyle style = CardStyle.regular,
})
```

### Return Values
- Functions should have a **clear, predictable return type**
- Avoid returning different types based on conditions
- Use nullable types (`T?`) explicitly when null is a valid return
- Prefer `Either` or `Result` types for operations that can fail

### Guard Clauses and Early Returns
- Use early returns to handle edge cases at the top
- Avoid deep nesting — flatten logic with guard clauses

```dart
// Bad - deeply nested
double getDiscount(User? user) {
  if (user != null) {
    if (user.isPremium) {
      if (user.hasActiveSubscription) {
        return calculateDiscount(user);
      }
    }
  }
  return 0;
}

// Good - guard clauses
double getDiscount(User? user) {
  if (user == null) return 0;
  if (!user.isPremium) return 0;
  if (!user.hasActiveSubscription) return 0;
  return calculateDiscount(user);
}
```

---

## Type Safety

- **Leverage Dart's strong type system** — avoid `dynamic` unless absolutely necessary
- Never use `as` casts without null checking — prefer `is` checks or safe parsing
- Use generics to write reusable, type-safe code
- Avoid `Map<String, dynamic>` for structured data — create a proper model class
- Use `required` keyword for non-optional named parameters

```dart
// Bad
Map<String, dynamic> getHotel() => {'name': 'Test', 'rating': 4.5};

// Good
Hotel getHotel() => Hotel(name: 'Test', rating: 4.5);
```

---

## Code Readability

### Comments
- **Don't comment WHAT** the code does — the code itself should be clear enough
- **Do comment WHY** — explain non-obvious business logic, workarounds, or decisions
- Delete commented-out code — version control exists for a reason

```dart
// Bad - describes what
// Loop through hotels and check availability
for (final hotel in hotels) {
  if (hotel.isAvailable) {

// Good - describes why
// We exclude hotels with pending reviews because they haven't passed
// the quality check required by our insurance policy
for (final hotel in hotels) {
  if (hotel.reviewStatus != ReviewStatus.pending) {
```

### Documentation
- Add doc comments (`///`) to **public classes, functions, and properties** that are non-trivial
- Use concise format — focus on what and why, not how

```dart
/// Calculates total booking price including taxes.
///
/// Tax is applied to the full stay amount, not per-night.
double calculateTotalPrice({
  required double basePrice,
  required int nights,
  required double taxRate,
}) {
```

### Imports
- Organize imports in this order (separated by blank lines):
  1. `dart:` SDK imports
  2. `package:` third-party packages
  3. `package:your_app/` project imports (relative imports within the project)
- Avoid wildcard imports
- Prefer explicit imports over `show`/`hide` unless narrowing is necessary
- Never use relative imports (`import '../...'`) — always use package imports

---

## No Magic Values

- Replace all magic numbers and strings with named constants or enums

```dart
// Bad
if (booking.status == 3) { ... }
if (guests.length > 10) { ... }
if (padding == 16.0) { ... }

// Good
if (booking.status == BookingStatus.confirmed) { ... }
if (guests.length > kMaxGuestsPerBooking) { ... }
if (padding == AppSpacing.md) { ... }
```

- Use Enums for status fields, categories, and any fixed set of values
- Use a design system or theme for spacing, colors, font sizes — not hardcoded values

---

## Dead Code

- **Delete unused functions, variables, imports, and commented-out code**
- Do not keep "just in case" code — Git has history
- Do not leave `TODO` comments without actionable context and ownership
- Run `dart fix --apply` periodically to auto-fix lint warnings

---

## Error Handling

- Handle specific exceptions, not bare `catch`
- Never silently swallow exceptions — at minimum, log them
- Raise meaningful errors with context
- Use `try/catch` only around code that can actually throw — not as a blanket wrapper

```dart
// Bad
try {
  final result = await processPayment(booking);
} catch (e) {
  // silently ignored
}

// Good
try {
  final result = await processPayment(booking);
} on PaymentGatewayException catch (e) {
  logger.error('Payment failed for booking ${booking.id}: $e');
  throw AppException.paymentFailed(bookingId: booking.id);
}
```

---

## Logging

- Use a structured logger (e.g., `logger` package), never `print()` or `debugPrint()` in production code
- Log at appropriate levels: `debug`, `info`, `warning`, `error`
- Include **context** in log messages: IDs, user info, action being performed
- Never log sensitive data: passwords, tokens, full credit card numbers

```dart
logger.i('Booking created', error: null, stackTrace: null);
logger.e('Payment failed for booking ${booking.id}', error: e, stackTrace: stackTrace);
```

---

## Immutability

- Prefer `final` over `var` for variables that don't change
- Use `const` constructors wherever possible — especially for widgets
- Model classes should be **immutable** — use `final` fields and `copyWith` methods
- Prefer `UnmodifiableListView` or immutable collections for exposed lists

```dart
// Bad
var name = 'Hotel';
var hotels = <Hotel>[];

// Good
final name = 'Hotel';
final hotels = <Hotel>[];
```

---

## Null Safety

- Embrace Dart's sound null safety — don't fight it
- Never use `!` (null assertion operator) unless you can **guarantee** non-null
- Prefer `??` (null-aware) and `?.` (null-aware access) over explicit null checks when cleaner
- Avoid `late` unless you are certain the value will be initialized before access

```dart
// Bad - dangerous assertion
final user = currentUser!;

// Good - handle null explicitly
final user = currentUser;
if (user == null) return;
```

---

## Code Smells to Avoid

- **God widgets**: Widgets that do too many things — split into smaller widgets
- **Deep nesting**: More than 2-3 levels of widget indentation → extract helper methods or child widgets
- **Primitive obsession**: Passing around raw Maps when a model would be clearer
- **Long parameter lists**: More than 4 params → use a model or named parameters
- **Copy-paste code**: If you copy-paste a block, extract it into a function or widget
- **Feature envy**: A function that uses more data from another module than its own
- **Stringly-typed code**: Using raw strings where enums or constants belong
- **Widget tree hell**: Deeply nested widget trees → extract into separate widget classes

---

## AI Agent Behavior for Clean Code

- When generating new code, apply ALL the rules above without exception
- When modifying existing code, improve the touched code to meet these standards but do not refactor unrelated code
- If existing code violates these rules, fix it in the area you're working on
- Never generate `build()` methods longer than 40 lines without extracting child widgets
- Always include type annotations in generated code
- Always use meaningful names — never placeholder names like `data`, `result`, `tmp`
- Always use `const` constructors where applicable
- Always use `final` for variables that don't change
