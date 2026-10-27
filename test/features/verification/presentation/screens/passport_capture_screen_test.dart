import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/passport_framing_guide.dart';

class FakeCameraService extends CameraService {
  @override
  Future<CameraController?> initCamera({
    required CameraLensDirection lensDirection,
    ResolutionPreset resolution = ResolutionPreset.max,
    bool enableAudio = false,
  }) async {
    // Return null in test environment to test fallback illustration and framing overlay
    return null;
  }
}

void main() {
  Widget createTestWidget({CameraService? cameraService}) {
    final camService = cameraService ?? FakeCameraService();

    final testRouter = GoRouter(
      initialLocation: AppRoutes.passportCapture,
      routes: [
        GoRoute(
          path: AppRoutes.passportCapture,
          builder: (context, state) =>
              PassportCaptureScreen(cameraService: camService),
        ),
        GoRoute(
          path: AppRoutes.passportReview,
          builder: (context, state) =>
              const Scaffold(body: Text('Passport Review Screen')),
        ),
      ],
    );

    return ProviderScope(child: MaterialApp.router(routerConfig: testRouter));
  }

  group('PassportCaptureScreen', () {
    testWidgets(
      'renders capture guidance, framing guide, and shutter button without upload option',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Verification'), findsOneWidget);
        expect(find.text('Fit the page in the frame'), findsOneWidget);
        expect(
          find.text('Both the photo page and the code lines.'),
          findsOneWidget,
        );
        expect(
          find.text('Hold steady ~20 cm away'),
          findsOneWidget,
        );
        expect(
          find.text('Keep the dashed box over the bottom 2 lines of text'),
          findsOneWidget,
        );
        expect(find.text('Upload from photo library'), findsNothing);

        // Verify the ICAO TD3 passport framing guide is rendered in the tree
        expect(find.byType(PassportFramingGuide), findsOneWidget);

        // Verify the shutter button is present
        expect(find.byType(BrandShutter), findsOneWidget);
      },
    );

    testWidgets(
      'framing guide inside capture screen maintains ICAO aspect ratio',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final framingGuideFinder = find.byType(PassportFramingGuide);
        expect(framingGuideFinder, findsOneWidget);

        final framingGuide = tester.widget<PassportFramingGuide>(
          framingGuideFinder,
        );
        final frameRect = PassportFramingGuide.calculatePassportFrame(
          framingGuide.viewportSize,
        );

        // Verify frame aspect ratio is strictly ICAO TD3 (125mm / 88mm ~ 1.42)
        final ar = frameRect.width / frameRect.height;
        expect(ar, closeTo(125.0 / 88.0, 0.01));
      },
    );

    testWidgets(
      'does not show photo library upload option (live capture only)',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Upload from photo library'), findsNothing);
      },
    );

    testWidgets(
      'shutter press does not trigger gallery when camera is uninitialized',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(BrandShutter));
        await tester.pump();

        expect(find.text('Passport Review Screen'), findsNothing);
      },
    );
  });
}
