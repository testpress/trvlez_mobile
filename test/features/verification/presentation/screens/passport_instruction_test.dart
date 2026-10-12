import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/kyc_progress_stepper.dart';
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
    testWidgets('renders KYC header and stepper at step 1', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('KYC'), findsOneWidget);
      expect(find.byType(KycProgressStepper), findsOneWidget);
      final stepper = tester.widget<KycProgressStepper>(
        find.byType(KycProgressStepper),
      );
      expect(stepper.progressIndex, 0);
    });

    testWidgets('renders clear passport title and user-friendly guidelines', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Passport Photo'), findsOneWidget);
      expect(
        find.textContaining('Take a clear, readable photo'),
        findsOneWidget,
      );
      expect(find.text('Please ensure:'), findsOneWidget);
      expect(
        find.text('Well-lit area with no flash reflection or glare'),
        findsOneWidget,
      );
      expect(
        find.text('All 4 corners of the page are inside the frame'),
        findsOneWidget,
      );
      expect(
        find.text(
          'The 2 lines of text and numbers at the bottom are fully visible',
        ),
        findsOneWidget,
      );
      expect(
        find.text('No fingers or shadows cover any information'),
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

    testWidgets('tapping Continue navigates to passport capture screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);

      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Passport Capture Screen'), findsOneWidget);
    });
  });
}
