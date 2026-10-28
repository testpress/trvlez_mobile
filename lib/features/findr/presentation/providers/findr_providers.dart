import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';

export 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
export 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

final findrPortfolioProvider =
    StateNotifierProvider<FindrPortfolioNotifier, FindrPortfolio>((ref) {
      return FindrPortfolioNotifier();
    });

class FindrPortfolioNotifier extends StateNotifier<FindrPortfolio> {
  FindrPortfolioNotifier()
    : super(
        const FindrPortfolio(
          joined: false,
          earned: '£240.00',
          joinedCount: 3,
          inReviewCount: 1,
          dueAmount: '£60',
          dueDate: '1 Oct',
          recommendations: [
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
          ],
          payouts: [
            FindrPayout(label: 'Due 1 Oct', amount: '£60.00'),
            FindrPayout(label: 'Paid 1 Sep', amount: '£180.00', last: true),
          ],
        ),
      );

  void joinFindr() {
    state = state.copyWith(joined: true);
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
