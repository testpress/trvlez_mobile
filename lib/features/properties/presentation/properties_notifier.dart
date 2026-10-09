import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';

final propertiesProvider =
    AsyncNotifierProvider<PropertiesNotifier, List<Property>>(
      () => PropertiesNotifier(),
    );

class PropertiesNotifier extends AsyncNotifier<List<Property>> {
  String? _searchQuery;
  String? _propertyType;

  String? get searchQuery => _searchQuery;
  String? get propertyType => _propertyType;

  @override
  FutureOr<List<Property>> build() async {
    final repository = ref.read(propertiesRepositoryProvider);
    return repository.getProperties(
      search: _searchQuery,
      propertyType: _propertyType,
    );
  }

  Future<void> fetchProperties({String? search, String? propertyType}) async {
    if (search != null) {
      _searchQuery = search.trim().isEmpty ? null : search.trim();
    }
    if (propertyType != null) {
      _propertyType =
          (propertyType.isEmpty || propertyType.toLowerCase() == 'all')
          ? null
          : propertyType.toLowerCase();
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(propertiesRepositoryProvider);
      return repository.getProperties(
        search: _searchQuery,
        propertyType: _propertyType,
      );
    });
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim().isEmpty ? null : query.trim();
    await fetchProperties();
  }

  Future<void> filterByPropertyType(String? type) async {
    _propertyType = (type == null || type.toLowerCase() == 'all')
        ? null
        : type.toLowerCase();
    await fetchProperties();
  }

  void reset() {
    _searchQuery = null;
    _propertyType = null;
    state = const AsyncData([]);
  }
}
