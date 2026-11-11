import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final capturedImage = state.capturedImage;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_howto.svg',
      title: 'Verification',
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 0),
        SizedBox(height: space.stackItem),
        Text(
          'Check your photo',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'Both parts need to be sharp. Look closely before you upload.',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        SizedBox(height: space.stackItem),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: shape.radiusSurface,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: shape.radiusControl,
                child: capturedImage != null
                    ? Image.file(
                        capturedImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(
                              'assets/art/passport_shot.svg',
                              fit: BoxFit.contain,
                            ),
                      )
                    : SvgPicture.asset(
                        'assets/art/passport_shot.svg',
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: space.stackItem),
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
        SizedBox(height: space.stackItem),
        const BrandSecurityNote(text: 'Nothing is sent until you tap upload.'),
      ],
    );
  }
}
