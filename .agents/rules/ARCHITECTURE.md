# Flutter App Architecture Guide

> Feature-first clean architecture for Flutter. Every piece of code has one obvious home and one job.
> Companion to `CODE_STANDARDS.md` and `DESIGN_SYSTEM.md`.

---

## 1. Summary & Dependency Rule

1. **Feature-first:** Group by feature (`features/auth/`, `features/orders/`), not by type. Shared code in `core/`.
2. **Three layers:** `presentation` → `domain` → `data`.
3. **The Dependency Rule:** Dependencies flow **down only**.
   - `presentation` imports `domain`. **Never** import `data` directly.
   - `data` imports `domain`.
   - `domain` is pure Dart. It imports **nothing** from Flutter, Dio, or data sources.
4. **Widgets only draw UI:** Never call APIs, never parse JSON, no business logic.
5. **Notifiers manage screen state:** Talk only to abstract repository interfaces.
6. **Repositories abstract data:** The single entry point for data. Map DTOs to entities and exceptions to `AppException`.

```
PRESENTATION  (Screens, Widgets, Notifiers/Providers)
      │ watches / calls
      ▼
   DOMAIN     (Entities, Repository Interfaces, Use Cases) ◄── Pure Dart
      ▲
      │ implements
    DATA      (Repository Impls, Remote/Local Data Sources, DTOs)
```

---

## 2. Recommended Stack

| Concern | Choice | Usage |
|---|---|---|
| State Management | **Riverpod** (`flutter_riverpod`) | `AsyncNotifier`, compile-safe DI |
| Navigation | **go_router** | Declarative routes, auth redirect guards |
| Networking | **Dio** | In `core/network/`, interceptors for auth & errors |
| Storage | `flutter_secure_storage` (tokens), `shared_preferences` (settings) | Repositories in `core/storage/` |
| Testing | `flutter_test`, `mocktail` | Unit, widget, and integration tests |

---

## 3. Folder Structure

```
lib/
├── main.dart                      # runApp entry point only
├── app/
│   ├── app.dart                   # Root MaterialApp.router
│   ├── router/                    # app_router.dart, routes.dart
│   └── theme/                     # Tokens, extensions, component themes (DESIGN_SYSTEM.md)
├── core/                          # Feature-independent shared code
│   ├── constants/                 # api_endpoints.dart, app_strings.dart
│   ├── errors/                    # app_exception.dart
│   ├── network/                   # dio_client.dart, interceptors/
│   ├── storage/                   # token_storage.dart, prefs.dart
│   ├── utils/                     # formatters, validators
│   └── widgets/                   # AppButton, AppTextField, LoadingView, ErrorView (reused 2+ features)
└── features/<feature_name>/
    ├── domain/
    │   ├── entities/              # Pure Dart business models
    │   └── repositories/          # Abstract repository interfaces
    ├── data/
    │   ├── datasources/           # Remote & local data sources (Dio/DB calls)
    │   ├── models/                # DTOs with fromJson/toJson & toEntity()
    │   └── repositories/          # Repository implementations
    └── presentation/
        ├── providers/             # Notifiers, states, and feature providers
        ├── screens/               # Screen widgets (read state, forward taps)
        └── widgets/               # Feature-specific sub-widgets
```

*Rules:*
- Features **never** import another feature's `data` or `presentation`. Share via `core/` or `domain`.
- `core/widgets/` is only for UI reused across 2+ features. Single-use widgets stay in `presentation/widgets/`.

---

## 4. "Where Do I Put This?" Cheat Sheet

| Need | Target Location |
|---|---|
| Screen UI / Dialog | `features/<f>/presentation/screens/` |
| Feature-only UI sub-widget | `features/<f>/presentation/widgets/` |
| Shared UI (button, card, loader) | `core/widgets/` |
| Screen state & UI actions | `features/<f>/presentation/providers/` (`<Name>Notifier`) |
| API HTTP calls | `features/<f>/data/datasources/` (`<Name>RemoteDataSource`) |
| API JSON serialization | `features/<f>/data/models/` (`<Name>Dto`) |
| Business entity & model logic | `features/<f>/domain/entities/` (`<Name>`) |
| Data contract / repository interface | `features/<f>/domain/repositories/` (`<Name>Repository`) |
| Concrete repository & error mapping | `features/<f>/data/repositories/` (`<Name>RepositoryImpl`) |
| Route constants & config | `app/router/routes.dart` & `app/router/app_router.dart` |
| Colors, spacing, radius, fonts | `app/theme/` (see `DESIGN_SYSTEM.md`) |
| Exceptions & failure models | `core/errors/app_exception.dart` |

---

## 5. Layer Architecture by Example

### 5.1 Domain (Pure Dart)
```dart
// domain/entities/order.dart
class Order {
  const Order({required this.id, required this.title, required this.total});
  final String id, title;
  final double total;
  bool get isFree => total == 0;
}

// domain/repositories/order_repository.dart
abstract interface class OrderRepository {
  Future<List<Order>> getOrders();
  Future<void> cancelOrder(String id);
}
```

