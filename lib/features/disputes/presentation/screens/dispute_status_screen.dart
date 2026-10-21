import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/disputes/presentation/providers/dispute_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.3d: Active dispute review and case withdrawal screen.
class DisputeStatusScreen extends ConsumerWidget {
  const DisputeStatusScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final disputes = ref.watch(disputesProvider);
    final dispute = disputes[reservationId];

    final hotel = dispute?.hotel ?? 'Hotel';
    final raisedText = dispute?.raisedAt.toLowerCase() ?? 'just now';

    return BrandVerifyScreen(
      title: 'Something wrong',
      backgroundAsset: 'assets/art/bg_checkin_steps.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Withdraw this',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            ref.read(disputesProvider.notifier).withdrawDispute(reservationId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Dispute withdrawn. Payment will be released to the hotel.',
                ),
              ),
            );
            context.pop();
          },
        ),
        const CheckInNotice(
          text:
              'Withdrawing releases your payment to the hotel and closes this. It cannot be reopened.',
        ),
      ],
      children: [
        SizedBox(height: space.stackSection),
        Text(
          'Payment on hold',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          '$hotel · raised $raisedText',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),

        CheckInFlagCallout(
          icon: AppIcons.clock,
          lead: "We're looking into it. ",
          body:
              'Your payment stays with us until this is closed. We will email you before anything changes.',
          marginTop: space.stackFormField,
        ),
        SizedBox(height: space.stackFormField),

        _StatusDetailRow(
          label: 'Reason',
          value: (dispute?.reason ?? DisputeReason.somethingElse).title,
        ),
        if (dispute != null && dispute.words.trim().isNotEmpty)
          _StatusDetailRow(label: 'You said', value: dispute.words.trim()),
        if (dispute != null && dispute.photoCount > 0)
          _StatusDetailRow(
            label: 'Photos',
            value: '${dispute.photoCount} attached',
          ),
        _StatusDetailRow(
          label: 'Booking',
          value: dispute?.bookingReference ?? reservationId,
          last: true,
        ),
      ],
    );
  }
}

class _StatusDetailRow extends StatelessWidget {
  const _StatusDetailRow({
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
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return Container(
      padding: EdgeInsets.symmetric(vertical: space.stackItem),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.checkInPassRef,
                  width: shape.borderDefault,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: sizes.thumbPhotoSm,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondarySmall,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: TypeScale.bold,
                color: colors.brandOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
