import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/welcome_screen.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders brand wordmark, launch art, and actions', (
      tester,
    ) async {
      await tester.pumpWidget(const TestApp(child: WelcomeScreen()));

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('TRVL'), findsOneWidget);
      expect(find.text('ez'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testMaterialScreenMatrix(
      'renders brand presentation and reachable actions across phone matrix',
      builder: (tester, scenario) async {
        await tester.pumpWidget(
          TestApp(
            textScaler: scenario.textScaler,
            child: const WelcomeScreen(),
          ),
        );

        await tester.pump(const Duration(milliseconds: 3000));
        await tester.pumpAndSettle();

        expect(find.text('TRVL'), findsOneWidget);
        expect(find.text('ez'), findsOneWidget);

        final createBtn = find.text('Create account');
        final loginBtn = find.text('Log in');
        expect(createBtn, findsOneWidget);
        expect(loginBtn, findsOneWidget);

        await tester.ensureVisible(createBtn);
        await tester.ensureVisible(loginBtn);
      },
    );
  });
}
