import 'package:trvlez_mobile/core/network/api_client.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/properties/data/property_dto.dart';

class PropertiesRemoteDataSource {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  const PropertiesRemoteDataSource({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<PropertyListingResponseDto> getProperties({
    int skip = 0,
    int limit = 50,
  }) async {
    final token = await tokenStorage.getToken();
    final response = await apiClient.get(
      '/properties/listing?skip=$skip&limit=$limit',
      authToken: token,
    );
    return PropertyListingResponseDto.fromJson(response);
  }
}
