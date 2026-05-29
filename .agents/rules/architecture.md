---
trigger: always_on
---

# Flutter Architecture Rules

These rules govern **system-level design decisions** — how code is organized, how modules
interact, and how the app stays maintainable as it grows.
These are universal principles, not prescriptions tied to any specific folder layout.

---

## Core Philosophy

- Prefer simple, maintainable architecture over enterprise-style abstraction
- Build incrementally — ship working software, then refine
- Prioritize developer velocity and readability
- Every architectural choice must earn its complexity
- Keep the app modular and production-aware

---

## Project Organization

### Principles
- **Consistency over preference**: Pick one organizational pattern and stick with it across the entire project
- **Discoverability**: A new developer should be able to find any piece of code within seconds
- **Colocation**: Related code should live close together
- **Separation of concerns**: Each file/module should have a clear, single responsibility

### Recommended Structure

Organize code by **feature/module** (domain-driven), not by technical layer:

```
lib/
├── app/                        # App-level configuration
│   ├── app.dart                # MaterialApp/CupertinoApp root widget
│   ├── router.dart             # Route definitions and navigation setup
│   └── theme.dart              # App theme, colors, typography
├── core/                       # Shared infrastructure (used across features)
│   ├── constants/              # App-wide constants
│   ├── errors/                 # Custom exception classes
│   ├── network/                # HTTP client, interceptors, API base
│   ├── storage/                # Local storage, secure storage wrappers
│   └── utils/                  # Truly generic utilities
├── features/                   # Feature modules (the bulk of the app)
│   ├── auth/
│   │   ├── data/               # Repositories, data sources, DTOs
│   │   ├── domain/             # Models, business logic
│   │   └── presentation/       # Screens, widgets, state management
│   ├── hotels/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── bookings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                     # Shared UI components used across features
│   ├── widgets/                # Reusable widgets (buttons, cards, inputs)
│   └── extensions/             # Dart extension methods
└── main.dart                   # Entry point
```

### Rules
- Follow the **existing project structure** — do not reorganize or introduce a competing pattern
- Before creating a new folder or module, check if the right location already exists
- Each file should contain one primary class (one widget, one model, one service)
- Avoid catch-all files like `helpers.dart`, `misc.dart`, or `common.dart` that grow unbounded
- Shared utilities are acceptable only when they are truly generic and reusable across features
- Feature modules should be **as independent as possible** — minimize cross-feature imports

---

## Feature Module Structure

Each feature follows a consistent internal structure:

### Data Layer (`data/`)
- **Repositories**: Abstract data access — the feature's single source of truth for data
- **Data Sources**: Concrete implementations (API calls, local database, cache)
- **DTOs/Models**: Data Transfer Objects for serialization/deserialization (JSON ↔ Dart)

### Domain Layer (`domain/`)
- **Models**: Pure Dart classes representing domain entities
- **Business Logic**: Complex rules and validations that don't belong in UI
- Keep this layer framework-agnostic — no Flutter imports

### Presentation Layer (`presentation/`)
- **Screens**: Full-page widgets that compose smaller widgets
- **Widgets**: Reusable, focused UI components specific to this feature
- **State Management**: Controllers, providers, blocs, or notifiers

### Rules
- Data flows **one direction**: Data Source → Repository → State/Controller → UI
- The presentation layer should never directly access data sources — always go through a repository
- The domain layer should have **zero Flutter dependencies**
- Repositories should return domain models, not raw JSON or DTOs

---

## Widget Architecture

### Widget Decomposition
- **One widget = one visual responsibility**
- If a widget's `build()` method exceeds 40 lines, extract child widgets
- Prefer composition (small widgets composed together) over inheritance
- Extract reusable widgets into `shared/widgets/` only when used by 2+ features

### Stateless vs Stateful
- Default to `StatelessWidget` — use `StatefulWidget` only when local mutable state is needed
- If state management is handled externally (Provider, Riverpod, Bloc), the widget should be stateless
- Keep `StatefulWidget` state minimal — only UI-specific state (animations, text controllers, scroll positions)

### Widget Keys
- Use `ValueKey` or `ObjectKey` when rendering lists of items to preserve state and enable animations
- Never use `UniqueKey` unless you intentionally want to force widget recreation
- Use `GlobalKey` sparingly — it's usually a sign of architectural issues

### Const Constructors
- **Always use `const` constructors when possible** — it improves performance
- If all fields are final and the constructor doesn't perform computation, mark it `const`
- Add `const` to widget instantiation when the widget supports it

```dart
// Good
const SizedBox(height: 16),
const Icon(Icons.star),
const HotelRatingBadge(rating: 4.5),

// Bad — missing const
SizedBox(height: 16),
Icon(Icons.star),
```

---

## State Management

### Principles
- Keep state **as simple and local as possible**
- Lift state up only when sibling widgets need to share it
- Avoid global state for things that can be local
- **Server state** (API data) and **UI state** (modals, tabs, form inputs) should be managed separately

### Rules
- Pick ONE state management approach for the project and stick with it
- Do not mix multiple state management solutions (e.g., Provider + Bloc + GetX)
- State management classes should be **testable in isolation** — no widget dependencies
- Avoid putting business logic inside `setState()` calls — keep it in controllers/providers

### State Categorization
- **Ephemeral state**: Local to a widget (animation, form input) → `StatefulWidget` or local state
- **App state**: Shared across features (auth status, user profile) → state management solution
- **Server state**: Data from APIs → state management + caching strategy

