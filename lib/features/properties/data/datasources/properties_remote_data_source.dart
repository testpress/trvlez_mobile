import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/features/properties/data/models/property_dto.dart';

/// Remote data source for property listing and detail API calls.
///
/// Auth token injection is handled by Dio [AuthInterceptor].
/// Errors are mapped to [ApiException] by Dio [ErrorInterceptor].
class PropertiesRemoteDataSource {
  final Dio dio;

  const PropertiesRemoteDataSource({required this.dio});

  Future<PropertyListingResponseDto> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    final queryParams = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (search != null && search.trim().length >= 2) {
      queryParams['search'] = search.trim();
    }
    if (city != null && city.trim().isNotEmpty) {
      queryParams['city'] = city.trim();
    }
    if (propertyType != null && propertyType.trim().isNotEmpty) {
      queryParams['property_type'] = propertyType.trim();
    }

    final response = await dio.get<Map<String, dynamic>>(
      '/properties/listing',
      queryParameters: queryParams,
    );
    return PropertyListingResponseDto.fromJson(response.data!);
  }

  Future<PropertyDto> getPropertyDetail(String id) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/properties/$id/public',
    );
    return PropertyDto.fromJson(response.data!);
  }
}

/// Provider for the [PropertiesRemoteDataSource].
final propertiesRemoteDataSourceProvider =
    Provider<PropertiesRemoteDataSource>((ref) {
  return PropertiesRemoteDataSource(dio: ref.watch(dioProvider));
});
