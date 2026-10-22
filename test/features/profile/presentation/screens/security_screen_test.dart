import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/storage/passcode_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/security_screen.dart';

class FakePasscodeStorage extends Fake implements PasscodeStorage {
  bool enabled = false;

  @override
  Future<bool> isPasscodeEnabled() async => enabled;

  @override
  Future<void> setPasscodeEnabled(bool isEnabled) async {
    enabled = isEnabled;
  }
}

void main() {
  group('SecurityScreen Widget Tests', () {
    late SettingsRepository settingsRepo;
    late FakePasscodeStorage passcodeStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsRepo = SettingsRepository(prefs);
      passcodeStorage = FakePasscodeStorage();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          passcodeStorageProvider.overrideWithValue(passcodeStorage),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SecurityScreen(),
        ),
      );
    }

    testWidgets(
      'Renders Password, Passcode, Two-step, and Keychain disclaimer',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Security'), findsOneWidget);

        // Password row
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('••••••••'), findsOneWidget);
        expect(find.text('Change'), findsOneWidget);

        // App passcode row
        expect(find.text('App passcode'), findsOneWidget);
        expect(find.text('Off'), findsOneWidget);

        // Two-step verification row
        expect(find.text('Two-step verification'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);

        // Keychain note
        expect(
          find.textContaining('lives in the Keychain — never on a server'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Toggling Two-step verification switch updates state', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final switchWidgetBefore = tester.widget<Switch>(switchFinder);
      expect(switchWidgetBefore.value, isFalse);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final switchWidgetAfter = tester.widget<Switch>(switchFinder);
      expect(switchWidgetAfter.value, isTrue);
      expect(settingsRepo.isTwoStepVerificationEnabled(), isTrue);
    });
  });
}
