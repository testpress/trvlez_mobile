import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/auth/presentation/welcome_screen.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders title and buttons correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('TrvlEz'), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Advance timer for entrance animation
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(AppButton), findsNWidgets(2));
    });
  });
}
