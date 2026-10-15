import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_parts.dart';

/// Capture screen for the traveler's selfie video liveness verification.
///
/// Features an ergonomic face oval with smooth progress ring, front camera feed,
/// elapsed timer counting up to 10 seconds, face alignment guidance, and round shutter control.
class SelfieCaptureScreen extends ConsumerStatefulWidget {
  const SelfieCaptureScreen({super.key, required this.cameraService});

  final CameraService cameraService;

  @override
  ConsumerState<SelfieCaptureScreen> createState() =>
      _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends ConsumerState<SelfieCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  int _elapsed = 0;
  double _progress = 0.0;
  Timer? _timer;

  static const int kSelfieSeconds = 10;
  static const double kOvalWidth = 224.0;
  static const double kOvalHeight = 296.0;

  @override
  void initState() {
    super.initState();
    _initFrontCamera();
  }

  Future<void> _initFrontCamera() async {
    try {
      _cameraController = await widget.cameraService.initCamera(
        lensDirection: CameraLensDirection.front,
        resolution: ResolutionPreset.high,
        enableAudio: false,
      );

      if (_cameraController != null && mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) return;

    try {
      await cam.startVideoRecording();
    } catch (_) {}

    setState(() {
      _isRecording = true;
      _elapsed = 0;
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.1 / kSelfieSeconds;
        if ((timer.tick % 10) == 0) {
          _elapsed++;
        }
      });

      if (_progress >= 1.0) {
        timer.cancel();
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    setState(() => _isRecording = false);

    final cam = _cameraController;
    File? videoFile;
    if (cam != null && cam.value.isRecordingVideo) {
      try {
        final XFile file = await cam.stopVideoRecording();
        videoFile = File(file.path);
      } catch (_) {}
    }

    if (mounted) {
      if (videoFile != null) {
        ref.read(verificationNotifierProvider.notifier).setVideo(videoFile);
      }
      context.pushReplacement(AppRoutes.selfieReview);
    }
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cam = _cameraController;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpLine: false,
      isScrollable: true,
      onBack: _isRecording ? null : () => context.pop(),
      body: [
        const VerificationStepper(current: 2, circleSize: 22.0),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _isRecording ? 'Keep still' : 'Centre your face',
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
          _isRecording
              ? 'Hold steady until the progress ring completes.'
              : 'Hold still until the ring fills.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12.0,
            fontWeight: TypeScale.regular,
            color: colors.brandSecondaryBody,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: VerifyFaceOval(
            width: kOvalWidth,
            height: kOvalHeight,
            progress: _progress.clamp(0.0, 1.0),
            previewChild: _isCameraInitialized && cam != null
                ? ClipRect(
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: cam.value.previewSize != null
                              ? cam.value.previewSize!.height
                              : kOvalWidth,
                          height: cam.value.previewSize != null
                              ? cam.value.previewSize!.width
                              : kOvalHeight,
                          child: CameraPreview(cam),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: VerifyRecordingTime(
            seconds: _elapsed.clamp(0, kSelfieSeconds),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? AppIcons.video : AppIcons.moodSmile,
              size: 14.0,
              color: colors.brandSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                _isRecording
                    ? 'Recording video... stay centered'
                    : 'Good lighting • Eye level • No accessories',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: TypeScale.regular,
                  color: colors.brandSecondaryBody,
                ),
              ),
            ),
          ],
        ),

      ],
      foot: [
        BrandShutter(
          square: false,
          recording: _isRecording,
          onPressed: _isRecording ? _stopRecording : _startRecording,
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: InkWell(
            onTap: () {
              context.push(
                AppRoutes.reportProblem,
                extra: const ProblemReportContext(
                  area: ProblemArea.verification,
                  screen: AppRoutes.selfieCapture,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.5,
                    color: colors.brandSecondaryBody,
                  ),
                  children: [
                    const TextSpan(text: 'Trouble with the camera? '),
                    TextSpan(
                      text: "Tell us what's wrong",
                      style: TextStyle(
                        color: colors.brandSecondary,
                        decoration: TextDecoration.underline,
                        fontWeight: TypeScale.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
