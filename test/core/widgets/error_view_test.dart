import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';

void main() {
  Widget wrap(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: textScaler ?? TextScaler.noScaling),
          child: child,
        ),
      ),
    );
  }

  group('ErrorView Widget Tests', () {
    testWidgets('renders title, message, and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          ErrorView(
            message: 'Unable to connect to server',
            onRetry: () => retried = true,
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

    testWidgets('ErrorView.fromError extracts user-safe message', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(ErrorView.fromError(error: Exception('Network timeout'))),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('supports large text scale without overflow', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ErrorView(
            title: 'Failed to load details',
            message: 'Check your internet connection and try again later.',
            onRetry: null,
          ),
          textScaler: const TextScaler.linear(2.0),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Failed to load details'), findsOneWidget);
    });
  });
}
