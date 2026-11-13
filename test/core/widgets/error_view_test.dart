import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ErrorView Widget Tests', () {
    testWidgets('renders title, message, and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: ErrorView(
              message: 'Unable to connect to server',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Unable to connect to server'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: ErrorView(message: 'Failed to connect', onRetry: () {}),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('ErrorView.fromError extracts user-safe message', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: ErrorView.fromError(error: Exception('Network timeout')),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('supports large text scale without overflow', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          textScaler: TextScaler.linear(2.0),
          child: Scaffold(
            body: ErrorView(
              title: 'Failed to load details',
              message: 'Check your internet connection and try again later.',
              onRetry: null,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Failed to load details'), findsOneWidget);
    });
  });
}
