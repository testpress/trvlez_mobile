import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/findr_portfolio.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/hotel_referral_item.dart';

/// Interactive card component representing a hotel referral in lists and dashboard feeds.
class ReferralCard extends StatelessWidget {
  const ReferralCard({
    super.key,
    required this.referral,
    required this.onTap,
    this.showLocation = false,
  });

  final HotelReferralItem referral;
  final VoidCallback onTap;
  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return InkWell(
      onTap: onTap,
      borderRadius: shape.radiusControl,
      child: Container(
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
                    referral.hotelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                  if (showLocation) ...[
                    SizedBox(height: space.stackTight),
                    Text(
                      referral.location,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  SizedBox(height: space.stackTight),
                  Text(
                    referral.formattedWhen,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: space.inlineIconLabel),
            StatusPill(
              label: referral.statusLabel,
              state: switch (referral.state) {
                FindrRecommendationState.awaiting => StatusPillState.awaiting,
                FindrRecommendationState.confirmed => StatusPillState.confirmed,
                FindrRecommendationState.declined => StatusPillState.cancelled,
              },
            ),
          ],
        ),
      ),
    );
  }
}

