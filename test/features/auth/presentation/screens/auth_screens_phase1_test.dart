import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/new_password_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/two_step_code_screen.dart';

void main() {
  group('Phase 1 New Auth Screens Tests', () {
    testWidgets('ForgotPasswordScreen renders inputs and send code button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ForgotPasswordScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
      expect(find.text('Back to log in'), findsOneWidget);
    });

    testWidgets('NewPasswordScreen validates password matching', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NewPasswordScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose a new password'), findsOneWidget);

      // Enter mismatched passwords
      await tester.enterText(
        find.widgetWithText(TextFormField, 'At least 8 characters'),
        'Password123!',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter it again'),
        'DifferentPass!',
      );
      await tester.pump();
      await tester.tap(find.text('Save and sign in'));
      await tester.pumpAndSettle();

      expect(find.text("Those don't match"), findsOneWidget);
    });

    testWidgets('TwoStepCodeScreen renders 6-box input and resend countdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TwoStepCodeScreen(email: 'user@example.com'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(find.textContaining('Resend in 0:'), findsOneWidget);
    });
  });
}
