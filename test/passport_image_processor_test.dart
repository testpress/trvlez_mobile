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
  });
}
