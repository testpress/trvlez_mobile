import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/heart_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('HeartButton Widget Tests', () {
    testWidgets(
      'renders unsaved state with correct semantics and handles tap',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrap(HeartButton(saved: false, onTap: () => tapped = true)),
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

    testWidgets('renders saved state with remove semantics label', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HeartButton(saved: true)));

      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
    });

    testWidgets('renders onPhoto variant cleanly', (tester) async {
      await tester.pumpWidget(
        wrap(const HeartButton(saved: false, onPhoto: true)),
      );

      expect(find.byType(HeartButton), findsOneWidget);
    });
  });
}