### 5.2 Data (External Boundary)
```dart
// data/models/order_dto.dart
class OrderDto {
  const OrderDto({required this.id, required this.title, required this.total});
  factory OrderDto.fromJson(Map<String, dynamic> json) => OrderDto(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    total: (json['total'] as num?)?.toDouble() ?? 0.0,
  );
  final String id, title;
  final double total;
  Order toEntity() => Order(id: id, title: title, total: total);
}

// data/datasources/order_remote_data_source.dart
class OrderRemoteDataSource {
  const OrderRemoteDataSource(this._dio);
  final Dio _dio;
  Future<List<OrderDto>> fetchOrders() async {
    final res = await _dio.get<List<dynamic>>('/orders');
    return (res.data ?? []).map((e) => OrderDto.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<void> cancel(String id) => _dio.post('/orders/$id/cancel');
}

// data/repositories/order_repository_impl.dart
class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._remote);
  final OrderRemoteDataSource _remote;
  @override
  Future<List<Order>> getOrders() async {
    try {
      final dtos = await _remote.fetchOrders();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioException(e); // maps to AppException
    }
  }
  @override
  Future<void> cancelOrder(String id) => _remote.cancel(id);
}
```

### 5.3 Dependency Wiring (Providers)
```dart
// presentation/providers/order_providers.dart
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>(
  (ref) => OrderRemoteDataSource(ref.watch(dioProvider)),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepositoryImpl(ref.watch(orderRemoteDataSourceProvider)),
);

final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);
```

### 5.4 Presentation (Notifier & Screen)
```dart
// presentation/providers/orders_notifier.dart
class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() => ref.read(orderRepositoryProvider).getOrders();

  Future<void> cancel(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(orderRepositoryProvider).cancelOrder(id);
      return ref.read(orderRepositoryProvider).getOrders();
    });
  }
}

// presentation/screens/orders_screen.dart
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(ordersNotifierProvider),
        ),
        data: (orders) => ListView.builder(
          itemCount: orders.length,
          itemBuilder: (_, i) => OrderTile(
            order: orders[i],
            onCancel: () => ref.read(ordersNotifierProvider.notifier).cancel(orders[i].id),
          ),
        ),
      ),
    );
  }
}
```

---

## 6. Widget, State & Navigation Rules

1. **One public widget per file:** Filename matches class name in snake_case.
2. **Classes over methods:** Use widget classes, not `_buildWidget()` methods.
3. **Short build methods:** Keep `build()` under ~80 lines. Split if larger.
4. **No magic styling:** Use semantic tokens (`context.colors`, `context.text`, `AppSpacing`, `AppRadius`). Never hardcode hex values or raw font sizes.
5. **StatefulWidget is only for local UI state:** (e.g. text controllers). Server data belongs in Notifiers.
6. **Async safety:** Guard context across async gaps: `if (!context.mounted) return;`.
7. **Side-effects:** Use `ref.listen` in screens for snackbars or navigation; never in Notifiers.
8. **Navigation:** Named paths in `app/router/routes.dart`. Use `context.go(Routes.orders)`.

---

## 7. Error Handling

Define app exceptions in `core/errors/app_exception.dart`. Map all network/HTTP exceptions in repositories:

```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}
class NetworkException extends AppException { const NetworkException([super.message = 'No internet connection']); }
class UnauthorizedException extends AppException { const UnauthorizedException([super.message = 'Session expired']); }
class ServerException extends AppException { const ServerException([super.message = 'Server error']); }
```

---

## 8. Testing Strategy

Screens depend on **repository interfaces** via providers, enabling clean test overrides:

```dart
ProviderScope(
  overrides: [orderRepositoryProvider.overrideWithValue(FakeOrderRepository())],
  child: const MaterialApp(home: OrdersScreen()),
)
```
- Domain: Unit test business entities.
- Data: Unit test DTOs and repositories with mocked data sources.
- Presentation: Notifier tests for state transitions; widget tests for render & interaction.
- `test/` mirrors `lib/` directory structure.

---

## 9. Anti-Patterns to Avoid

| ❌ Anti-Pattern | ✅ Correct Pattern |
|---|---|
| Calling Dio/HTTP in widgets or `initState` | Call repository via `AsyncNotifier` |
| Parsing JSON in screens or controllers | Parse in `data/models/*_dto.dart` |
| Using `FutureBuilder` for server data in screens | Watch `AsyncNotifierProvider` with `.when()` |
| 500+ line screen files with private helpers | Split into standalone widgets in `presentation/widgets/` |
| Hardcoded colors/styles (`Color(0x...)`, `Colors.*`) | Use `context.colors`, `context.text`, `AppSpacing` |
| Returning `Map<String, dynamic>` from repository | Return strongly typed domain entities |
| Presentation importing `data/` directly | Presentation imports `domain/repositories/` interface |
| Feature A importing Feature B internals | Share via `core/` or domain model |

---

## 10. Pull Request & Architecture Checklist

- [ ] Files placed in proper layer (`presentation/`, `domain/`, `data/`).
- [ ] No `data/` imports in `presentation/`; no Flutter/Dio in `domain/`.
- [ ] Repositories implement abstract domain interfaces.
- [ ] No hardcoded colors, text styles, or raw spacing constants.
- [ ] Network exceptions mapped to `AppException` in repositories.
- [ ] No files exceeding ~300 lines; widgets broken down.
- [ ] `flutter analyze` and `flutter test` pass with zero errors.
