import 'package:trvlez_mobile/features/booking/domain/entities/booking_date_range.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Room type available at a property.
class BookingRoomType {
  const BookingRoomType({
    required this.id,
    required this.name,
    required this.sleeps,
    required this.nightly,
  });

  final String id;
  final String name;
  final int sleeps;
  final int nightly;
}

/// A selected room line: type, quantity, and its specific date range.
class RoomPick {
  const RoomPick({
    required this.type,
    required this.quantity,
    required this.range,
  });

  final BookingRoomType type;
  final int quantity;
  final BookingDateRange range;

  int get sleeps => type.sleeps * quantity;

  int get total => type.nightly * range.nights * quantity;

  RoomPick withQuantity(int value) =>
      RoomPick(type: type, quantity: value, range: range);

  RoomPick withRange(BookingDateRange value) =>
      RoomPick(type: type, quantity: quantity, range: value);
}

/// Helper to resolve rooms from a property entity or fallback pricing.
class BookingRoomCatalogue {
  const BookingRoomCatalogue._();

  static List<BookingRoomType> forProperty(Property property) {
    if (property.roomTypes.isNotEmpty) {
      final active = property.roomTypes.where((rt) => rt.isActive).toList();
      final roomsToUse = active.isNotEmpty ? active : property.roomTypes;
      return roomsToUse.map((rt) {
        final price = rt.pricePerNight?.round() ??
            property.pricePerNight?.round() ??
            100;
        return BookingRoomType(
          id: rt.id,
          name: rt.name,
          sleeps: rt.maxOccupancy > 0 ? rt.maxOccupancy : 2,
          nightly: price > 0 ? price : 100,
        );
      }).toList();
    }

    final basePrice = property.pricePerNight?.round() ?? 240;
    return forNightly(property.id, basePrice);
  }

  static List<BookingRoomType> forNightly(String propertyId, int nightly) => [
        BookingRoomType(
          id: '$propertyId-r1',
          name: 'Room type one',
          sleeps: 2,
          nightly: nightly > 0 ? nightly : 240,
        ),
        BookingRoomType(
          id: '$propertyId-r2',
          name: 'Room type two',
          sleeps: 4,
          nightly: ((nightly > 0 ? nightly : 240) * 1.42).round(),
        ),
      ];
}
