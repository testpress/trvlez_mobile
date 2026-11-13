import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('BrandShutter Widget Tests', () {
    testWidgets('renders capture button, handles tap, and ensures touch size', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(BrandShutter(onPressed: () => tapped = true)),
      );

      expect(find.bySemanticsLabel('Capture'), findsOneWidget);

      final shutterSize = tester.getSize(find.byType(BrandShutter));
      expect(shutterSize.width, greaterThanOrEqualTo(48.0));
      expect(shutterSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.byType(BrandShutter));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders recording state with correct semantics label', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(BrandShutter(recording: true, onPressed: () {})),
      );

      expect(find.bySemanticsLabel('Recording'), findsOneWidget);
    });
  });
}
