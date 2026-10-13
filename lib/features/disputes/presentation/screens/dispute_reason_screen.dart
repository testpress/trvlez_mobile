import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show reservationListProvider;
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/disputes/presentation/providers/dispute_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.3a: Categorized reason selection for raising a stay complaint.
class DisputeReasonScreen extends ConsumerWidget {
  const DisputeReasonScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final reservationsState = ref.watch(reservationListProvider);
    final allReservations = reservationsState.valueOrNull ?? [];
    final reservation = allReservations
        .where((r) => r.id == reservationId)
        .firstOrNull;

    final hotel = reservation?.propertySummary.name ?? 'Hotel';
    final refCode = reservation?.confirmationCode ?? reservationId;

    // Determine window
    final now = DateTime.now();
    final window = reservation == null
        ? DisputeWindow.open
        : (now.isBefore(reservation.checkInDate)
              ? DisputeWindow.beforeArrival
              : (now.isAfter(
                      reservation.checkOutDate.add(const Duration(hours: 48)),
                    )
                    ? DisputeWindow.closed
                    : DisputeWindow.open));

    final reasons = DisputeReasonCopy.forWindow(window);

    return BrandVerifyScreen(
      title: 'Something wrong',
      backgroundAsset: 'assets/art/bg_checkin_steps.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: const [
        CheckInNotice(
          text:
              'Raising this holds your payment to the hotel while we look into it. It does not cancel your stay.',
        ),
      ],
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'What went wrong?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Pick the closest one. You can explain in your own words next.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        for (final reason in reasons)
          _ReasonRow(
            reason: reason,
            onTap: () {
              ref
                  .read(disputeDraftProvider.notifier)
                  .initDraft(
                    reservationId: reservationId,
                    bookingReference: refCode,
                    hotel: hotel,
                    window: window,
                  );
              ref.read(disputeDraftProvider.notifier).setReason(reason);
              context.push(AppRoutes.disputeDetailPath(reservationId));
            },
          ),
      ],
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.reason, required this.onTap});

  final DisputeReason reason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: colors.checkInStepPanel,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.checkInRingPanel,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  reason.icon,
                  size: 14,
                  color: colors.brandOnSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reason.title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 13,
                        fontWeight: TypeScale.bold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason.subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                AppIcons.chevronRight,
                size: 16,
                color: colors.brandOnSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DisputeReason {
  IconData get icon => switch (this) {
    DisputeReason.notAsBooked => AppIcons.alertTriangle,
    DisputeReason.couldNotGetIn => AppIcons.doorEnter,
    DisputeReason.wrongAmount => AppIcons.receipt,
    DisputeReason.somethingElse => AppIcons.messageCircle,
  };
}
