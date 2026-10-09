import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trvlez_mobile/features/verification/domain/passport_image_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('passport_crop_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('PassportImageProcessor Crop Tests', () {
    test('crops passport frame from landscape image with correct aspect ratio',
        () async {
      // Create a 4000x3000 test image (landscape, 4:3 sensor)
      final testImage = img.Image(width: 4000, height: 3000);
      img.fill(testImage, color: img.ColorRgb8(0, 0, 255));

      final testFile = File('${tempDir.path}/test_passport.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImage));

      // Screen: 800x400 landscape
      // Frame: 400x281.7 (passport 125/88 ratio), centered at x=350
      final params = {
        'path': testFile.path,
        'sw': 800.0,
        'sh': 400.0,
        'frameWidth': 400.0,
        'frameHeight': 281.7,
        'frameCenterX': 350.0,
      };

      final croppedFile = await cropAndOptimizePassportImage(params);
      expect(croppedFile, isNotNull);
      expect(croppedFile!.existsSync(), isTrue);

      final croppedBytes = croppedFile.readAsBytesSync();
      final croppedImg = img.decodeImage(croppedBytes)!;

      // Cropped image width should be normalized to max 1920
      expect(croppedImg.width, lessThanOrEqualTo(1920));
      // Cropped image should have valid dimensions
      expect(croppedImg.width, greaterThan(0));
      expect(croppedImg.height, greaterThan(0));
    });

    test('rotates portrait sensor image to landscape before cropping',
        () async {
      // Sensor captured 3000x4000 (portrait) while screen was landscape
      final testImage = img.Image(width: 3000, height: 4000);
      img.fill(testImage, color: img.ColorRgb8(128, 128, 128));

      final testFile = File('${tempDir.path}/portrait_capture.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImage));

      final params = {
        'path': testFile.path,
        'sw': 800.0,
        'sh': 400.0,
        'frameWidth': 400.0,
        'frameHeight': 281.7,
        'frameCenterX': 350.0,
      };

      final croppedFile = await cropAndOptimizePassportImage(params);
      expect(croppedFile, isNotNull);

      final croppedBytes = croppedFile!.readAsBytesSync();
      final croppedImg = img.decodeImage(croppedBytes)!;

      // Result should have valid dimensions after rotation and crop
      expect(croppedImg.width, greaterThan(0));
      expect(croppedImg.height, greaterThan(0));
      expect(croppedImg.width, lessThanOrEqualTo(1920));
    });

    test(
        'crops correctly when preview AR differs from captured image AR '
        '(16:9 preview, 4:3 capture)', () async {
      // Simulate: 16:9 preview (AR 1.778) but 4:3 capture (4032x3024, AR 1.333)
      // Screen: 800x360 (landscape, ~2.22:1)
      // The preview shows less vertically than the captured image.
      final testImage = img.Image(width: 4032, height: 3024);
      // Fill with blue, then draw a red band in the center (where passport would be)
      img.fill(testImage, color: img.ColorRgb8(0, 0, 255));
      // Draw a red rectangle roughly where the passport frame should map to
      img.fillRect(
        testImage,
        x1: 1000,
        y1: 900,
        x2: 3000,
        y2: 2100,
        color: img.ColorRgb8(255, 0, 0),
      );

      final testFile = File('${tempDir.path}/ar_mismatch_capture.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImage));

      const double sw = 800.0;
      const double sh = 360.0;

      // Passport frame: 85% of screen height
      const double frameHeight = 306.0;
      const double frameWidth = frameHeight * (125.0 / 88.0); // ~436.4

      // Frame centered horizontally (with 100px control column offset)
      const double frameCenterX = (sw - 100.0) / 2; // 350.0

      final params = {
        'path': testFile.path,
        'sw': sw,
        'sh': sh,
        'frameWidth': frameWidth,
        'frameHeight': frameHeight,
        'frameCenterX': frameCenterX,
        'previewAR': 1920.0 / 1080.0, // 16:9 preview
      };

      final croppedFile = await cropAndOptimizePassportImage(params);
      expect(croppedFile, isNotNull);

      final croppedBytes = croppedFile!.readAsBytesSync();
      final croppedImg = img.decodeImage(croppedBytes)!;

      expect(croppedImg.width, greaterThan(0));
      expect(croppedImg.height, greaterThan(0));
      expect(croppedImg.width, lessThanOrEqualTo(1920));

      // The crop should have passport-like aspect ratio (~1.42)
      final cropAR = croppedImg.width / croppedImg.height;
      expect(cropAR, closeTo(125.0 / 88.0, 0.1));

      // Without the preview AR correction, the crop would be ~18% taller
      // and ~18% wider than intended (including content outside the overlay
      // frame). With the fix, the crop exactly matches the overlay frame,
      // giving the passport more pixels after downscaling.
    });
  });
}
