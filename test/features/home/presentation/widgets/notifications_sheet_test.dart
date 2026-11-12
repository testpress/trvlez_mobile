import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/notifications_sheet.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

void main() {
  group('NotificationsSheet Widget & Matrix Tests', () {
    final sampleItems = List.generate(
      5,
      (i) => NotificationItem(
        id: 'item-$i',
        title: 'Alert $i: Reservation update',
        body: 'Your check-in details have been confirmed by the front desk.',
        timeAgo: '${i + 1}h ago',
        icon: Icons.notifications,
        isUnread: i == 0,
      ),
    );

    testWidgets('renders alerts and invokes onClearAll', (tester) async {
      bool cleared = false;
      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                NotificationsSheet.show(
                  context,
                  items: sampleItems,
                  onClearAll: () => cleared = true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Alert 0: Reservation update'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(cleared, isTrue);
    });

    testWidgets('renders cleanly on compact viewport at 2.0x text scale', (
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
                NotificationsSheet.show(
                  context,
                  items: sampleItems,
                  onClearAll: () {},
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
      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}
