import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/room_dates_sheet.dart';

import '../../../../helpers/test_app.dart';
import '../../../../helpers/viewport_testing.dart';

void main() {
  group('RoomDatesSheet Widget & Matrix Tests', () {
    final samplePick = RoomPick(
      type: const BookingRoomType(
        id: 'deluxe-1',
        name: 'Deluxe King Suite',
        sleeps: 2,
        nightly: 150,
      ),
      quantity: 1,
      range: BookingDateRange(DateTime(2026, 12, 1), DateTime(2026, 12, 5)),
    );

    testWidgets('renders room dates sheet content and Done button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRoomDatesSheet(context, samplePick),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Deluxe King Suite'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('renders cleanly on compact viewport at 2.0x text scale', (
      tester,
    ) async {
      tester.setViewport(TestViewports.compactAndroid);
      addTearDown(tester.resetViewport);

      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            textScaler: TestTextScales.accessibility,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showRoomDatesSheet(context, samplePick),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Deluxe King Suite'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
