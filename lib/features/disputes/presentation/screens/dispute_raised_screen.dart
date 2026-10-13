import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_big_ring.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/disputes/presentation/providers/dispute_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.3c: Confirmation that payment hold has been activated.
class DisputeRaisedScreen extends ConsumerWidget {
  const DisputeRaisedScreen({
    super.key,
    required this.reservationId,
  });

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final disputes = ref.watch(disputesProvider);
    final dispute = disputes[reservationId];
    final hotel = dispute?.hotel ?? 'your property';
    final bookingRef = dispute?.bookingReference ?? reservationId;

    return BrandVerifyScreen(
      title: 'Something wrong',
      backgroundAsset: 'assets/art/bg_checkin_flow.svg',
      helpArea: ProblemArea.checkIn,
      closeIcon: true,
      onBack: () => context.go(AppRoutes.bookings),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Back to my booking',
          variant: AppButtonVariant.brandWhite,
          onPressed: () => context.go(AppRoutes.bookings),
        ),
        const CheckInNotice(
          text:
              'Nothing is decided yet. We will email you as soon as there is an update.',
        ),
      ],
      children: [
        const SizedBox(height: AppSpacing.sm),
        const CheckInBigRing(icon: AppIcons.check),
        const SizedBox(height: AppSpacing.md),
        Text(
          "We've got it",
          textAlign: TextAlign.center,
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
          'Your payment for $hotel is on hold while we look into this.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _DisputeDetailRow(label: 'Booking', value: bookingRef),
        _DisputeDetailRow(
          label: 'Raised',
          value: dispute?.raisedAt ?? 'Just now',
          last: true,
        ),
      ],
    );
  }
}

class _DisputeDetailRow extends StatelessWidget {
  const _DisputeDetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(color: colors.checkInPassRef, width: 1),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colors.brandSecondarySmall,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.bold,
              color: colors.brandOnSurface,
            ),
          ),
        ],
      ),
    );
  }
}
