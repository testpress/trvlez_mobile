# App architecture and boundaries

This chapter defines the structural principles that govern where code lives, how layers communicate, and what each layer is allowed to do. It is a direction for all new work and incremental improvement, not a claim that every existing feature already conforms perfectly. Preserve the current feature-first Riverpod/GoRouter architecture unless an approved architecture decision says otherwise.

---

## The dependency rule

Dependencies flow downward only. Violations create hidden coupling, untestable code, and cascading changes.

```
PRESENTATION  (Screens, Widgets, Notifiers/Providers)
      │ watches / calls
      ▼
   DOMAIN     (Entities, Repository Interfaces, Value Objects)  ← Pure Dart
      ▲
      │ implements
    DATA      (Repository Impls, Remote/Local Data Sources, DTOs)
```

- **Presentation** imports **domain**. It never imports **data** directly — no Dio types, no DTO classes, no data source references in a screen or widget file.
- **Data** imports **domain** to implement its interfaces and to convert DTOs into domain entities.
- **Domain** is pure Dart. It imports nothing from Flutter, Dio, platform plugins, or data-layer packages. It defines what the application can do, not how it does it.

```dart
// ❌ Incorrect: screen imports data layer directly.
import 'package:trvlez_mobile/features/auth/data/datasources/auth_remote_data_source.dart';

// ✅ Correct: screen watches a provider backed by a domain interface.
final authState = ref.watch(authNotifierProvider);
```

---

## Feature-first folder structure

Group code by feature, not by type. Each feature owns its own `domain/`, `data/`, and `presentation/` directories. Shared code lives in `core/`.

```
lib/
├── main.dart
├── app/
│   ├── app.dart                      # Root MaterialApp.router
│   ├── router/                       # Route definitions, guards, path constants
│   └── theme/                        # ThemeData, component themes, token definitions
├── core/                             # Feature-independent shared code
│   ├── constants/                    # API endpoints, string keys
│   ├── design_tokens/                # AppSpace, AppSize, AppShape ThemeExtensions
│   ├── errors/                       # AppException hierarchy
│   ├── network/                      # Dio client, interceptors
│   ├── storage/                      # Secure storage, preferences
│   ├── utils/                        # Formatters, validators, helpers
│   └── widgets/                      # Shared widgets used by 2+ features
└── features/<feature_name>/
    ├── domain/
    │   ├── entities/                 # Pure Dart business models
    │   └── repositories/             # Abstract repository interfaces
    ├── data/
    │   ├── datasources/              # Remote/local data sources (Dio, DB)
    │   ├── models/                   # DTOs with fromJson/toJson and toEntity()
    │   └── repositories/             # Concrete repository implementations
    └── presentation/
        ├── providers/                # Notifiers, state classes, provider declarations
        ├── screens/                  # Screen widgets (one public widget per file)
        └── widgets/                  # Feature-local sub-widgets
```

### Placement rules

| Need | Location | Rationale |
|---|---|---|
| Screen UI, dialog, bottom sheet | `features/<f>/presentation/screens/` | Owned by the feature |
| Feature-only sub-widget | `features/<f>/presentation/widgets/` | Not shared |
| Widget reused across 2+ features | `core/widgets/` | Shared visual contract |
| Screen state and UI actions | `features/<f>/presentation/providers/` | Notifier owns view state |
| API HTTP calls | `features/<f>/data/datasources/` | Data layer only |
| JSON serialization | `features/<f>/data/models/` | DTO boundary |
| Business entity | `features/<f>/domain/entities/` | Pure Dart |
| Data contract interface | `features/<f>/domain/repositories/` | Abstraction |
| Concrete data implementation | `features/<f>/data/repositories/` | Behind interface |
| Route paths and config | `app/router/` | Central routing |
| Colours, spacing, sizing, shape | `app/theme/` and `core/design_tokens/` | Token ownership |
| Error types | `core/errors/` | Shared across features |

---

## Layer responsibilities and prohibitions

### Presentation layer

**Owns:** rendering, interaction wiring, view-state interpretation, layout composition, animation, navigation triggers.

**Prohibited from:** making HTTP calls, parsing JSON, accessing databases, containing business rules, knowing about Dio/HTTP types, importing data-layer files.

```dart
// ❌ Incorrect: business logic in a widget.
if (booking.checkInDate.isBefore(DateTime.now())) {
  // complex cancellation policy calculation
}

// ✅ Correct: domain entity owns the logic.
// In domain/entities/booking.dart:
bool get isCancellable => checkInDate.isAfter(DateTime.now().add(const Duration(hours: 24)));

// In presentation:
if (booking.isCancellable) { /* show cancel button */ }
```

Widgets only draw UI. They read state from providers and forward user actions to notifiers. They do not orchestrate multi-step operations.

### Domain layer

**Owns:** business entities, repository interfaces, value objects, business rule methods on entities, and use cases when the orchestration logic justifies a separate class.

**Prohibited from:** importing Flutter, any UI package, Dio, database packages, or platform plugins. Domain must compile as pure Dart.

```dart
// ❌ Incorrect: domain entity imports Flutter.
import 'package:flutter/material.dart';
class User {
  Color get statusColor => isVerified ? Colors.green : Colors.red; // UI concern
}

// ✅ Correct: domain entity is pure Dart.
class User {
  final String id;
  final String name;
  final bool isVerified;
  // Business logic only — no colours, no widgets.
}
```

### Data layer

**Owns:** API calls, JSON parsing, database queries, platform plugin adapters, DTO-to-entity conversion, error mapping from transport exceptions to `AppException`.

**Prohibited from:** containing business rules, making UI decisions, importing Flutter widgets, or being imported directly by the presentation layer.

