---
trigger: always_on
---

# Design Pattern Rules (Dart / Flutter)

These rules define **when and how** to apply design patterns in the Flutter app.
The goal is to use patterns that solve real problems — not to add patterns for their own sake.

---

## Core Philosophy

- **Patterns are tools, not goals** — use them to solve specific problems
- Every pattern must earn its place — if a simpler approach works, use it
- Prefer Flutter/Dart idiomatic solutions over textbook OOP patterns
- Do not add a pattern preemptively — add it when the problem actually appears
- Readability always wins over cleverness

---

## Repository Pattern

### When to Use
- To abstract data access behind a consistent interface
- When a feature needs to combine multiple data sources (remote API + local cache)
- To make the presentation layer testable without real data sources

### Rules
- One repository per feature domain: `HotelRepository`, `BookingRepository`
- Repositories return **domain models**, never DTOs, JSON, or raw Maps
- Repositories handle the decision of where to get data (cache vs API)
- Keep repositories thin — they orchestrate data sources, they don't contain business logic

### When NOT to Use
- For features with only one simple data source — a direct data source call is fine
- Don't create a repository that just proxies a single API call with no added value

```dart
// Good — adds value by combining sources
class HotelRepository {
  final HotelRemoteDataSource _remote;
  final HotelLocalDataSource _local;

  Future<List<Hotel>> getHotels({required String city}) async {
    try {
      final dtos = await _remote.fetchHotels(city: city);
      await _local.cache(dtos);
      return dtos.map((e) => e.toDomain()).toList();
    } on NetworkException {
      return _local.getCached(city: city);
    }
  }
}

// Bad — adds no value, just a pass-through
class HotelRepository {
  final HotelApi _api;

  Future<List<Hotel>> getHotels() => _api.getHotels(); // pointless wrapper
}
```

---

## Provider / Notifier Pattern (State Management)

### When to Use
- To manage state that needs to be shared across multiple widgets
- To separate business logic from UI code
- To make state changes testable

### Rules
- One state class per feature or screen: `HotelListNotifier`, `BookingFormController`
- State classes should be **framework-agnostic where possible** — business logic should work without Flutter
- Expose **immutable state** — consumers should not mutate state directly
- State changes should be explicit and traceable — no hidden side effects

### Anti-Patterns to Avoid
- God notifiers that manage state for multiple unrelated features
- Putting UI logic (navigation, dialogs) inside state management classes
- Using state management for ephemeral state that belongs in `StatefulWidget`

```dart
// Good — focused, single-responsibility state
class HotelListNotifier extends ChangeNotifier {
  final HotelRepository _repository;
  
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Hotel> get hotels => List.unmodifiable(_hotels);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHotels({required String city}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hotels = await _repository.getHotels(city: city);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Observer Pattern (Streams and Reactive Data)

### When to Use
- Real-time data (WebSocket, Firebase, live updates)
- When multiple consumers need to react to the same data changes
- For event-driven communication between decoupled components

### Rules
- Use `Stream` and `StreamController` for event-based data flows
- Always close `StreamController` instances when done
- Prefer `BroadcastStream` when multiple listeners are needed
- Use `StreamBuilder` or state management wrappers in the UI — never listen to streams directly in `build()`

### When NOT to Use
- For one-time data fetching — use `Future` instead
- For simple parent-child communication — use callbacks or state management

---

## Builder Pattern (Widget Composition)

### When to Use
- When constructing complex widget configurations with many optional parameters
- For creating reusable, configurable UI components

### Rules
- Use named parameters with sensible defaults instead of builders when possible
- Leverage Flutter's built-in builder patterns: `ListView.builder()`, `FutureBuilder`, `StreamBuilder`
- Extract builder methods for complex widget subtrees within `build()`

```dart
// Good — extract builder methods for clarity
class HotelListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(title: const Text('Hotels'));
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemCount: hotels.length,
      itemBuilder: (context, index) => HotelCard(hotel: hotels[index]),
    );
  }
}
```

---

## Factory Pattern

### When to Use
- When you need to create different widget or object variants based on runtime conditions
- For parsing API responses into different model types
- For creating platform-specific implementations

### Rules
- Use factory constructors in Dart — they're a first-class language feature
- Keep factory logic simple — if the factory has complex branching, reconsider the design
- Prefer `sealed class` + `switch` over factory patterns for type-safe variant handling

```dart
// Good — factory constructor for JSON parsing
class Notification {
  final String id;
  final String title;
  final NotificationType type;

  const Notification({
    required this.id,
    required this.title,
    required this.type,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      type: NotificationType.values.byName(json['type'] as String),
    );
  }
}

