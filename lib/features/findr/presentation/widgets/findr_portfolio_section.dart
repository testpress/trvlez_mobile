import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_hotel_bottom_sheet.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_traveler_card.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/referral_card.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/referral_detail_sheet.dart';

/// Active portfolio dashboard displaying live earnings, referrals, and payouts.
class FindrPortfolioSection extends ConsumerWidget {
  const FindrPortfolioSection({
    super.key,
    required this.isSuspendedOrTerminated,
    required this.summary,
  });

  final bool isSuspendedOrTerminated;
  final FinderStateSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final portfolioAsync = ref.watch(findrPortfolioProvider);

    if (portfolioAsync.isLoading && !portfolioAsync.hasValue) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: space.stackHero),
        child: const LoadingView(message: 'Loading portfolio data...'),
      );
    }

    if (portfolioAsync.hasError && !portfolioAsync.hasValue) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: space.stackSection),
        child: ErrorView(
          message: portfolioAsync.error.toString(),
          onRetry: () => ref.read(findrPortfolioProvider.notifier).refresh(),
        ),
      );
    }

    final portfolio = portfolioAsync.valueOrNull ?? FindrPortfolio.empty;
    final recentReferrals = portfolio.hotelReferrals.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Primary Findr Card
        FindrCard(
          state: isSuspendedOrTerminated
              ? FindrState.locked
              : FindrState.active,
          ctaLabel: isSuspendedOrTerminated
              ? 'Activity Paused'
              : 'Recommend a hotel',
          earned: portfolio.earned,
          joined: portfolio.joinedCount,
          inReview: portfolio.inReviewCount,
          due: portfolio.dueAmount,
          dueDate: portfolio.dueDate,
          onCta: isSuspendedOrTerminated
              ? null
              : () => showReferHotelSheet(context),
        ),

        SizedBox(height: space.stackSection),

        // 2. Refer a Traveler Action Card
        ReferTravelerCard(
          shareCode: portfolio.shareCode,
          shareUrl: portfolio.shareUrl,
        ),

        SizedBox(height: space.stackSection),

        // 3. Recent Recommendations Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent',
              style: context.text.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: TypeScale.bold,
              ),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.findrReferrals),
              borderRadius: shape.radiusControlSm,
              child: Padding(
                padding: space.insetTagSm,
                child: Text(
                  'All',
                  style: context.text.labelMedium?.copyWith(
                    color: colors.brandPrimary,
                    fontWeight: TypeScale.semiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: space.stackItem),

        if (recentReferrals.isEmpty)
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: shape.radiusControl,
              border: Border.all(
                color: colors.cardBorder,
                width: shape.borderDefault,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  AppIcons.building,
                  size: sizes.iconLg,
                  color: colors.textSecondary,
                ),
                SizedBox(height: space.stackItem),
                Text(
                  'No recommendations yet',
                  style: context.text.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: TypeScale.bold,
                  ),
                ),
                SizedBox(height: space.stackTight),
                Text(
                  'Recommend a hotel partner to lock your 10% first-year and 1% forever commission.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          for (final referral in recentReferrals)
            ReferralCard(
              key: ValueKey(referral.id),
              referral: referral,
              onTap: () => showReferralDetailSheet(context, referral),
            ),

        SizedBox(height: space.stackSection),

        // 4. Payouts Header
        Text(
          'Payouts',
          style: context.text.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: TypeScale.bold,
          ),
        ),
        SizedBox(height: space.stackItem),

        if (portfolio.payouts.isEmpty)
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: shape.radiusControl,
              border: Border.all(
                color: colors.cardBorder,
                width: shape.borderDefault,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  AppIcons.creditCard,
                  size: sizes.iconLg,
                  color: colors.textSecondary,
                ),
                SizedBox(height: space.stackItem),
                Text(
                  'No payout history yet',
                  style: context.text.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: TypeScale.bold,
                  ),
                ),
                SizedBox(height: space.stackTight),
                Text(
                  'Monthly commission payouts are calculated on completed guest stays from your referred hotels.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: shape.radiusControl,
              border: Border.all(
                color: colors.cardBorder,
                width: shape.borderDefault,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final payout in portfolio.payouts)
                  _PayoutRow(payout: payout),
              ],
            ),
          ),

        SizedBox(height: space.stackHero),
      ],
    );
  }
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout});

  final FindrPayout payout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.symmetric(vertical: space.stackItem),
      decoration: BoxDecoration(
        border: payout.last
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.line,
                  width: shape.borderDefault,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            payout.label,
            style: context.text.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            payout.amount,
            style: context.text.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: TypeScale.bold,
            ),
          ),
        ],
      ),
    );
  }
}
