import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

export 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
export 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

final findrPortfolioProvider =
    NotifierProvider<FindrPortfolioNotifier, FindrPortfolio>(
  FindrPortfolioNotifier.new,
);

class FindrPortfolioNotifier extends Notifier<FindrPortfolio> {
  static const _defaultRecommendations = [
    FindrRecommendation(
      name: 'Casa Verde Villas',
      when: 'Recommended 12 Sep',
      status: 'In review',
      state: FindrRecommendationState.awaiting,
    ),
    FindrRecommendation(
      name: 'Alpine Lodge Interlaken',
      when: 'Joined 1 Aug',
      status: 'Joined',
      state: FindrRecommendationState.confirmed,
    ),
    FindrRecommendation(
      name: 'Grand Ocean Resort',
      when: 'Joined 4 Jul',
      status: 'Joined',
      state: FindrRecommendationState.confirmed,
    ),
  ];

  static const _defaultPayouts = [
    FindrPayout(label: 'Due 1 Oct', amount: '£60.00'),
    FindrPayout(label: 'Paid 1 Sep', amount: '£180.00', last: true),
  ];

  @override
  FindrPortfolio build() {
    bool isJoined = false;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      isJoined = settings.isFindrActivated();
    } catch (_) {
      // settingsRepositoryProvider not overridden in isolated unit/widget tests
    }

    final liveFinder = ref.read(finderNotifierProvider).valueOrNull?.finder;
    if (liveFinder != null) {
      isJoined = liveFinder.isActive;
    }

    ref.listen<AsyncValue<FinderStateSummary>>(finderNotifierProvider,
        (previous, next) {
      final active = next.valueOrNull?.finder?.isActive;
      if (active != null && active != state.joined) {
        state = state.copyWith(joined: active);
        _persistJoined(active);
      }
    });

    return FindrPortfolio(
      joined: isJoined,
      earned: '£240.00',
      joinedCount: 3,
      inReviewCount: 1,
      dueAmount: '£60',
      dueDate: '1 Oct',
      recommendations: _defaultRecommendations,
      payouts: _defaultPayouts,
    );
  }

  void _persistJoined(bool joined) {
    try {
      ref.read(settingsRepositoryProvider).setFindrActivated(joined);
    } catch (_) {}
  }

  void joinFindr() {
    state = state.copyWith(joined: true);
    _persistJoined(true);
  }

  void setJoined(bool joined) {
    state = state.copyWith(joined: joined);
    _persistJoined(joined);
  }

  void addRecommendation(String name, String place) {
    final updated = [
      FindrRecommendation(
        name: name,
        when: 'Recommended just now',
        status: 'In review',
        state: FindrRecommendationState.awaiting,
      ),
      ...state.recommendations,
    ];
    state = state.copyWith(
      recommendations: updated,
      inReviewCount: state.inReviewCount + 1,
    );
  }
}
