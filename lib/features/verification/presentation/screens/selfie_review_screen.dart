import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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

  static const double kReviewWidth = 196.0;
  static const double kReviewHeight = 260.0;

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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final controller = _videoController;
    final notifier = ref.read(verificationNotifierProvider.notifier);

    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? const Duration(seconds: 10);
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final durationSeconds = duration.inSeconds.clamp(0, 59);
    final positionSeconds = position.inSeconds.clamp(0, 59);
    final displaySeconds = _isPlaying ? positionSeconds : durationSeconds;
    final timeStr = '0:${displaySeconds.toString().padLeft(2, '0')}';

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpPrefix: 'Having difficulties? ',
      helpLinkText: "Tell us what's wrong",
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 2),
        SizedBox(height: space.stackItem),
        Text(
          'Check your video',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'Watch it back before you upload. Make sure your face is clearly visible, well-lit, and centered throughout.',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        SizedBox(height: space.stackItem),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            space.insetScreen.left,
            space.stackItem,
            space.insetScreen.left,
            space.stackItem,
          ),
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: shape.radiusSurface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _togglePlayback,
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(
                    (kReviewWidth + 12.0) / 2,
                    (kReviewHeight + 12.0) / 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer subtle halo ring matching capture aesthetic
                    Container(
                      width: kReviewWidth + 12.0,
                      height: kReviewHeight + 12.0,
                      decoration: BoxDecoration(
                        color: colors.brandOnSurface.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(
                            (kReviewWidth + 12.0) / 2,
                            (kReviewHeight + 12.0) / 2,
                          ),
                        ),
                        border: Border.all(
                          color: colors.brandOnSurface.withValues(alpha: 0.15),
                          width: shape.borderDefault,
                        ),
                      ),
                    ),
                    // Clipped oval video player or placeholder
                    ClipOval(
                      child: SizedBox(
                        width: kReviewWidth,
                        height: kReviewHeight,
                        child:
                            controller != null && controller.value.isInitialized
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
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    // Play overlay button with white circle and red play icon
                    if (!_isPlaying)
                      Container(
                        width: sizes.controlLg,
                        height: sizes.controlLg,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.brandOnSurface,
                          boxShadow: [
                            BoxShadow(
                              color: colors.cardShadow.withValues(alpha: 0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: sizes.iconFeature,
                          color: colors.brandSurface,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: space.stackItem),
              Row(
                children: [
                  Text(
                    timeStr,
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.brandOnSurface,
                    ),
                  ),
                  SizedBox(width: space.inlineItem),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: shape.radiusSubtle,
                      child: Container(
                        height: sizes.indicatorProgressHeight,
                        color: colors.brandOnSurface.withValues(alpha: 0.25),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(color: colors.brandOnSurface),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: space.inlineItem),
                  Text(
                    _isPlaying ? 'Tap to pause' : 'Tap to play',
                    style: context.text.bodySmall?.copyWith(
                      color: colors.brandSecondaryBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Looks good, upload',
          variant: AppButtonVariant.brandWhite,
          height: sizes.controlLg,
          onPressed: () {
            notifier.uploadSelfie();
            context.pushReplacement(AppRoutes.selfieProcessing);
          },
        ),
        SizedBox(height: space.stackFormField),
        AppButton(
          label: 'Record again',
          variant: AppButtonVariant.brandOutline,
          height: sizes.controlLg,
          onPressed: () {
            notifier.clearVideo();
            context.pushReplacement(AppRoutes.selfieCapture);
          },
        ),
        SizedBox(height: space.stackFormField),
        const BrandSecurityNote(text: 'Nothing is sent until you tap upload.'),
      ],
    );
  }
}
