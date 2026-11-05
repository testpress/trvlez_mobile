import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_create_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/traveler_share_link.dart';

/// Abstract domain interface defining Finder persistence and lifecycle operations.
abstract interface class FinderRepository {
  /// Fetches the caller's live Finder identity, eligibility, and re-verification state.
  Future<FinderStateSummary> getFinderStatus();

  /// Returns the current active Finder participation terms and conditions.
  FinderTerms getFinderTerms();

  /// Idempotently activates the caller's Finder account with residential address and accepted terms.
  Future<FinderIdentity> activateFinder(FinderActivationParams params);

  /// Updates allowed profile fields (address and email).
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params);

  /// Fetches hotel referrals initiated by the authenticated Finder.
  Future<List<HotelReferralItem>> listHotelReferrals({
    String? status,
    int skip = 0,
    int limit = 50,
  });

  /// Counts converted hotels permanently associated with the authenticated Finder.
  Future<int> countAssociatedHotels();

  /// Retrieves or initializes the Finder's permanent traveler share code and link.
  Future<TravelerShareLink> getTravelerShareLink();

  /// Submits an outreach invitation to a prospective hotel partner.
  Future<HotelReferralItem> createHotelReferral(
    HotelReferralCreateParams params,
  );

  /// Aggregates live Finder identity, associated hotels, and outreach pipeline into portfolio metrics.
  Future<FindrPortfolio> getFindrPortfolio();
}
