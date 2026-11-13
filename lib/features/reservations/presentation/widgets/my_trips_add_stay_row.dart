import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Row CTA prompting travelers to add an off-platform stay.
class MyTripsAddStayRow extends StatelessWidget {
  const MyTripsAddStayRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Material(
      color: colors.transparent,
      child: InkWell(
        borderRadius: shape.radiusSurface,
        onTap: onTap,
        child: Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.cardBorderSoft,
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: sizes.controlSm,
                height: sizes.controlSm,
                decoration: BoxDecoration(
                  color: colors.redTint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.plus,
                    size: sizes.iconSm,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in Anywhere',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      'Staying at a hotel not on TRVLez? Check in online here.',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Icon(
                AppIcons.chevronRight,
                size: sizes.iconSm,
                color: colors.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
