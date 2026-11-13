import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/palette.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_card.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';

void main() {
  Widget wrapWithTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  Widget wrapWithDarkTheme(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
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

    testWidgets('AppButton satisfies accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapWithTheme(
          Center(
            child: AppButton(label: 'Submit Booking', onPressed: () {}),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets(
      'AppButton brandWhite variant renders pill shape, tokens, and disabled state',
      (tester) async {
        await tester.pumpWidget(
          wrapWithDarkTheme(
            AppButton(
              label: 'Create account',
              variant: AppButtonVariant.brandWhite,
              onPressed: () {},
            ),
          ),
        );

        final buttonFinder = find.byType(ElevatedButton);
        expect(buttonFinder, findsOneWidget);
        expect(find.text('Create account'), findsOneWidget);
        expect(tester.getSize(buttonFinder).height, 72.0);

        final textWidget = tester.widget<Text>(find.text('Create account'));
        expect(textWidget.textAlign, TextAlign.center);

        // Disabled state test
        await tester.pumpWidget(
          wrapWithDarkTheme(
            AppButton(
              label: 'Create account',
              variant: AppButtonVariant.brandWhite,
              enabled: false,
              onPressed: () {},
            ),
          ),
        );

        final disabledButton = tester.widget<ElevatedButton>(buttonFinder);
        expect(disabledButton.onPressed, isNull);
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

    testWidgets(
      'ErrorView.fromError resolves user-safe message from raw exception',
      (tester) async {
        var retried = false;

        await tester.pumpWidget(
          wrapWithTheme(
            ErrorView.fromError(
              error: Exception('Internal network socket reset 500'),
              title: 'Could not load',
              onRetry: () => retried = true,
            ),
          ),
        );

        expect(find.text('Could not load'), findsOneWidget);
        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
        expect(find.text('Try Again'), findsOneWidget);

        await tester.tap(find.text('Try Again'));
        await tester.pump();
        expect(retried, isTrue);
      },
    );

    testWidgets(
      'BrandTextField renders label, placeholder, and uses transparent input decoration in dark theme',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          wrapWithDarkTheme(
            BrandTextField(
              label: 'Email',
              placeholder: 'Enter your email address',
              controller: controller,
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email address'), findsOneWidget);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.filled, isTrue);
        expect(
          textField.decoration?.fillColor,
          AppColors.dark.brandFieldBackground,
        );

        await tester.enterText(find.byType(TextField), 'test@example.com');
        await tester.pump();
        expect(controller.text, 'test@example.com');
      },
    );

    testWidgets('BrandTextField renders visible error state below pill', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrapWithTheme(
          Form(
            key: formKey,
            child: BrandTextField(
              label: 'Email',
              placeholder: 'Enter your email address',
              validator: (v) => 'Email is required',
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.errorBorder, isNotNull);
    });

    testWidgets('BrandTextField obscurable toggles obscured state', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const BrandTextField(
            label: 'Password',
            placeholder: 'Enter your password',
            obscurable: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      await tester.tap(find.bySemanticsLabel('Show password'));
      await tester.pump();

      final updatedField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedField.obscureText, isFalse);
    });

    testWidgets(
      'FindrCard renders visible dark mode tokens in notJoined state',
      (tester) async {
        await tester.pumpWidget(
          wrapWithDarkTheme(const FindrCard(state: FindrState.notJoined)),
        );

        expect(find.byType(FindrCard), findsOneWidget);

        // Card container background is paperDark
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(FindrCard),
            matching: find.byType(Container).first,
          ),
        );
        final boxDecoration = container.decoration as BoxDecoration;
        expect(boxDecoration.color, Palette.paperDark);

        // Description text is paperInk2Dark (high contrast, warm parchment)
        final descText = tester.widget<Text>(
          find.text(
            'Know a hotel worth staying in? Recommend it. When they '
            'join TRVLez, you earn a share of what they book.',
          ),
        );
        expect(descText.style?.color, Palette.paperInk2Dark);

        // Heading prefix is paperInkDark
        final headingText = tester.widget<Text>(
          find.descendant(
            of: find.byType(FindrHeading),
            matching: find.byType(Text),
          ),
        );
        final span = headingText.textSpan as TextSpan?;
        final prefixSpan = span?.children?.first as TextSpan?;
        expect(prefixSpan?.style?.color, Palette.paperInkDark);

        // Icon tile background is AppColors.white
        final iconTile = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(FindrHeading),
                matching: find.byType(Container),
              )
              .first,
        );
        final iconTileDecoration = iconTile.decoration as BoxDecoration;
        expect(iconTileDecoration.color, AppColors.white);

        // CTA button text is textOnAction
        final ctaText = tester.widget<Text>(find.text('Activate Findr'));
        expect(ctaText.style?.color, AppColors.dark.textOnAction);
      },
    );

    testWidgets('FindrCard renders visible dark mode tokens in active state', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithDarkTheme(
          const FindrCard(
            state: FindrState.active,
            earned: '£120.00',
            joined: 4,
            inReview: 1,
            due: '£45.00',
            dueDate: '1 Nov',
          ),
        ),
      );

      // Earned amount is paperInkDark
      final earnedText = tester.widget<Text>(find.text('£120.00'));
      expect(earnedText.style?.color, Palette.paperInkDark);

      // 'earned so far' is paperInk2Dark
      final earnedLabel = tester.widget<Text>(find.text('earned so far'));
      expect(earnedLabel.style?.color, Palette.paperInk2Dark);

      // Stat values are paperInkDark
      final joinedVal = tester.widget<Text>(find.text('4'));
      expect(joinedVal.style?.color, Palette.paperInkDark);

      // Stat labels are paperInk2Dark
      final joinedLabel = tester.widget<Text>(find.text('joined'));
      expect(joinedLabel.style?.color, Palette.paperInk2Dark);

      final reviewLabel = tester.widget<Text>(find.text('in review'));
      expect(reviewLabel.style?.color, Palette.paperInk2Dark);
    });
  });
}
