import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';

import '../../helpers/test_app.dart';

void main() {
  group('StatusPill Widget Tests', () {
    testWidgets('renders all status pill variants with correct label text', (
      tester,
    ) async {
      for (final state in StatusPillState.values) {
        await tester.pumpWidget(
          TestApp(
            child: Scaffold(
              body: Center(
                child: StatusPill(
                  label: state.name.toUpperCase(),
                  state: state,
                ),
              ),
            ),
          ),
        );

        expect(find.text(state.name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('scales text cleanly under 2.0x text scaler without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          textScaler: TextScaler.linear(2.0),
          child: Scaffold(
            body: Center(
              child: StatusPill(
                label: 'CONFIRMED RESERVATION',
                state: StatusPillState.confirmed,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('CONFIRMED RESERVATION'), findsOneWidget);
    });
  });
}
