import 'package:trvlez_mobile/features/properties/data/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';

class PropertiesRepository {
  final PropertiesRemoteDataSource remoteDataSource;

  const PropertiesRepository({required this.remoteDataSource});

  Future<List<Property>> getProperties({int skip = 0, int limit = 50}) async {
    final dto = await remoteDataSource.getProperties(skip: skip, limit: limit);
    return dto.items.map((e) => e.toDomain()).toList();
  }

  Future<Property> getPropertyDetail(String id) async {
    final dto = await remoteDataSource.getPropertyDetail(id);
    return dto.toDomain();
  }
}
