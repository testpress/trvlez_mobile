import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';

import '../../helpers/test_app.dart';
import '../../helpers/viewport_testing.dart';

void main() {
  group('BrandVerifyScreen Layout & Matrix Tests', () {
    testMaterialScreenMatrix(
      'renders cleanly without overflow across required device matrix',
      scenarios: [
        ...MaterialScreenTestScenarios.required,
        const MaterialScreenTestScenario(
          name: 'compact-android-keyboard-open-text-1.0',
          viewport: TestViewports.compactAndroid,
          textScaler: TestTextScales.normal,
          insetProfile: TestInsetProfiles.androidKeyboardOpen,
        ),
      ],
      builder: (tester, scenario) async {
        await tester.pumpWidget(
          TestApp(
            textScaler: scenario.textScaler,
            child: BrandVerifyScreen(
              title: 'Verification Step',
              isScrollable: true,
              body: [
                const Text('Content Section 1'),
                const SizedBox(height: 20),
                TextFormField(),
              ],
              foot: [AppButton(label: 'Proceed', onPressed: () {})],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Verification Step'), findsOneWidget);
        expect(find.text('Content Section 1'), findsOneWidget);
        expect(find.text('Proceed'), findsOneWidget);
        expect(find.text("Tell us what's wrong"), findsOneWidget);

        final footButton = find.widgetWithText(AppButton, 'Proceed');
        expect(footButton, findsOneWidget);
        final footRect = tester.getRect(footButton);
        final screenHeight =
            tester.view.physicalSize.height / tester.view.devicePixelRatio;
        expect(footRect.bottom, lessThanOrEqualTo(screenHeight));
      },
    );

    testWidgets('help line wraps cleanly at large text scale (2.0x)', (
      tester,
    ) async {
      tester.setViewport(TestViewports.compactAndroid);
      addTearDown(tester.resetViewport);

      bool helpTapped = false;
      await tester.pumpWidget(
        TestApp(
          textScaler: TestTextScales.accessibility,
          child: BrandVerifyScreen(
            title: 'Verify Identity',
            onHelpTap: () => helpTapped = true,
            body: const [Text('Instructions')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final linkFinder = find.text("Tell us what's wrong");
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
      await tester.pumpAndSettle();
      expect(helpTapped, isTrue);
    });
  });
}
