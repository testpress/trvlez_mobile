import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/login_screen.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  bool shouldThrow = false;
  String? emailCalled;
  String? passwordCalled;

  @override
  Future<void> login({required String email, required String password}) async {
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

    testWidgets('renders brand header, inputs, and log-in button', (
      tester,
    ) async {
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Log in'), findsNWidgets(1));
      expect(find.text('New to TRVLez? '), findsOneWidget);
    });

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testMaterialScreenMatrix(
      'keeps the login form usable across the required phone matrix',
      builder: (tester, scenario) async {
        await tester.pumpWidget(
          testAppWithProviders(
            overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
            textScaler: scenario.textScaler,
            child: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));

        final loginButton = find.widgetWithText(ElevatedButton, 'Log in');
        await tester.ensureVisible(loginButton);
        expect(
          tester.getRect(loginButton).bottom,
          lessThanOrEqualTo(
            MediaQuery.sizeOf(tester.element(loginButton)).height,
          ),
        );

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

    testWidgets('triggers client-side validation on empty submission', (
      tester,
    ) async {
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(mockRepo.emailCalled, isNull);
    });

    testWidgets('submits valid credentials and invokes repository login', (
      tester,
    ) async {
      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const LoginScreen(),
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
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(mockRepo.emailCalled, 'traveler@example.com');
      expect(mockRepo.passwordCalled, 'Secret1234');
    });

    testWidgets('displays error banner when repository fails', (tester) async {
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: const LoginScreen(),
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
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
