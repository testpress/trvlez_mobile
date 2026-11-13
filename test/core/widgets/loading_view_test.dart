import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';

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

  group('LoadingView Widget Tests', () {
    testWidgets('renders progress indicator and optional message', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const LoadingView(message: 'Loading properties...')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading properties...'), findsOneWidget);
    });

    testWidgets('renders progress indicator without message cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const LoadingView()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('supports large text scale without overflow', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LoadingView(message: 'Syncing your reservation details...'),
          textScaler: const TextScaler.linear(2.0),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Syncing your reservation details...'), findsOneWidget);
    });
  });
}
