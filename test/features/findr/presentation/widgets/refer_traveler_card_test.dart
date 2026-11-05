import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_traveler_card.dart';

void main() {
  group('ReferTravelerCard Widget Tests', () {
    testWidgets('renders permanent share code and copy/share buttons',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ReferTravelerCard(
              shareCode: 'TRV-FIND-XYZ789',
              shareUrl: 'https://trvlez.com/r/TRV-FIND-XYZ789',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Refer a Traveler'), findsOneWidget);
      expect(find.text('TRV-FIND-XYZ789'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('tapping Copy Link triggers clipboard copy and toast',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ReferTravelerCard(
              shareCode: 'TRV-FIND-XYZ789',
              shareUrl: 'https://trvlez.com/r/TRV-FIND-XYZ789',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Link'));
      await tester.pumpAndSettle();

      expect(
        find.text('Traveler referral link copied to clipboard'),
        findsOneWidget,
      );
    });
  });
}
