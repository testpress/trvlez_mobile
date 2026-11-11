import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_image_processor.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_framing_guide.dart';

/// Capture screen for the passport photo page.
///
/// Features an ICAO Doc 9303 TD3 (125mm x 88mm) framing guide with four corner guides
/// and dashed MRZ alignment box, live camera feed support with SVG fallback, and square shutter capture button.
class PassportCaptureScreen extends ConsumerStatefulWidget {
  const PassportCaptureScreen({super.key, required this.cameraService});

  final CameraService cameraService;

  @override
  ConsumerState<PassportCaptureScreen> createState() =>
      _PassportCaptureScreenState();
}

class _PassportCaptureScreenState extends ConsumerState<PassportCaptureScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _controller = await widget.cameraService.initCamera(
        lensDirection: CameraLensDirection.back,
        resolution: ResolutionPreset.high,
        enableAudio: false,
      );

      final cam = _controller;
      if (cam != null && mounted) {
        try {
          await cam.setFocusMode(FocusMode.auto);
        } catch (_) {}
        try {
          await cam.setExposureMode(ExposureMode.auto);
        } catch (_) {}
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (_) {
      // Graceful fallback to SVG illustration if camera is unavailable in simulator/environment
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;

    setState(() => _isCapturing = true);
    try {
      final XFile file = await cam.takePicture();
      final viewportSize = _viewportSize;
      final frameRect = PassportFramingGuide.calculatePassportFrame(
        viewportSize,
      );

      // Compute effective preview aspect ratio matching the viewport orientation.
      // CameraController.value.aspectRatio is sensor width / sensor height (> 1.0).
      // In portrait mode (sw < sh), the effective preview aspect ratio is 1.0 / camAR.
      final camAR = cam.value.aspectRatio;
      final double previewAR =
          (viewportSize.width < viewportSize.height && camAR > 1.0)
          ? (1.0 / camAR)
          : camAR;

      final cropParams = PassportCropParams(
        imagePath: file.path,
        screenWidth: viewportSize.width,
        screenHeight: viewportSize.height,
        frameWidth: frameRect.width,
        frameHeight: frameRect.height,
        frameCenterX: frameRect.center.dx,
        frameCenterY: frameRect.center.dy,
        previewAspectRatio: previewAR,
      );

      // Immediately crop the captured photo to strictly the guidance frame
      // so that the surrounding table/background is discarded
      final croppedFile = await compute(
        cropAndOptimizePassportImage,
        cropParams.toMap(),
      );

      final passportFile = croppedFile ?? File(file.path);

      // Retrieve or generate the cropped MRZ region strip from the passport image
      final mrzPath = passportFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_mrz_cropped.jpg',
      );
      File? mrzFile = File(mrzPath);
      if (!mrzFile.existsSync()) {
        mrzFile = await compute<String, File?>(
          cropMrzRegionFromPath,
          passportFile.path,
        );
      }

      ref
          .read(verificationNotifierProvider.notifier)
          .setImage(passportFile, mrzImage: mrzFile);

      if (mounted) {
        context.push(AppRoutes.passportReview);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final cam = _controller;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_capture.svg',
      title: 'Verification',
      helpPrefix: 'Trouble with the camera? ',
      helpLinkText: "Tell us what's wrong",
      isScrollable: false,
      onBack: () => context.pop(),
      body: [
        const VerificationStepper(current: 0),
        SizedBox(height: space.stackItem),
        Text(
          'Fit the page in the frame',
          textAlign: TextAlign.center,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          'Both the photo page and the code lines.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        SizedBox(height: space.stackItem),
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: sizes.containerViewfinder),
              child: AspectRatio(
                aspectRatio: 1 / 1.05,
                child: ClipRRect(
                  borderRadius: shape.radiusControl,
                  child: Container(
                    color: colors.brandShotBackdrop.withValues(alpha: 0.35),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final viewportSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        _viewportSize = viewportSize;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_isCameraInitialized && cam != null)
                              Builder(
                                builder: (context) {
                                  final preview = cam.value.previewSize;
                                  final isPortrait =
                                      viewportSize.width < viewportSize.height;
                                  final previewWidth = preview != null
                                      ? (isPortrait
                                            ? preview.height
                                            : preview.width)
                                      : viewportSize.width;
                                  final previewHeight = preview != null
                                      ? (isPortrait
                                            ? preview.width
                                            : preview.height)
                                      : viewportSize.height;

                                  return ClipRect(
                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: previewWidth,
                                          height: previewHeight,
                                          child: CameraPreview(cam),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              SvgPicture.asset(
                                'assets/art/camera_passport.svg',
                                fit: BoxFit.cover,
                              ),
                            // Framing overlay guide with ICAO TD3 aspect ratio, corners, and dashed MRZ box
                            PassportFramingGuide(
                              viewportSize: viewportSize,
                              colors: colors,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: space.stackItem),
        Text(
          'Hold steady ~20 cm away',
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            color: colors.brandSecondaryBody,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Keep the dashed box over the bottom 2 lines of text',
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
          square: true,
          onPressed: _isCapturing ? null : _capturePhoto,
        ),
      ],
    );
  }
}
