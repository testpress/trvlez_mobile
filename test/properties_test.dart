import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/data/property_dto.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';
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

  group('PropertyDetailScreen Widget', () {
    const detailProperty = Property(
      id: 'prop-detail-1',
      name: 'Grand Bayfront Hotel',
      city: 'Kochi',
      stateRegion: 'Kerala',
      countryCode: 'IN',
      propertyType: 'hotel',
      shortDescription: 'Luxury seaside stay',
      longDescription:
          'Experience unparalleled luxury at the waterfront with spectacular harbor views, award-winning restaurants, and personalized service across every floor of our historic establishment.',
      heroImageUrl: 'https://example.com/kochi.jpg',
      amenities: ['wifi', 'swimming_pool', 'gym', 'spa'],
      checkinTime: '15:00',
      checkoutTime: '11:00',
      totalRooms: 45,
      roomTypes: [
        RoomType(
          id: 'rt-1',
          name: 'Deluxe King Harbour View',
          maxOccupancy: 3,
          maxAdults: 2,
          maxChildren: 1,
          description: 'Spacious king room facing the Arabian Sea',
        ),
        RoomType(
          id: 'rt-2',
          name: 'Executive Suite',
          maxOccupancy: 4,
          maxAdults: 3,
          maxChildren: 2,
          description: 'Two-room suite with private lounge access',
        ),
      ],
    );

    testWidgets('renders full property details, facilities, and room types',
        (tester) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            property: detailProperty,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify name, location, and type badge
      expect(find.text('Grand Bayfront Hotel'), findsOneWidget);
      expect(find.text('Kochi, Kerala, IN'), findsOneWidget);
      expect(find.text('HOTEL'), findsOneWidget);

      // Verify operational badges
      expect(find.text('Check-in: 15:00'), findsOneWidget);
      expect(find.text('Check-out: 11:00'), findsOneWidget);
      expect(find.text('45 Rooms'), findsOneWidget);

      // Verify facility pills
      expect(find.text('Wifi'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Spa'), findsOneWidget);

      // Verify room types section
      expect(find.text('Available Rooms'), findsOneWidget);
      expect(find.text('Deluxe King Harbour View'), findsOneWidget);
      expect(find.text('Max 3'), findsOneWidget);
      expect(find.text('Executive Suite'), findsOneWidget);
      expect(find.text('Max 4'), findsOneWidget);

      // Verify CTA button
      expect(find.text('Book Now'), findsOneWidget);
      expect(find.text('Free Reservation'), findsOneWidget);
    });

    testWidgets('expands and collapses description when Read more is tapped',
        (tester) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            property: detailProperty,
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      expect(find.text('Read more'), findsOneWidget);
    });

    testWidgets('supports deep linking by ID when initial property is null',
        (tester) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [detailProperty];

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            propertyId: 'prop-detail-1',
            repository: mockRepo,
          ),
        ),
      );

      // Initially shows loading
      expect(find.text('Loading property details...'), findsOneWidget);

      // After future completes
      await tester.pumpAndSettle();
      expect(find.text('Grand Bayfront Hotel'), findsOneWidget);
      expect(find.text('Deluxe King Harbour View'), findsOneWidget);
    });

    testWidgets('shows error state with retry when deep link fetch fails',
        (tester) async {
      final mockRepo = MockPropertiesRepository();
      mockRepo.shouldThrow = true;

      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailScreen(
            propertyId: 'non-existent',
            repository: mockRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load property'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}

