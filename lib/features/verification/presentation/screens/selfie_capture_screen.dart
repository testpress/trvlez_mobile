import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
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

  (IconData, String) get _captureGuidance {
    if (!_isRecording) {
      return (AppIcons.moodSmile, 'Please look directly into the camera');
    }
    if (_elapsed < 3) {
      return (AppIcons.userCircle, 'Look directly into the camera');
    } else if (_elapsed < 6) {
      return (AppIcons.eye, 'Blink naturally — do not stare');
    } else {
      return (AppIcons.rotate, 'Slowly turn your head a little left and right');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;
    final cam = _cameraController;
    final (guidanceIcon, guidanceText) = _captureGuidance;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpPrefix: 'Trouble with the camera? ',
      helpLinkText: "Tell us what's wrong",
      isScrollable: true,
      onBack: _isRecording ? null : () => context.pop(),
      body: [
        const VerificationStepper(current: 2),
        SizedBox(height: space.stackItem),
        Text(
          'Centre your face',
          textAlign: TextAlign.center,
          style: context.text.headlineLarge?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          'Hold still until the ring fills.',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        SizedBox(height: space.stackItem),
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
        if (_isRecording) ...[
          SizedBox(height: space.stackText),
          Center(
            child: VerifyRecordingTime(
              seconds: _elapsed.clamp(0, kSelfieSeconds),
            ),
          ),
        ],
        SizedBox(height: space.stackText),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              guidanceIcon,
              size: sizes.iconXs,
              color: colors.brandSecondary,
            ),
            SizedBox(width: space.inlineMicro),
            Flexible(
              child: Text(
                guidanceText,
                style: context.text.bodySmall?.copyWith(
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
      ],
    );
  }
}
