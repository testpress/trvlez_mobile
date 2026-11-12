import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Translucent callout highlighting destination-specific requirements.
class CheckInFlagCallout extends StatelessWidget {
  const CheckInFlagCallout({
    super.key,
    required this.icon,
    required this.lead,
    required this.body,
    this.marginTop,
    this.centreIcon = false,
  });

  final IconData icon;
  final String lead;
  final String body;
  final double? marginTop;
  final bool centreIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      margin: EdgeInsets.only(top: marginTop ?? space.stackTight),
      padding: space.insetCardCompact,
      decoration: BoxDecoration(
        color: colors.checkInFlagPanel,
        borderRadius: shape.radiusControl,
      ),
      child: Row(
        crossAxisAlignment: centreIcon
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: centreIcon ? 0 : shape.borderMedium),
            child: Icon(icon, size: sizes.iconXs, color: colors.brandSecondary),
          ),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: lead,
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.brandSecondary,
                      height: 1.35,
                    ),
                  ),
                  TextSpan(
                    text: body,
                    style: context.text.labelMedium?.copyWith(
                      color: colors.brandSecondaryBody,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
