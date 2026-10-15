import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
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
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final capturedImage = state.capturedImage;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_passport_howto.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 0, circleSize: 24.0),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.xs),
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
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.brandShotBackdrop,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 200.0,
                height: 140.0,
                child: capturedImage != null
                    ? Image.file(
                        capturedImage,
                        fit: BoxFit.contain,
                      )
                    : SvgPicture.asset(
                        'assets/art/passport_shot.svg',
                        width: 196.0,
                        height: 122.0,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        VerifyZoomPanel(
          mrzImage: state.mrzImage,
          mrzLines: state.mrzLines,
        ),
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
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Retake photo',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            notifier.clearImage();
            context.pushReplacement(AppRoutes.passportCapture);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(text: 'Nothing is sent until you tap upload.'),
      ],
    );
  }
}
