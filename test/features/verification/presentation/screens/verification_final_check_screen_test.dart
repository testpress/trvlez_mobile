import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/verification_final_check_screen.dart';

import 'package:trvlez_mobile/features/verification/presentation/widgets/verify_status_rows.dart';

class TestVerificationNotifier extends VerificationNotifier {
  final VerificationState _initialState;

  TestVerificationNotifier([VerificationState? initialState])
    : _initialState = initialState ?? const VerificationState();

  @override
  VerificationState build() {
    return _initialState;
  }

  int submitCallCount = 0;
  int reconcileCallCount = 0;
  String? polledJobId;

  @override
  Future<void> submitVerificationAsync() async {
    submitCallCount++;
  }

  @override
  Future<void> reconcileWithBackend() async {
    reconcileCallCount++;
  }

  @override
  void startPollingVerificationJob(String jobId) {
    polledJobId = jobId;
  }

  void updateState(VerificationState newState) {
    state = newState;
  }
}

void main() {
  Widget createTestWidget({
    required ProviderContainer container,
    String? verificationJobId,
  }) {
    final testRouter = GoRouter(
      initialLocation: AppRoutes.verificationFinalCheck,
      routes: [
        GoRoute(
          path: AppRoutes.verificationFinalCheck,
          builder: (context, state) => VerificationFinalCheckScreen(
            verificationJobId: verificationJobId,
          ),
        ),
        GoRoute(
          path: AppRoutes.verificationSuccess,
          builder: (context, state) =>
              const Scaffold(body: Text('Verification Success Screen')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: AppRoutes.nfcFailed,
          builder: (context, state) =>
              const Scaffold(body: Text('NFC Failed Screen')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('VerificationFinalCheckScreen', () {
    testWidgets('renders all verification status rows and headers', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Verification'), findsOneWidget);
      expect(find.text('Checking everything'), findsOneWidget);
      expect(
        find.text(
          "Usually under a minute. You can close the app — we'll let you know.",
        ),
        findsOneWidget,
      );
      final statusRows = find.byType(VerifyStatusRows);
      expect(
        find.descendant(of: statusRows, matching: find.text('Your details')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Passport photo')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Selfie')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Chip scan')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Final check')),
        findsOneWidget,
      );
    });

    testWidgets('omits chip scan row when NFC is skipped', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(
          phase: VerificationPhase.verifying,
          isNfcSkipped: true,
        ),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      final statusRows = find.byType(VerifyStatusRows);
      expect(
        find.descendant(of: statusRows, matching: find.text('Your details')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Passport photo')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Selfie')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Chip scan')),
        findsNothing,
      );
      expect(
        find.descendant(of: statusRows, matching: find.text('Final check')),
        findsOneWidget,
      );
    });

    testWidgets('triggers submitVerificationAsync on initial mount if idle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.idle),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump();

      expect(notifier.submitCallCount, 1);
    });

    testWidgets('navigates to success when verification succeeds', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      notifier.updateState(
        const VerificationState(phase: VerificationPhase.verified),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Verification Success Screen'), findsOneWidget);
    });

    testWidgets('navigates to failure screen when verification fails', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      notifier.updateState(
        const VerificationState(
          phase: VerificationPhase.verificationFailed,
          verificationStatus: VerificationStatus(
            status: 'failed',
            failedStep: 'passport_scan',
            errorReason: 'Blurry photo',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('NFC Failed Screen'), findsOneWidget);
    });

    testWidgets('shows error retry UI when phase is error', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(
          phase: VerificationPhase.error,
          errorMessage: 'Network timeout during submission',
        ),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Network timeout during submission'), findsOneWidget);
      final retryButton = find.text('Retry submission');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      expect(notifier.submitCallCount, 1);
    });

    testWidgets('starts polling when verificationJobId is provided', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createTestWidget(container: container, verificationJobId: 'job-12345'),
      );
      await tester.pump();

      expect(notifier.polledJobId, 'job-12345');
    });

    testWidgets('tapping back button navigates to home instead of previous screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      final backButton = find.byTooltip('Back');
      final backButtonSemantics = find.bySemanticsLabel('Back');
      final backTarget = backButtonSemantics.evaluate().isNotEmpty
          ? backButtonSemantics
          : backButton;

      expect(backTarget, findsOneWidget);
      await tester.tap(backTarget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('hardware or system back invokes PopScope and navigates to home', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = TestVerificationNotifier(
        const VerificationState(phase: VerificationPhase.verifying),
      );
      final container = ProviderContainer(
        overrides: [verificationNotifierProvider.overrideWith(() => notifier)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate system pop attempt
      final dynamic popScope = tester.widget(
        find.byWidgetPredicate((widget) => widget is PopScope),
      );
      expect(popScope.canPop, isFalse);

      popScope.onPopInvokedWithResult(false, null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
