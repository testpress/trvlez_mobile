import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/preferences_screen.dart';

void main() {
  group('PreferencesScreen Widget Tests', () {
    late SettingsRepository settingsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsRepo = SettingsRepository(prefs);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(settingsRepo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PreferencesScreen(),
        ),
      );
    }

    testWidgets(
      'Renders Text size control with 4 ezChat presets and preview card',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Reading'), findsOneWidget);
        expect(find.text('Text size'), findsOneWidget);

        // Four named presets
        expect(find.text('Smaller'), findsOneWidget);
        expect(find.text('Normal'), findsOneWidget);
        expect(find.text('Larger'), findsOneWidget);
        expect(find.text('Largest'), findsOneWidget);

        // Live preview box
        expect(find.text('PREVIEW (ILLUSTRATIVE)'), findsOneWidget);
        expect(find.text('Grand Ocean Hotel'), findsOneWidget);
        expect(
          find.text('Lisbon · 2–6 Nov · check-in from 3pm'),
          findsOneWidget,
        );

        // Appearance / Theme row
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
      },
    );

    testWidgets('Tapping Larger preset updates selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final largerBtn = find.text('Larger');
      await tester.tap(largerBtn);
      await tester.pumpAndSettle();

      expect(settingsRepo.getTextScalePreset(), TextScalePreset.larger);
    });

    testWidgets('Tapping Normal preset updates selection', (tester) async {
      await settingsRepo.setTextScalePreset(TextScalePreset.larger);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final normalBtn = find.text('Normal');
      await tester.tap(normalBtn);
      await tester.pumpAndSettle();

      expect(settingsRepo.getTextScalePreset(), TextScalePreset.followSystem);
    });
  });
}
