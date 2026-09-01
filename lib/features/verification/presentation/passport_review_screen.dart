import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_workflow_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';
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
    final notifier = ref.read(verificationNotifierProvider.notifier);
    final image = state.capturedImage;

    if (image == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No passport photo captured.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.passportCapture),
                child: const Text('Capture Passport'),
              ),
            ],
          ),
        ),
      );
    }

    final hasError =
        state is VerificationStateError ||
        state is VerificationStatePassportQualityFailed ||
        state is VerificationStateMrzExtractionFailed;

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
        notifier.send(PassportCaptured(image));
        context.go(
          AppRoutes.verificationProcessing,
          extra: {'type': ProcessingType.passport},
        );
      },
      mediaChild: InteractiveViewer(
        child: Image.file(image, fit: BoxFit.contain),
      ),
    );
  }
}
