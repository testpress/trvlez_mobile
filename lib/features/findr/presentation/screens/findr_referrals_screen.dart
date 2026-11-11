import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_hotel_bottom_sheet.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/referral_card.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/referral_detail_sheet.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/referral_filter_chip.dart';

enum _ReferralFilter { all, live, pending, outreach }

/// Screen displaying the complete, filterable list of hotel partner referrals.
class FindrReferralsScreen extends ConsumerStatefulWidget {
  const FindrReferralsScreen({super.key});

  @override
  ConsumerState<FindrReferralsScreen> createState() =>
      _FindrReferralsScreenState();
}

class _FindrReferralsScreenState extends ConsumerState<FindrReferralsScreen> {
  _ReferralFilter _selectedFilter = _ReferralFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizes = context.sizes;
    final portfolioAsync = ref.watch(findrPortfolioProvider);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // Pinned Header
          AppPinnedHeader(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    AppIcons.arrowLeft,
                    size: sizes.iconMd,
                    color: colors.textPrimary,
                  ),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    'All Recommendations',
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => showReferHotelSheet(context),
                  icon: Icon(
                    AppIcons.plus,
                    size: sizes.iconMd,
                    color: colors.brandPrimary,
                  ),
                  tooltip: 'Refer Hotel',
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: portfolioAsync.when(
              loading: () =>
                  const LoadingView(message: 'Loading recommendations...'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () =>
                    ref.read(findrPortfolioProvider.notifier).refresh(),
              ),
              data: (portfolio) => _ReferralsContent(
                portfolio: portfolio,
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) =>
                    setState(() => _selectedFilter = filter),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralsContent extends StatelessWidget {
  const _ReferralsContent({
    required this.portfolio,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final FindrPortfolio portfolio;
  final _ReferralFilter selectedFilter;
  final ValueChanged<_ReferralFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final allReferrals = portfolio.hotelReferrals;
    final liveCount = allReferrals.where((referral) => referral.isLive).length;
    final pendingCount = allReferrals
        .where((referral) => referral.isPending)
        .length;
    final outreachCount = allReferrals
        .where((referral) => referral.isOutreach)
        .length;

    final filteredList = switch (selectedFilter) {
      _ReferralFilter.all => allReferrals,
      _ReferralFilter.live =>
        allReferrals.where((referral) => referral.isLive).toList(),
      _ReferralFilter.pending =>
        allReferrals.where((referral) => referral.isPending).toList(),
      _ReferralFilter.outreach =>
        allReferrals.where((referral) => referral.isOutreach).toList(),
    };

    return RefreshIndicator(
      onRefresh: () => Future.value(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: sizes.containerForm),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: space.insetCard,
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ReferralFilterChip(
                          label: 'All (${allReferrals.length})',
                          isSelected: selectedFilter == _ReferralFilter.all,
                          onTap: () => onFilterChanged(_ReferralFilter.all),
                        ),
                        SizedBox(width: space.inlineIconLabel),
                        ReferralFilterChip(
                          label: 'Live ($liveCount)',
                          isSelected: selectedFilter == _ReferralFilter.live,
                          onTap: () => onFilterChanged(_ReferralFilter.live),
                        ),
                        SizedBox(width: space.inlineIconLabel),
                        ReferralFilterChip(
                          label: 'In Review ($pendingCount)',
                          isSelected: selectedFilter == _ReferralFilter.pending,
                          onTap: () => onFilterChanged(_ReferralFilter.pending),
                        ),
                        SizedBox(width: space.inlineIconLabel),
                        ReferralFilterChip(
                          label: 'Outreach ($outreachCount)',
                          isSelected:
                              selectedFilter == _ReferralFilter.outreach,
                          onTap: () =>
                              onFilterChanged(_ReferralFilter.outreach),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (filteredList.isEmpty)
                SliverPadding(
                  padding: space.insetCard,
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: space.insetCard,
                      margin: EdgeInsets.only(top: space.stackSection),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: shape.radiusControl,
                        border: Border.all(
                          color: colors.cardBorder,
                          width: shape.borderDefault,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.building,
                            size: sizes.iconXl,
                            color: colors.textSecondary,
                          ),
                          SizedBox(height: space.stackItem),
                          Text(
                            'No recommendations in this category',
                            style: context.text.titleSmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: TypeScale.bold,
                            ),
                          ),
                          SizedBox(height: space.stackTight),
                          Text(
                            'Submit a new partner hotel to lock your attribution claim',
                            textAlign: TextAlign.center,
                            style: context.text.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: space.stackItem),
                          AppButton(
                            label: 'Recommend a hotel',
                            onPressed: () => showReferHotelSheet(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: space.insetCard,
                  sliver: SliverList.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return ReferralCard(
                        key: ValueKey(item.id),
                        referral: item,
                        showLocation: true,
                        onTap: () => showReferralDetailSheet(context, item),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
