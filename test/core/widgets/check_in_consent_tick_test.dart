import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/check_in_consent_tick.dart';

import '../../helpers/test_app.dart';

void main() {
  group('CheckInConsentTick Widget Tests', () {
    testWidgets(
      'renders label, checked status, handles tap, and ensures target size',
      (tester) async {
        var agreed = false;

        await tester.pumpWidget(
          TestApp(
            child: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) => CheckInConsentTick(
                    agreed: agreed,
                    label: 'I confirm the guest details are accurate',
                    onTap: () => setState(() => agreed = !agreed),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.text('I confirm the guest details are accurate'),
          findsOneWidget,
        );

        final tickFinder = find.byType(CheckInConsentTick);
        final size = tester.getSize(tickFinder);
        expect(size.height, greaterThanOrEqualTo(48.0));

        await tester.tap(tickFinder);
        await tester.pumpAndSettle();

        expect(agreed, isTrue);
      },
    );

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(
              child: CheckInConsentTick(
                agreed: false,
                label: 'I agree to the terms',
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });
}
