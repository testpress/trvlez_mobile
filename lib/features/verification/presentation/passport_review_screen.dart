import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/app/routes.dart';
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
          // Fallback if no image is captured somehow
          return Scaffold(
            appBar: AppBar(title: const Text('Review Passport')),
            body: const Center(child: Text('No image captured')),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Review', style: TextStyle(color: Colors.white)),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Captured Image
              InteractiveViewer(child: Image.file(image, fit: BoxFit.contain)),

              // Overlay for Upload Status
              if (status == VerificationStatus.uploading)
                Container(
                  color: Colors.black.withAlpha(180),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 24),
                        Text(
                          notifier.phase == VerificationPhase.extractingMrz
                              ? 'Extracting Passport Data...'
                              : 'Uploading Passport...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress > 0 ? progress : null,
                              minHeight: 8,
                              backgroundColor: Colors.white.withAlpha(50),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Success Overlay
              if (status == VerificationStatus.success)
                Container(
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
                            // Navigate to MRZ review screen
                            context.go(AppRoutes.mrzReview);
                          },
                          child: const Text('Review Details'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Actions (Hidden during upload)
              if (status == VerificationStatus.idle ||
                  status == VerificationStatus.error)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom + 24,
                      left: 24,
                      right: 24,
                      top: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(200),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  notifier.clearImage();
                                  context.go(AppRoutes.passportCapture);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Retake'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => notifier.uploadPassport(),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  status == VerificationStatus.error
                                      ? 'Retry Upload'
                                      : 'Upload',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
