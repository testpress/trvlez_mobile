import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Card guiding travelers who have not yet verified their passport identity.
class UnverifiedIdentityCard extends StatelessWidget {
  const UnverifiedIdentityCard({super.key, required this.onStartVerify});

  final VoidCallback onStartVerify;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.borderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: space.insetCard.horizontal / 2,
                  vertical: space.stackItem,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(shape.radiusSurface.topLeft.x),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FROM YOUR PASSPORT',
                      style: text.labelSmall?.copyWith(
                        letterSpacing: 0.6,
                        color: colors.textSecondary,
                      ),
                    ),
                    Icon(
                      AppIcons.lock,
                      size: sizes.iconXs,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Locked legal name row
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: sizes.touchTargetMin * 2,
                      ),
                      child: Text(
                        'Legal name',
                        style: text.labelMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Add with your passport',
                        style: text.bodyMedium?.copyWith(
                          color: colors.textDisabled,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.lock,
                      size: sizes.iconXs,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackItem),

        // Locked Note with brand-tinted accent
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.brandPrimary.withAlpha(16),
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.brandPrimary.withAlpha(50),
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.alertCircle,
                size: sizes.iconXs + 2,
                color: colors.brandPrimary,
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Text(
                  'Your legal name comes straight from your passport chip. You can\'t type it in — and you won\'t need to.',
                  style: text.labelMedium?.copyWith(
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackSection),

        // Primary action button
        AppButton(
          label: 'Verify with your passport',
          icon: const Icon(AppIcons.idBadge2),
          onPressed: onStartVerify,
        ),
      ],
    );
  }
}
