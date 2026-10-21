import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_review_screen.dart';

import '../../../../fixtures/fake_verification_repository.dart';

void main() {
  Widget createTestWidget({required ProviderContainer container}) {
    final testRouter = GoRouter(
      initialLocation: AppRoutes.selfieReview,
      routes: [
        GoRoute(
          path: AppRoutes.selfieReview,
          builder: (context, state) => const SelfieReviewScreen(),
        ),
        GoRoute(
          path: AppRoutes.selfieCapture,
          builder: (context, state) =>
              const Scaffold(body: Text('Selfie Capture Screen')),
        ),
        GoRoute(
          path: AppRoutes.selfieProcessing,
          builder: (context, state) =>
              const Scaffold(body: Text('Selfie Processing Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('SelfieReviewScreen', () {
    late FakeVerificationRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeVerificationRepository();
      container = ProviderContainer(
        overrides: [verificationRepositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('renders review guidance and fallback SVG illustration', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Verification'), findsOneWidget);
      expect(find.text('Check your video'), findsOneWidget);
      expect(
        find.text(
          'Watch it back before you upload. Make sure your face is clearly visible, well-lit, and centered throughout.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tap to play'), findsOneWidget);
      expect(find.text('Looks good, upload'), findsOneWidget);
      expect(find.text('Record again'), findsOneWidget);

      // SvgPicture fallback should be present
      expect(find.byType(SvgPicture), findsWidgets);

      // Play overlay button should be present when paused
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets(
      'tapping Record again clears video and navigates to selfieCapture',
      (tester) async {
        final dummyVideo = File('selfie_to_clear.mp4');
        container
            .read(verificationNotifierProvider.notifier)
            .setVideo(dummyVideo);

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        expect(
          container.read(verificationNotifierProvider).capturedVideo,
          equals(dummyVideo),
        );

        final recordAgainFinder = find.widgetWithText(
          AppButton,
          'Record again',
        );
        expect(recordAgainFinder, findsOneWidget);

        await tester.tap(recordAgainFinder);
        await tester.pumpAndSettle();

        expect(
          container.read(verificationNotifierProvider).capturedVideo,
          isNull,
        );
        expect(find.text('Selfie Capture Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Looks good, upload triggers uploadSelfie and navigates to selfieProcessing',
      (tester) async {
        final dummyVideo = File('selfie_to_upload.mp4');
        container
            .read(verificationNotifierProvider.notifier)
            .setVideo(dummyVideo);

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        final uploadButtonFinder = find.widgetWithText(
          AppButton,
          'Looks good, upload',
        );
        expect(uploadButtonFinder, findsOneWidget);

        await tester.tap(uploadButtonFinder);
        await tester.pumpAndSettle();

        expect(fakeRepo.uploadSelfieCalled, isTrue);
        expect(find.text('Selfie Processing Screen'), findsOneWidget);
      },
    );
  });
}
