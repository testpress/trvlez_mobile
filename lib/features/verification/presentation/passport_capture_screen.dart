import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
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

    final double cropW = frameWidth / scaleX;
    final double cropH = frameHeight / scaleY;
    final double cropX = (iw - cropW) / 2;
    final double cropY = (ih - cropH) / 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX.toInt().clamp(0, originalImage.width - 1),
      y: cropY.toInt().clamp(0, originalImage.height - 1),
      width: cropW.toInt().clamp(1, originalImage.width),
      height: cropH.toInt().clamp(1, originalImage.height),
    );

    // The capture screen encourages users to hold the mobile sideways.
    // Rotate 90 degrees before saving and showing in the review screen.
    final img.Image rotatedImage = img.copyRotate(croppedImage, angle: 90);

    final croppedBytes = img.encodePng(rotatedImage);
    final pngPath = imagePath.replaceAll(RegExp(r'\.[^.]+$'), '.png');
    final pngFile = File(pngPath)..writeAsBytesSync(croppedBytes);
    return pngFile;
  }
  return null;
}

class PassportCaptureScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const PassportCaptureScreen({super.key, required this.notifier});

  @override
  State<PassportCaptureScreen> createState() => PassportCaptureScreenState();
}

class PassportCaptureScreenState extends State<PassportCaptureScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        // Find back camera if possible
        final backCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras!.first,
        );

        controller = CameraController(
          backCamera,
          ResolutionPreset.max,
          enableAudio: false,
        );

        await controller!.initialize();
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

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    controller?.dispose();
    super.dispose();
  }

  Future<void> capturePassport() async {
    if (controller == null || !controller!.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      final sw = MediaQuery.sizeOf(context).width;
      final sh = MediaQuery.sizeOf(context).height;
      // Make frame tall to encourage landscape capturing
      final frameHeight = sh * 0.65;
      final frameWidth = frameHeight / 1.43; // Standard passport aspect ratio

      final XFile file = await controller!.takePicture();

      final croppedFile = await compute(processAndCropImage, {
        'path': file.path,
        'sw': sw,
        'sh': sh,
        'frameWidth': frameWidth,
        'frameHeight': frameHeight,
      });

      // We pass the captured file to the notifier and go to review screen
      widget.notifier.setImage(croppedFile ?? File(file.path));

      if (mounted) {
        context.push('/verification/passport-review');
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
          widget.notifier.setImage(File(croppedFile.path));
          if (mounted) {
            context.push('/verification/passport-review');
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

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized || controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    // Vertical frame (taller than wide) to force user to hold phone sideways
    final frameHeight = screenSize.height * 0.65;
    final frameWidth = frameHeight / 1.43;
    
    final cutoutRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(controller!),

          // Reliable Overlay Mask & Border using CustomPaint
          CustomPaint(
            size: Size.infinite,
            painter: CameraOverlayPainter(
              cutout: cutoutRect,
              overlayColor: Colors.black.withAlpha(150),
              radius: 16.0,
            ),
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/verification/status');
                }
              },
            ),
          ),

          // Instructions (Rotated to prompt sideways holding)
          Positioned(
            top: 0,
            bottom: 0,
            right: 16, // Place on the right side of the screen
            child: Center(
              child: RotatedBox(
                quarterTurns: 1, // Rotates text 90 degrees clockwise
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.document_scanner,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Position your passport\nwithin the frame',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure all text is clear and readable',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 48,
                ), // Empty space on left to keep center button centered
                GestureDetector(
                  onTap: capturePassport,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: isCapturing
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: pickPassportFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  final Rect cutout;
  final double radius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  CameraOverlayPainter({
    required this.cutout,
    this.radius = 16.0,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the darkened background with a transparent hole
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(radius)));

    // Subtract the cutout from the background using PathOperation.difference
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()..color = overlayColor;
    canvas.drawPath(overlayPath, paint);

    // 2. Draw the white border around the cutout
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(cutout, Radius.circular(radius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return oldDelegate.cutout != cutout ||
           oldDelegate.overlayColor != overlayColor ||
           oldDelegate.borderColor != borderColor;
  }
}
