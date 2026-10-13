import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_instruction_screen.dart';

void main() {
  Widget createTestWidget({GoRouter? router}) {
    final testRouter =
        router ??
        GoRouter(
          initialLocation: AppRoutes.passportInstructions,
          routes: [
            GoRoute(
              path: AppRoutes.passportInstructions,
              builder: (context, state) => const PassportInstructionScreen(),
            ),
            GoRoute(
              path: AppRoutes.passportCapture,
              builder: (context, state) =>
                  const Scaffold(body: Text('Passport Capture Screen')),
            ),
          ],
        );

    return MaterialApp.router(routerConfig: testRouter);
  }

  group('PassportInstructionScreen', () {
    testWidgets('renders Verification header and stepper at step 0', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Verification'), findsOneWidget);
      expect(find.byType(VerificationStepper), findsOneWidget);
      final stepper = tester.widget<VerificationStepper>(
        find.byType(VerificationStepper),
      );
      expect(stepper.current, 0);
    });

    testWidgets('renders clear passport title and user-friendly guidelines', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Passport photo'), findsOneWidget);
      expect(find.textContaining('We need both of these'), findsOneWidget);
      expect(find.text('Photo page'), findsOneWidget);
      expect(find.text('Code lines'), findsOneWidget);
      expect(
        find.text('Well lit, no glare or flash reflection'),
        findsOneWidget,
      );
      expect(
        find.text('All four corners of the page inside the frame'),
        findsOneWidget,
      );
      expect(
        find.text('No fingers or shadows across either part'),
        findsOneWidget,
      );
    });

    testWidgets('does not contain technical MRZ jargon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that user-facing text does not say "MRZ" or "Machine Readable Zone"
      expect(find.textContaining('MRZ'), findsNothing);
      expect(find.textContaining('Machine Readable Zone'), findsNothing);
    });

    testWidgets('tapping Open camera navigates to passport capture screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final openCameraButton = find.widgetWithText(AppButton, 'Open camera');
      expect(openCameraButton, findsOneWidget);

      await tester.ensureVisible(openCameraButton);
      await tester.tap(openCameraButton);
      await tester.pumpAndSettle();

      expect(find.text('Passport Capture Screen'), findsOneWidget);
    });
  });
}
