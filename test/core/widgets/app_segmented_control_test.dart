import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/app_segmented_control.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppSegmentedControl Widget Tests', () {
    testWidgets(
      'renders all segment tabs, indicates selection, and handles taps',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          wrap(
            StatefulBuilder(
              builder: (context, setState) => AppSegmentedControl(
                count: 3,
                selected: selectedIndex,
                onSelect: (index) => setState(() => selectedIndex = index),
                label: (context, index, active) => Text('Tab $index'),
              ),
            ),
          ),
        );

        expect(find.text('Tab 0'), findsOneWidget);
        expect(find.text('Tab 1'), findsOneWidget);
        expect(find.text('Tab 2'), findsOneWidget);

        // Verify touch target height is at least 48dp
        final controlSize = tester.getSize(find.byType(AppSegmentedControl));
        expect(controlSize.height, greaterThanOrEqualTo(48.0));

        await tester.tap(find.text('Tab 1'));
        await tester.pumpAndSettle();

        expect(selectedIndex, 1);
      },
    );
  });
}
