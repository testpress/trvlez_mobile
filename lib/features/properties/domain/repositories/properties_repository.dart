import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Domain contract for property data operations.
///
/// Pure Dart interface that decouples presentation from data sources.
abstract interface class PropertiesRepository {
  /// Fetches a paginated list of properties matching optional filters.
  Future<List<Property>> getProperties({
    int skip = 0,
    int limit = 50,
    String? search,
    String? city,
    String? propertyType,
  });

  /// Fetches full property details and room types by [id].
  Future<Property> getPropertyDetail(String id);
}
