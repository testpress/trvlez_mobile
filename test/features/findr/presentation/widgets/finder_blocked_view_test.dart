import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_blocked_view.dart';

void main() {
  group('FinderBlockedView Widget Tests', () {
    Widget buildWidget({
      required FinderEligibility eligibility,
      String? title,
      String? message,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: FinderBlockedView(
            eligibility: eligibility,
            title: title,
            message: message,
          ),
        ),
      );
    }

    testWidgets('renders Market Capacity Reached with default message', (
      tester,
    ) async {
      const eligibility = FinderEligibility(
        isEligible: false,
        reason: FinderEligibilityReason.marketLimitReached,
      );

      await tester.pumpWidget(buildWidget(eligibility: eligibility));
      await tester.pumpAndSettle();

      expect(find.text('Market Capacity Reached'), findsOneWidget);
      expect(
        find.text(
          'The Findr programme in your market has reached its maximum onboarding capacity. Please check back later.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders dynamic backend message when present in eligibility', (
      tester,
    ) async {
      const eligibility = FinderEligibility(
        isEligible: false,
        reason: FinderEligibilityReason.marketLimitReached,
        message:
            'The maximum number of Finders for market GB has been reached.',
      );

      await tester.pumpWidget(buildWidget(eligibility: eligibility));
      await tester.pumpAndSettle();

      expect(find.text('Market Capacity Reached'), findsOneWidget);
      expect(
        find.text(
          'The maximum number of Finders for market GB has been reached.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('explicit message parameter overrides eligibility message', (
      tester,
    ) async {
      const eligibility = FinderEligibility(
        isEligible: false,
        reason: FinderEligibilityReason.marketLimitReached,
        message:
            'The maximum number of Finders for market GB has been reached.',
      );

      await tester.pumpWidget(
        buildWidget(
          eligibility: eligibility,
          message: 'Direct override message',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Market Capacity Reached'), findsOneWidget);
      expect(find.text('Direct override message'), findsOneWidget);
    });
  });
}
