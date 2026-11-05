import 'package:meta/meta.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';

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
    this.hotelReferrals = const [],
    this.shareCode,
    this.shareUrl,
  });

  final bool joined;
  final String earned;
  final int joinedCount;
  final int inReviewCount;
  final String dueAmount;
  final String dueDate;
  final List<FindrRecommendation> recommendations;
  final List<FindrPayout> payouts;
  final List<HotelReferralItem> hotelReferrals;
  final String? shareCode;
  final String? shareUrl;

  static const empty = FindrPortfolio(
    joined: false,
    earned: '£0.00',
    joinedCount: 0,
    inReviewCount: 0,
    dueAmount: '£0.00',
    dueDate: '—',
    recommendations: [],
    payouts: [],
    hotelReferrals: [],
    shareCode: null,
    shareUrl: null,
  );

  FindrPortfolio copyWith({
    bool? joined,
    String? earned,
    int? joinedCount,
    int? inReviewCount,
    String? dueAmount,
    String? dueDate,
    List<FindrRecommendation>? recommendations,
    List<FindrPayout>? payouts,
    List<HotelReferralItem>? hotelReferrals,
    String? shareCode,
    String? shareUrl,
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
      hotelReferrals: hotelReferrals ?? this.hotelReferrals,
      shareCode: shareCode ?? this.shareCode,
      shareUrl: shareUrl ?? this.shareUrl,
    );
  }
}
