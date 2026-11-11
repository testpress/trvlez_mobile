import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';

/// Opens the modal bottom sheet displaying complete referral and outreach metadata.
Future<void> showReferralDetailSheet(
  BuildContext context,
  HotelReferralItem item,
) {
  final colors = context.colors;
  final space = context.space;
  final shape = context.shape;
  final sizes = context.sizes;

  final email = item.targetEmail;
  final phone = item.targetPhone;
  final note = item.personalNote;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: sizes.containerForm),
          child: Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.page,
              borderRadius: shape.radiusOverlay,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: space.stackTight),
                      width: sizes.controlSm,
                      height: space.stackText,
                      decoration: BoxDecoration(
                        color: colors.line,
                        borderRadius: shape.radiusPill,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.hotelName,
                          style: context.text.titleMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: TypeScale.bold,
                          ),
                        ),
                      ),
                      StatusPill(
                        label: item.statusLabel,
                        state: switch (item.state) {
                          FindrRecommendationState.awaiting =>
                            StatusPillState.awaiting,
                          FindrRecommendationState.confirmed =>
                            StatusPillState.confirmed,
                          FindrRecommendationState.declined =>
                            StatusPillState.cancelled,
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: space.stackItem),
                  const Divider(height: 1),
                  SizedBox(height: space.stackItem),

                  _ReferralDetailRow(
                    label: 'Address',
                    value: item.fullAddress,
                    icon: AppIcons.building,
                  ),
                  SizedBox(height: space.stackItem),

                  if (email != null && email.isNotEmpty) ...[
                    _ReferralDetailRow(
                      label: 'Contact Email',
                      value: email,
                      icon: AppIcons.mail,
                    ),
                    SizedBox(height: space.stackItem),
                  ],

                  if (phone != null && phone.isNotEmpty) ...[
                    _ReferralDetailRow(
                      label: 'Contact Phone',
                      value: phone,
                      icon: AppIcons.phone,
                    ),
                    SizedBox(height: space.stackItem),
                  ],

                  _ReferralDetailRow(
                    label: 'Referred On',
                    value: item.formattedWhen,
                    icon: AppIcons.calendar,
                  ),
                  SizedBox(height: space.stackItem),

                  if (note != null && note.isNotEmpty) ...[
                    _ReferralDetailRow(
                      label: 'Personal Note',
                      value: note,
                      icon: AppIcons.fileText,
                    ),
                    SizedBox(height: space.stackItem),
                  ],

                  SizedBox(height: space.stackSection),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ReferralDetailRow extends StatelessWidget {
  const _ReferralDetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: sizes.iconSm, color: colors.textSecondary),
        SizedBox(width: space.inlineIconLabel),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: space.stackTight),
              Text(
                value,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: TypeScale.medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
