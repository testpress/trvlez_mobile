import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';

import '../../helpers/test_app.dart';

void main() {
  group('BrandShutter Widget Tests', () {
    testWidgets('renders capture button, handles tap, and ensures touch size', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(child: BrandShutter(onPressed: () => tapped = true)),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Capture'), findsOneWidget);

      final shutterSize = tester.getSize(find.byType(BrandShutter));
      expect(shutterSize.width, greaterThanOrEqualTo(48.0));
      expect(shutterSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.byType(BrandShutter));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(child: BrandShutter(onPressed: () {})),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('renders recording state with correct semantics label', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Center(
              child: BrandShutter(recording: true, onPressed: () {}),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Recording'), findsOneWidget);
    });
  });
}
