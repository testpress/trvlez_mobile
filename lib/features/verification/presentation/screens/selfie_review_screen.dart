import 'dart:io';

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
import 'package:video_player/video_player.dart';

/// Screen allowing the traveler to review their recorded selfie video prior to upload.
///
/// Features video playback within a 126x168 oval, scrub track, and upload/re-record actions.
class SelfieReviewScreen extends ConsumerStatefulWidget {
  const SelfieReviewScreen({super.key});

  @override
  ConsumerState<SelfieReviewScreen> createState() => _SelfieReviewScreenState();
}

class _SelfieReviewScreenState extends ConsumerState<SelfieReviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoFile = ref.read(verificationNotifierProvider).capturedVideo;
      if (videoFile != null) {
        _initVideo(videoFile);
      }
    });
  }

  Future<void> _initVideo(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(true);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      setState(() => _isPlaying = false);
    } else {
      controller.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _videoController;
    final notifier = ref.read(verificationNotifierProvider.notifier);

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 2, circleSize: 23.0),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Check your video',
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
          'Watch it back before you upload. Your face should stay inside the oval throughout.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
            height: 1.4,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _togglePlayback,
                  child: ClipOval(
                    child: SizedBox(
                      width: 126.0,
                      height: 168.0,
                      child:
                          controller != null && controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            )
                          : SvgPicture.asset(
                              'assets/art/selfie_video.svg',
                              width: 126.0,
                              height: 168.0,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '0:10',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 96.0,
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: colors.brandScrubTrack,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _isPlaying ? 'Tap to pause' : 'Tap to play',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 10.5,
                        fontWeight: TypeScale.regular,
                        color: colors.brandSecondaryBody,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Looks good, upload',
          variant: AppButtonVariant.brandWhite,
          onPressed: () {
            notifier.uploadSelfie();
            context.pushReplacement(AppRoutes.selfieProcessing);
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Record again',
          variant: AppButtonVariant.brandOutline,
          onPressed: () {
            notifier.clearVideo();
            context.pushReplacement(AppRoutes.selfieCapture);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        const BrandSecurityNote(text: 'Nothing is sent until you tap upload.'),
      ],
    );
  }
}
