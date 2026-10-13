import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_info_card.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';

/// Instruction screen preparing the traveler for the selfie video recording.
///
/// Features a smile disc icon, clear instructions, and a security note explaining
/// that liveness verification is performed on proprietary systems without external AI.
class SelfieInstructionScreen extends StatelessWidget {
  const SelfieInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_selfie_intro.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 2, circleSize: 22.0),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 54.0,
            height: 54.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardIconBackground,
            ),
            child: Icon(
              AppIcons.moodSmile,
              size: 26.0,
              color: colors.brandOnSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Selfie check',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20.0,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "A few seconds of video, to confirm you're the person in the passport photo.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const BrandInfoCard(
          heading: 'Please make sure',
          borderRadius: 12.0,
          paddingVertical: 10.0,
          paddingHorizontal: 12.0,
          itemGap: 8.0,
          iconSize: 13.0,
          bullets: [
            BrandBullet(
              icon: AppIcons.bulb,
              text: "You're in a well-lit room, with light on your face",
            ),
            BrandBullet(
              icon: AppIcons.userCircle,
              text: 'Your whole face is inside the oval',
            ),
            BrandBullet(
              icon: AppIcons.eyeglassOff,
              text: 'No glasses, hat or face covering',
            ),
          ],
        ),
      ],
      foot: [
        AppButton(
          label: "I'm ready",
          variant: AppButtonVariant.brandWhite,
          onPressed: () => context.push(AppRoutes.selfieCapture),
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
