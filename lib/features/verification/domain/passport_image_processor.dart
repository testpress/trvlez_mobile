import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Crops the passport region from the camera capture within the viewfinder overlay frame,
/// normalizes the resolution to max 1920px width, and encodes as JPEG with 100% quality.
Future<File?> cropAndOptimizePassportImage(Map<String, dynamic> params) async {
  final String imagePath = params['path'] as String;
  final double sw = params['sw'] as double;
  final double sh = params['sh'] as double;
  final double frameWidth = params['frameWidth'] as double;
  final double frameHeight = params['frameHeight'] as double;
  final double frameCenterX = (params['frameCenterX'] as double?) ?? (sw / 2);

  final bytes = File(imagePath).readAsBytesSync();
  img.Image? originalImage = img.decodeImage(bytes);

  if (originalImage != null) {
    originalImage = img.bakeOrientation(originalImage);

    // If device was in landscape but captured image is portrait, rotate to match
    if (sw > sh && originalImage.width < originalImage.height) {
      originalImage = img.copyRotate(originalImage, angle: 90);
    }

    final double iw = originalImage.width.toDouble();
    final double ih = originalImage.height.toDouble();

    // Uniform scale matching BoxFit.cover — no stretch or compression
    final double scale = max(sw / iw, sh / ih);

    final double cropCenterX = (frameCenterX - (sw / 2)) / scale + (iw / 2);
    final double cropCenterY = ih / 2;

    final double cropW = frameWidth / scale;
    final double cropH = frameHeight / scale;
    final double cropX = cropCenterX - (cropW / 2);
    final double cropY = cropCenterY - (cropH / 2);

    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX.toInt().clamp(0, originalImage.width - 1),
      y: cropY.toInt().clamp(0, originalImage.height - 1),
      width: cropW.toInt().clamp(1, originalImage.width),
      height: cropH.toInt().clamp(1, originalImage.height),
    );

    // Normalize resolution: standard passport page needs ~300-400 DPI (~1800-1920px width).
    // Downscaling from raw sensor resolution eliminates noise while keeping file size optimal.
    if (croppedImage.width > 1920) {
      croppedImage = img.copyResize(
        croppedImage,
        width: 1920,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Encode as maximum-quality JPEG (quality: 100) for maximum sharpness
    final jpgBytes = img.encodeJpg(croppedImage, quality: 100);
    final jpgPath = imagePath.replaceAll(RegExp(r'\.[^.]+$'), '_cropped.jpg');
    final jpgFile = File(jpgPath)..writeAsBytesSync(jpgBytes);
    return jpgFile;
  }
  return null;
}
