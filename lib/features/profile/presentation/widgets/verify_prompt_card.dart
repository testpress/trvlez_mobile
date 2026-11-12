import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Prompt card encouraging unverified travelers to complete KYC identity verification.
class VerifyPromptCard extends StatelessWidget {
  const VerifyPromptCard({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
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
      padding: space.insetCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: sizes.iconFeature,
              height: sizes.iconFeature,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.redTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.id,
                size: sizes.iconMd,
                color: colors.brandPrimary,
              ),
            ),
          ),
          SizedBox(height: space.stackItem),
          Text(
            'Verify your identity',
            textAlign: TextAlign.center,
            style: context.text.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            'One check unlocks booking, ezMoney and faster hotel check-in. '
            'Takes about two minutes, and you never repeat it.',
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: space.stackFormField),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.brandPrimary,
              foregroundColor: colors.textOnAction,
              elevation: 0,
              minimumSize: Size.fromHeight(sizes.controlMd),
              shape: RoundedRectangleBorder(borderRadius: shape.radiusPill),
            ),
            child: Text(
              'Start verification',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
