import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';

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
}

