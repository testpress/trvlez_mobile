import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/registration_screen.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool shouldThrow = false;
  String? emailCalled;
  String? passwordCalled;

  @override
  Future<SignupResult> signUp({
    required String email,
    required String password,
  }) async {
    emailCalled = email;
    passwordCalled = password;
    if (shouldThrow) {
      throw const ValidationException('Email already registered');
    }
    return const SignupResult(
      id: 'usr-new-1',
      email: 'new@example.com',
      travelerProfileId: 'tp-new-1',
      onboardingStep: 'profile_pending',
    );
  }

  @override
  Future<void> login({required String email, required String password}) async {}
}

void main() {
  group('RegistrationScreen Widget Tests', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    testWidgets('renders registration form components', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: RegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Create account'), findsNWidgets(1));
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('validates required fields on empty submit', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: RegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(mockRepo.emailCalled, isNull);
    });

    testWidgets('submits valid inputs to repository', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: RegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        'new@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'At least 8 characters'),
        'Password123!',
      );
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(mockRepo.emailCalled, 'new@example.com');
      expect(mockRepo.passwordCalled, 'Password123!');
    });

    testWidgets('displays error banner when registration fails', (
      tester,
    ) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const MaterialApp(home: RegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        'dup@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'At least 8 characters'),
        'Password123!',
      );
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Email already registered'), findsOneWidget);
    });
  });
}
