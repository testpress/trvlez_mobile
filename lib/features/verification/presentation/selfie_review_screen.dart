import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'verification_notifier.dart';

class SelfieReviewScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const SelfieReviewScreen({super.key, required this.notifier});

  @override
  State<SelfieReviewScreen> createState() => SelfieReviewScreenState();
}

class SelfieReviewScreenState extends State<SelfieReviewScreen> {
  VideoPlayerController? videoController;
  bool isPlaying = false;
  bool isUploadingLocally = false;

  @override
  void initState() {
    super.initState();
    final videoFile = widget.notifier.capturedVideo;
    if (videoFile != null) {
      initializeVideo(videoFile);
    }
  }

  Future<void> initializeVideo(File videoFile) async {
    videoController = VideoPlayerController.file(videoFile);
    await videoController!.initialize();
    await videoController!.setLooping(true);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (videoController == null) return;

    if (videoController!.value.isPlaying) {
      videoController!.pause();
      setState(() => isPlaying = false);
    } else {
      videoController!.play();
      setState(() => isPlaying = true);
    }
  }

  Future<void> handleUpload() async {
    if (isUploadingLocally) return;
    setState(() => isUploadingLocally = true);
    await widget.notifier.uploadSelfie();

    if (!mounted) return;
    setState(() => isUploadingLocally = false);

    final phase = widget.notifier.phase;

    if (phase == VerificationPhase.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.notifier.errorMessage ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Upload succeeded — show confirmation summary before navigating
    if (!mounted) return;
    showUploadSuccessSheet(phase);
  }

  void showUploadSuccessSheet(VerificationPhase phase) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return UploadSuccessSheet(
          phase: phase,
          onViewStatus: () {
            Navigator.of(sheetContext).pop();
            // Proceed to the NFC step
            context.go('/verification/nfc-intro');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Review Video'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: ListenableBuilder(
        listenable: widget.notifier,
        builder: (context, _) {
          final phase = widget.notifier.phase;
          final isUploading = phase == VerificationPhase.uploading;
          final isSubmitting = phase == VerificationPhase.submitting;
          final isBusy = isUploading || isSubmitting;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (videoController != null &&
                  videoController!.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: GestureDetector(
                      onTap: togglePlay,
                      child: VideoPlayer(videoController!),
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              if (videoController != null && !isPlaying && !isBusy)
                Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: togglePlay,
                  ),
                ),

              if (isBusy)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          isSubmitting
                              ? 'Submitting for verification...'
                              : 'Uploading... ${(widget.notifier.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        if (isSubmitting) ...[
                          const SizedBox(height: 8),
                          Text(
                            'This may take a moment',
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              if (!isBusy)
                Positioned(
                  bottom: 32,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            widget.notifier.clearVideo();
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          child: const Text('Retake'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: handleUpload,
                          child: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Upload Success Confirmation Sheet ────────────────────────────────────

class UploadSuccessSheet extends StatelessWidget {
  final VerificationPhase phase;
  final VoidCallback onViewStatus;

  const UploadSuccessSheet({required this.phase, required this.onViewStatus});

  @override
  Widget build(BuildContext context) {
    final isAlreadyVerified = phase == VerificationPhase.verified;
    final hasFailed = phase == VerificationPhase.verificationFailed;

    final String title;
    final String message;
    final IconData icon;
    final Color iconColor;

    if (isAlreadyVerified) {
      title = 'Verification Complete!';
      message =
          'Your identity has been verified successfully. You\'re all set to start exploring.';
      icon = Icons.verified_rounded;
      iconColor = const Color(0xFF27AE60);
    } else if (hasFailed) {
      title = 'Verification Unsuccessful';
      message =
          'We couldn\'t verify your identity at this time. Please review your documents and try again.';
      icon = Icons.error_outline_rounded;
      iconColor = const Color(0xFFE65100);
    } else {
      title = 'Documents Uploaded!';
      message =
          'Your documents have been uploaded successfully. Your verification is now in progress — you can track the status on the next screen.';
      icon = Icons.cloud_done_rounded;
      iconColor = const Color(0xFF0277BD);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(40),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onViewStatus,
              icon: Icon(
                isAlreadyVerified
                    ? Icons.explore_rounded
                    : Icons.visibility_rounded,
              ),
              label: Text(
                isAlreadyVerified
                    ? 'Start Exploring'
                    : 'Continue to Passport Scan',
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
