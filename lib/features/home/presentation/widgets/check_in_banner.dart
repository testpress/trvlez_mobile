import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Callout banner displayed when an online check-in window is open.
class CheckInBanner extends StatelessWidget {
  const CheckInBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label: '$title. $subtitle. Tap to start check in.',
      child: Material(
        color: colors.transparent,
        child: InkWell(
          borderRadius: shape.radiusSurface,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: colors.cardBorderSoft,
                width: shape.borderDefault,
              ),
              borderRadius: shape.radiusSurface,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: shape.radiusSurface,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: shape.borderFocus,
                      color: colors.brandPrimary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: space.inlineItem,
                          vertical: space.stackItem,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: sizes.iconXl,
                              height: sizes.iconXl,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.redTint,
                                borderRadius: shape.radiusControl,
                              ),
                              child: Icon(
                                AppIcons.doorEnter,
                                size: sizes.iconSm,
                                color: colors.brandPrimary,
                              ),
                            ),
                            SizedBox(width: space.inlineIconLabel),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: space.stackText),
                                  Text(
                                    subtitle,
                                    style: context.text.bodySmall?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              AppIcons.chevronRight,
                              size: sizes.iconSm,
                              color: colors.brandPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
