import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/router.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

// In-memory fake secure storage for test isolation
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

class FakePropertiesNotifier extends AsyncNotifier<List<Property>>
    implements PropertiesNotifier {
  @override
  String? get propertyType => null;

  @override
  String? get searchQuery => null;

  @override
  Future<List<Property>> build() async => [];

  @override
  Future<void> fetchProperties({String? search, String? propertyType}) async {
    state = const AsyncData([]);
  }

  @override
  Future<void> filterByPropertyType(String? type) async {
    state = const AsyncData([]);
  }

  @override
  Future<void> search(String query) async {
    state = const AsyncData([]);
  }

  @override
  void reset() {
    state = const AsyncData([]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp({required TokenStorage tokenStorage}) {
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
        propertiesProvider.overrideWith(() => FakePropertiesNotifier()),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(routerConfig: router);
        },
      ),
    );
  }

  group('Auth & Welcome Screen Routing', () {
    testWidgets('Unauthenticated user on startup stays on WelcomeScreen', (
      tester,
    ) async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(storage: fakeStorage);

      await tester.pumpWidget(createTestApp(tokenStorage: tokenStorage));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets(
      'Authenticated user on startup redirects away from WelcomeScreen to Home',
      (tester) async {
        final fakeStorage = FakeSecureStorage();
        final tokenStorage = TokenStorage(
          storage: fakeStorage,
          initialToken: 'fake_jwt_token',
        );

        await tester.pumpWidget(createTestApp(tokenStorage: tokenStorage));
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        // WelcomeScreen should NOT be visible for authenticated users
        expect(find.byType(WelcomeScreen), findsNothing);
      },
    );

    testWidgets('Authenticated user navigating to /welcome redirects to Home', (
      tester,
    ) async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(
        storage: fakeStorage,
        initialToken: 'fake_jwt_token',
      );

      await tester.pumpWidget(createTestApp(tokenStorage: tokenStorage));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(context);
      final router = container.read(routerProvider);

      router.go(AppRoutes.welcome);
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets(
      'Unauthenticated user navigating to home is redirected to login',
      (tester) async {
        final fakeStorage = FakeSecureStorage();
        final tokenStorage = TokenStorage(storage: fakeStorage);

        await tester.pumpWidget(createTestApp(tokenStorage: tokenStorage));
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        // Now attempt to navigate to protected route
        final BuildContext context = tester.element(find.byType(WelcomeScreen));
        final container = ProviderScope.containerOf(context);
        final router = container.read(routerProvider);

        router.go(AppRoutes.home);
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();

        // Should be on login screen
        expect(find.text('Welcome back'), findsOneWidget);
      },
    );
  });
}