```dart
// Repository implementation maps transport errors to domain exceptions.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  @override
  Future<User> login(String email, String password) async {
    try {
      final dto = await _remote.login(email, password);
      return dto.toEntity();
    } on DioException catch (e) {
      throw mapDioException(e); // Returns AppException subtype
    }
  }
}
```

---

## Cross-feature communication

Features must not import another feature's `data/` or `presentation/` directories. When features need to share data or coordinate:

- **Shared domain entities:** Place in `core/domain/` or the feature that owns the concept.
- **Shared providers:** A provider in one feature may depend on a domain-level provider from another, but never on its presentation or data internals.
- **Navigation:** Features communicate through route parameters, not by importing each other's screens or state.

```dart
// ❌ Incorrect: feature A imports feature B's presentation.
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_notifier.dart';

// ✅ Correct: feature A depends on a domain-level auth state provider.
import 'package:trvlez_mobile/core/auth/auth_state_provider.dart';
```

---

## State management boundaries

### Notifier responsibilities

Notifiers (`AsyncNotifier`, `Notifier`, `StateNotifier`) own the view state for a screen or a coherent piece of UI. They:

- Talk only to abstract repository interfaces (never to data sources or Dio directly).
- Expose typed, immutable state objects.
- Handle loading, error, and success transitions.
- Do not hold `BuildContext`, do not trigger navigation, and do not show UI feedback directly.

```dart
class BookingNotifier extends AsyncNotifier<BookingState> {
  @override
  Future<BookingState> build() async {
    final bookings = await ref.read(bookingRepositoryProvider).getBookings();
    return BookingState(bookings: bookings);
  }

  Future<void> cancelBooking(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).cancel(id);
      return build();
    });
  }
}
```

### Side effects in screens

Navigation, snackbars, and dialogs triggered by state changes belong in the screen using `ref.listen`, not in the notifier:

```dart
ref.listen(bookingNotifierProvider, (prev, next) {
  next.whenOrNull(
    error: (error, _) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    },
  );
});
```

---

## Widget composition rules

1. **Clear public ownership.** A public reusable widget normally has its own `snake_case` file. Closely coupled private widgets may remain with their owner when separation would obscure the screen contract.
2. **Extract meaningful subtrees.** Prefer `StatelessWidget`, `ConsumerWidget`, or `HookConsumerWidget` for reusable, state-selecting, or independently testable subtrees. A small private helper is acceptable when it improves local readability and has no independent state, lifecycle, or rebuild boundary.
3. **Use size thresholds as review signals.** A `build()` method approaching ~80 lines or a file approaching ~300 lines should prompt extraction review; it is not an automatic split requirement. Extract when it improves ownership, testing, or rebuild scope.
4. **No magic numbers in styling.** Use semantic tokens. See chapter 04 for the nuanced policy on when a private named constant is acceptable.
5. **`StatefulWidget` only for local ephemeral UI state:** text controllers, focus nodes, animation controllers, scroll controllers. Server data and feature state belong in notifiers.
6. **Async safety:** Guard `BuildContext` across every `await` boundary: `if (!context.mounted) return;`

---

## Error handling architecture

Define a sealed exception hierarchy in `core/errors/`:

```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
```

**Where errors are handled:**

| Layer | Responsibility |
|---|---|
| Data source | Throws transport/platform exceptions (Dio, database, plugin) |
| Repository | Catches transport exceptions, maps to `AppException` subtypes |
| Notifier | Catches `AppException`, updates `AsyncValue.error` state |
| Screen | Displays user-friendly message via `.when()` or `ref.listen` |

Never display raw `e.toString()` to the user. Never use empty `catch (_) {}`. Specific catches (`on DioException`, `on AppException`) are required.

---

## Platform and plugin boundaries

Camera, NFC, biometric, location, and other platform-specific capabilities must sit behind a narrow adapter or documented widget boundary in the data layer. Do not scatter platform checks (`Platform.isAndroid`, `Platform.isIOS`) through unrelated screens.

```dart
// ❌ Incorrect: platform check in a screen.
if (Platform.isAndroid) {
  // Android-specific NFC handling
} else {
  // iOS-specific NFC handling
}

// ✅ Correct: platform adapter behind an interface.
abstract interface class NfcAdapter {
  Future<NfcResult> scan();
}

// Concrete implementations selected via dependency injection.
```

---

## Anti-patterns

| ❌ Anti-pattern | ✅ Correct approach |
|---|---|
| Calling Dio/HTTP in widgets or `initState` | Call repository via `AsyncNotifier` |
| Parsing JSON in screens | Parse in `data/models/*_dto.dart` |
| `FutureBuilder` for server data | Watch `AsyncNotifierProvider` with `.when()` |
| 500+ line screen with private `_build` helpers | Split into standalone widget classes |
| Returning `Map<String, dynamic>` from repository | Return typed domain entities |
| Presentation importing `data/` | Import `domain/repositories/` interface |
| Feature A importing Feature B internals | Share via `core/` or domain |
| Empty `catch (_) {}` | Specific catch with `AppException` mapping |
| `print()` for debugging | Structured logger in `core/utils/` |
| Business logic in widgets | Logic on domain entities or in use cases |

---

## Correcting a UI issue at the right layer

When fixing a visual or layout problem:

1. Determine which layer owns the concern. A layout overflow is a presentation issue. A wrong value is a data mapping issue. A missing state is a notifier issue.
2. Fix at that layer. Do not move layout decisions into a notifier, add network knowledge to a widget, or duplicate a component to avoid understanding an existing boundary.
3. If the fix requires a new shared component, verify at least two consumers truly share the visual, semantic, and behavioural contract before placing it in `core/widgets/`.
4. If the existing architecture does not cleanly support the fix, propose an architecture decision rather than introducing a silent workaround.
