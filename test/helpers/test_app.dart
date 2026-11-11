import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';

/// Deterministic test wrapper for widget and golden tests.
///
/// Provides controlled viewport size, text scale, theme, locale,
/// and optional Riverpod provider overrides — without changing
/// production UI code.
///
/// Reference: docs/engineering/playbook/05-visual-validation-standard.md
class TestApp extends StatelessWidget {
  const TestApp({
    required this.child,
    this.theme,
    this.textScaler,
    this.locale,
    this.supportedLocales,
    super.key,
  });

  final Widget child;

  /// Defaults to [AppTheme.lightTheme] when null.
  final ThemeData? theme;

  /// System text scale override. Defaults to 1.0 (no scaling).
  final TextScaler? textScaler;

  /// Locale override. Defaults to en_US.
  final Locale? locale;

  /// Supported locales passed to [MaterialApp].
  ///
  /// Defaults to `{en_US, locale}` so non-US locale overrides resolve rather
  /// than falling back to `en_US`.
  final Iterable<Locale>? supportedLocales;

  @override
  Widget build(BuildContext context) {
    final scaler = textScaler;
    final effectiveLocale = locale ?? const Locale('en', 'US');
    final effectiveSupportedLocales =
        supportedLocales ?? <Locale>{const Locale('en', 'US'), effectiveLocale};

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.lightTheme,
      locale: effectiveLocale,
      supportedLocales: effectiveSupportedLocales,
      home: child,
      // Inject text scale inside MaterialApp's own MediaQuery so it
      // is not overwritten by the framework's view-based MediaQuery.
      builder: scaler != null
          ? (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: child!,
              );
            }
          : null,
    );
  }
}

/// Wraps [child] in a [ProviderScope] and [TestApp] with optional overrides.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   testAppWithProviders(
///     child: const MyScreen(),
///     overrides: [myProvider.overrideWithValue(fakeValue)],
///   ),
/// );
/// ```
Widget testAppWithProviders({
  required Widget child,
  List<Override> overrides = const [],
  ThemeData? theme,
  TextScaler? textScaler,
  Locale? locale,
  Iterable<Locale>? supportedLocales,
}) {
  return ProviderScope(
    overrides: overrides,
    child: TestApp(
      theme: theme,
      textScaler: textScaler,
      locale: locale,
      supportedLocales: supportedLocales,
      child: child,
    ),
  );
}

/// Standard logical viewport sizes for the phone device matrix.
///
/// These match the test categories in:
///   docs/engineering/playbook/06-testing-device-matrix.md
///
/// Usage with WidgetTester:
/// ```dart
/// tester.view.physicalSize = TestViewports.compactAndroid;
/// tester.view.devicePixelRatio = 1.0;
/// addTearDown(() => tester.view.resetPhysicalSize());
/// addTearDown(() => tester.view.resetDevicePixelRatio());
/// ```
abstract final class TestViewports {
  // ── Android ──────────────────────────────────────────────────────
  /// Compact Android: ~360 × 640 dp (e.g. older 5" phones)
  static const compactAndroid = Size(360, 640);

  /// Regular Android: ~393 × 852 dp (e.g. Pixel 8)
  static const regularAndroid = Size(393, 852);

  /// Tall Android: ~412 × 915 dp (e.g. Pixel 9 Pro)
  static const tallAndroid = Size(412, 915);

  /// Large Android: ~432 × 932 dp (e.g. Galaxy S24 Ultra)
  static const largeAndroid = Size(432, 932);

  // ── iOS ──────────────────────────────────────────────────────────
  /// Compact iPhone: ~375 × 667 dp (e.g. iPhone SE / 8)
  static const compactIPhone = Size(375, 667);

  /// Regular iPhone: ~393 × 852 dp (e.g. iPhone 15 / 16)
  static const regularIPhone = Size(393, 852);

  /// Tall iPhone: ~430 × 932 dp (e.g. iPhone 16 Pro Max)
  static const tallIPhone = Size(430, 932);

  /// All Android viewport sizes for matrix testing.
  static const androidAll = [
    compactAndroid,
    regularAndroid,
    tallAndroid,
    largeAndroid,
  ];

  /// All iOS viewport sizes for matrix testing.
  static const iosAll = [compactIPhone, regularIPhone, tallIPhone];

  /// All phone viewports across both platforms.
  static const all = [
    compactAndroid,
    regularAndroid,
    tallAndroid,
    largeAndroid,
    compactIPhone,
    regularIPhone,
    tallIPhone,
  ];
}

/// Standard text scale values for accessibility testing.
abstract final class TestTextScales {
  /// Default system text scale.
  static const normal = TextScaler.linear(1.0);

  /// Moderately enlarged (common accessibility setting).
  static const large = TextScaler.linear(1.3);

  /// Maximum standard Android/iOS scaling.
  static const extraLarge = TextScaler.linear(1.5);

  /// Accessibility extreme (iOS "Accessibility Sizes").
  static const accessibility = TextScaler.linear(2.0);
}
