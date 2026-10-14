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

/// Helper to resolve bookable rooms directly from property entity room types.
class BookingRoomCatalogue {
  const BookingRoomCatalogue._();

  static List<BookingRoomType> forProperty(Property property) {
    if (property.roomTypes.isEmpty) {
      return const <BookingRoomType>[];
    }

    final bookableRooms = property.roomTypes
        .where((rt) => rt.isActive && rt.hasValidPrice)
        .toList();

    return bookableRooms.map((rt) {
      return BookingRoomType(
        id: rt.id,
        name: rt.name,
        sleeps: rt.maxOccupancy,
        nightly: rt.pricePerNight!.round(),
      );
    }).toList();
  }
}
