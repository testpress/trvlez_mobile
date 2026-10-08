import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/properties/data/datasources/properties_remote_data_source.dart';
import 'package:trvlez_mobile/features/properties/data/repositories/properties_repository_impl.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

export 'package:trvlez_mobile/features/properties/data/datasources/properties_remote_data_source.dart';
export 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

/// Provider for the domain [PropertiesRepository] interface.
final propertiesRepositoryProvider = Provider<PropertiesRepository>((ref) {
  return PropertiesRepositoryImpl(
    remoteDataSource: ref.watch(propertiesRemoteDataSourceProvider),
  );
});

/// Standard naming alias for [propertiesProvider].
final propertiesNotifierProvider = propertiesProvider;

/// Notifier managing single property detail state asynchronously.
class PropertyDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Property, String> {
  @override
  FutureOr<Property> build(String arg) {
    final repository = ref.read(propertiesRepositoryProvider);
    return repository.getPropertyDetail(arg);
  }

  /// Reloads property details.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(propertiesRepositoryProvider).getPropertyDetail(arg);
    });
  }
}

/// Provider for observing and loading property details by property ID.
final propertyDetailNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<PropertyDetailNotifier, Property, String>(
      PropertyDetailNotifier.new,
    );
