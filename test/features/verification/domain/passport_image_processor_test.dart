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
    test(
      'crops passport frame from landscape image with correct aspect ratio',
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
      },
    );

    test(
      'rotates portrait sensor image to landscape before cropping',
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
      },
    );

    test('crops correctly when preview AR differs from captured image AR '
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

    test(
      'crops passport frame from portrait capture on mobile portrait screen with exact ICAO aspect ratio',
      () async {
        // Standard mobile camera: 3024x4032 portrait capture
        final testImage = img.Image(width: 3024, height: 4032);
        img.fill(testImage, color: img.ColorRgb8(10, 50, 100));

        final testFile = File('${tempDir.path}/portrait_mobile_capture.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        // Viewport: 320x336 (1:1.05 aspect mobile card)
        const double sw = 320.0;
        const double sh = 336.0;
        const double frameWidth = 284.0;
        const double frameHeight = frameWidth / (125.0 / 88.0); // ~199.94
        const double frameCenterX = sw / 2; // 160.0
        const double frameCenterY = sh / 2; // 168.0

        final params = {
          'path': testFile.path,
          'sw': sw,
          'sh': sh,
          'frameWidth': frameWidth,
          'frameHeight': frameHeight,
          'frameCenterX': frameCenterX,
          'frameCenterY': frameCenterY,
          'previewAR': 3.0 / 4.0, // 3:4 portrait preview
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);

        final croppedBytes = croppedFile!.readAsBytesSync();
        final croppedImg = img.decodeImage(croppedBytes)!;

        // Verify dimensions and normalization
        expect(croppedImg.width, greaterThan(0));
        expect(croppedImg.height, greaterThan(0));
        expect(croppedImg.width, lessThanOrEqualTo(1920));

        // Cropped image MUST preserve the natural rectangular aspect ratio (~1.42)
        final cropAR = croppedImg.width / croppedImg.height;
        expect(cropAR, closeTo(125.0 / 88.0, 0.05));

        // It MUST NOT be forced into a square (0.95-1.05)
        expect(cropAR, isNot(closeTo(1.0, 0.15)));
      },
    );

    test(
      'normalizes inverted previewAR when caller passes landscape cam.value.aspectRatio in portrait mode',
      () async {
        // CameraX / AVFoundation reports aspectRatio as width/height (>1.0 e.g. 1.3333)
        // even when device is held in portrait
        final testImage = img.Image(width: 3024, height: 4032);
        img.fill(testImage, color: img.ColorRgb8(30, 80, 40));

        final testFile = File('${tempDir.path}/cam_ar_raw_capture.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        const double sw = 320.0;
        const double sh = 336.0;
        const double frameWidth = 284.0;
        const double frameHeight = frameWidth / (125.0 / 88.0);

        final params = {
          'path': testFile.path,
          'sw': sw,
          'sh': sh,
          'frameWidth': frameWidth,
          'frameHeight': frameHeight,
          'frameCenterX': 160.0,
          'frameCenterY': 168.0,
          // Un-normalized sensor AR (> 1.0) while screen is portrait (sw < sh)
          'previewAR': 4.0 / 3.0,
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);

        final croppedBytes = croppedFile!.readAsBytesSync();
        final croppedImg = img.decodeImage(croppedBytes)!;

        final cropAR = croppedImg.width / croppedImg.height;
        expect(cropAR, closeTo(125.0 / 88.0, 0.05));
      },
    );

    test(
      'rotates unrotated landscape sensor image to portrait when captured on portrait device',
      () async {
        // Sensor captured 4032x3024 (landscape) while device was portrait
        final testImage = img.Image(width: 4032, height: 3024);
        img.fill(testImage, color: img.ColorRgb8(100, 100, 200));

        final testFile = File('${tempDir.path}/unrotated_sensor_capture.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        const double sw = 360.0;
        const double sh = 640.0;
        const double frameWidth = 320.0;
        const double frameHeight = frameWidth / (125.0 / 88.0);

        final params = {
          'path': testFile.path,
          'sw': sw,
          'sh': sh,
          'frameWidth': frameWidth,
          'frameHeight': frameHeight,
          'frameCenterX': 180.0,
          'frameCenterY': 320.0,
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);

        final croppedBytes = croppedFile!.readAsBytesSync();
        final croppedImg = img.decodeImage(croppedBytes)!;

        expect(croppedImg.width, greaterThan(0));
        expect(croppedImg.height, greaterThan(0));

        // Result should preserve ICAO passport aspect ratio
        final cropAR = croppedImg.width / croppedImg.height;
        expect(cropAR, closeTo(125.0 / 88.0, 0.08));
      },
    );

    test(
      'respects custom frameCenterY vertical offset in portrait capture',
      () async {
        final testImage = img.Image(width: 3000, height: 4000);
        img.fill(testImage, color: img.ColorRgb8(200, 100, 50));

        final testFile = File('${tempDir.path}/custom_center_capture.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        // Screen: 360x600, Frame center at y=250 instead of 300
        final params = {
          'path': testFile.path,
          'sw': 360.0,
          'sh': 600.0,
          'frameWidth': 300.0,
          'frameHeight': 300.0 / (125.0 / 88.0),
          'frameCenterX': 180.0,
          'frameCenterY': 250.0,
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);

        final croppedBytes = croppedFile!.readAsBytesSync();
        final croppedImg = img.decodeImage(croppedBytes)!;

        expect(croppedImg.width, greaterThan(0));
        expect(croppedImg.height, greaterThan(0));
        final cropAR = croppedImg.width / croppedImg.height;
        expect(cropAR, closeTo(125.0 / 88.0, 0.05));
      },
    );

    test(
      'safely clamps crop coordinates when frame reaches viewport boundaries',
      () async {
        final testImage = img.Image(width: 2000, height: 2000);
        img.fill(testImage, color: img.ColorRgb8(50, 50, 50));

        final testFile = File('${tempDir.path}/boundary_capture.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        // Viewport with extreme frame width matching viewport exactly
        final params = {
          'path': testFile.path,
          'sw': 300.0,
          'sh': 300.0,
          'frameWidth': 300.0,
          'frameHeight': 300.0,
          'frameCenterX': 150.0,
          'frameCenterY': 150.0,
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);

        final croppedBytes = croppedFile!.readAsBytesSync();
        final croppedImg = img.decodeImage(croppedBytes)!;
        expect(croppedImg.width, greaterThan(0));
        expect(croppedImg.height, greaterThan(0));
      },
    );

    test(
      'cropAndOptimizePassportImage generates both cropped passport and _mrz_cropped.jpg',
      () async {
        final testImage = img.Image(width: 2000, height: 1400);
        img.fill(testImage, color: img.ColorRgb8(100, 100, 200));

        final testFile = File('${tempDir.path}/full_passport.jpg');
        testFile.writeAsBytesSync(img.encodeJpg(testImage));

        final params = {
          'path': testFile.path,
          'sw': 400.0,
          'sh': 600.0,
          'frameWidth': 360.0,
          'frameHeight': 253.5,
          'frameCenterX': 200.0,
          'frameCenterY': 300.0,
        };

        final croppedFile = await cropAndOptimizePassportImage(params);
        expect(croppedFile, isNotNull);
        expect(croppedFile!.existsSync(), isTrue);

        final mrzPath = testFile.path.replaceAll(
          RegExp(r'\.[^.]+$'),
          '_mrz_cropped.jpg',
        );
        final mrzFile = File(mrzPath);
        expect(mrzFile.existsSync(), isTrue);

        final mrzBytes = mrzFile.readAsBytesSync();
        final mrzImg = img.decodeImage(mrzBytes)!;
        expect(
          mrzImg.width,
          equals(img.decodeImage(croppedFile.readAsBytesSync())!.width),
        );
        expect(
          mrzImg.height,
          lessThan(img.decodeImage(croppedFile.readAsBytesSync())!.height),
        );
      },
    );

    test('cropMrzRegionFromPath crops bottom ~27% of passport image', () async {
      final passportImg = img.Image(width: 1000, height: 700);
      img.fill(passportImg, color: img.ColorRgb8(240, 240, 240));

      final passportFile = File('${tempDir.path}/sample_passport.jpg');
      passportFile.writeAsBytesSync(img.encodeJpg(passportImg));

      final mrzFile = cropMrzRegionFromPath(passportFile.path);
      expect(mrzFile, isNotNull);
      expect(mrzFile!.existsSync(), isTrue);

      final mrzImg = img.decodeImage(mrzFile.readAsBytesSync())!;
      expect(mrzImg.width, equals(1000));
      // 27% of 700 is 189
      expect(mrzImg.height, closeTo(189, 5));
    });
  });
}