---

## Navigation and Routing

- Use a **declarative routing** approach (e.g., `go_router`, `auto_route`)
- Define all routes in a central router file — no scattered `Navigator.push()` calls
- Use typed route parameters — not raw strings
- Handle deep linking and navigation state restoration
- Keep route names consistent and RESTful: `/hotels`, `/hotels/:id`, `/bookings/:id`

---

## API Integration

### HTTP Client
- Use a single, configured HTTP client instance (e.g., `dio` with interceptors)
- Centralize base URL, headers, auth tokens, and timeout configuration
- Never scatter raw HTTP calls across widgets or screens

### Data Sources
- Each feature has its own remote data source class
- Data sources handle serialization/deserialization (JSON → DTO)
- Data sources handle API-specific error mapping

### Repository Pattern
- Repositories abstract the data layer from the presentation layer
- Repositories combine multiple data sources (remote + local cache) when needed
- Repositories return **domain models**, not DTOs or raw Maps
- Keep repositories thin — they orchestrate, not compute

```dart
// Good
class HotelRepository {
  final HotelRemoteDataSource _remoteDataSource;
  final HotelLocalDataSource _localDataSource;

  Future<List<Hotel>> getHotels({required String city}) async {
    try {
      final hotels = await _remoteDataSource.fetchHotels(city: city);
      await _localDataSource.cacheHotels(hotels);
      return hotels.map((dto) => dto.toDomain()).toList();
    } on NetworkException {
      return _localDataSource.getCachedHotels(city: city);
    }
  }
}
```

---

## Model Design

### Domain Models
- Domain models are **immutable** — use `final` fields
- Implement `copyWith()` for creating modified copies
- Use `equatable` or override `==` and `hashCode` for value equality
- Keep models framework-agnostic — no Flutter imports

### DTOs (Data Transfer Objects)
- DTOs handle serialization/deserialization only
- Use `json_serializable`, `freezed`, or manual `fromJson`/`toJson`
- DTOs live in the data layer — never expose them to the presentation layer
- Always include a `toDomain()` method to convert DTO → domain model

```dart
// Domain Model
class Hotel {
  final String id;
  final String name;
  final double rating;
  final HotelStatus status;

  const Hotel({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
  });
}

// DTO
class HotelDto {
  final String id;
  final String name;
  final double rating;
  final String status;

  Hotel toDomain() => Hotel(
    id: id,
    name: name,
    rating: rating,
    status: HotelStatus.values.byName(status),
  );
}
```

---

## Dependency Injection

- Use a lightweight DI approach — constructor injection is preferred
- Register dependencies at app startup in a centralized location
- Avoid service locators scattered throughout the code
- Dependencies should flow **downward** — a parent provides, children consume
- Keep the DI graph simple — if it's hard to understand, the architecture is too complex

---

## Error Handling Architecture

- Define a custom `AppException` hierarchy for domain-specific errors
- Map API/network errors to domain exceptions in the data layer
- Never let raw exceptions (SocketException, FormatException) leak to the presentation layer
- Display user-friendly error messages — not technical error details
- Implement a global error handler for uncaught exceptions

```dart
// Custom exception hierarchy
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}
```

---

## Async Strategy

- Use `async/await` for all asynchronous operations — avoid raw Future chaining (`.then()`)
- Cancel ongoing async operations when a widget is disposed (use `CancelableOperation` or check `mounted`)
- Never ignore `Future` return values — always `await` or explicitly ignore with `unawaited()`
- Use `Stream` for continuous data flows (WebSocket, real-time updates)
- For parallel operations, use `Future.wait()` instead of sequential awaits

---

## Authentication and Security

- Follow the authentication pattern already established in the project
- Never hardcode secrets, tokens, or credentials — use environment variables or secure storage
- Store sensitive data (tokens, keys) in `flutter_secure_storage`, not `SharedPreferences`
- Implement token refresh logic at the HTTP client level (interceptors)
- Clear all sensitive data on logout

---

## Configuration and Environment

- All environment-specific values (API URLs, feature flags) must come from configuration
- Use build flavors or environment files for different environments (dev, staging, production)
- Never commit API keys or secrets to version control
- Maintain sensible defaults for development

---

## Performance Awareness

- Use `const` constructors to reduce unnecessary rebuilds
- Avoid unnecessary widget rebuilds — scope state changes to the smallest possible subtree
- Use `ListView.builder()` for large lists — never `ListView()` with a pre-built list of children
- Cache expensive computations — don't recalculate in every `build()`
- Profile before optimizing — don't guess where bottlenecks are
- Lazy-load heavy resources (images, data) when possible

---

## Platform Awareness

- Design for both iOS and Android from the start
- Use adaptive widgets when platform-specific behavior is needed
- Handle platform-specific permissions (camera, location, storage) gracefully
- Test on both platforms regularly — don't assume behavior is identical
- Handle different screen sizes and orientations

---

## AI Agent Behavior for Architecture

- **Always follow the existing project structure and patterns** — do not reorganize or introduce competing patterns
- Before creating new files, verify the correct location by examining the existing project layout
- Do not refactor unrelated code when implementing a feature
- Prefer extending existing modules over creating parallel systems
- If a pattern is established (even if imperfect), follow it for consistency — propose improvements separately
- When adding a new feature, create the full feature module structure (data, domain, presentation)
- Never introduce a new state management solution without discussion
