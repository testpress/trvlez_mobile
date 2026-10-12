import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/guest_counts.dart';
import 'package:trvlez_mobile/features/booking/domain/entities/room_pick.dart';

void main() {
  group('BookingDateRange', () {
    test('calculates nights and validity correctly', () {
      final range = BookingDateRange(
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 14),
      );
      expect(range.nights, 4);
      expect(range.isValid, isTrue);

      final same = BookingDateRange(
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 14),
      );
      expect(range.sameAs(same), isTrue);

      final different = BookingDateRange(
        DateTime(2026, 10, 11),
        DateTime(2026, 10, 14),
      );
      expect(range.sameAs(different), isFalse);
    });

    test('calculates free cancellation deadline', () {
      final futureRange = BookingDateRange(
        DateTime.now().add(const Duration(days: 10)),
        DateTime.now().add(const Duration(days: 14)),
      );
      expect(futureRange.freeCancellationUntil, isNotNull);

      final immediateRange = BookingDateRange(
        DateTime.now().add(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 3)),
      );
      expect(immediateRange.freeCancellationUntil, isNull);
    });
  });

  group('GuestCounts', () {
    test('default counts and summary string', () {
      const counts = GuestCounts();
      expect(counts.adults, 2);
      expect(counts.children, 0);
      expect(counts.infants, 0);
      expect(counts.sleepingCount, 2);
      expect(counts.summary, '2 adults');
    });

    test('withKind and floor constraints', () {
      var counts = const GuestCounts();
      counts = counts.withKind(GuestKind.adults, 4);
      counts = counts.withKind(GuestKind.children, 2);
      counts = counts.withKind(GuestKind.infants, 1);

      expect(counts.sleepingCount, 6);
      expect(counts.summary, '4 adults, 2 children, 1 infant');
      expect(counts.floorFor(GuestKind.adults), 1);
      expect(counts.floorFor(GuestKind.children), 0);
      expect(counts.floorFor(GuestKind.infants), 0);
    });
  });

  group('RoomPick & BookingDraft', () {
    const type1 = BookingRoomType(
      id: 'r1',
      name: 'Deluxe Room',
      sleeps: 2,
      nightly: 100,
    );
    const type2 = BookingRoomType(
      id: 'r2',
      name: 'Family Suite',
      sleeps: 4,
      nightly: 200,
    );

    final range = BookingDateRange(
      DateTime(2026, 11, 1),
      DateTime(2026, 11, 4),
    );

    test('RoomPick arithmetic', () {
      final pick = RoomPick(type: type1, quantity: 2, range: range);
      expect(pick.sleeps, 4);
      expect(pick.total, 600); // 100 * 3 nights * 2 rooms
    });

    test('BookingDraft validation and splitting', () {
      final pick1 = RoomPick(type: type1, quantity: 1, range: range);
      final draft = BookingDraft(
        propertyId: 'p1',
        propertyName: 'Grand Hotel',
        propertyPlace: 'London',
        propertyNightly: 100,
        range: range,
        guests: const GuestCounts(adults: 2),
        picks: [pick1],
      );

      expect(draft.chosen.length, 1);
      expect(draft.sleepsEveryone, isTrue);
      expect(draft.canReview, isTrue);
      expect(draft.canConfirm, isFalse); // no card yet

      final readyDraft = draft.copyWith(cardAdded: true);
      expect(readyDraft.canConfirm, isTrue);
      expect(readyDraft.splits, isFalse);

      // Add second room on different dates
      final diffRange = BookingDateRange(
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 5),
      );
      final pick2 = RoomPick(type: type2, quantity: 1, range: diffRange);
      final splitDraft = readyDraft.copyWith(picks: [pick1, pick2]);

      expect(splitDraft.splits, isTrue);
      expect(splitDraft.split().length, 2);
    });
  });
}
