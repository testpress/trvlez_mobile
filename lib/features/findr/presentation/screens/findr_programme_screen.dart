import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_blocked_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_status_banner.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/findr_not_joined_section.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/findr_portfolio_section.dart';

/// Screen 4.1: The Findr rewards & referral programme dashboard.
/// Reactive to live backend Finder identity, eligibility, and lifecycle state.
class FindrProgrammeScreen extends ConsumerWidget {
  const FindrProgrammeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final sizes = context.sizes;
    final finderAsync = ref.watch(finderNotifierProvider);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      AppIcons.arrowLeft,
                      size: sizes.iconMd,
                      color: colors.textPrimary,
                    ),
                    tooltip: 'Back',
                  )
                else
                  SizedBox(width: sizes.controlLg),
                Expanded(
                  child: Text(
                    'Findr',
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: sizes.controlLg),
              ],
            ),
          ),

          // ── Asynchronous Body ──────────────────────────────────────────
          Expanded(
            child: finderAsync.when(
              loading: () => const LoadingView(
                message: 'Checking Findr status...',
              ),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () =>
                    ref.read(finderNotifierProvider.notifier).refresh(),
              ),
              data: (summary) => _FinderContent(summary: summary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinderContent extends ConsumerWidget {
  const _FinderContent({required this.summary});

  final FinderStateSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final finder = summary.finder;
    final isActivated = finder?.isActive ?? false;
    final isSuspendedOrTerminated =
        finder?.isSuspended ?? finder?.isTerminated ?? false;
    final isBlocked = !summary.eligibility.isEligible;

    final sizes = context.sizes;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait<void>([
          ref.read(finderNotifierProvider.notifier).refresh(),
          ref.read(findrPortfolioProvider.notifier).refresh(),
        ]);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: sizes.containerForm),
          child: ListView(
            padding: space.insetCard,
            children: [
              // Lifecycle / Re-verification banner
              FinderStatusBanner(
                summary: summary,
                onReverificationReturned: () =>
                    ref.read(finderNotifierProvider.notifier).refresh(),
              ),

              // 1. Ineligible and Not Activated: Render Blocked View
              if (!isActivated && !isSuspendedOrTerminated && isBlocked)
                FinderBlockedView(
                  eligibility: summary.eligibility,
                  onActionCompleted: () =>
                      ref.read(finderNotifierProvider.notifier).refresh(),
                )

              // 2. Not Activated but Eligible: Prompt Onboarding
              else if (!isActivated && !isSuspendedOrTerminated)
                FindrNotJoinedSection(
                  onActivate: () async {
                    await context.push(AppRoutes.findrTerms);
                    ref.read(finderNotifierProvider.notifier).refresh();
                  },
                )

              // 3. Activated or Retained Suspended/Terminated State
              else ...[
                FindrPortfolioSection(
                  isSuspendedOrTerminated: isSuspendedOrTerminated,
                  summary: summary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
