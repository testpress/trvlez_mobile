import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/camera_overlay_painter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/app/routes.dart';

/// Crops the passport region from the full camera capture.
///
/// In landscape mode the captured image already has the correct orientation,
/// so no rotation is needed. The result is encoded as high-quality JPEG
/// to preserve text sharpness for MRZ extraction while keeping file size
/// reasonable (~1-3 MB vs 10-20 MB for PNG).
Future<File?> processAndCropImage(Map<String, dynamic> params) async {
  final String imagePath = params['path'] as String;
  final double sw = params['sw'] as double;
  final double sh = params['sh'] as double;
  final double frameWidth = params['frameWidth'] as double;
  final double frameHeight = params['frameHeight'] as double;

  final bytes = File(imagePath).readAsBytesSync();
  img.Image? originalImage = img.decodeImage(bytes);

  if (originalImage != null) {
    originalImage = img.bakeOrientation(originalImage);

    final double iw = originalImage.width.toDouble();
    final double ih = originalImage.height.toDouble();

    final double scaleX = sw / iw;
    final double scaleY = sh / ih;

    final double frameCenterX = (params['frameCenterX'] as double?) ?? (sw / 2);
    final double cropCenterX = frameCenterX / scaleX;

    final double cropW = frameWidth / scaleX;
    final double cropH = frameHeight / scaleY;
    final double cropX = cropCenterX - (cropW / 2);
    final double cropY = (ih - cropH) / 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX.toInt().clamp(0, originalImage.width - 1),
      y: cropY.toInt().clamp(0, originalImage.height - 1),
      width: cropW.toInt().clamp(1, originalImage.width),
      height: cropH.toInt().clamp(1, originalImage.height),
    );

    // Encode as PNG — no rotation needed in landscape mode.
    final pngBytes = img.encodePng(croppedImage);
    final pngPath = imagePath.replaceAll(RegExp(r'\.[^.]+$'), '_cropped.png');
    final pngFile = File(pngPath)..writeAsBytesSync(pngBytes);
    return pngFile;
  }
  return null;
}

class PassportCaptureScreen extends ConsumerStatefulWidget {
  final CameraService cameraService;

  const PassportCaptureScreen({super.key, required this.cameraService});

  @override
  ConsumerState<PassportCaptureScreen> createState() =>
      PassportCaptureScreenState();
}

