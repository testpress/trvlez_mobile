import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/check_in_consent_tick.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('CheckInConsentTick Widget Tests', () {
    testWidgets(
      'renders label, checked status, handles tap, and ensures target size',
      (tester) async {
        var agreed = false;

        await tester.pumpWidget(
          wrap(
            StatefulBuilder(
              builder: (context, setState) => CheckInConsentTick(
                agreed: agreed,
                label: 'I confirm the guest details are accurate',
                onTap: () => setState(() => agreed = !agreed),
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
  });
}
