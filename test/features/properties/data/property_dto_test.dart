import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/properties/data/models/property_dto.dart';

void main() {
  group('PropertyDto JSON Serialization', () {
    test('parses backend listing payload correctly', () {
      final json = {
        'id': 'prop-123',
        'name': 'Azure Coastal Resort',
        'description': 'A beautiful beachside resort.',
        'property_type': 'resort',
        'address_line1': '100 Ocean Drive',
        'city': 'Goa',
        'state_region': 'Goa',
        'postal_code': '403001',
        'country_code': 'IN',
        'amenities': ['wifi', 'pool', 'spa'],
        'images': [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
        'total_rooms': 24,
        'checkin_time': '14:00',
        'checkout_time': '11:00',
      };

      final dto = PropertyDto.fromJson(json);
      final property = dto.toDomain();

      expect(property.id, 'prop-123');
      expect(property.name, 'Azure Coastal Resort');
      expect(property.shortDescription, 'A beautiful beachside resort.');
      expect(property.longDescription, 'A beautiful beachside resort.');
      expect(property.propertyType, 'resort');
      expect(property.addressLine1, '100 Ocean Drive');
      expect(property.city, 'Goa');
      expect(property.stateRegion, 'Goa');
      expect(property.countryCode, 'IN');
      expect(property.amenities, ['wifi', 'pool', 'spa']);
      expect(property.heroImageUrl, 'https://example.com/img1.jpg');
      expect(property.totalRooms, 24);
      expect(property.checkinTime, '14:00');
      expect(property.checkoutTime, '11:00');
      expect(property.pricePerNight, isNull);
      expect(property.rating, isNull);
      expect(property.reviewsCount, isNull);
    });

    test('parses public detail payload using facilities as amenities', () {
      final json = {
        'id': 'prop-456',
        'name': 'Mountain Grand Hotel',
        'description': 'Nestled in the hills.',
        'city': 'Manali',
        'country_code': 'IN',
        'facilities': ['parking', 'restaurant', 'gym'],
        'images': <String>[],
      };

      final dto = PropertyDto.fromJson(json);
      final property = dto.toDomain();

      expect(property.id, 'prop-456');
      expect(property.name, 'Mountain Grand Hotel');
      expect(property.countryCode, 'IN');
      expect(property.amenities, ['parking', 'restaurant', 'gym']);
      expect(property.heroImageUrl, isEmpty);
    });

    test('deserializes starting_price_per_night and room type base_price_per_night', () {
      final json = {
        'id': 'prop-789',
        'name': 'Seaside Haven',
        'city': 'Goa',
        'country_code': 'IN',
        'currency_code': 'USD',
        'starting_price_per_night': 149.00,
        'room_types': [
          {
            'id': 'rt-1',
            'name': 'Standard Room',
            'max_occupancy': 2,
            'max_adults': 2,
            'max_children': 0,
            'description': 'Standard room',
            'base_price_per_night': 149.00,
            'is_active': true,
          },
          {
            'id': 'rt-2',
            'name': 'Deluxe Room',
            'max_occupancy': 3,
            'max_adults': 2,
            'max_children': 1,
            'description': 'Deluxe room',
            'base_price_per_night': 229.00,
            'is_active': true,
          },
        ],
      };

      final dto = PropertyDto.fromJson(json);
      final property = dto.toDomain();

      expect(property.pricePerNight, 149.00);
      expect(property.currencyCode, 'USD');
      expect(property.roomTypes.length, 2);
      expect(property.roomTypes[0].pricePerNight, 149.00);
      expect(property.roomTypes[0].hasValidPrice, isTrue);
      expect(property.roomTypes[1].pricePerNight, 229.00);
      expect(property.roomTypes[1].hasValidPrice, isTrue);
    });

    test('deserializes string-encoded pricing (e.g. from Decimal "2000.0") without error', () {
      final json = {
        'id': 'prop-str-price',
        'name': 'String Price Resort',
        'city': 'Goa',
        'country_code': 'IN',
        'currency_code': 'USD',
        'latitude': '15.2993',
        'longitude': '74.1240',
        'starting_price_per_night': '2000.0',
        'room_types': [
          {
            'id': 'rt-str',
            'name': 'Luxury Villa',
            'max_occupancy': 4,
            'base_price_per_night': '2000.0',
            'is_active': true,
          },
        ],
      };

      final dto = PropertyDto.fromJson(json);
      final property = dto.toDomain();

      expect(property.pricePerNight, 2000.0);
      expect(dto.latitude, 15.2993);
      expect(dto.longitude, 74.1240);
      expect(property.roomTypes.first.pricePerNight, 2000.0);
      expect(property.roomTypes.first.hasValidPrice, isTrue);
    });
  });
}
