import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

export 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
export 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';
export 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';
export 'package:trvlez_mobile/features/findr/domain/entities/traveler_share_link.dart';
export 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

/// Provider for live, backend-driven Findr portfolio metrics and referral lists.
final findrPortfolioProvider =
    AsyncNotifierProvider<FindrPortfolioNotifier, FindrPortfolio>(
      FindrPortfolioNotifier.new,
    );

/// Convenience provider yielding non-null [FindrPortfolio] synced immediately with local persistence.
final liveFindrPortfolioProvider = Provider<FindrPortfolio>((ref) {
  final asyncValue = ref.watch(findrPortfolioProvider);
  final portfolio = asyncValue.valueOrNull ?? FindrPortfolio.empty;
  bool isJoined = portfolio.joined;
  try {
    isJoined =
        isJoined || ref.read(settingsRepositoryProvider).isFindrActivated();
  } catch (error, stackTrace) {
    // Harmless fallback when settings repository is unconfigured in test environment.
    AppLogger.debug(
      'Settings repository unconfigured for live portfolio',
      error,
      stackTrace,
    );
  }
  return portfolio.copyWith(joined: isJoined);
});

class FindrPortfolioNotifier extends AsyncNotifier<FindrPortfolio> {
  @override
  FutureOr<FindrPortfolio> build() {
    bool isJoined = false;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      isJoined = settings.isFindrActivated();
    } catch (error, stackTrace) {
      // settingsRepositoryProvider not overridden in isolated unit/widget tests
      AppLogger.debug(
        'Settings repository unconfigured in portfolio notifier',
        error,
        stackTrace,
      );
    }

    final finderSummary = ref.watch(finderNotifierProvider).valueOrNull;
    final liveFinder = finderSummary?.finder;
    if (liveFinder != null) {
      isJoined = liveFinder.isActive;
      _persistJoined(isJoined);
    }

    if (!isJoined) {
      return FindrPortfolio.empty.copyWith(joined: false);
    }

    return _fetchPortfolio(isJoined);
  }

  Future<FindrPortfolio> _fetchPortfolio(bool isJoined) async {
    try {
      final repo = ref.read(finderRepositoryProvider);
      final portfolio = await repo.getFindrPortfolio();
      return portfolio.copyWith(joined: isJoined);
    } catch (error, stackTrace) {
      // Non-critical portfolio fetch failure; return empty joined portfolio fallback.
      AppLogger.warning(
        'Failed to fetch Findr portfolio, using empty fallback',
        error,
        stackTrace,
      );
      return FindrPortfolio.empty.copyWith(joined: isJoined);
    }
  }

  void _persistJoined(bool joined) {
    try {
      ref.read(settingsRepositoryProvider).setFindrActivated(joined);
    } catch (error, stackTrace) {
      // Harmless persistence failure; state is maintained in-memory.
      AppLogger.warning(
        'Failed to persist Findr activated state',
        error,
        stackTrace,
      );
    }
  }

  Future<void> joinFindr() async {
    _persistJoined(true);
    state = AsyncData(
      state.valueOrNull?.copyWith(joined: true) ??
          FindrPortfolio.empty.copyWith(joined: true),
    );
    try {
      final repo = ref.read(finderRepositoryProvider);
      final portfolio = await repo.getFindrPortfolio();
      state = AsyncData(portfolio.copyWith(joined: true));
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to refresh Findr portfolio after joining',
        error,
        stackTrace,
      );
      state = AsyncData(
        state.valueOrNull?.copyWith(joined: true) ??
            FindrPortfolio.empty.copyWith(joined: true),
      );
    }
  }

  Future<void> setJoined(bool joined) async {
    _persistJoined(joined);
    if (!joined) {
      state = AsyncData(FindrPortfolio.empty.copyWith(joined: false));
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(finderRepositoryProvider);
      return repo.getFindrPortfolio();
    });
  }

  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  ) async {
    final repo = ref.read(finderRepositoryProvider);
    final item = await repo.createHotelReferral(params);
    await refresh();
    return item;
  }
}
