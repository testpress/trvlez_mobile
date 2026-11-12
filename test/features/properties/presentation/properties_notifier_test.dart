import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';

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
      throw const NetworkException('Failed to load properties');
    }
    return propertiesToReturn;
  }

  @override
  Future<Property> getPropertyDetail(String id) async {
    if (shouldThrow) {
      throw const NotFoundException('Property not found');
    }
    return propertiesToReturn.firstWhere((p) => p.id == id);
  }
}

void main() {
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
        overrides: [propertiesRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial load fetches properties without filters', () async {
      final properties = await container.read(
        propertiesNotifierProvider.future,
      );
      expect(properties.length, 1);
      expect(properties.first.name, 'Grand Hyatt');
      expect(mockRepo.lastSearch, isNull);
      expect(mockRepo.lastPropertyType, isNull);
    });

    test('search passes query to repository and updates state', () async {
      await container.read(propertiesNotifierProvider.future);

      final notifier = container.read(propertiesNotifierProvider.notifier);
      await notifier.search('Mumbai');

      expect(notifier.searchQuery, 'Mumbai');
      expect(mockRepo.lastSearch, 'Mumbai');
    });

    test('filterByPropertyType updates filter and re-fetches', () async {
      await container.read(propertiesNotifierProvider.future);

      final notifier = container.read(propertiesNotifierProvider.notifier);
      await notifier.filterByPropertyType('resort');

      expect(notifier.propertyType, 'resort');
      expect(mockRepo.lastPropertyType, 'resort');
    });

    test('reset clears search and filter state', () async {
      await container.read(propertiesNotifierProvider.future);
      final notifier = container.read(propertiesNotifierProvider.notifier);

      await notifier.search('Beach');
      await notifier.filterByPropertyType('villa');
      expect(notifier.searchQuery, 'Beach');
      expect(notifier.propertyType, 'villa');

      notifier.reset();
      expect(notifier.searchQuery, isNull);
      expect(notifier.propertyType, isNull);
    });
  });

  group('PropertyDetailNotifier', () {
    late MockPropertiesRepository mockRepo;
    late ProviderContainer container;

    const testProperty = Property(
      id: 'prop-detail-1',
      name: 'Sea View Resort',
      city: 'Goa',
      countryCode: 'IN',
      propertyType: 'resort',
      shortDescription: 'Resort by sea',
      longDescription: 'Resort by sea description',
      heroImageUrl: '',
    );

    setUp(() {
      mockRepo = MockPropertiesRepository();
      mockRepo.propertiesToReturn = [testProperty];
      container = ProviderContainer(
        overrides: [propertiesRepositoryProvider.overrideWithValue(mockRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads property detail by id', () async {
      final property = await container.read(
        propertyDetailNotifierProvider('prop-detail-1').future,
      );
      expect(property.id, 'prop-detail-1');
      expect(property.name, 'Sea View Resort');
    });

    test('refresh re-fetches property detail', () async {
      await container.read(
        propertyDetailNotifierProvider('prop-detail-1').future,
      );

      final notifier = container.read(
        propertyDetailNotifierProvider('prop-detail-1').notifier,
      );
      await notifier.refresh();

      final state = container.read(
        propertyDetailNotifierProvider('prop-detail-1'),
      );
      expect(state.value?.name, 'Sea View Resort');
    });

    test('yields AsyncError when repository fails', () async {
      mockRepo.shouldThrow = true;

      expect(
        () =>
            container.read(propertyDetailNotifierProvider('prop-fail').future),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
