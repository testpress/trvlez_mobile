import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/verification_landing_screen.dart';

import '../../../../fixtures/fake_verification_repository.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  final Profile _profile;
  _FakeProfileNotifier(this._profile);

  @override
  FutureOr<Profile> build() => _profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVerificationRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeVerificationRepository();
  });

  Widget createTestWidget({
    required ProviderContainer container,
    List<RouteBase> additionalRoutes = const [],
  }) {
    final router = GoRouter(
      initialLocation: AppRoutes.verificationLanding,
      routes: [
        GoRoute(
          path: AppRoutes.verificationLanding,
          builder: (context, state) => const VerificationLandingScreen(),
        ),
        GoRoute(
          path: AppRoutes.passportInstructions,
          builder: (context, state) =>
              const Scaffold(body: Text('Passport Instructions Page')),
        ),
        GoRoute(
          path: AppRoutes.confirmDetails,
          builder: (context, state) =>
              const Scaffold(body: Text('Confirm Details Page')),
        ),
        GoRoute(
          path: AppRoutes.selfieInstructions,
          builder: (context, state) =>
              const Scaffold(body: Text('Selfie Instructions Page')),
        ),
        GoRoute(
          path: AppRoutes.nfcIntro,
          builder: (context, state) =>
              const Scaffold(body: Text('NFC Intro Page')),
        ),
        GoRoute(
          path: AppRoutes.verificationStatus,
          builder: (context, state) =>
              const Scaffold(body: Text('Verification Status Page')),
        ),
        ...additionalRoutes,
      ],
    );
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('VerificationLandingScreen State Handling', () {
    testWidgets(
      'when traveler is verified, displays 4 of 4 completed and cards are NOT clickable',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        fakeRepo.verificationStatus = const VerificationStatus(
          sessionId: 'session-v1',
          status: 'verified',
        );

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-v1', onboardingStep: 'verified'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        // Header shows verified state
        expect(find.text('Identity verified'), findsOneWidget);
        expect(find.text('4 of 4 steps completed'), findsOneWidget);
        expect(find.text('100%'), findsOneWidget);

        // Verification status CTA button is visible
        expect(find.byType(AppButton), findsOneWidget);
        expect(find.text('View verification status'), findsOneWidget);

        // Tapping any step card should NOT navigate
        await tester.tap(find.text('Upload Passport'));
        await tester.pumpAndSettle();
        expect(find.text('Passport Instructions Page'), findsNothing);

        await tester.tap(find.text('Review Details'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm Details Page'), findsNothing);

        await tester.tap(find.text('Selfie Verification'));
        await tester.pumpAndSettle();
        expect(find.text('Selfie Instructions Page'), findsNothing);

        await tester.scrollUntilVisible(find.text('NFC Verification'), 100);
        await tester.tap(find.text('NFC Verification'));
        await tester.pumpAndSettle();
        expect(find.text('NFC Intro Page'), findsNothing);

        // Tapping CTA navigates to status (CTA is pinned in footer)
        await tester.tap(find.text('View verification status'));
        await tester.pumpAndSettle();
        expect(find.text('Verification Status Page'), findsOneWidget);
      },
    );

    testWidgets(
      'when all things are done including NFC, 4 of 4 completed and cards are NOT clickable',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(id: 'prof-nfc-done', onboardingStep: 'submitted'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(verificationNotifierProvider.notifier).skipNfc();

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        expect(find.text('4 of 4 steps completed'), findsOneWidget);
        expect(find.text('100%'), findsOneWidget);

        // Clicking any step does NOT allow navigation
        await tester.tap(find.text('Upload Passport'));
        await tester.pumpAndSettle();
        expect(find.text('Passport Instructions Page'), findsNothing);

        await tester.scrollUntilVisible(find.text('NFC Verification'), 100);
        await tester.tap(find.text('NFC Verification'));
        await tester.pumpAndSettle();
        expect(find.text('NFC Intro Page'), findsNothing);
      },
    );

    testWidgets(
      'when traveler is on step 2 (Selfie), only Selfie is active and clickable',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-step-2',
                  onboardingStep: 'passport_reviewed',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        expect(find.text('2 of 4 steps completed'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);

        // Completed step 0 cannot be tapped
        await tester.tap(find.text('Upload Passport'));
        await tester.pumpAndSettle();
        expect(find.text('Passport Instructions Page'), findsNothing);

        // Completed step 1 cannot be tapped
        await tester.tap(find.text('Review Details'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm Details Page'), findsNothing);

        // Locked step 3 cannot be tapped
        await tester.tap(find.text('NFC Verification'));
        await tester.pumpAndSettle();
        expect(find.text('NFC Intro Page'), findsNothing);

        // Active step 2 CAN be tapped and navigates
        await tester.tap(find.text('Selfie Verification'));
        await tester.pumpAndSettle();
        expect(find.text('Selfie Instructions Page'), findsOneWidget);
      },
    );

    testWidgets(
      'when traveler is fresh on step 0, only step 0 is active and clickable',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer(
          overrides: [
            verificationRepositoryProvider.overrideWithValue(fakeRepo),
            currentProfileProvider.overrideWith(
              () => _FakeProfileNotifier(
                const Profile(
                  id: 'prof-fresh',
                  onboardingStep: 'profile_complete',
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestWidget(container: container));
        await tester.pumpAndSettle();

        expect(find.text('0 of 4 steps completed'), findsOneWidget);
        expect(find.text('0%'), findsOneWidget);

        // Locked steps cannot be tapped
        await tester.tap(find.text('Review Details'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm Details Page'), findsNothing);

        await tester.tap(find.text('Selfie Verification'));
        await tester.pumpAndSettle();
        expect(find.text('Selfie Instructions Page'), findsNothing);

        // Step 0 can be tapped
        await tester.tap(find.text('Upload Passport'));
        await tester.pumpAndSettle();
        expect(find.text('Passport Instructions Page'), findsOneWidget);
      },
    );
  });
}
