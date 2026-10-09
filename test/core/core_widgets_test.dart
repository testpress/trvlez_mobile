import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_card.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';

void main() {
  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('Core Widgets', () {
    testWidgets(
      'AppButton renders label, handles taps, and shows spinner when loading',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrapWithTheme(
            AppButton(label: 'Submit Booking', onPressed: () => tapped = true),
          ),
        );

        expect(find.text('Submit Booking'), findsOneWidget);
        await tester.tap(find.byType(AppButton));
        await tester.pump();
        expect(tapped, isTrue);

        // Loading state
        await tester.pumpWidget(
          wrapWithTheme(
            AppButton(
              label: 'Submit Booking',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit Booking'), findsNothing);
      },
    );

    testWidgets('AppTextField renders label, hint, and accepts user input', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        wrapWithTheme(
          AppTextField(
            label: 'Full Name',
            hintText: 'Enter your name',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Jane Doe');
      await tester.pump();

      expect(controller.text, 'Jane Doe');
    });

    testWidgets(
      'AppCard renders child and handles taps when onTap is provided',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          wrapWithTheme(
            AppCard(
              onTap: () => tapped = true,
              child: const Text('Hotel Card'),
            ),
          ),
        );

        expect(find.text('Hotel Card'), findsOneWidget);
        await tester.tap(find.text('Hotel Card'));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets('LoadingView renders spinner and message', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(const LoadingView(message: 'Loading reservations...')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading reservations...'), findsOneWidget);
    });

    testWidgets(
      'ErrorView displays message, title, and invokes retry callback',
      (tester) async {
        var retried = false;

        await tester.pumpWidget(
          wrapWithTheme(
            ErrorView(
              title: 'Failed to load',
              message: 'Connection timeout',
              onRetry: () => retried = true,
            ),
          ),
        );

        expect(find.text('Failed to load'), findsOneWidget);
        expect(find.text('Connection timeout'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        await tester.tap(find.text('Try Again'));
        await tester.pump();
        expect(retried, isTrue);
      },
    );
  });
}
