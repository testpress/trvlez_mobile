import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/app_error_banner.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppErrorBanner Widget Tests', () {
    testWidgets('returns shrink when message is null or empty', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: Scaffold(body: AppErrorBanner(message: null))),
      );
      expect(find.byType(AppErrorBanner), findsOneWidget);
      expect(find.byType(Container), findsNothing);

      await tester.pumpWidget(
        const TestApp(
          child: Scaffold(body: AppErrorBanner(message: '   ')),
        ),
      );
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders standard variant and handles dismiss action', (
      tester,
    ) async {
      var dismissed = false;

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: AppErrorBanner(
              message: 'Unable to connect to server',
              variant: AppErrorBannerVariant.standard,
              onDismiss: () => dismissed = true,
            ),
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

    testWidgets('satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: AppErrorBanner(
              message: 'Connection failed',
              onDismiss: () {},
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('renders brand variant with brand styling and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          theme: AppTheme.darkTheme,
          child: const Scaffold(
            body: AppErrorBanner(
              message: 'Invalid credentials entered',
              variant: AppErrorBannerVariant.brand,
            ),
          ),
        ),
      );

      expect(find.text('Invalid credentials entered'), findsOneWidget);
      expect(find.byType(AppErrorBanner), findsOneWidget);
    });

    testWidgets('preserves layout under 2.0x text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          textScaler: TextScaler.linear(2.0),
          child: Scaffold(
            body: AppErrorBanner(
              message:
                  'A very long detailed error message describing that something failed in network communication.',
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
