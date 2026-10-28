import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/screens/findr_address_screen.dart';


class _CapturingFinderNotifier extends FinderNotifier {
  FinderActivationParams? capturedParams;
  bool shouldSucceed = true;

  @override
  Future<FinderStateSummary> build() async {
    return const FinderStateSummary(
      finder: null,
      eligibility: FinderEligibility(
        isEligible: true,
        reason: FinderEligibilityReason.eligible,
      ),
      reverificationRequired: false,
    );
  }

  @override
  Future<bool> activate(FinderActivationParams params) async {
    capturedParams = params;
    return shouldSucceed;
  }
}

void main() {
  group('FindrAddressScreen Widget Tests', () {
    late _CapturingFinderNotifier capturingNotifier;

    Widget buildScreen() {
      capturingNotifier = _CapturingFinderNotifier();
      final router = GoRouter(
        initialLocation: '/address',
        routes: [
          GoRoute(
            path: '/address',
            builder: (context, state) => const FindrAddressScreen(),
          ),
          GoRoute(
            path: AppRoutes.findr,
            builder: (context, state) =>
                const Scaffold(body: Text('Findr Dashboard')),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          finderNotifierProvider.overrideWith(() => capturingNotifier),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders UK locked market notice and required address inputs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Residential Address'), findsWidgets);
      expect(find.text('United Kingdom (GBR)'), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('Address Line 1'), findsOneWidget);
      expect(find.text('Town / City'), findsOneWidget);
      expect(find.text('Postcode'), findsOneWidget);
      expect(find.text('Activate Findr'), findsOneWidget);
    });

    testWidgets('validates required fields before submitting', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Tap Activate Findr without entering text
      await tester.tap(find.text('Activate Findr'));
      await tester.pumpAndSettle();

      expect(find.text('Address Line 1 is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('Postcode is required'), findsOneWidget);
      expect(capturingNotifier.capturedParams, isNull);
    });

    testWidgets('submits UK address and activates Findr when valid',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Enter valid UK address details
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(5));

      // Address line 1
      await tester.enterText(textFields.at(0), '10 Downing Street');
      // Town / city (at index 2)
      await tester.enterText(textFields.at(2), 'London');
      // Postcode (at index 4)
      await tester.enterText(textFields.at(4), 'SW1A 2AA');

      await tester.tap(find.text('Activate Findr'));
      await tester.pumpAndSettle();

      expect(capturingNotifier.capturedParams, isNotNull);
      expect(capturingNotifier.capturedParams?.addressLine1,
          '10 Downing Street');
      expect(capturingNotifier.capturedParams?.city, 'London');
      expect(capturingNotifier.capturedParams?.postalCode, 'SW1A 2AA');
      expect(capturingNotifier.capturedParams?.residentialCountryCode, 'GB');
      expect(capturingNotifier.capturedParams?.agreementAccepted, isTrue);
    });

    testWidgets('adapts safely to status bar padding and 1.5x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      capturingNotifier = _CapturingFinderNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            finderNotifierProvider.overrideWith(() => capturingNotifier),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(1.5),
                padding: EdgeInsets.only(top: 48.0),
              ),
              child: FindrAddressScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Residential Address'), findsWidgets);
    });
  });
}

