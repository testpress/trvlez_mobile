import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_review_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('passport_review_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('PassportReviewScreen', () {
    testWidgets('renders fallback SVG illustration when capturedImage is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PassportReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check your photo'), findsOneWidget);
      expect(find.byType(SvgPicture), findsWidgets);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders Image.file with BoxFit.contain when capturedImage is present', (
      tester,
    ) async {
      // Create a test passport image (125:88 ratio)
      final testImg = img.Image(width: 500, height: 352);
      img.fill(testImg, color: img.ColorRgb8(100, 150, 200));

      final testFile = File('${tempDir.path}/uploaded_passport.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImg));

      final container = ProviderContainer();
      container.read(verificationNotifierProvider.notifier).setImage(testFile);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PassportReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Check your photo'), findsOneWidget);
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      // Verify BoxFit.contain is used so no edges of the uploaded image are clipped or hidden
      expect(imageWidget.fit, BoxFit.contain);

      container.dispose();
    });
  });
}
