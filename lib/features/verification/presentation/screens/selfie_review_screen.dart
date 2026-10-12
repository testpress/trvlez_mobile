import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/kyc_progress_stepper.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/state/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/shared_review_scaffold.dart';
import 'package:video_player/video_player.dart';

/// Displays the captured selfie video for the traveler to review
/// before uploading.
///
/// Uses the shared KYC review layout (light theme, card, stepper).
/// On upload, fires the upload and navigates to [VerificationProcessingScreen].
class SelfieReviewScreen extends ConsumerStatefulWidget {
  const SelfieReviewScreen({super.key});

  @override
  ConsumerState<SelfieReviewScreen> createState() => SelfieReviewScreenState();
}

class SelfieReviewScreenState extends ConsumerState<SelfieReviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoFile = ref.read(verificationNotifierProvider).capturedVideo;
      if (videoFile != null) {
        _initializeVideo(videoFile);
      }
    });
  }

  Future<void> _initializeVideo(File videoFile) async {
    _videoController = VideoPlayerController.file(videoFile);
    await _videoController!.initialize();
    await _videoController!.setLooping(true);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (_videoController == null) return;

    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() => _isPlaying = false);
    } else {
      _videoController!.play();
      setState(() => _isPlaying = true);
    }
  }

  void _handleUpload() {
    final notifier = ref.read(verificationNotifierProvider.notifier);
    // Fire-and-forget: the notifier manages the async state
    notifier.uploadSelfie();
    // Navigate to the dedicated processing experience
    context.go(
      AppRoutes.verificationProcessing,
      extra: {'type': ProcessingType.video},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationNotifierProvider);
    final notifier = ref.watch(verificationNotifierProvider.notifier);
    final phase = state.phase;

    final hasError =
        phase == VerificationPhase.error ||
        phase == VerificationPhase.videoQualityFailed;

    return SharedReviewScaffold(
      title: 'Review Your Video',
      subtitle: 'Make sure your face is clearly visible throughout.',
      kycStepIndex: 2,
      stepper: const KycProgressStepper(progressIndex: 2),
      errorMessage: hasError ? state.errorMessage : null,
      uploadText: hasError ? 'Retry Upload' : 'Upload',
      onRetake: () {
        notifier.clearVideo();
        context.go(AppRoutes.selfieCapture);
      },
      onUpload: _handleUpload,
      mediaChild: _buildVideoPreview(),
    );
  }

  Widget _buildVideoPreview() {
    final isReady =
        _videoController != null && _videoController!.value.isInitialized;

    if (!isReady) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: GestureDetector(
        onTap: _togglePlayback,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            if (!_isPlaying)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
