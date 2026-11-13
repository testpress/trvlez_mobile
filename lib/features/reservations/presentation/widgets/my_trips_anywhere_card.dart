import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/anywhere/domain/entities/anywhere_stay.dart';

/// Card displaying off-platform "Check-in Anywhere" stays.
class MyTripsAnywhereCard extends StatelessWidget {
  const MyTripsAnywhereCard({super.key, required this.stay});

  final AnywhereStay stay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final (pillLabel, pillState) = switch (stay.status) {
      AnywhereStatus.sent => ('Sent to hotel', StatusPillState.awaiting),
      AnywhereStatus.noted => ('Noted by hotel', StatusPillState.confirmed),
      AnywhereStatus.desk => ('Check-in at desk', StatusPillState.completed),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.cardBorderSoft,
          width: shape.borderDefault,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sizes.avatarMd,
                height: sizes.avatarMd,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.globe,
                    size: sizes.iconSm,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stay.hotel,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: space.stackText),
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: sizes.iconXs,
                          color: colors.inkTertiary,
                        ),
                        SizedBox(width: space.inlineMicro),
                        Expanded(
                          child: Text(
                            stay.place,
                            style: context.text.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              StatusPill(label: pillLabel, state: pillState),
            ],
          ),
          Divider(height: space.stackFormField),
          Row(
            children: [
              Icon(
                AppIcons.calendar,
                size: sizes.iconXs,
                color: colors.brandPrimary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Text(
                stay.dates,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${stay.guests} guest${stay.guests > 1 ? 's' : ''}',
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackTight),
          Row(
            children: [
              Icon(
                stay.route == AnywhereRoute.byEmail
                    ? AppIcons.mail
                    : AppIcons.shieldCheck,
                size: sizes.iconXs,
                color: colors.inkTertiary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  stay.route == AnywhereRoute.byEmail
                      ? 'Delivered to ${stay.hotelEmail}'
                      : 'TRVLez connected direct check-in',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackItem),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: space.inlineIconLabel,
              vertical: space.stackTight,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: shape.radiusControlSm,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.info,
                  size: sizes.iconXs,
                  color: colors.inkTertiary,
                ),
                SizedBox(width: space.inlineIconLabel),
                Expanded(
                  child: Text(
                    'Check-in Anywhere pass · Show passport upon arrival',
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
