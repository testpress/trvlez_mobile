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

    testWidgets('renders enlarged cropped MRZ image when mrzImage is present', (
      tester,
    ) async {
      final testImg = img.Image(width: 500, height: 352);
      img.fill(testImg, color: img.ColorRgb8(100, 150, 200));
      final testFile = File('${tempDir.path}/passport.jpg');
      testFile.writeAsBytesSync(img.encodeJpg(testImg));

      final mrzImg = img.Image(width: 500, height: 95);
      img.fill(mrzImg, color: img.ColorRgb8(20, 20, 20));
      final mrzFile = File('${tempDir.path}/passport_mrz_cropped.jpg');
      mrzFile.writeAsBytesSync(img.encodeJpg(mrzImg));

      final container = ProviderContainer();
      container.read(verificationNotifierProvider.notifier).setImage(
            testFile,
            mrzImage: mrzFile,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PassportReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Code lines, enlarged'), findsOneWidget);
      expect(find.text('Can you read every character?'), findsOneWidget);
      // Should find two Image widgets: the passport shot and the enlarged MRZ strip
      expect(find.byType(Image), findsNWidgets(2));
      // Should not contain dummy British passport text
      expect(find.textContaining('OKAFOR'), findsNothing);

      container.dispose();
    });

    testWidgets('renders monospace MRZ text lines when mrzLines are present', (
      tester,
    ) async {
      const line1 = 'P<INDTESTER<<PRIYA<<<<<<<<<<<<<<<<<<<<<<<<<<';
      const line2 = 'Z1234567<4IND9501018F3012312<<<<<<<<<<<<<<6';

      final container = ProviderContainer();
      container.read(verificationNotifierProvider.notifier).setImage(
            File('${tempDir.path}/dummy.jpg'),
            mrzLines: const [line1, line2],
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PassportReviewScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(line1), findsOneWidget);
      expect(find.text(line2), findsOneWidget);
      // Should not show dummy placeholder data
      expect(find.textContaining('OKAFOR'), findsNothing);

      container.dispose();
    });
  });
}
