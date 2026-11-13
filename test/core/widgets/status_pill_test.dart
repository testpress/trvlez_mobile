import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';

void main() {
  Widget wrap(Widget child, {TextScaler? textScaler}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: textScaler ?? TextScaler.noScaling),
          child: Center(child: child),
        ),
      ),
    );
  }

  group('StatusPill Widget Tests', () {
    testWidgets('renders all status pill variants with correct label text', (
      tester,
    ) async {
      for (final state in StatusPillState.values) {
        await tester.pumpWidget(
          wrap(StatusPill(label: state.name.toUpperCase(), state: state)),
        );

        expect(find.text(state.name.toUpperCase()), findsOneWidget);
      }
    });

    testWidgets('scales text cleanly under 2.0x text scaler without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StatusPill(
            label: 'CONFIRMED RESERVATION',
            state: StatusPillState.confirmed,
          ),
          textScaler: const TextScaler.linear(2.0),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('CONFIRMED RESERVATION'), findsOneWidget);
    });
  });
}
