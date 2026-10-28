import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/findr/data/repositories/finder_repository_impl.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';

export 'package:trvlez_mobile/features/findr/data/repositories/finder_repository_impl.dart'
    show finderRepositoryProvider;
export 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
export 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
export 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';
export 'package:trvlez_mobile/features/findr/domain/repositories/finder_repository.dart';

/// Provider exposing versioned Finder terms and conditions.
final finderTermsProvider = Provider<FinderTerms>((ref) {
  final repository = ref.watch(finderRepositoryProvider);
  return repository.getFinderTerms();
});

/// Checks whether a given traveler profile nationality qualifies for the UK-exclusive Findr programme.
bool isGbrNationality(String? nationality) {
  if (nationality == null || nationality.trim().isEmpty) {
    return false;
  }
  final code = nationality.trim().toUpperCase();
  return code == 'GBR' ||
      code == 'GB' ||
      code == 'UNITED KINGDOM' ||
      code == 'GREAT BRITAIN' ||
      code == 'UK';
}

/// Provider for the live Finder state and lifecycle operations.
final finderNotifierProvider =
    AsyncNotifierProvider<FinderNotifier, FinderStateSummary>(
  () => FinderNotifier(),
);

/// State notifier managing live Finder status, eligibility, and activation.
class FinderNotifier extends AsyncNotifier<FinderStateSummary> {
  @override
  FutureOr<FinderStateSummary> build() async {
    final repository = ref.read(finderRepositoryProvider);
    return repository.getFinderStatus();
  }

  /// Reloads the caller's live Finder status from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading<FinderStateSummary>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final repository = ref.read(finderRepositoryProvider);
      return repository.getFinderStatus();
    });
  }

  /// Submits structured address and agreement acceptance to activate Finder status.
  Future<bool> activate(FinderActivationParams params) async {
    state = const AsyncLoading<FinderStateSummary>().copyWithPrevious(state);

    try {
      final repository = ref.read(finderRepositoryProvider);
      await repository.activateFinder(params);
      final summary = await repository.getFinderStatus();
      state = AsyncData(summary);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<FinderStateSummary>(error, stackTrace)
          .copyWithPrevious(state);
      return false;
    }
  }

  /// Updates residential address or email fields.
  Future<bool> updateProfile(FinderProfileUpdateParams params) async {
    state = const AsyncLoading<FinderStateSummary>().copyWithPrevious(state);

    try {
      final repository = ref.read(finderRepositoryProvider);
      await repository.updateProfile(params);
      final summary = await repository.getFinderStatus();
      state = AsyncData(summary);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<FinderStateSummary>(error, stackTrace)
          .copyWithPrevious(state);
      return false;
    }
  }

  /// Clears any cached error state.
  void clearError() {
    final currentValue = state.valueOrNull;
    if (state.hasError && currentValue != null) {
      state = AsyncData(currentValue);
    }
  }
}
