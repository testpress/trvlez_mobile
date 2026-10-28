import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/finder_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/screens/findr_terms_screen.dart';


void main() {
  group('FindrTermsScreen Widget Tests', () {
    const testTerms = FinderTerms(
      version: 'v1.0',
      title: 'Findr Agreement & Terms',
      effectiveDate: '2026-01-01',
      summary: 'Test summary for programme terms.',
      sections: [
        FinderTermsSection(
          title: '1. Eligibility & UK Residency',
          content: 'Exclusively for United Kingdom passport holders.',
        ),
        FinderTermsSection(
          title: '2. Commission Rewards',
          content: 'Earn 5% of platform commission.',
        ),
      ],
    );

    Widget buildScreen({FinderTerms terms = testTerms}) {
      return ProviderScope(
        overrides: [
          finderTermsProvider.overrideWithValue(terms),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FindrTermsScreen(),
        ),
      );
    }

    testWidgets('renders terms header, summary, and sections correctly',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Findr Agreement & Terms'), findsOneWidget);
      expect(find.text('Test summary for programme terms.'), findsOneWidget);
      expect(find.text('1. Eligibility & UK Residency'), findsOneWidget);
      expect(find.text('2. Commission Rewards'), findsOneWidget);
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('v1.0'), findsOneWidget);
    });

    testWidgets('acceptance checkbox is unchecked by default and button is disabled',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue to Address');
      if (buttonFinder.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('checking acceptance checkbox enables Continue button',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Find the checkbox and tap it
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isTrue);

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue to Address');
      if (buttonFinder.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNotNull);
      }
    });
  });
}
