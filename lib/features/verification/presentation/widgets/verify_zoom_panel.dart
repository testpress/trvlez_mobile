import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Enlarged MRZ zoom card showing question and code lines zoom illustration.
class VerifyZoomPanel extends StatelessWidget {
  const VerifyZoomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 16.0,
                height: 16.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brandSecondary,
                ),
                child: Text(
                  '2',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: TypeScale.bold,
                    color: colors.brandActionLabel,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                'Code lines, enlarged',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: TypeScale.semiBold,
                  color: colors.brandOnSurface,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Can you read every character?',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: TypeScale.regular,
                    color: colors.brandSecondaryBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: SvgPicture.asset(
              'assets/art/mrz_zoom.svg',
              width: 220,
              height: 40,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}
