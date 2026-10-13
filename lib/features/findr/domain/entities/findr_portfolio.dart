import 'package:meta/meta.dart';

/// State of a recommendation in the Findr review pipeline.
enum FindrRecommendationState { awaiting, confirmed, declined }

/// A single hotel recommendation made through Findr.
@immutable
class FindrRecommendation {
  const FindrRecommendation({
    required this.name,
    required this.when,
    required this.status,
    required this.state,
  });

  final String name;
  final String when;
  final String status;
  final FindrRecommendationState state;
}

/// A payout record in the Findr programme.
@immutable
class FindrPayout {
  const FindrPayout({
    required this.label,
    required this.amount,
    this.last = false,
  });

  final String label;
  final String amount;
  final bool last;
}

/// Aggregated state and portfolio metrics for the traveler's Findr account.
@immutable
class FindrPortfolio {
  const FindrPortfolio({
    required this.joined,
    required this.earned,
    required this.joinedCount,
    required this.inReviewCount,
    required this.dueAmount,
    required this.dueDate,
    required this.recommendations,
    required this.payouts,
  });

  final bool joined;
  final String earned;
  final int joinedCount;
  final int inReviewCount;
  final String dueAmount;
  final String dueDate;
  final List<FindrRecommendation> recommendations;
  final List<FindrPayout> payouts;

  FindrPortfolio copyWith({
    bool? joined,
    String? earned,
    int? joinedCount,
    int? inReviewCount,
    String? dueAmount,
    String? dueDate,
    List<FindrRecommendation>? recommendations,
    List<FindrPayout>? payouts,
  }) {
    return FindrPortfolio(
      joined: joined ?? this.joined,
      earned: earned ?? this.earned,
      joinedCount: joinedCount ?? this.joinedCount,
      inReviewCount: inReviewCount ?? this.inReviewCount,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDate: dueDate ?? this.dueDate,
      recommendations: recommendations ?? this.recommendations,
      payouts: payouts ?? this.payouts,
    );
  }
}
