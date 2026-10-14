import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/brand_shutter.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verify_face_oval.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verify_recording_time.dart';

class MockSelfieCameraService extends CameraService {
  MockSelfieCameraService({this.galleryFile});

  final File? galleryFile;
  bool pickVideoCalled = false;

  @override
  Future<CameraController?> initCamera({
    required CameraLensDirection lensDirection,
    ResolutionPreset resolution = ResolutionPreset.max,
    bool enableAudio = false,
  }) async {
    return null;
  }

  @override
  Future<File?> pickVideoFromGallery() async {
    pickVideoCalled = true;
    return galleryFile;
  }
}

void main() {
  Widget createTestWidget({
    required CameraService cameraService,
    ProviderContainer? container,
  }) {
    final testRouter = GoRouter(
      initialLocation: AppRoutes.selfieCapture,
      routes: [
        GoRoute(
          path: AppRoutes.selfieCapture,
          builder: (context, state) =>
              SelfieCaptureScreen(cameraService: cameraService),
        ),
        GoRoute(
          path: AppRoutes.selfieReview,
          builder: (context, state) =>
              const Scaffold(body: Text('Selfie Review Screen')),
        ),
      ],
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: testRouter),
      );
    }

    return ProviderScope(
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('SelfieCaptureScreen', () {
    testWidgets(
      'renders capture guidance, ergonomic face oval, and gallery upload button',
      (tester) async {
        final camService = MockSelfieCameraService();
        await tester.pumpWidget(createTestWidget(cameraService: camService));
        await tester.pumpAndSettle();

        expect(find.text('Verification'), findsOneWidget);
        expect(find.text('Centre your face'), findsOneWidget);
        expect(find.text('Hold still until the ring fills.'), findsOneWidget);
        expect(
          find.text('Good lighting • Eye level • No accessories'),
          findsOneWidget,
        );
        expect(find.text('Upload from photo library'), findsOneWidget);

        // Verify face oval is rendered with comfortable proportions
        final faceOvalFinder = find.byType(VerifyFaceOval);
        expect(faceOvalFinder, findsOneWidget);

        final faceOval = tester.widget<VerifyFaceOval>(faceOvalFinder);
        expect(faceOval.width, equals(224.0));
        expect(faceOval.height, equals(296.0));

        // Verify timer and shutter button are present
        expect(find.byType(VerifyRecordingTime), findsOneWidget);
        expect(find.byType(BrandShutter), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Upload from photo library picks video and routes to SelfieReviewScreen',
      (tester) async {
        final dummyVideo = File('test_selfie.mp4');
        final camService = MockSelfieCameraService(galleryFile: dummyVideo);
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(
            cameraService: camService,
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        final galleryButtonFinder = find.text('Upload from photo library');
        expect(galleryButtonFinder, findsOneWidget);

        await tester.ensureVisible(galleryButtonFinder);
        await tester.tap(galleryButtonFinder);
        await tester.pumpAndSettle();

        expect(camService.pickVideoCalled, isTrue);
        expect(
          container.read(verificationNotifierProvider).capturedVideo?.path,
          equals('test_selfie.mp4'),
        );
        expect(find.text('Selfie Review Screen'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets(
      'tapping shutter when camera is inactive invokes gallery fallback',
      (tester) async {
        final dummyVideo = File('fallback_selfie.mp4');
        final camService = MockSelfieCameraService(galleryFile: dummyVideo);
        final container = ProviderContainer();

        await tester.pumpWidget(
          createTestWidget(
            cameraService: camService,
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        final shutterFinder = find.byType(BrandShutter);
        expect(shutterFinder, findsOneWidget);

        await tester.tap(shutterFinder);
        await tester.pumpAndSettle();

        expect(camService.pickVideoCalled, isTrue);
        expect(
          container.read(verificationNotifierProvider).capturedVideo?.path,
          equals('fallback_selfie.mp4'),
        );
        expect(find.text('Selfie Review Screen'), findsOneWidget);

        container.dispose();
      },
    );
  });
}
