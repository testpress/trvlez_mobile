import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/data/property_dto.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';

class MockPropertiesRepository extends Fake implements PropertiesRepository {
  List<Property> propertiesToReturn = [];
  String? lastSearch;
  String? lastPropertyType;
  bool shouldThrow = false;

  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    lastSearch = search;
    lastPropertyType = propertyType;
    if (shouldThrow) {
      throw Exception('Failed to load properties');
    }
    return propertiesToReturn;
  }

  @override
  Future<Property> getPropertyDetail(String id) async {
    return propertiesToReturn.firstWhere((p) => p.id == id);
  }
}

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
        'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
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
  });

  group('PropertiesNotifier', () {
    late MockPropertiesRepository mockRepo;
    late ProviderContainer container;

    const testProperty = Property(
      id: 'prop-1',
      name: 'Grand Hyatt',
      city: 'Mumbai',
      countryCode: 'IN',
      propertyType: 'hotel',
      shortDescription: 'Luxury hotel',
      longDescription: 'Luxury hotel in central Mumbai',
      heroImageUrl: 'https://example.com/hotel.jpg',
      amenities: ['wifi', 'pool'],
    );

    setUp(() {
      mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [testProperty];
      container = ProviderContainer(
        overrides: [
          propertiesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial load fetches properties without filters', () async {
      final properties = await container.read(propertiesProvider.future);
      expect(properties.length, 1);
      expect(properties.first.name, 'Grand Hyatt');
      expect(mockRepo.lastSearch, isNull);
      expect(mockRepo.lastPropertyType, isNull);
    });

    test('search passes query to repository and updates state', () async {
      // Ensure initial load completes
      await container.read(propertiesProvider.future);

      final notifier = container.read(propertiesProvider.notifier);
      await notifier.search('Mumbai');

      expect(notifier.searchQuery, 'Mumbai');
      expect(mockRepo.lastSearch, 'Mumbai');
    });

    test('filterByPropertyType updates filter and re-fetches', () async {
      await container.read(propertiesProvider.future);

      final notifier = container.read(propertiesProvider.notifier);
      await notifier.filterByPropertyType('resort');

      expect(notifier.propertyType, 'resort');
      expect(mockRepo.lastPropertyType, 'resort');
    });

    test('reset clears search and filter state', () async {
      await container.read(propertiesProvider.future);
      final notifier = container.read(propertiesProvider.notifier);

      await notifier.search('Beach');
      await notifier.filterByPropertyType('villa');
      expect(notifier.searchQuery, 'Beach');
      expect(notifier.propertyType, 'villa');

      notifier.reset();
      expect(notifier.searchQuery, isNull);
      expect(notifier.propertyType, isNull);
    });
  });

  group('PropertyCard Widget', () {
    const property = Property(
      id: 'prop-99',
      name: 'Hilltop Sanctuary Resort',
      city: 'Ooty',
      stateRegion: 'Tamil Nadu',
      countryCode: 'India',
      propertyType: 'resort',
      shortDescription: 'Peaceful getaway',
      longDescription: 'Peaceful getaway nestled in the hills of Ooty',
      heroImageUrl: 'https://example.com/sanctuary.jpg',
      amenities: ['wifi', 'spa', 'mountain view'],
    );

    testWidgets('renders recommended card without hardcoded fake data',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              isHorizontal: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify name and location
      expect(find.text('Hilltop Sanctuary Resort'), findsOneWidget);
      expect(find.text('Ooty, Tamil Nadu, India'), findsOneWidget);

      // Verify amenity text is rendered
      expect(find.text('wifi • spa'), findsOneWidget);

      // Verify no fake hardcoded price or ratings
      expect(find.text('\$199'), findsNothing);
      expect(find.text('4N/5D'), findsNothing);
      expect(find.text('355 reviews'), findsNothing);
    });

    testWidgets('renders popular card with property type badge and without fake data',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              isHorizontal: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify name and location
      expect(find.text('Hilltop Sanctuary Resort'), findsOneWidget);
      expect(find.text('Ooty, Tamil Nadu, India'), findsOneWidget);

      // Verify property type badge
      expect(find.text('RESORT'), findsOneWidget);

      // Verify no fake hardcoded price or ratings
      expect(find.text('\$199'), findsNothing);
      expect(find.text('4N/5D'), findsNothing);
      expect(find.text('355 reviews'), findsNothing);
    });
  });
}
