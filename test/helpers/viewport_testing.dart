import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Standard inset profiles aligned with chapter 06 device scenarios.
abstract final class TestInsetProfiles {
  /// Android gesture navigation: status bar + bottom gesture inset.
  static const androidGestureNav = TestInsetProfile(
    name: 'android-gesture-nav',
    padding: FakeViewPadding(top: 24, bottom: 48),
    viewPadding: FakeViewPadding(top: 24, bottom: 48),
  );

  /// Android 3-button navigation: status bar + nav-bar inset.
  static const androidThreeButton = TestInsetProfile(
    name: 'android-3button-nav',
    padding: FakeViewPadding(top: 24, bottom: 48),
    viewPadding: FakeViewPadding(top: 24, bottom: 48),
  );

  /// Notched / punch-hole top inset with gesture bottom.
  static const notchedGestureNav = TestInsetProfile(
    name: 'notched-gesture-nav',
    padding: FakeViewPadding(top: 44, bottom: 34),
    viewPadding: FakeViewPadding(top: 44, bottom: 34),
  );

  /// Keyboard open: viewInsets consume bottom; padding.bottom clears.
  ///
  /// Mirrors typical framework behaviour where `viewPadding.bottom` remains
  /// while `padding.bottom` is zero and `viewInsets.bottom` is the keyboard.
  static const keyboardOpen = TestInsetProfile(
    name: 'keyboard-open',
    padding: FakeViewPadding(top: 24),
    viewPadding: FakeViewPadding(top: 24, bottom: 48),
    viewInsets: FakeViewPadding(bottom: 300),
  );

  /// Profiles used for material-layout inset matrices.
  static const materialLayoutDefaults = [
    androidGestureNav,
    androidThreeButton,
    keyboardOpen,
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
