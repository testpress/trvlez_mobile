import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/join_findr_sheet.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';

class _MockOnboardingFinderNotifier extends FinderNotifier {
  FinderActivationParams? lastParams;
  bool returnSuccess = true;

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
    lastParams = params;
    return returnSuccess;
  }
}

void main() {
  group('FinderOnboardingSheet Widget Tests', () {
    late _MockOnboardingFinderNotifier notifier;

    setUp(() {
      notifier = _MockOnboardingFinderNotifier();
    });

    Widget createTestSheet() {
      return ProviderScope(
        overrides: [
          finderNotifierProvider.overrideWith(() => notifier),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: FinderOnboardingSheet(),
          ),
        ),
      );
    }

    testWidgets('renders terms on step 1 and requires acceptance to continue',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestSheet());
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Findr Agreement'), findsOneWidget);
      expect(find.text('Continue to Address'), findsOneWidget);

      // Checkbox is unchecked -> Continue button disabled
      final continueButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue to Address'),
      );
      expect(continueButton.onPressed, isNull);

      // Check terms checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Now button is enabled
      final enabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Continue to Address'),
      );
      expect(enabledButton.onPressed, isNotNull);

      // Advance to Step 2
      await tester.tap(find.text('Continue to Address'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('UK Residential Address'), findsOneWidget);
      expect(find.text('United Kingdom (GBR)'), findsOneWidget);
      expect(find.text('Address Line 1'), findsOneWidget);
      expect(find.text('Town / City'), findsOneWidget);
      expect(find.text('Postcode'), findsOneWidget);
      expect(find.text('Activate Findr'), findsOneWidget);
    });

    testWidgets('validates required address fields in step 2 when empty',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestSheet());
      await tester.pumpAndSettle();

      // Accept terms and advance to step 2
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Address'));
      await tester.pumpAndSettle();

      // Tap Activate without entering fields
      await tester.tap(find.text('Activate Findr'));
      await tester.pumpAndSettle();

      expect(find.text('Address Line 1 is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('Postcode is required'), findsOneWidget);
      expect(notifier.lastParams, isNull);
    });

    testWidgets('submits UK address and activates Findr from sheet',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestSheet());
      await tester.pumpAndSettle();

      // Step 1: Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Address'));
      await tester.pumpAndSettle();

      // Step 2: Fill address fields
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(5));

      await tester.enterText(textFields.at(0), '10 Downing St');
      await tester.enterText(textFields.at(2), 'London');
      await tester.enterText(textFields.at(4), 'SW1A 2AA');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Activate Findr'));
      await tester.pumpAndSettle();

      expect(notifier.lastParams, isNotNull);
      expect(notifier.lastParams?.addressLine1, '10 Downing St');
      expect(notifier.lastParams?.city, 'London');
      expect(notifier.lastParams?.postalCode, 'SW1A 2AA');
      expect(notifier.lastParams?.residentialCountryCode, 'GB');
      expect(notifier.lastParams?.agreementAccepted, isTrue);
    });

    testWidgets(
        'renders JoinFindrSheet inside Scaffold and SafeArea without drag handle',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            finderNotifierProvider.overrideWith(() => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const JoinFindrSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Findr Agreement'), findsOneWidget);
    });

    testWidgets('adapts safely to elevated text scale (1.5x) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            finderNotifierProvider.overrideWith(() => notifier),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(1.5),
                padding: EdgeInsets.only(top: 44.0),
              ),
              child: Scaffold(
                body: FinderOnboardingSheet(isStandalone: true),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Findr Agreement'), findsOneWidget);
    });
  });
}

