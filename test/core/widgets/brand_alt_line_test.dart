import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';

import '../../helpers/test_app.dart';
import '../../helpers/viewport_testing.dart';

void main() {
  group('BrandAltLine Widget & Scale Tests', () {
    testWidgets('renders prefix and link, invoking callback on tap', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        TestApp(
          child: BrandAltLine(
            prefix: 'Already have an account? ',
            linkText: 'Log in',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testTextScaleMatrix(
      'wraps without shrinking text or throwing overflow at all text scales',
      viewport: TestViewports.compactAndroid,
      scales: [
        TestTextScales.normal,
        TestTextScales.large,
        TestTextScales.accessibility,
      ],
      builder: (tester, scale) async {
        await tester.pumpWidget(
          TestApp(
            textScaler: scale,
            child: BrandAltLine(
              prefix: 'Already have an account? ',
              linkText: 'Log in',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Log in'), findsOneWidget);

        // Verify that link is tappable and text is not shrunk by FittedBox
        expect(find.byType(FittedBox), findsNothing);
      },
    );
  });
}
