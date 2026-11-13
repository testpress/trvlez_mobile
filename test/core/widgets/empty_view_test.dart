import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/widgets/empty_view.dart';

import '../../helpers/test_app.dart';

void main() {
  group('EmptyView Widget Tests', () {
    testWidgets('renders title, subtitle, icon, and handles CTA tap', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: EmptyView(
              icon: Icons.inbox_outlined,
              title: 'No items yet',
              subtitle: 'Start browsing to see items here.',
              actionLabel: 'Browse items',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Start browsing to see items here.'), findsOneWidget);
      expect(find.text('Browse items'), findsOneWidget);

      await tester.tap(find.text('Browse items'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: EmptyView(
              icon: Icons.inbox_outlined,
              title: 'No items yet',
              subtitle: 'Start browsing to see items here.',
              actionLabel: 'Browse items',
              onAction: () {},
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('renders without icon or CTA button cleanly', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(
            body: EmptyView(
              title: 'Empty list',
              subtitle: 'Nothing to display right now.',
            ),
          ),
        ),
      );

      expect(find.text('Empty list'), findsOneWidget);
      expect(find.text('Nothing to display right now.'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('preserves layout under 2.0x text scaling without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          textScaler: const TextScaler.linear(2.0),
          child: Scaffold(
            body: EmptyView(
              icon: Icons.calendar_today,
              title: 'No upcoming trips',
              subtitle: 'Browse properties and book your next adventure!',
              actionLabel: 'Explore Properties',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('No upcoming trips'), findsOneWidget);
      expect(find.text('Explore Properties'), findsOneWidget);
    });
  });
}
