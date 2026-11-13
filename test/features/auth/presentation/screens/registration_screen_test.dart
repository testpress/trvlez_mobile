import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/registration_screen.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

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
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      final btn = find.widgetWithText(AppButton, 'Create account');
      expect(btn, findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const RegistrationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testMaterialScreenMatrix(
      'keeps registration form usable across phone matrix',
      builder: (tester, scenario) async {
        await tester.pumpWidget(
          testAppWithProviders(
            overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
            textScaler: scenario.textScaler,
            child: const RegistrationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create your account'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));

        final submitBtn = find.widgetWithText(AppButton, 'Create account');
        await tester.ensureVisible(submitBtn);
        expect(find.byType(AppButton), findsOneWidget);

        if (scenario.keyboardIsOpen) {
          final passwordField = find.byType(TextFormField).last;
          await tester.ensureVisible(passwordField);
          await tester.tap(passwordField);
          await tester.pumpAndSettle();

          final context = tester.element(passwordField);
          final visibleHeight =
              MediaQuery.sizeOf(context).height -
              MediaQuery.viewInsetsOf(context).bottom;
          expect(
            tester.getRect(passwordField).bottom,
            lessThanOrEqualTo(visibleHeight),
          );
        }
      },
      scenarios: [
        ...MaterialScreenTestScenarios.required,
        const MaterialScreenTestScenario(
          name: 'compact-android-keyboard-open-text-1.0',
          viewport: TestViewports.compactAndroid,
          textScaler: TestTextScales.normal,
          insetProfile: TestInsetProfiles.androidKeyboardOpen,
        ),
      ],
    );

    testWidgets('validates required fields on empty submit', (tester) async {
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const RegistrationScreen(),
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
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const RegistrationScreen(),
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
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const RegistrationScreen(),
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
