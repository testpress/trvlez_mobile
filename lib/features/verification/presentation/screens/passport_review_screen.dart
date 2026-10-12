import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/state/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/shared_review_scaffold.dart';

/// Displays the captured passport image for the traveler to review
/// before uploading.
///
/// Uses the shared KYC review layout (light theme, card, stepper).
/// On upload, fires the upload and navigates to [VerificationProcessingScreen].
class PassportReviewScreen extends ConsumerWidget {
  const PassportReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.watch(verificationNotifierProvider.notifier);
    final image = state.capturedImage;
    final phase = state.phase;

    if (image == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('No image captured')),
      );
    }

    final hasError =
        phase == VerificationPhase.error ||
        phase == VerificationPhase.imageQualityFailed ||
        phase == VerificationPhase.mrzExtractionFailed;

    return SharedReviewScaffold(
      title: 'Review Your Passport',
      subtitle: 'Make sure all text and the photo are clearly visible.',
      kycStepIndex: 0,
      stepper: const KycProgressStepper(progressIndex: 0),
      errorMessage: hasError ? state.errorMessage : null,
      uploadText: hasError ? 'Retry Upload' : 'Upload',
      onRetake: () {
        notifier.clearImage();
        context.go(AppRoutes.passportCapture);
      },
      onUpload: () {
        // Fire-and-forget: the notifier manages the async state
        notifier.uploadPassport();
        // Navigate to the dedicated processing experience
        context.go(
          AppRoutes.verificationProcessing,
          extra: {'type': ProcessingType.passport},
        );
      },
      mediaChild: AspectRatio(
        aspectRatio: 125.0 / 88.0,
        child: InteractiveViewer(child: Image.file(image, fit: BoxFit.contain)),
      ),
    );
  }
}
