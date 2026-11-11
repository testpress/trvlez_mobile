import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/app/app.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
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

// Fake auth repository that returns success on credentials
class FakeAuthRepository implements AuthRepository {
  bool loginCalled = false;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalled = true;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication & Login Flow Integration Tests', () {
    late FakeSecureStorage fakeStorage;
    late TokenStorage tokenStorage;
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      tokenStorage = TokenStorage(storage: fakeStorage);
      fakeAuthRepository = FakeAuthRepository();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Login screen form input, validation, and submit flow', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(tokenStorage),
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            propertiesProvider.overrideWith(() => FakePropertiesNotifier()),
          ],
          child: const TrvlEzApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Starts on Welcome Screen
      expect(find.text('Begin your journey with TRVLez'), findsOneWidget);

      // Tap Sign In / Log in to navigate to LoginScreen
      final signInFinder = find.widgetWithText(AppButton, 'Sign in');
      expect(signInFinder, findsOneWidget);
      await tester.tap(signInFinder);
      await tester.pumpAndSettle();

      // Verify LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);

      // Verify email and password inputs exist
      final emailFields = find.byType(BrandTextField);
      expect(emailFields, findsNWidgets(2)); // Email and Password

      final emailInput = find.descendant(
        of: emailFields.first,
        matching: find.byType(TextFormField),
      );
      final passwordInput = find.descendant(
        of: emailFields.last,
        matching: find.byType(TextFormField),
      );

      // Type credentials
      await tester.enterText(emailInput, 'traveler@trvlez.com');
      await tester.enterText(passwordInput, 'ValidPassword123!');
      await tester.pumpAndSettle();

      // Verify submit button is active
      final loginButton = find.widgetWithText(AppButton, 'Log in');
      expect(loginButton, findsOneWidget);

      // Tap submit
      await tester.tap(loginButton);
      await tester.pump();

      // Verify repository was called with entered credentials
      expect(fakeAuthRepository.loginCalled, isTrue);
      expect(fakeAuthRepository.lastEmail, 'traveler@trvlez.com');
      expect(fakeAuthRepository.lastPassword, 'ValidPassword123!');
    });
  });
}
