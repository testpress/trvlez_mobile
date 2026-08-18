import 'package:dio/dio.dart';

import 'package:trvlez_mobile/features/properties/data/property_dto.dart';

/// Remote data source for property listing and detail API calls.
///
/// Auth token injection is handled by the Dio [AuthInterceptor].
/// Errors are mapped to [ApiException] by the Dio [ErrorInterceptor].
class PropertiesRemoteDataSource {
  final Dio dio;

  const PropertiesRemoteDataSource({required this.dio});

  Future<PropertyListingResponseDto> getProperties({
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/properties/listing',
      queryParameters: {'skip': skip, 'limit': limit},
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
