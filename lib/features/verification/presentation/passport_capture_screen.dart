import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/camera_overlay_painter.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_capture_controls.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_guidance_bar.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_top_bar.dart';

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

  /// ICAO 9303 TD3 passport data page: 125 mm × 88 mm → ratio ≈ 1.42.
  static const double _passportAspectRatio = 125.0 / 88.0;

  @override
  void initState() {
    super.initState();
    _initOrientationAndCamera();
  }

  Future<void> _initOrientationAndCamera() async {
    // Lock to landscape for natural passport framing
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

      final cam = controller;
      if (cam != null) {
        // Configure autofocus and exposure for document capture
        await _configureCameraForDocumentCapture(cam);

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

  Future<void> _configureCameraForDocumentCapture(CameraController cam) async {
    try {
      await cam.setFocusMode(FocusMode.auto);
    } catch (_) {
      // Device may not support settable focus modes
    }

    try {
      await cam.setExposureMode(ExposureMode.auto);
    } catch (_) {
      // Device may not support settable exposure modes
    }

    try {
      await cam.setFlashMode(FlashMode.off);
    } catch (_) {
      // Flash may not be available
    }
  }

  @override
  void dispose() {
    // Restore portrait orientation so subsequent screens render in portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final cam = controller;
    if (cam == null || !cam.value.isInitialized) return;

    final nextMode = switch (currentFlashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      _ => FlashMode.off,
    };

    try {
      await cam.setFlashMode(nextMode);
      setState(() {
        currentFlashMode = nextMode;
      });
    } catch (_) {
      // Flash mode not supported — silently ignore
    }
  }

  Future<void> capturePassport() async {
    final cam = controller;
    if (cam == null || !cam.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    final screenSize = MediaQuery.sizeOf(context);
    final sw = screenSize.width;
    final sh = screenSize.height;
    final (frameWidth, frameHeight) = _computeFrameDimensions(screenSize);
    const double controlColumnWidth = 100.0;
    final frameCenterX = (screenSize.width - controlColumnWidth) / 2;

    try {
      final XFile file = await cam.takePicture();

      // Immediately freeze/stop the camera preview
      await cam.pausePreview();

      final cropParams = PassportCropParams(
        imagePath: file.path,
        screenWidth: sw,
        screenHeight: sh,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        frameCenterX: frameCenterX,
        previewAspectRatio: cam.value.aspectRatio,
      );

      // Hand off image and crop params, then transition to review screen immediately
      ref
          .read(verificationNotifierProvider.notifier)
          .setImage(File(file.path), cropParams: cropParams);

      if (mounted) {
        // Restore portrait before leaving so the processing screen renders correctly
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        if (mounted) {
          context.go(
            AppRoutes.passportProcessing,
            extra: {'cropParams': cropParams},
          );
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
      try {
        await cam.resumePreview();
      } catch (_) {}
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

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
          await controller?.pausePreview();
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
          return;
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

  (double width, double height) _computeFrameDimensions(Size screenSize) {
    const double controlColumnWidth = 100.0;
    final availableWidth = screenSize.width - controlColumnWidth;

    final candidateHeight = screenSize.height * 0.70;
    final candidateWidth = candidateHeight * _passportAspectRatio;

    if (candidateWidth <= availableWidth * 0.95) {
      return (candidateWidth, candidateHeight);
    }

    final constrainedWidth = availableWidth * 0.95;
    final constrainedHeight = constrainedWidth / _passportAspectRatio;
    return (constrainedWidth, constrainedHeight);
  }

  @override
  Widget build(BuildContext context) {
    final cam = controller;
    if (!isCameraInitialized || cam == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final (frameWidth, frameHeight) = _computeFrameDimensions(screenSize);

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
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: cam.value.aspectRatio,
              height: 1,
              child: CameraPreview(cam),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: CameraOverlayPainter(
              cutout: cutoutRect,
              overlayColor: Colors.black.withAlpha(150),
              radius: 16.0,
            ),
          ),
          PassportTopBar(
            onClose: () {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.passportInstructions);
              }
            },
            onToggleFlash: _toggleFlash,
            flashMode: currentFlashMode,
            padding: padding,
          ),
          PassportGuidanceBar(cutoutRect: cutoutRect, screenSize: screenSize),
          PassportCaptureControls(
            isCapturing: isCapturing,
            onCapture: capturePassport,
            onPickGallery: pickPassportFromGallery,
            padding: padding,
          ),
        ],
      ),
    );
  }
}
