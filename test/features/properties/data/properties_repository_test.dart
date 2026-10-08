import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/features/properties/data/datasources/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/data/models/property_dto.dart';
import 'package:trvlez_mobile/features/properties/data/repositories/properties_repository_impl.dart';

class FakePropertiesRemoteDataSource extends Fake
    implements PropertiesRemoteDataSource {
  PropertyListingResponseDto? listingResponse;
  PropertyDto? detailResponse;
  DioException? exceptionToThrow;

  int? lastSkip;
  int? lastLimit;
  String? lastSearch;
  String? lastCity;
  String? lastPropertyType;
  String? lastDetailId;

  @override
  Future<PropertyListingResponseDto> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    lastSkip = skip;
    lastLimit = limit;
    lastSearch = search;
    lastCity = city;
    lastPropertyType = propertyType;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return listingResponse!;
  }

  @override
  Future<PropertyDto> getPropertyDetail(String id) async {
    lastDetailId = id;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return detailResponse!;
  }
}

void main() {
  group('PropertiesRepositoryImpl', () {
    late FakePropertiesRemoteDataSource fakeDataSource;
    late PropertiesRepositoryImpl repository;

    final sampleDto = PropertyDto.fromJson(const {
      'id': 'prop-1',
      'name': 'Azure Coastal Resort',
      'city': 'Goa',
      'country_code': 'IN',
      'property_type': 'resort',
      'description': 'A beautiful beachside resort.',
      'starting_price_per_night': 150.0,
      'images': ['https://example.com/azure.jpg'],
      'amenities': ['wifi', 'pool'],
    });

    setUp(() {
      fakeDataSource = FakePropertiesRemoteDataSource();
      repository = PropertiesRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getProperties returns mapped domain entities and forwards params',
        () async {
      fakeDataSource.listingResponse = PropertyListingResponseDto(
        items: [sampleDto],
        total: 1,
        skip: 10,
        limit: 20,
      );

      final result = await repository.getProperties(
        skip: 10,
        limit: 20,
        search: 'Azure',
        city: 'Goa',
        propertyType: 'resort',
      );

      expect(result.length, 1);
      expect(result.first.id, 'prop-1');
      expect(result.first.name, 'Azure Coastal Resort');
      expect(result.first.pricePerNight, 150.0);
      expect(fakeDataSource.lastSkip, 10);
      expect(fakeDataSource.lastLimit, 20);
      expect(fakeDataSource.lastSearch, 'Azure');
      expect(fakeDataSource.lastCity, 'Goa');
      expect(fakeDataSource.lastPropertyType, 'resort');
    });

    test('getProperties maps DioException into AppException', () async {
      fakeDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/properties/listing'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => repository.getProperties(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getPropertyDetail returns mapped domain entity', () async {
      fakeDataSource.detailResponse = sampleDto;

      final result = await repository.getPropertyDetail('prop-1');

      expect(result.id, 'prop-1');
      expect(result.name, 'Azure Coastal Resort');
      expect(fakeDataSource.lastDetailId, 'prop-1');
    });

    test('getPropertyDetail maps DioException into AppException', () async {
      fakeDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/properties/prop-999/public'),
        response: Response(
          requestOptions: RequestOptions(path: '/properties/prop-999/public'),
          statusCode: 404,
          data: {'detail': 'Property not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        () => repository.getPropertyDetail('prop-999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
