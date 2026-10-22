import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Card displaying the passport-verified legal name and re-verify workflow.
class VerifiedIdentityCard extends StatelessWidget {
  const VerifiedIdentityCard({
    super.key,
    required this.legalName,
    required this.onReverify,
  });

  final String legalName;
  final VoidCallback onReverify;

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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.inlineItem,
                        vertical: space.inlineMicro,
                      ),
                      decoration: BoxDecoration(
                        color: colors.feedbackSuccess.withAlpha(30),
                        borderRadius: shape.radiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: sizes.iconXs,
                            color: colors.feedbackSuccess,
                          ),
                          SizedBox(width: space.stackText),
                          Text(
                            'Verified',
                            style: text.labelSmall?.copyWith(
                              color: colors.feedbackSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Legal name row
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
                        legalName,
                        style: text.titleSmall?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.check,
                      size: sizes.iconXs + 2,
                      color: colors.feedbackSuccess,
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Re-verify row
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Changed your legal name?',
                            style: text.titleSmall?.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackText),
                          Text(
                            'Married, deed poll, new passport — re-scan to update it.',
                            style: text.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: space.inlineItem),
                    TextButton(
                      onPressed: onReverify,
                      child: Text(
                        'Re-verify',
                        style: text.labelLarge?.copyWith(
                          color: colors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackItem),

        // Privacy note
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.borderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.alertCircle,
                size: sizes.iconXs + 2,
                color: colors.textSecondary,
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Text(
                  'Your name comes from your passport and can\'t be typed. Your date of birth was checked once to confirm you\'re 18+, and is kept private.',
                  style: text.labelMedium?.copyWith(
                    height: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
