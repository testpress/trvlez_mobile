import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/app_error_banner.dart';

void main() {
  Widget wrap(Widget child, {bool dark = false}) {
    return MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('AppErrorBanner Widget Tests', () {
    testWidgets('returns shrink when message is null or empty', (tester) async {
      await tester.pumpWidget(wrap(const AppErrorBanner(message: null)));
      expect(find.byType(AppErrorBanner), findsOneWidget);
      expect(find.byType(Container), findsNothing);

      await tester.pumpWidget(wrap(const AppErrorBanner(message: '   ')));
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders standard variant and handles dismiss action', (
      tester,
    ) async {
      var dismissed = false;

      await tester.pumpWidget(
        wrap(
          AppErrorBanner(
            message: 'Unable to connect to server',
            variant: AppErrorBannerVariant.standard,
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(find.text('Unable to connect to server'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      final dismissFinder = find.byTooltip('Dismiss error');
      expect(dismissFinder, findsOneWidget);

      // Verify touch target is at least 48x48
      final dismissSize = tester.getSize(dismissFinder);
      expect(dismissSize.width, greaterThanOrEqualTo(48.0));
      expect(dismissSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(dismissFinder);
      await tester.pump();
      expect(dismissed, isTrue);
    });

    testWidgets('renders brand variant with brand styling and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppErrorBanner(
            message: 'Invalid credentials entered',
            variant: AppErrorBannerVariant.brand,
          ),
          dark: true,
        ),
      );

      expect(find.text('Invalid credentials entered'), findsOneWidget);
      expect(find.byType(AppErrorBanner), findsOneWidget);
    });

    testWidgets('preserves layout under 2.0x text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: AppErrorBanner(
                message:
                    'A very long detailed error message describing that something failed in network communication.',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.text(
          'A very long detailed error message describing that something failed in network communication.',
        ),
        findsOneWidget,
      );
    });
  });
}
