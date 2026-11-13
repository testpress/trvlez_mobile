import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_confirmation_dialog.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppConfirmationDialog Widget Tests', () {
    testWidgets('renders title, message, and returns false when cancelled', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showConfirmationDialog(
                    context,
                    title: 'Sign out?',
                    message: "You'll need your password to log back in.",
                    confirmLabel: 'Sign out',
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      expect(
        find.text("You'll need your password to log back in."),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('satisfies accessibility guidelines when open', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showConfirmationDialog(
                  context,
                  title: 'Confirm',
                  message: 'Are you sure?',
                  confirmLabel: 'Confirm',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('returns true when confirmed and renders destructive styling', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showConfirmationDialog(
                    context,
                    title: 'Delete Reservation?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Open Destructive'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Destructive'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Reservation?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