class PassportCaptureScreenState extends ConsumerState<PassportCaptureScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;
  bool isCapturing = false;
  FlashMode currentFlashMode = FlashMode.off;
  String? captureStatusMessage;

  /// ICAO 9303 TD3 passport data page: 125 mm × 88 mm → ratio ≈ 1.42.
  static const double _passportAspectRatio = 125.0 / 88.0;

  @override
  void initState() {
    super.initState();
    _initOrientationAndCamera();
  }

  Future<void> _initOrientationAndCamera() async {
    // Lock to landscape for natural passport framing — eliminates the need
    // to rotate the captured image, which previously degraded MRZ text quality.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      controller = await widget.cameraService.initCamera(
        lensDirection: CameraLensDirection.back,
        resolution: ResolutionPreset.max,
        enableAudio: false,
      );

      if (controller != null) {
        // Configure autofocus and exposure for document capture
        await _configureCameraForDocumentCapture();

        if (mounted) {
          setState(() {
            isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera.')),
        );
      }
    }
  }

  /// Configures camera settings optimised for document / passport capture.
  ///
  /// Enables continuous autofocus and auto exposure. Calls are wrapped in
  /// try/catch because not all devices support every focus/exposure mode.
  Future<void> _configureCameraForDocumentCapture() async {
    try {
      await controller!.setFocusMode(FocusMode.auto);
    } catch (_) {
      // Device may not support settable focus modes
    }

    try {
      await controller!.setExposureMode(ExposureMode.auto);
    } catch (_) {
      // Device may not support settable exposure modes
    }

    try {
      await controller!.setFlashMode(FlashMode.off);
    } catch (_) {
      // Flash may not be available
    }
  }

  @override
  void dispose() {
    // Restore all orientations so subsequent screens are not stuck in landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    controller?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Flash control
  // ---------------------------------------------------------------------------

  /// Cycles flash mode: off → auto → torch → off.
  ///
  /// Torch mode provides continuous illumination which is preferable for
  /// document capture — the user can see the lighting effect before capturing.
  Future<void> _toggleFlash() async {
    if (controller == null || !controller!.value.isInitialized) return;

    final nextMode = switch (currentFlashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      _ => FlashMode.off,
    };

    try {
      await controller!.setFlashMode(nextMode);
      setState(() {
        currentFlashMode = nextMode;
      });
    } catch (_) {
      // Flash mode not supported — silently ignore
    }
  }

  IconData get _flashIcon => switch (currentFlashMode) {
    FlashMode.off => Icons.flash_off,
    FlashMode.auto => Icons.flash_auto,
    FlashMode.torch || FlashMode.always => Icons.flash_on,
  };

  String get _flashLabel => switch (currentFlashMode) {
    FlashMode.off => 'Off',
    FlashMode.auto => 'Auto',
    FlashMode.torch || FlashMode.always => 'On',
  };

  // ---------------------------------------------------------------------------
  // Capture
  // ---------------------------------------------------------------------------

  Future<void> capturePassport() async {
    if (controller == null || !controller!.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
      captureStatusMessage = 'Capturing...';
    });

    // Capture screen dimensions before any async work to avoid using
    // BuildContext across async gaps.
    final screenSize = MediaQuery.sizeOf(context);
    final sw = screenSize.width;
    final sh = screenSize.height;
    final (frameWidth, frameHeight) = _computeFrameDimensions(screenSize);

    try {
      final XFile file = await controller!.takePicture();

      setState(() {
        captureStatusMessage = 'Processing...';
      });

      // Offset frame slightly left to make room for the right-side controls
      // This matches the calculation in the build method.
      const double controlColumnWidth = 100.0;
      final frameCenterX = (screenSize.width - controlColumnWidth) / 2;

      final croppedFile = await compute(processAndCropImage, {
        'path': file.path,
        'sw': sw,
        'sh': sh,
        'frameWidth': frameWidth,
        'frameHeight': frameHeight,
        'frameCenterX': frameCenterX,
      });

      if (croppedFile == null) {
        throw Exception('Failed to process captured image.');
      }

      // Hand off image and navigate to review
      ref.read(verificationNotifierProvider.notifier).setImage(croppedFile);

      if (mounted) {
        // Restore portrait before leaving so the review screen renders correctly
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        if (mounted) {
          context.go(AppRoutes.passportReview);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture image. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
          captureStatusMessage = null;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Gallery picker
  // ---------------------------------------------------------------------------

  Future<void> pickPassportFromGallery() async {
    if (isCapturing) return;

    setState(() {
      isCapturing = true;
    });

    try {
      final File? image = await widget.cameraService.pickImageFromGallery();

      if (image != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Passport',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Passport',
              aspectRatioLockEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          ref
              .read(verificationNotifierProvider.notifier)
              .setImage(File(croppedFile.path));
          if (mounted) {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            if (mounted) {
              context.go(AppRoutes.passportReview);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Frame dimensions
  // ---------------------------------------------------------------------------

  /// Computes the passport overlay frame dimensions for landscape mode.
  ///
  /// The frame is a horizontal rectangle matching the ICAO 9303 TD3 passport
  /// aspect ratio (125 mm × 88 mm ≈ 1.42 : 1). Sized to fill most of the
  /// screen while leaving a right-side column for the capture button.
  (double width, double height) _computeFrameDimensions(Size screenSize) {
    // Reserve right column for controls (capture + gallery buttons)
    const double controlColumnWidth = 100.0;
    final availableWidth = screenSize.width - controlColumnWidth;

    // Use 85 % of screen height, then cap so width stays within bounds
    final candidateHeight = screenSize.height * 0.85;
    final candidateWidth = candidateHeight * _passportAspectRatio;

    if (candidateWidth <= availableWidth * 0.95) {
      return (candidateWidth, candidateHeight);
    }

    // Width-constrained — fit to available width instead
    final constrainedWidth = availableWidth * 0.95;
    final constrainedHeight = constrainedWidth / _passportAspectRatio;
    return (constrainedWidth, constrainedHeight);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized || controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final (frameWidth, frameHeight) = _computeFrameDimensions(screenSize);

    // Offset frame slightly left to make room for the right-side controls
    const double controlColumnWidth = 100.0;
    final frameCenterX = (screenSize.width - controlColumnWidth) / 2;
    final cutoutRect = Rect.fromCenter(
      center: Offset(frameCenterX, screenSize.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller!),
          CustomPaint(
            size: Size.infinite,
            painter: CameraOverlayPainter(
              cutout: cutoutRect,
              overlayColor: Colors.black.withAlpha(150),
              radius: 16.0,
            ),
          ),
          _buildTopBar(theme, padding),
          _buildGuidanceText(theme, cutoutRect, screenSize),
          if (captureStatusMessage != null) _buildStatusOverlay(theme),
          _buildControls(padding),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, EdgeInsets padding) {
    return Positioned(
      top: padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.profile);
              }
            },
          ),
          GestureDetector(
            onTap: _toggleFlash,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_flashIcon, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _flashLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceText(ThemeData theme, Rect cutoutRect, Size screenSize) {
    return Positioned(
      top: cutoutRect.bottom + 8,
      left: cutoutRect.left,
      right: screenSize.width - cutoutRect.right,
      child: Text(
        'Hold steady • ~20 cm away • Ensure MRZ zone is visible',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }

  Widget _buildStatusOverlay(ThemeData theme) {
    return Container(
      color: Colors.black.withAlpha(100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              captureStatusMessage!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(EdgeInsets padding) {
    return Positioned(
      right: padding.right + 16,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: isCapturing ? null : capturePassport,
              child: Opacity(
                opacity: isCapturing ? 0.5 : 1.0,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            IconButton(
              iconSize: 28,
              onPressed: isCapturing ? null : pickPassportFromGallery,
              icon: Icon(
                Icons.photo_library,
                color: isCapturing ? Colors.white38 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
