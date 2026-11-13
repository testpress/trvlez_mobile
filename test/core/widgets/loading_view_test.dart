import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';

import '../../helpers/test_app.dart';

void main() {
  group('LoadingView Widget Tests', () {
    testWidgets('renders progress indicator and optional message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(body: LoadingView(message: 'Loading properties...')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading properties...'), findsOneWidget);
    });

    testWidgets('renders progress indicator without message cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(child: Scaffold(body: LoadingView())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('supports large text scale without overflow', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          textScaler: TextScaler.linear(2.0),
          child: Scaffold(
            body: LoadingView(message: 'Syncing your reservation details...'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Syncing your reservation details...'), findsOneWidget);
    });
  });
}
