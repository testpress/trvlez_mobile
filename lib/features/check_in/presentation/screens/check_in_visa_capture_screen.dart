import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.2b: Document camera viewfinder for capturing the visa page.
class CheckInVisaCaptureScreen extends ConsumerStatefulWidget {
  const CheckInVisaCaptureScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  ConsumerState<CheckInVisaCaptureScreen> createState() =>
      _CheckInVisaCaptureScreenState();
}

class _CheckInVisaCaptureScreenState
    extends ConsumerState<CheckInVisaCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameraService = ref.read(cameraServiceProvider);
      _cameraController = await cameraService.initCamera(
        lensDirection: CameraLensDirection.back,
        resolution: ResolutionPreset.high,
        enableAudio: false,
      );

      final cam = _cameraController;
      if (cam != null && mounted) {
        try {
          await cam.setFocusMode(FocusMode.auto);
        } catch (_) {}
        try {
          await cam.setExposureMode(ExposureMode.auto);
        } catch (_) {}
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCameraReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    if (_isCapturing) return;

    String? photoPath;
    final cam = _cameraController;
    if (cam != null && cam.value.isInitialized) {
      setState(() => _isCapturing = true);
      try {
        final XFile file = await cam.takePicture();
        photoPath = file.path;
      } catch (_) {}
      if (mounted) setState(() => _isCapturing = false);
    }

    ref
        .read(checkInNotifierProvider(widget.reservationId).notifier)
        .setVisaSource(VisaSource.camera, photoPath);

    if (mounted) {
      context.pushReplacement(
        AppRoutes.checkInVisaReviewPath(widget.reservationId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return BrandVerifyScreen(
      title: 'Your visa',
      backgroundAsset: 'assets/art/bg_capture.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      foot: [
        BrandShutter(square: true, onPressed: _handleCapture),
        SizedBox(height: space.stackItem),
      ],
      children: [
        SizedBox(height: space.stackItem),
        Text(
          'Fit the visa in the frame',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          'All four edges, and both dates readable.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
          ),
        ),
        SizedBox(height: space.stackFormField),

        // Live camera feed or SVG illustration fallback
        Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: sizes.previewDocMaxHeight),
            decoration: BoxDecoration(
              color: colors.brandCardBackground,
              borderRadius: shape.radiusSurface,
              border: Border.all(
                color: colors.brandBorderSubtle,
                width: shape.borderMedium,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 1 / 1.05,
              child: _isCameraReady && _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : SvgPicture.asset(
                      'assets/art/camera_passport.svg',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        SizedBox(height: space.stackFormField),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.bulb,
              size: sizes.iconXs,
              color: colors.brandSecondary,
            ),
            SizedBox(width: space.inlineMicro),
            Flexible(
              child: Text(
                'No glare across the hologram',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: colors.brandSecondaryBody,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
