import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Translucent callout highlighting destination-specific requirements.
class CheckInFlagCallout extends StatelessWidget {
  const CheckInFlagCallout({
    super.key,
    required this.icon,
    required this.lead,
    required this.body,
    this.marginTop = AppSpacing.sm + 4,
    this.centreIcon = false,
  });

  final IconData icon;
  final String lead;
  final String body;
  final double marginTop;
  final bool centreIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(top: marginTop),
      padding: EdgeInsets.all(
        centreIcon ? AppSpacing.sm + 1 : AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: colors.checkInFlagPanel,
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
      ),
      child: Row(
        crossAxisAlignment: centreIcon
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: centreIcon ? 0 : 1.5),
            child: Icon(icon, size: 14, color: colors.brandSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: lead,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: TypeScale.bold,
                      color: colors.brandSecondary,
                      height: 1.35,
                    ),
                  ),
                  TextSpan(
                    text: body,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: TypeScale.regular,
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