// Good — sealed class for type-safe variants
sealed class PaymentMethod {
  const PaymentMethod();
}

class CreditCard extends PaymentMethod {
  final String last4;
  const CreditCard({required this.last4});
}

class UPI extends PaymentMethod {
  final String vpa;
  const UPI({required this.vpa});
}
```

---

## Strategy Pattern

### When to Use
- When you need to swap algorithms or behaviors at runtime
- For pluggable sorting, filtering, or formatting logic
- For supporting multiple implementations (e.g., different payment gateways)

### Rules
- Define the strategy as an abstract interface (Dart abstract class)
- Keep strategies focused on ONE algorithm or behavior
- Inject strategies via constructor — not via global state or service locator

```dart
// Good — strategy for different price formatting
abstract class PriceFormatter {
  String format(double price);
}

class INRFormatter implements PriceFormatter {
  @override
  String format(double price) => '₹${price.toStringAsFixed(0)}';
}

class USDFormatter implements PriceFormatter {
  @override
  String format(double price) => '\$${price.toStringAsFixed(2)}';
}
```

---

## Singleton Pattern

### When to Use (Sparingly)
- For app-wide services that must have exactly one instance (HTTP client, logger, analytics)
- For configuration that's initialized once at startup

### Rules
- **Prefer dependency injection over singletons** — singletons make testing harder
- If using a singleton, implement it with Dart's factory constructor pattern
- Never use singletons for data that changes or needs to be scoped to a feature
- If your DI framework manages the lifecycle, you don't need a manual singleton

```dart
// Acceptable — for truly global, stateless services
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  void info(String message) { /* ... */ }
  void error(String message, {Object? error}) { /* ... */ }
}

// Better — register as a singleton in DI container
// getIt.registerSingleton<AppLogger>(AppLogger());
```

---

## Extension Methods

### When to Use
- To add utility methods to existing types without subclassing
- For domain-specific formatting, parsing, or validation on primitive types
- To add convenience methods to Flutter types (`BuildContext`, `ThemeData`)

### Rules
- Keep extensions focused — one extension per concern
- Name extensions descriptively: `StringValidation`, `DateTimeFormatting`, `BuildContextExtensions`
- Do not use extensions to add business logic that belongs in a service or model
- Extensions should be **stateless** — they add behavior, not data

```dart
// Good — focused, useful extensions
extension StringValidation on String {
  bool get isValidEmail => RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(this);
  bool get isNotBlank => trim().isNotEmpty;
}

extension DateTimeFormatting on DateTime {
  String toDisplayDate() => '${day}/${month}/${year}';
  String toApiFormat() => toIso8601String();
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}
```

---

## Mixin Pattern

### When to Use
- To share behavior across unrelated widget classes (e.g., analytics tracking, form validation)
- When you need to reuse logic across classes that don't share a common ancestor

### Rules
- Keep mixins focused on a single cross-cutting concern
- Prefer mixins over utility base classes — Dart's single inheritance makes base classes expensive
- Name mixins with descriptive verbs or adjectives: `FormValidationMixin`, `AnalyticsTrackingMixin`
- Do not use mixins for stateful logic that's better handled by composition

---

## Patterns to AVOID

### Over-Engineering
- **No abstract factory patterns** unless you're building a plugin system
- **No elaborate builder chains** when named parameters suffice
- **No observer networks** when a simple callback works
- **No repository-service-controller stacks** for simple CRUD

### Anti-Patterns
- **God objects**: Classes that know and do everything
- **Anemic models**: Models that are just data holders with all logic elsewhere
- **Service locator abuse**: Using `GetIt` or similar as a global grab bag instead of structured DI
- **Premature generalization**: Making things generic before you have 2+ concrete cases
- **Pattern soup**: Applying multiple patterns where one would suffice

---

## Decision Framework

Before applying a pattern, ask:

1. **What problem does this solve?** — If you can't name a specific problem, don't use it
2. **Is there a simpler approach?** — A function, a callback, or a named parameter might be enough
3. **Does Flutter/Dart have a built-in solution?** — Check the framework first
4. **Will the next developer understand this?** — If it needs a lengthy explanation, reconsider
5. **Is this pattern already used in the project?** — If so, follow the existing usage

---

## AI Agent Behavior for Design Patterns

- Do not introduce design patterns unless the complexity requires them
- Follow existing patterns in the project before introducing new ones
- When a pattern is needed, implement the simplest version that solves the problem
- Never create abstract classes with a single implementation — wait for the second use case
- Prefer Dart/Flutter idiomatic patterns (factory constructors, extensions, mixins) over classical OOP patterns
- If suggesting a pattern, explain WHY it's needed — not just what it is
