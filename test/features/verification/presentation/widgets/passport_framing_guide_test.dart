import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_framing_guide.dart';

void main() {
  group('PassportFramingGuide Geometry & Rendering', () {
    test('calculatePassportFrame preserves ICAO TD3 aspect ratio on mobile portrait viewport', () {
      const viewport = Size(320.0, 336.0); // 1:1.05 standard mobile card
      final frame = PassportFramingGuide.calculatePassportFrame(viewport);

      // Verify aspect ratio matches 125mm x 88mm (~1.42045)
      final ar = frame.width / frame.height;
      expect(ar, closeTo(125.0 / 88.0, 0.001));

      // Verify centered horizontally and vertically
      expect(frame.center.dx, closeTo(viewport.width / 2, 0.01));
      expect(frame.center.dy, closeTo(viewport.height / 2, 0.01));

      // Verify frame fits completely within the viewport bounds
      expect(frame.left, greaterThanOrEqualTo(0));
      expect(frame.top, greaterThanOrEqualTo(0));
      expect(frame.right, lessThanOrEqualTo(viewport.width));
      expect(frame.bottom, lessThanOrEqualTo(viewport.height));
    });

    test('calculatePassportFrame preserves ICAO TD3 aspect ratio on various device viewports', () {
      const viewports = [
        Size(300.0, 315.0), // Small mobile
        Size(360.0, 378.0), // Medium mobile
        Size(390.0, 410.0), // Large mobile
        Size(600.0, 400.0), // Tablet landscape
        Size(800.0, 400.0), // Landscape display
      ];

      for (final vp in viewports) {
        final frame = PassportFramingGuide.calculatePassportFrame(vp);
        final ar = frame.width / frame.height;
        expect(
          ar,
          closeTo(125.0 / 88.0, 0.001),
          reason: 'Failed for viewport: $vp',
        );
        expect(frame.left, greaterThanOrEqualTo(0));
        expect(frame.top, greaterThanOrEqualTo(0));
        expect(frame.right, lessThanOrEqualTo(vp.width));
        expect(frame.bottom, lessThanOrEqualTo(vp.height));
      }
    });

    testWidgets('renders PassportFramingGuide in widget tree without error', (tester) async {
      const viewportSize = Size(320.0, 336.0);
      const colors = AppColors.dark;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: viewportSize.width,
                height: viewportSize.height,
                child: const PassportFramingGuide(
                  viewportSize: viewportSize,
                  colors: colors,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PassportFramingGuide), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
