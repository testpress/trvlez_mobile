import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Screen allowing the traveler to inspect their captured passport photo before transmission.
///
/// Ensures both the photo page and MRZ code lines are sharp, displaying an enlarged
/// MRZ zoom panel to prevent common retakes.
class PassportReviewScreen extends ConsumerWidget {
  const PassportReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final capturedImage = state.capturedImage;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_howto.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        VerificationStepper(current: 0, circleSize: sizes.iconDefault),
        SizedBox(height: space.stackFormField),
        Text(
          'Check your photo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 20.0,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'Both parts need to be sharp. Look closely before you upload.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
          ),
        ),
        SizedBox(height: space.stackSection),
        Center(
          child: Container(
            padding: EdgeInsets.all(space.inlineMicro),
            decoration: BoxDecoration(
              color: colors.brandShotBackdrop,
              borderRadius: shape.radiusControl,
            ),
            child: ClipRRect(
              borderRadius: shape.radiusControlSm,
              child: SizedBox(
                width: sizes.previewDocWidth,
                height: sizes.previewDocHeight,
                child: capturedImage != null
                    ? Image.file(capturedImage, fit: BoxFit.contain)
                    : SvgPicture.asset(
                        'assets/art/passport_shot.svg',
                        width: sizes.previewDocWidth,
                        height: sizes.previewDocHeight,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: space.stackFormField),
        VerifyZoomPanel(mrzImage: state.mrzImage, mrzLines: state.mrzLines),
      ],
      foot: [
        AppButton(
          label: 'Looks good, upload',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            notifier.uploadPassport();
            context.pushReplacement(AppRoutes.passportProcessing);
          },
        ),
        SizedBox(height: space.stackItem),
        AppButton(
          label: 'Retake photo',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            notifier.clearImage();
            context.pushReplacement(AppRoutes.passportCapture);
          },
        ),
        SizedBox(height: space.stackFormField),
        const BrandSecurityNote(text: 'Nothing is sent until you tap upload.'),
      ],
    );
  }
}
