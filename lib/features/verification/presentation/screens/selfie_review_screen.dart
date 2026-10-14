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
/// Features video playback within an ergonomic face oval, scrub track, and upload/re-record actions.
class SelfieReviewScreen extends ConsumerStatefulWidget {
  const SelfieReviewScreen({super.key});

  @override
  ConsumerState<SelfieReviewScreen> createState() => _SelfieReviewScreenState();
}

class _SelfieReviewScreenState extends ConsumerState<SelfieReviewScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  static const double kReviewWidth = 210.0;
  static const double kReviewHeight = 280.0;

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
      controller.addListener(_onVideoUpdate);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final isPlaying = _videoController?.value.isPlaying ?? false;
    if (_isPlaying != isPlaying) {
      setState(() => _isPlaying = isPlaying);
    } else {
      // Re-render for smooth progress bar update during playback
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = _videoController;
    final notifier = ref.read(verificationNotifierProvider.notifier);

    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? const Duration(seconds: 10);
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final seconds = position.inSeconds.clamp(0, 59);
    final timeStr = '0:${seconds.toString().padLeft(2, '0')}';

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
          'Watch it back before you upload. Make sure your face is clearly visible, well-lit, and centered throughout.',
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer halo matching capture aesthetic
                      Container(
                        width: kReviewWidth + 14.0,
                        height: kReviewHeight + 14.0,
                        decoration: BoxDecoration(
                          color: colors.brandOnSurface.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(
                              (kReviewWidth + 14.0) / 2,
                              (kReviewHeight + 14.0) / 2,
                            ),
                          ),
                        ),
                      ),
                      // Clipped oval video player with cover fit
                      ClipOval(
                        child: SizedBox(
                          width: kReviewWidth,
                          height: kReviewHeight,
                          child:
                              controller != null &&
                                  controller.value.isInitialized
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: controller.value.size.width > 0
                                        ? controller.value.size.width
                                        : kReviewWidth,
                                    height: controller.value.size.height > 0
                                        ? controller.value.size.height
                                        : kReviewHeight,
                                    child: VideoPlayer(controller),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/art/selfie_video.svg',
                                  width: kReviewWidth,
                                  height: kReviewHeight,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      // Play overlay button when paused
                      if (!_isPlaying)
                        Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.brandSurface.withValues(alpha: 0.7),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 32.0,
                            color: colors.brandOnSurface,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: TypeScale.semiBold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: Container(
                        width: 120.0,
                        height: 3.5,
                        color: colors.brandScrubTrack,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            color: colors.brandOnSurface,
                          ),
                        ),
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
