import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';

final propertiesProvider = AsyncNotifierProvider<PropertiesNotifier, List<Property>>(
  () => PropertiesNotifier(),
);

class PropertiesNotifier extends AsyncNotifier<List<Property>> {
  @override
  FutureOr<List<Property>> build() async {
    final repository = ref.read(propertiesRepositoryProvider);
    return repository.getProperties();
  }

  Future<void> fetchProperties() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(propertiesRepositoryProvider);
      return repository.getProperties();
    });
  }

  void reset() {
    state = const AsyncData([]);
  }
}
