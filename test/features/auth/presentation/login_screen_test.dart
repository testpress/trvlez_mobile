import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/login_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool shouldThrow = false;
  String? emailCalled;
  String? passwordCalled;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emailCalled = email;
    passwordCalled = password;
    if (shouldThrow) {
      throw const UnauthorizedException('Invalid credentials');
    }
  }

  @override
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    return const SignupResult(
      id: 'usr-1',
      email: 'a@b.com',
      travelerProfileId: 'tp-1',
      onboardingStep: 'welcome',
    );
  }
}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    testWidgets('renders brand header, inputs, and sign-in button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? '), findsOneWidget);
    });

    testWidgets('triggers client-side validation on empty submission', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(mockRepo.emailCalled, isNull);
    });

    testWidgets('submits valid credentials and invokes repository login', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'traveler@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        'Secret1234',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(mockRepo.emailCalled, 'traveler@example.com');
      expect(mockRepo.passwordCalled, 'Secret1234');
    });

    testWidgets('displays error banner when repository fails', (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'traveler@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        'WrongPassword',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
