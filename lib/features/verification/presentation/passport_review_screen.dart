import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/shared_review_scaffold.dart';

class PassportReviewScreen extends StatelessWidget {
  final VerificationNotifier notifier;

  const PassportReviewScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final image = notifier.capturedImage;
        final status = notifier.status;
        final progress = notifier.uploadProgress;
        final error = notifier.errorMessage;

        if (image == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Review Passport')),
            body: const Center(child: Text('No image captured')),
          );
        }

        final theme = Theme.of(context);

        Widget? successOverlay;
        if (status == VerificationStatus.success) {
          successOverlay = Container(
            color: Colors.black.withAlpha(200),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Passport Uploaded!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review your extracted details next.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      context.go(AppRoutes.mrzReview);
                    },
                    child: const Text('Review Details'),
                  ),
                ],
              ),
            ),
          );
        }

        return SharedReviewScaffold(
          title: 'Review',
          isBusy: status == VerificationStatus.uploading,
          busyText: notifier.phase == VerificationPhase.extractingMrz
              ? 'Extracting Passport Data...'
              : 'Uploading Passport...',
          progress: progress,
          overlay: successOverlay,
          errorMessage: status == VerificationStatus.error ? error : null,
          onRetake: () {
            notifier.clearImage();
            context.go(AppRoutes.passportCapture);
          },
          onUpload: () => notifier.uploadPassport(),
          uploadText: status == VerificationStatus.error ? 'Retry Upload' : 'Upload',
          child: InteractiveViewer(child: Image.file(image, fit: BoxFit.contain)),
        );
      },
    );
  }
}
