import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Crops the passport region from the camera capture within the viewfinder overlay frame,
/// normalizes the resolution to max 1920px width, and encodes as JPEG with 100% quality.
///
/// Maps screen coordinates → preview coordinates → captured image coordinates
/// to correctly handle preview/capture aspect-ratio mismatches (e.g. 16:9
/// preview vs 4:3 capture).
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

    // Read the preview aspect ratio. Falls back to the captured image AR
    // when unavailable (e.g. gallery-picked images), which makes the mapping
    // an identity — equivalent to the old behaviour.
    final double previewAR = (params['previewAR'] as double?) ?? (iw / ih);
    final double captureAR = iw / ih;

    // --- Step 1: Screen → Preview normalized coordinates (0–1) ---
    //
    // The preview (logical size previewAR × 1) was displayed with
    // BoxFit.cover on the screen (sw × sh). Compute the offset
    // introduced by cover-clipping so we can map the overlay frame
    // from screen space into the preview's full coordinate space.
    final double coverScale = max(sw / previewAR, sh);
    final double displayW = previewAR * coverScale;
    final double displayH = coverScale;
    final double offX = (displayW - sw) / 2;
    final double offY = (displayH - sh) / 2;

    final double normCenterX = (frameCenterX + offX) / displayW;
    final double normCenterY = (sh / 2 + offY) / displayH;
    final double normW = frameWidth / displayW;
    final double normH = frameHeight / displayH;

    // --- Step 2: Preview normalized → Captured image pixels ---
    //
    // The preview and capture share the same sensor. When their aspect
    // ratios differ, one dimension has a wider field-of-view (FOV).
    // Standard behaviour (CameraX / AVFoundation): the preview and
    // capture share horizontal FOV; the narrower AR (e.g. 4:3) shows
    // more vertically.
    //
    // We compute the rectangle of the captured image that the preview
    // actually covers ("visible" region), then map into it.
    final double visibleW;
    final double visibleH;
    final double visibleOffX;
    final double visibleOffY;

    if (previewAR >= captureAR) {
      // Preview is wider (or equal): same width FOV, preview crops height
      visibleW = iw;
      visibleH = iw / previewAR;
      visibleOffX = 0;
      visibleOffY = (ih - visibleH) / 2;
    } else {
      // Preview is taller: same height FOV, preview crops width
      visibleW = ih * previewAR;
      visibleH = ih;
      visibleOffX = (iw - visibleW) / 2;
      visibleOffY = 0;
    }

    final double cropCenterX = visibleOffX + normCenterX * visibleW;
    final double cropCenterY = visibleOffY + normCenterY * visibleH;
    final double cropW = normW * visibleW;
    final double cropH = normH * visibleH;
    final double cropX = cropCenterX - cropW / 2;
    final double cropY = cropCenterY - cropH / 2;

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
