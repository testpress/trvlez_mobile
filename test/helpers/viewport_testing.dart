import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// Named system-inset configuration for cross-device widget tests.
///
/// Logical sizes alone do not reproduce SafeArea / keyboard defects.
/// Apply a profile after [ViewportTesting.setViewport] so `MediaQuery`
/// padding, viewPadding, and viewInsets match the scenario under test.
///
/// Reference: docs/engineering/playbook/05-visual-validation-standard.md
@immutable
class TestInsetProfile {
  const TestInsetProfile({
    required this.name,
    this.padding = FakeViewPadding.zero,
    this.viewPadding = FakeViewPadding.zero,
    this.viewInsets = FakeViewPadding.zero,
  });

  /// Short label used in matrix test names.
  final String name;

  /// [MediaQuery.padding] — safe padding after the current view state.
  final FakeViewPadding padding;

  /// [MediaQuery.viewPadding] — stable system-area padding.
  final FakeViewPadding viewPadding;

  /// [MediaQuery.viewInsets] — obscured space (keyboard).
  final FakeViewPadding viewInsets;
}

/// Synthetic inset profiles for exercising distinct phone-layout behaviours.
///
/// These are deliberately not handset emulators. Real inset values vary with
/// OS version, cut-out, navigation mode, and keyboard. Use them to make
/// ownership defects reproducible in widget tests, then record actual runtime
/// values for emulator/simulator or physical-device evidence.
abstract final class TestInsetProfiles {
  /// Android status bar with gesture navigation.
  static const androidGestureNav = TestInsetProfile(
    name: 'android-gesture-nav',
    padding: FakeViewPadding(top: 24, bottom: 24),
    viewPadding: FakeViewPadding(top: 24, bottom: 24),
  );

  /// Android status bar with a three-button navigation bar.
  static const androidThreeButton = TestInsetProfile(
    name: 'android-3button-nav',
    padding: FakeViewPadding(top: 24, bottom: 48),
    viewPadding: FakeViewPadding(top: 24, bottom: 48),
  );

  /// Android cut-out with gesture navigation.
  static const androidCutoutGestureNav = TestInsetProfile(
    name: 'android-cutout-gesture-nav',
    padding: FakeViewPadding(top: 36, bottom: 24),
    viewPadding: FakeViewPadding(top: 36, bottom: 24),
  );

  /// Compact iPhone without a home indicator.
  static const iOSCompact = TestInsetProfile(
    name: 'ios-compact',
    padding: FakeViewPadding(top: 20),
    viewPadding: FakeViewPadding(top: 20),
  );

  /// Face ID iPhone with a top cut-out and home indicator.
  static const iOSHomeIndicator = TestInsetProfile(
    name: 'ios-home-indicator',
    padding: FakeViewPadding(top: 47, bottom: 34),
    viewPadding: FakeViewPadding(top: 47, bottom: 34),
  );

  /// Keyboard open: viewInsets consume bottom; padding.bottom clears.
  ///
  /// Mirrors typical framework behaviour where `viewPadding.bottom` remains
  /// while `padding.bottom` is zero and `viewInsets.bottom` is the keyboard.
  static const androidKeyboardOpen = TestInsetProfile(
    name: 'android-keyboard-open',
    padding: FakeViewPadding(top: 24),
    viewPadding: FakeViewPadding(top: 24, bottom: 24),
    viewInsets: FakeViewPadding(bottom: 300),
  );

  /// Face ID iPhone with a visible keyboard.
  static const iOSKeyboardOpen = TestInsetProfile(
    name: 'ios-keyboard-open',
    padding: FakeViewPadding(top: 47),
    viewPadding: FakeViewPadding(top: 47, bottom: 34),
    viewInsets: FakeViewPadding(bottom: 336),
  );

  /// Profiles used for material-layout inset matrices.
  static const materialLayoutDefaults = [
    androidGestureNav,
    androidThreeButton,
    androidCutoutGestureNav,
    iOSHomeIndicator,
  ];
}

/// One required cross-device scenario for a material screen test.
@immutable
class MaterialScreenTestScenario {
  const MaterialScreenTestScenario({
    required this.name,
    required this.viewport,
    required this.textScaler,
    required this.insetProfile,
  });

  final String name;
  final Size viewport;
  final TextScaler textScaler;
  final TestInsetProfile insetProfile;

  bool get keyboardIsOpen => insetProfile.viewInsets.bottom > 0;
}

