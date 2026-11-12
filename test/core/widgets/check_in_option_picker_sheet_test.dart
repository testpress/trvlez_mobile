import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/check_in_option_picker_sheet.dart';

import '../../helpers/test_app.dart';
import '../../helpers/viewport_testing.dart';

void main() {
  group('CheckInOptionPickerSheet Widget & Matrix Tests', () {
    testWidgets('opens sheet, selects option, and returns chosen value', (
      tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showCheckInOptionPicker(
                  context,
                  title: 'Select Arrival Time',
                  options: const [
                    '14:00 - 15:00',
                    '15:00 - 16:00',
                    '16:00 - 17:00',
                  ],
                  current: '14:00 - 15:00',
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Select Arrival Time'), findsOneWidget);
      expect(find.text('15:00 - 16:00'), findsOneWidget);

      await tester.tap(find.text('15:00 - 16:00'));
      await tester.pumpAndSettle();

      expect(result, '15:00 - 16:00');
    });

    testWidgets('renders cleanly at compact viewport and 2.0x text scale', (
      tester,
    ) async {
      tester.setViewport(TestViewports.compactAndroid);
      addTearDown(tester.resetViewport);

      await tester.pumpWidget(
        TestApp(
          textScaler: TestTextScales.accessibility,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCheckInOptionPicker(
                  context,
                  title: 'Long Option Title For Accessibility Testing',
                  options: List.generate(
                    10,
                    (i) => 'Option $i - Detailed description for scale',
                  ),
                  current: 'Option 0 - Detailed description for scale',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text('Long Option Title For Accessibility Testing'),
        findsOneWidget,
      );
    });
  });
}
