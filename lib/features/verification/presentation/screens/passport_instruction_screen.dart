import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_info_card.dart';
import 'package:trvlez_mobile/core/widgets/brand_pointer_pair.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';

/// Instruction screen guiding the user on how to take an acceptable passport photo.
///
/// Promotes the MRZ code lines to half the visual explanation with numbered
/// pointers (1 & 2) and clear guidance bullets to prevent common retake loops.
class PassportInstructionScreen extends StatelessWidget {
  const PassportInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_howto.svg',
      title: 'Verification',
      isScrollable: false,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.verificationLanding);
        }
      },
      body: [
        const VerificationStepper(current: 0),
        const Spacer(flex: 1),
        Text(
          'Passport photo',
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          'We need both of these. Most retakes happen because the bottom two lines were cut off.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.3,
          ),
        ),
        const Spacer(flex: 1),
        Flexible(
          flex: 6,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: sizes.thumbPhotoMd,
              ),
              child: SvgPicture.asset(
                'assets/art/passport_diagram.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
        BrandPointerPair(
          padding: space.insetCardCompact,
          badgeSize: sizes.iconSm,
          gapBadgeToTitle: space.stackTight,
          gapTitleToDescription: space.stackText,
          titleStyle: context.text.labelLarge?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
          ),
          descriptionStyle: context.text.labelSmall?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.25,
          ),
          items: const [
            ('1', 'Photo page', 'Your picture and details, sharp'),
            ('2', 'Code lines', 'Every character, nothing cropped'),
          ],
        ),
        const Spacer(flex: 1),
        BrandInfoCard(
          paddingVertical: space.stackTight,
          paddingHorizontal: space.insetCardCompact.left,
          itemGap: space.stackText,
          iconSize: sizes.iconXs,
          textStyle: context.text.labelSmall?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.2,
          ),
          bullets: const [
            BrandBullet(
              icon: AppIcons.bulb,
              text: 'Well lit, no glare or flash reflection',
            ),
            BrandBullet(
              icon: AppIcons.crop,
              text: 'All four corners of the page inside the frame',
            ),
            BrandBullet(
              icon: AppIcons.handStop,
              text: 'No fingers or shadows across either part',
            ),
          ],
        ),
        const Spacer(flex: 1),
      ],
      foot: [
        AppButton(
          label: 'Open camera',
          variant: AppButtonVariant.brandWhite,
          height: sizes.controlLg,
          onPressed: () => context.push(AppRoutes.passportCapture),
        ),
        SizedBox(height: space.stackFormField),
        const BrandSecurityNote(
          text:
              'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
        ),
      ],
    );
  }
}
