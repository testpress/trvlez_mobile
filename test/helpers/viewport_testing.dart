import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on [WidgetTester] for controlled viewport testing.
///
/// Sets physical size and pixel ratio to simulate different phone
/// configurations. Always call [addTearDown] with the reset methods
/// to avoid leaking viewport state between tests.
///
/// Reference: docs/engineering/playbook/06-testing-device-matrix.md
extension ViewportTesting on WidgetTester {
  /// Configures the test viewport to a specific logical size.
  ///
  /// Sets [devicePixelRatio] to 1.0 so [physicalSize] equals logical size.
  /// Call [addTearDown] with [resetViewport] after using this.
  ///
  /// Example:
  /// ```dart
  /// testWidgets('screen fits compact phone', (tester) async {
  ///   tester.setViewport(TestViewports.compactAndroid);
  ///   addTearDown(tester.resetViewport);
  ///
  ///   await tester.pumpWidget(/* ... */);
  ///   expect(tester.takeException(), isNull);
  /// });
  /// ```
  void setViewport(Size logicalSize, {double devicePixelRatio = 1.0}) {
    view.physicalSize = logicalSize * devicePixelRatio;
    view.devicePixelRatio = devicePixelRatio;
  }

  /// Resets the viewport to Flutter test defaults.
  ///
  /// Use in [addTearDown] after [setViewport]:
  /// ```dart
  /// addTearDown(tester.resetViewport);
  /// ```
  void resetViewport() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  }
}

/// Runs a test callback at every viewport in the provided list.
///
/// Useful for matrix testing a screen across all phone configurations.
///
/// Example:
/// ```dart
/// testViewportMatrix(
///   'ProfileScreen renders without overflow',
///   viewports: TestViewports.androidAll,
///   builder: (tester, viewport) async {
///     await tester.pumpWidget(
///       testAppWithProviders(child: const ProfileScreen()),
///     );
///     expect(tester.takeException(), isNull);
///   },
/// );
/// ```
void testViewportMatrix(
  String description, {
  required List<Size> viewports,
  required Future<void> Function(WidgetTester tester, Size viewport) builder,
}) {
  for (final viewport in viewports) {
    final label = '${viewport.width.toInt()}x${viewport.height.toInt()}';

    testWidgets('$description [$label]', (tester) async {
      tester.setViewport(viewport);
      addTearDown(tester.resetViewport);

      await builder(tester, viewport);
    });
  }
}

/// Runs a test callback at multiple text scale factors.
///
/// Example:
/// ```dart
/// testTextScaleMatrix(
///   'LoginForm remains usable at all text scales',
///   viewport: TestViewports.compactAndroid,
///   scales: [TestTextScales.normal, TestTextScales.large, TestTextScales.accessibility],
///   builder: (tester, scale) async {
///     await tester.pumpWidget(
///       testAppWithProviders(
///         textScaler: scale,
///         child: const Scaffold(body: LoginForm()),
///       ),
///     );
///     expect(tester.takeException(), isNull);
///   },
/// );
/// ```
void testTextScaleMatrix(
  String description, {
  required Size viewport,
  required List<TextScaler> scales,
  required Future<void> Function(WidgetTester tester, TextScaler scale) builder,
}) {
  for (final scale in scales) {
    // Extract the scale factor for the test label.
    final factor = scale.scale(1.0);
    final label = 'text-${factor.toStringAsFixed(1)}';

    testWidgets('$description [$label]', (tester) async {
      tester.setViewport(viewport);
      addTearDown(tester.resetViewport);

      await builder(tester, scale);
    });
  }
}
