import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final sizes = context.sizes;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_selfie_intro.svg',
      title: 'Verification',
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 2),
        const Spacer(),
        Center(
          child: Container(
            width: sizes.avatarXl,
            height: sizes.avatarXl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.brandCardIconBackground,
            ),
            child: Icon(
              AppIcons.moodSmile,
              size: sizes.iconFeature,
              color: colors.brandOnSurface,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Selfie check',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          "A few seconds of video, to confirm you're the person in the passport photo.",
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 2),
        BrandInfoCard(
          heading: 'Please make sure',
          headingStyle: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.brandOnSurface,
          ),
          iconSize: sizes.iconSm,
          itemGap: space.stackTight,
          bullets: const [
            BrandBullet(
              icon: AppIcons.userCircle,
              text: 'Look directly at the camera with face centered',
            ),
            BrandBullet(
              icon: AppIcons.eye,
              text: 'Blink naturally during the recording',
            ),
            BrandBullet(
              icon: AppIcons.rotate,
              text: 'Slowly turn your head a little left and right',
            ),
            BrandBullet(
              icon: AppIcons.bulb,
              text: "You're in a well-lit room, with light on your face",
            ),
            BrandBullet(
              icon: AppIcons.eyeglassOff,
              text: 'No glasses, hat or face covering',
            ),
          ],
        ),
        const Spacer(),
      ],
      foot: [
        AppButton(
          label: "I'm ready",
          variant: AppButtonVariant.brandWhite,
          height: sizes.controlLg,
          onPressed: () => context.push(AppRoutes.selfieCapture),
        ),
        SizedBox(height: space.stackFormField),
        const BrandSecurityNote(
          text: 'Checked on our own systems.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
