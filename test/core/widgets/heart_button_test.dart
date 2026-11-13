import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';

import '../../helpers/test_app.dart';

void main() {
  group('HeartButton Widget Tests', () {
    testWidgets(
      'renders unsaved state with correct semantics and handles tap',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          TestApp(
            child: Scaffold(
              body: Center(
                child: HeartButton(saved: false, onTap: () => tapped = true),
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Save property'), findsOneWidget);

        // Verify minimum 48x48 touch target
        final buttonSize = tester.getSize(find.byType(HeartButton));
        expect(buttonSize.width, greaterThanOrEqualTo(48.0));
        expect(buttonSize.height, greaterThanOrEqualTo(48.0));

        await tester.tap(find.byType(HeartButton));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(child: HeartButton(saved: false, onTap: () {})),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('renders saved state with remove semantics label', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(body: Center(child: HeartButton(saved: true))),
        ),
      );

      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
    });

    testWidgets('renders onPhoto variant cleanly', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(
            body: Center(child: HeartButton(saved: false, onPhoto: true)),
          ),
        ),
      );

      expect(find.byType(HeartButton), findsOneWidget);
    });
  });
}