/// Required baseline matrix for a material phone screen.
///
/// The matrix covers compact and regular geometry, routine and accessibility
/// text scaling, Android navigation variance, iOS home-indicator space, and a
/// keyboard-obscured viewport. A screen test supplies its own product-specific
/// assertions through [testMaterialScreenMatrix].
abstract final class MaterialScreenTestScenarios {
  static const required = <MaterialScreenTestScenario>[
    MaterialScreenTestScenario(
      name: 'compact-android-gesture-text-1.0',
      viewport: TestViewports.compactAndroid,
      textScaler: TestTextScales.normal,
      insetProfile: TestInsetProfiles.androidGestureNav,
    ),
    MaterialScreenTestScenario(
      name: 'regular-android-3button-text-1.0',
      viewport: TestViewports.regularAndroid,
      textScaler: TestTextScales.normal,
      insetProfile: TestInsetProfiles.androidThreeButton,
    ),
    MaterialScreenTestScenario(
      name: 'compact-android-gesture-text-1.3',
      viewport: TestViewports.compactAndroid,
      textScaler: TestTextScales.large,
      insetProfile: TestInsetProfiles.androidGestureNav,
    ),
    MaterialScreenTestScenario(
      name: 'compact-android-gesture-text-2.0',
      viewport: TestViewports.compactAndroid,
      textScaler: TestTextScales.accessibility,
      insetProfile: TestInsetProfiles.androidGestureNav,
    ),
    MaterialScreenTestScenario(
      name: 'regular-ios-home-indicator-text-1.0',
      viewport: TestViewports.regularIPhone,
      textScaler: TestTextScales.normal,
      insetProfile: TestInsetProfiles.iOSHomeIndicator,
    ),
  ];
}

/// Extension on [WidgetTester] for controlled viewport and inset testing.
///
/// Sets physical size, pixel ratio, and optional system insets. Always call
/// [addTearDown] with [resetViewport] to avoid leaking state between tests.
///
/// Reference: docs/engineering/playbook/06-testing-device-matrix.md
extension ViewportTesting on WidgetTester {
  /// Configures the test viewport to a specific logical size.
  ///
  /// Sets [devicePixelRatio] to 1.0 so [physicalSize] equals logical size.
  /// Call [addTearDown] with [resetViewport] after using this.
  void setViewport(Size logicalSize, {double devicePixelRatio = 1.0}) {
    view.physicalSize = logicalSize * devicePixelRatio;
    view.devicePixelRatio = devicePixelRatio;
  }

  /// Applies a named [TestInsetProfile] to the test view.
  ///
  /// Call after [setViewport]. [resetViewport] clears inset overrides.
  void setInsetProfile(TestInsetProfile profile) {
    view.padding = profile.padding;
    view.viewPadding = profile.viewPadding;
    view.viewInsets = profile.viewInsets;
  }

  /// Resets viewport size, DPR, and inset overrides to Flutter test defaults.
  void resetViewport() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.resetPadding();
    view.resetViewPadding();
    view.resetViewInsets();
  }
}

/// Runs a test callback at every viewport in the provided list.
void testViewportMatrix(
  String description, {
  required List<Size> viewports,
  required Future<void> Function(WidgetTester tester, Size viewport) builder,
  TestInsetProfile? insetProfile,
}) {
  for (final viewport in viewports) {
    final label = '${viewport.width.toInt()}x${viewport.height.toInt()}';

    testWidgets('$description [$label]', (tester) async {
      tester.setViewport(viewport);
      if (insetProfile != null) {
        tester.setInsetProfile(insetProfile);
      }
      addTearDown(tester.resetViewport);

      await builder(tester, viewport);
    });
  }
}

/// Runs a test callback at multiple text scale factors.
void testTextScaleMatrix(
  String description, {
  required Size viewport,
  required List<TextScaler> scales,
  required Future<void> Function(WidgetTester tester, TextScaler scale) builder,
  TestInsetProfile? insetProfile,
}) {
  for (final scale in scales) {
    final factor = scale.scale(1.0);
    final label = 'text-${factor.toStringAsFixed(1)}';

    testWidgets('$description [$label]', (tester) async {
      tester.setViewport(viewport);
      if (insetProfile != null) {
        tester.setInsetProfile(insetProfile);
      }
      addTearDown(tester.resetViewport);

      await builder(tester, scale);
    });
  }
}

/// Runs a test callback at every inset profile in the provided list.
void testInsetMatrix(
  String description, {
  required Size viewport,
  required List<TestInsetProfile> profiles,
  required Future<void> Function(WidgetTester tester, TestInsetProfile profile)
  builder,
}) {
  for (final profile in profiles) {
    testWidgets('$description [${profile.name}]', (tester) async {
      tester.setViewport(viewport);
      tester.setInsetProfile(profile);
      addTearDown(tester.resetViewport);

      await builder(tester, profile);
    });
  }
}

/// Runs a material screen through the required cross-device baseline matrix.
///
/// The callback must pump the screen with [scenario.textScaler] using
/// [TestApp] or [testAppWithProviders], then assert the screen's critical
/// content is visible and usable. This harness verifies the requested window
/// and inset state and fails on any uncaught Flutter framework exception.
void testMaterialScreenMatrix(
  String description, {
  required Future<void> Function(
    WidgetTester tester,
    MaterialScreenTestScenario scenario,
  )
  builder,
  List<MaterialScreenTestScenario> scenarios =
      MaterialScreenTestScenarios.required,
}) {
  for (final scenario in scenarios) {
    testWidgets('$description [${scenario.name}]', (tester) async {
      tester.setViewport(scenario.viewport);
      tester.setInsetProfile(scenario.insetProfile);
      addTearDown(tester.resetViewport);

      await builder(tester, scenario);
      expect(tester.takeException(), isNull);
    });
  }
}
