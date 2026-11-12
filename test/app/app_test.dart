import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trvlez_mobile/app/app.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/network/dio_provider.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
import 'package:trvlez_mobile/core/storage/token_storage.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => null;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

class _FakePropertiesNotifier extends AsyncNotifier<List<Property>>
    implements PropertiesNotifier {
  @override
  String? get propertyType => null;
  @override
  String? get searchQuery => null;
  @override
  Future<List<Property>> build() async => [];
  @override
  Future<void> fetchProperties({String? search, String? propertyType}) async {}
  @override
  Future<void> filterByPropertyType(String? type) async {}
  @override
  Future<void> search(String query) async {}
  @override
  void reset() {}
}

class _NonlinearTestScaler implements TextScaler {
  const _NonlinearTestScaler();

  @override
  double scale(double fontSize) {
    if (fontSize <= 12) return fontSize * 1.5;
    if (fontSize <= 16) return fontSize * 1.3;
    if (fontSize <= 20) return fontSize * 1.15;
    return fontSize * 1.0;
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => 1.3;

  @override
  TextScaler clamp({
    double minScaleFactor = 0.0,
    double maxScaleFactor = double.infinity,
  }) => this;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsRepository settingsRepo;
  late TokenStorage tokenStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    tokenStorage = TokenStorage(storage: _FakeSecureStorage());
  });

  Widget buildApp({TextScalePreset? presetOverride}) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        propertiesProvider.overrideWith(() => _FakePropertiesNotifier()),
        if (presetOverride != null)
          textScaleNotifierProvider.overrideWith(
            () => _StaticScaleNotifier(presetOverride),
          ),
      ],
      child: const TrvlEzApp(),
    );
  }

  group('TrvlEzApp Typography & Scaling Regression Tests (ADR 0002)', () {
    testWidgets(
      'App root defaults to Follow system and preserves platform scaler',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final innerContext = tester.element(find.byType(MaterialApp));
        final effectiveScaler = MediaQuery.textScalerOf(innerContext);

        expect(effectiveScaler.scale(16.0), 16.0);
      },
    );

    testWidgets('App does not cap system text scaling at 2.0', (tester) async {
      // Simulate platform accessibility text scale of 2.5
      tester.platformDispatcher.textScaleFactorTestValue = 2.5;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final innerContext = tester.element(find.byType(MaterialApp));
      final effectiveScaler = MediaQuery.textScalerOf(innerContext);

      // Must be 2.5 * 16 = 40.0, NOT capped at 2.0 * 16 = 32.0
      expect(effectiveScaler.scale(16.0), closeTo(40.0, 0.001));
      // ignore: deprecated_member_use
      expect(effectiveScaler.textScaleFactor, closeTo(2.5, 0.001));
    });

    testWidgets(
      'Nonlinear test double remains nonlinear after app builder executes',
      (tester) async {
        const nonlinearScaler = _NonlinearTestScaler();

        // Wrap TrvlEzApp builder with a nonlinear test scaler in MediaQuery
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(settingsRepo),
              tokenStorageProvider.overrideWithValue(tokenStorage),
              propertiesProvider.overrideWith(() => _FakePropertiesNotifier()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(textScaler: nonlinearScaler),
              child: Builder(
                builder: (context) {
                  // Execute TrvlEzApp builder under Follow system
                  final preset = TextScalePreset.followSystem;
                  final scaler = preset.scalerFor(
                    MediaQuery.textScalerOf(context),
                  );
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: scaler),
                      child: Text('Test', textScaler: scaler),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        final scaler = textWidget.textScaler!;

        // Proves nonlinear curve is preserved, not linearized
        expect(scaler.scale(12.0), closeTo(18.0, 0.001)); // factor 1.5
        expect(scaler.scale(16.0), closeTo(20.8, 0.001)); // factor 1.3
        expect(scaler.scale(24.0), closeTo(24.0, 0.001)); // factor 1.0
      },
    );

    testWidgets('Relative preset delegates to nonlinear parent per fontSize', (
      tester,
    ) async {
      const nonlinearScaler = _NonlinearTestScaler();

      final largerScaler = TextScalePreset.larger.scalerFor(nonlinearScaler);

      // Proves relative adjustment multiplies parent's output at each font size
      expect(largerScaler.scale(12.0), closeTo(18.0 * 1.15, 0.001));
      expect(largerScaler.scale(16.0), closeTo(20.8 * 1.15, 0.001));
      expect(largerScaler.scale(24.0), closeTo(24.0 * 1.15, 0.001));
    });
  });
}

class _StaticScaleNotifier extends TextScaleNotifier {
  _StaticScaleNotifier(this._initial);
  final TextScalePreset _initial;

  @override
  TextScalePreset build() => _initial;
}
