// ── Shared Providers Facade ──────────────────────────────────────────────────
// Architecture Rule: Features never import another feature's data or presentation.
// Shared cross-feature state is accessed through core.

export 'package:trvlez_mobile/core/providers/repository_providers.dart'
    show reservationRepositoryProvider;

export 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart'
    show anywhereDraftProvider, anywhereStaysProvider;

export 'package:trvlez_mobile/features/disputes/presentation/providers/dispute_providers.dart'
    show disputeDraftProvider, disputesProvider;

export 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart'
    show
        finderNotifierProvider,
        findrPortfolioProvider,
        liveFindrPortfolioProvider,
        FindrPortfolio,
        FindrRecommendation,
        FindrPayout;

export 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart'
    show currentProfileProvider;

export 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart'
    show propertiesProvider, propertyDetailNotifierProvider;

export 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart'
    show
        checkInTokenProvider,
        reservationDetailNotifierProvider,
        reservationListProvider;

export 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart'
    show verificationNotifierProvider;
