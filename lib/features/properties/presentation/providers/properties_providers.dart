import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/providers/repository_providers.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

export 'package:trvlez_mobile/core/providers/repository_providers.dart'
    show propertiesRepositoryProvider;
export 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';
export 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

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
