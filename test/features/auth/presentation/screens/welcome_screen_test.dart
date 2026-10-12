import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders brand wordmark, launch art, and actions', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('TRVL'), findsOneWidget);
      expect(find.text('ez'), findsOneWidget);

      // Advance through sequenced entrance animations
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });
  });
}
