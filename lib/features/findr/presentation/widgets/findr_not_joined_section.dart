import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';

/// Pre-onboarding marketing and call-to-action section explaining the Findr programme.
class FindrNotJoinedSection extends StatelessWidget {
  const FindrNotJoinedSection({
    super.key,
    required this.onActivate,
  });

  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FindrCard(
          state: FindrState.notJoined,
          ctaLabel: 'Activate Findr',
          onCta: onActivate,
        ),
        SizedBox(height: space.stackSection),
        Text(
          'How it works',
          style: context.text.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: TypeScale.bold,
          ),
        ),
        SizedBox(height: space.stackItem),
        const _BenefitTile(
          icon: AppIcons.mapSearch,
          title: 'Recommend properties you rate',
          subtitle:
              'Share quality hotels you have experienced. We handle contact on your behalf.',
        ),
        const _BenefitTile(
          icon: AppIcons.clock,
          title: 'Dedicated human review',
          subtitle:
              'Every recommendation is checked by our team before approaching the property.',
        ),
        const _BenefitTile(
          icon: AppIcons.coin,
          title: 'Earn 5% TRVLez commission',
          subtitle:
              'Earn a share of commission on bookings made at your recommended hotel for 12 months.',
        ),
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final shape = context.shape;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackItem),
      child: Container(
        padding: space.insetCard,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: shape.radiusControl,
          border: Border.all(
            color: colors.borderSubtle,
            width: shape.borderDefault,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: sizes.iconXl,
              height: sizes.iconXl,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: shape.radiusControlSm,
              ),
              child: Icon(
                icon,
                size: sizes.iconSm,
                color: colors.brandPrimary,
              ),
            ),
            SizedBox(width: space.inlineIconLabel),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                  SizedBox(height: space.stackTight),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
