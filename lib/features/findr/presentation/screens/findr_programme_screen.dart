import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';

/// Screen 4.1: The Findr rewards & referral programme dashboard.
class FindrProgrammeScreen extends ConsumerWidget {
  const FindrProgrammeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;
    final portfolio = ref.watch(findrPortfolioProvider);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    'Findr',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: TypeScale.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      AppIcons.arrowLeft,
                      size: sizes.iconMd,
                      color: colors.textPrimary,
                    ),
                    splashRadius: sizes.iconMd,
                    tooltip: 'Back',
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Body ────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: space.insetCard,
              children: [
                // Findr Active Card
                FindrCard(
                  state: FindrState.active,
                  earned: portfolio.earned,
                  joined: portfolio.joinedCount,
                  inReview: portfolio.inReviewCount,
                  due: portfolio.dueAmount,
                  dueDate: portfolio.dueDate,
                  onCta: () {
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

                // ── Recent Recommendations ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: TypeScale.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'All',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: space.stackItem),

                for (final rec in portfolio.recommendations)
                  _RecommendationCard(recommendation: rec),

                SizedBox(height: space.stackSection),

                // ── Payouts Section ────────────────────────────────────────
                Text(
                  'Payouts',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
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
            ),
          ),
        ],
      ),
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
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: space.stackText),
                Text(
                  recommendation.when,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
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
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          Text(
            payout.amount,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
