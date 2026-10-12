import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Instruction screen guiding the user on how to take an acceptable passport photo.
///
/// Promotes the MRZ code lines to half the visual explanation with numbered
/// pointers (1 & 2) and clear guidance bullets to prevent common retake loops.
class PassportInstructionScreen extends StatelessWidget {
  const PassportInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_howto.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.verificationLanding);
        }
      },
      body: [
        const VerificationStepper(current: 0, circleSize: 24.0),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Passport photo',
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
          'We need both of these. Most retakes happen because the bottom two lines were cut off.',
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
        Center(
          child: SvgPicture.asset(
            'assets/art/passport_diagram.svg',
            width: 170.0,
            height: 129.0,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const VerifyPointerPair(
          items: [
            ('1', 'Photo page', 'Your picture and details, sharp'),
            ('2', 'Code lines', 'Every character, nothing cropped'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const VerifyInfoCard(
          borderRadius: 13.0,
          paddingVertical: 11.0,
          paddingHorizontal: 12.0,
          itemGap: 8.0,
          iconSize: 13.0,
          bullets: [
            VerifyBullet(
              icon: AppIcons.bulb,
              text: 'Well lit, no glare or flash reflection',
            ),
            VerifyBullet(
              icon: AppIcons.crop,
              text: 'All four corners of the page inside the frame',
            ),
            VerifyBullet(
              icon: AppIcons.handStop,
              text: 'No fingers or shadows across either part',
            ),
          ],
        ),
      ],
      foot: [
        AppButton(
          label: 'Open camera',
          variant: AppButtonVariant.brandWhite,
          onPressed: () => context.push(AppRoutes.passportCapture),
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(
          text: 'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
