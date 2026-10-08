import 'package:dio/dio.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/properties/data/datasources/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';

/// Concrete implementation of [PropertiesRepository] interfacing with remote data source.
///
/// Maps network exceptions into the sealed [AppException] hierarchy.
class PropertiesRepositoryImpl implements PropertiesRepository {
  final PropertiesRemoteDataSource remoteDataSource;

  const PropertiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  }) async {
    try {
      final dto = await remoteDataSource.getProperties(
        skip: skip,
        limit: limit,
        search: search,
        city: city,
        propertyType: propertyType,
      );
      return dto.items.map((e) => e.toDomain()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Property> getPropertyDetail(String id) async {
    try {
      final dto = await remoteDataSource.getPropertyDetail(id);
      return dto.toDomain();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
