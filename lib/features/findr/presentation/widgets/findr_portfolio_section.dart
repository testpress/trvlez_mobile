import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';

/// Active portfolio dashboard displaying earnings, recommendations, and payouts.
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
    final portfolio = ref.watch(findrPortfolioProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'To recommend a property, share your referral code or add hotel details.',
                        style: TextStyle(color: colors.textPrimary),
                      ),
                      backgroundColor: colors.surface,
                    ),
                  );
                },
        ),

        SizedBox(height: space.stackSection),

        // Recent Recommendations Header
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
            Text(
              'All',
              style: context.text.labelMedium?.copyWith(
                color: colors.brandPrimary,
                fontWeight: TypeScale.semiBold,
              ),
            ),
          ],
        ),
        SizedBox(height: space.stackItem),

        for (final recommendation in portfolio.recommendations)
          _RecommendationCard(recommendation: recommendation),

        SizedBox(height: space.stackSection),

        // Payouts Header
        Text(
          'Payouts',
          style: context.text.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: TypeScale.bold,
          ),
        ),
        SizedBox(height: space.stackItem),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: space.insetCard.left,
            vertical: space.stackItem,
          ),
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final FindrRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return Container(
      margin: EdgeInsets.only(bottom: space.stackItem),
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
      child: Row(
        children: [
          Container(
            width: sizes.avatarSm,
            height: sizes.avatarSm,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: shape.radiusControlSm,
            ),
            child: Icon(
              AppIcons.building,
              size: sizes.iconSm,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  recommendation.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: TypeScale.bold,
                  ),
                ),
                SizedBox(height: space.stackTight),
                Text(
                  recommendation.when,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: space.inlineIconLabel),
          StatusPill(
            label: recommendation.status,
            state: switch (recommendation.state) {
              FindrRecommendationState.awaiting => StatusPillState.awaiting,
              FindrRecommendationState.confirmed => StatusPillState.confirmed,
              FindrRecommendationState.declined => StatusPillState.cancelled,
            },
          ),
        ],
      ),
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
