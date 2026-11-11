# Visual validation standard

Visual validation is a layered evidence process. No single layer — static analysis, widget tests, golden tests, integration tests, or manual inspection — replaces the others. Each layer answers a different question, has different reliability characteristics, and produces different evidence.

The purpose is not perfection or pixel-identical rendering across devices. It is to prove that the approved visual hierarchy, spacing relationships, content readability, touchability, and non-overlap behaviour are preserved across the supported configurations.

---

## Validation layers

### Layer 1: Static analysis and token guards

**What it proves:** Code compiles, follows lint rules, and does not violate import/token boundaries.

**What it does not prove:** That the layout is visually correct, that content fits, or that insets are handled properly.

**Commands:**

```bash
# Full static analysis
flutter analyze --fatal-infos

# Dart formatting check (no write)
dart format --output=show --set-exit-if-changed .

# Token guard (if available)
python3 scripts/verify_layout_tokens.py
```

Run these before committing. They are the lowest-cost, highest-frequency check.

### Layer 2: Widget tests

**What it proves:** Widget structure, state transitions, interaction wiring, semantic labels, and deterministic layout assertions at controlled viewport sizes.

**What it does not prove:** That the widget looks correct to a human eye, that platform rendering matches, or that real system insets behave as expected.

**When to write:**
- Every new shared widget in `core/widgets/`.
- Every screen that handles multiple async states (loading, error, empty, data).
- Every form with validation logic.
- Every widget with dynamic content that may overflow.

**Test helpers:** Use the deterministic wrappers in `test/helpers/` as the standard path for all widget tests. They provide controlled viewport, theme, text scale, locale, and Riverpod overrides.

- `TestApp` / `testAppWithProviders()` — wraps the widget under test with `MaterialApp`, theme, and optional text scale injection via `MaterialApp.builder` (so the framework's own `MediaQuery` is not overwritten).
- `TestViewports` — named logical viewport sizes matching the device matrix in chapter 06.
- `TestTextScales` — named text scale values for accessibility testing.
- `TestInsetProfiles` — distinct synthetic Android gesture/three-button/cut-out and iOS compact/home-indicator/keyboard profiles. They reproduce layout behaviours; they do not claim to emulate a named handset.
- `ViewportTesting` extension — `tester.setViewport()` / `tester.setInsetProfile()` / `tester.resetViewport()`.
- `testViewportMatrix()` / `testTextScaleMatrix()` / `testInsetMatrix()` — run a test callback across viewports, text scales, or inset profiles.
- `testMaterialScreenMatrix()` — required baseline for a material screen: compact + regular geometry, 1.0/1.3/2.0 text, Android navigation variation, iOS home-indicator space, and an explicit keyboard scenario when inputs exist.

**Test structure:**

```dart
import '../helpers/test_app.dart';

testWidgets('BookingCard shows cancel button only when cancellable', (tester) async {
  await tester.pumpWidget(
    testAppWithProviders(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()),
      ],
      child: const BookingCard(booking: cancellableBooking),
    ),
  );

  expect(find.text('Cancel'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

**Controlled viewport testing:**

```dart
import '../helpers/test_app.dart';
import '../helpers/viewport_testing.dart';

// Single viewport test
testWidgets('ProfileScreen does not overflow at compact viewport', (tester) async {
  tester.setViewport(TestViewports.compactAndroid);
  addTearDown(tester.resetViewport);

  await tester.pumpWidget(
    testAppWithProviders(
      overrides: [/* ... */],
      child: const ProfileScreen(),
    ),
  );

  // No RenderFlex overflow
  expect(tester.takeException(), isNull);
});

// Matrix test — runs at every Android viewport
testViewportMatrix(
  'ProfileScreen renders without overflow',
  viewports: TestViewports.androidAll,
  builder: (tester, viewport) async {
    await tester.pumpWidget(
      testAppWithProviders(
        overrides: [/* ... */],
        child: const ProfileScreen(),
      ),
    );
    expect(tester.takeException(), isNull);
  },
);
```

**Text scale testing:**

Text scale must be injected **inside** `MaterialApp`, not outside it — wrapping `MediaQuery` around `MaterialApp` is unreliable because `MaterialApp` installs its own `MediaQuery` from the platform view. The `TestApp` helper handles this correctly using `MaterialApp.builder`.

```dart
import '../helpers/test_app.dart';
import '../helpers/viewport_testing.dart';

testWidgets('FormField remains usable at 2.0 text scale', (tester) async {
  tester.setViewport(TestViewports.compactAndroid);
  addTearDown(tester.resetViewport);

  await tester.pumpWidget(
    testAppWithProviders(
      textScaler: TestTextScales.accessibility,
      child: const Scaffold(body: LoginForm()),
    ),
  );

  expect(tester.takeException(), isNull);
  expect(find.byType(TextField), findsNWidgets(2)); // Still rendered
});

// Matrix test — runs at every text scale
testTextScaleMatrix(
  'LoginForm remains usable at all text scales',
  viewport: TestViewports.compactAndroid,
  scales: [TestTextScales.normal, TestTextScales.large, TestTextScales.accessibility],
  builder: (tester, scale) async {
    await tester.pumpWidget(
      testAppWithProviders(
        textScaler: scale,
        child: const Scaffold(body: LoginForm()),
      ),
    );
    expect(tester.takeException(), isNull);
  },
);
```

**Inset / system-UI testing:**

Width-only matrices miss SafeArea and keyboard defects. Apply a named inset profile after setting the viewport:

```dart
testWidgets('bottom action clears gesture-nav inset', (tester) async {
  tester.setViewport(TestViewports.compactAndroid);
  tester.setInsetProfile(TestInsetProfiles.androidGestureNav);
  addTearDown(tester.resetViewport);

  await tester.pumpWidget(
    testAppWithProviders(child: const ProfileScreen()),
  );

  expect(tester.takeException(), isNull);
});

testInsetMatrix(
  'form remains usable with keyboard and nav insets',
  viewport: TestViewports.compactAndroid,
  profiles: [
    TestInsetProfiles.androidGestureNav,
    TestInsetProfiles.androidThreeButton,
    TestInsetProfiles.androidKeyboardOpen,
  ],
  builder: (tester, profile) async {
    await tester.pumpWidget(
      testAppWithProviders(child: const Scaffold(body: LoginForm())),
    );
    expect(tester.takeException(), isNull);
  },
);
```

### Layer 3: Golden tests

**What it proves:** Pixel-level regressions in a deterministic, pinned environment. A golden test baseline is a reviewed reference image.

**What it does not prove:** That the widget looks correct on a real device, that system fonts match, or that platform rendering is identical.

**Current status:** The golden feasibility gate has passed for the pilot. CI pins Flutter **3.44.4** (ADR 0001), deterministic fonts load via `test/flutter_test_config.dart`, and `test/core/widgets/app_card_golden_test.dart` runs with `tags: ['golden']` against the committed baseline `test/core/widgets/goldens/app_card_scales.png`. Add further goldens only for stable shared components that still satisfy the gate below; treat every baseline update as a reviewed visual change.

**Prerequisites (the feasibility gate for new goldens):**

Before adding a **new** golden test, all of the following must remain true:

1. **Flutter SDK is pinned** for the golden job (CI and local developer environment). Golden baselines generated with different Flutter versions will produce false failures.
2. **Font assets are deterministic.** Either bundle test fonts or use `FontLoader` with known font files. `GoogleFonts` with runtime download will produce inconsistent results.
3. **Time, locale, and network are deterministic.** Use `clock` package for time-dependent UI. Use a fixed locale. Replace network images with asset images or placeholders in tests.
4. **Animation and async are settled.** Call `tester.pumpAndSettle()` or advance frames to a known state.
5. **The widget state is stable.** Do not golden-test widgets that are actively iterating on design. Golden-test stable shared components and high-value reference states.

**Writing a golden test:**

```dart
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('AppButton renders correctly at multiple scales', (tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario(
        'default',
        const AppButton(label: 'Continue', onPressed: null),
      )
      ..addScenario(
        'loading',
        const AppButton(label: 'Continue', onPressed: null, isLoading: true),
      )
      ..addTextScaleScenario(
        'large text',
        const AppButton(label: 'Continue', onPressed: null),
        textScaleFactor: 1.5,
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
      surfaceSize: const Size(400, 300),
    );

    await screenMatchesGolden(tester, 'app_button_states');
  });
}
```

**Golden baseline management:**

- Store baselines under `test/<path>/goldens/` mirroring the test file location.
- Every golden update is a **reviewed visual change**, not an automatic acceptance. Treat golden baseline changes like code changes in review.
- When a golden test fails, inspect the diff. If the change is expected (design update, token change), update the baseline deliberately. If unexpected, investigate before accepting.
- CI must use the same Flutter version, platform, and font configuration as the golden generation environment.

**Updating baselines:**

```bash
# Regenerate golden files
flutter test --update-goldens test/core/widgets/

# Verify the change visually before committing
# Use an image diff tool to compare old vs new baselines
```

### Layer 4: Integration tests

**What it proves:** End-to-end flows work on an actual Android emulator, iOS simulator, or physical device. Navigation, state transitions, platform permissions, and real system UI behaviour.

**What it does not prove:** Pixel-perfect visual fidelity (use goldens for that) or deterministic layout (use widget tests).

**When to write:**

- Critical user flows: login, verification, booking, check-in.
- Flows involving platform plugins: camera, NFC, biometrics.
- Flows involving system UI: keyboard, navigation mode, permissions dialogs.

**Setup:**

```yaml
# pubspec.yaml - dev_dependencies
dev_dependencies:
  integration_test:
    sdk: flutter
```

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trvlez_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow completes successfully', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate and interact...
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

**Running integration tests:**

```bash
# On a connected device or emulator
flutter test integration_test/app_test.dart

# On a specific device
flutter test integration_test/app_test.dart -d <device_id>
```

### Layer 5: Manual device inspection

**What it proves:** Real system bars, home indicators, gesture navigation, OEM fonts, keyboard behaviour, camera/NFC/platform views, and physical-device rendering. This is the only layer that provides physical-device evidence.

**What it does not prove:** Deterministic regression (use automated tests) or broad configuration coverage (limited by available devices).

**Protocol:**

1. Build and install the app on the target device.
2. Navigate to the affected screen(s).
3. Test the required states: default, loading, error, empty, long content, keyboard open.
4. Capture screenshots with the device's built-in screenshot tool.
5. Record: device model, OS version, logical viewport (from `MediaQuery.sizeOf`), text scale, navigation mode.
6. Note any rendering differences from the emulator or from other devices.

**DevTools layout inspection:**

When diagnosing a layout issue on a running app:

1. Connect Flutter DevTools.
2. Select the problematic widget in the Inspector.
3. Inspect `constraints` (what the parent offered) and `size` (what the widget chose).
4. Enable "Show Baselines" and "Show Guidelines" when relevant.
5. Record the diagnosis in the task/PR note — the constraints, not just the visual symptom.

---

## Required evidence by change type

| Change type | Minimum evidence |
|---|---|
| Shared widget styling | Widget test + golden test (pinned environment; see Layer 3) |
| Screen layout or inset/keyboard change | Chapter 02 checklist: compact + regular viewports, text 1.0/1.3/2.0, keyboard/inset profile when inputs exist, validated `scripts/device_matrix.sh` capture |
| SafeArea, keyboard, pinned-footer, platform-typography, or system-UI change | Material screen matrix + validated Android emulator **and** iOS simulator capture |
| Navigation/input/device-plugin flow | Integration test where feasible + platform runtime evidence |
| Token/theme-wide change | Component goldens + affected widget tests + documented baseline review |
| Accessibility improvement | Widget test with semantic assertions + text scale test + screen reader manual test |
| Reported device-pair discrepancy | Paired MediaQuery worksheet (chapter 06) **before** edit + compact/regular widget matrix after |

---

## Screenshot naming convention

```
<feature>__<state>__<platform>__<width>x<height>__text-<scale>__<inset-state>.png
```

Examples:
- `login__default__android__360x640__text-1.0__gesture-nav.png`
- `booking__error__ios__393x852__text-1.5__safe-area.png`
- `profile__keyboard-open__android__412x915__text-1.0__3button-nav.png`

The capture command derives `<width>x<height>`, `<scale>`, and `<inset-state>` from a required runtime-MediaQuery JSON file, then writes a sibling `.json` sidecar. Do not label a screenshot with manually supplied viewport, text-scale, or navigation values.

Store only approved, non-sensitive fixtures. Never commit user data, credentials, serials, or device identifiers.

---

## Mismatch investigation protocol

When a visual mismatch is reported between devices or between a device and a design reference:

1. **Do not immediately change a dimension.** The symptom (visual difference) may not indicate the cause (wrong constraint, missing inset, incorrect scroll model).
2. **Capture `MediaQuery` data** on both devices/configurations: `size`, `padding`, `viewPadding`, `viewInsets`, `devicePixelRatio`, `textScaler`.
3. **Inspect constraints** at the affected widget using DevTools. What constraints does the parent offer? What size does the widget choose?
4. **Compare system insets.** Different navigation modes (gesture vs 3-button), notch/punch-hole, and home indicators produce different inset values.
5. **Check text scaling.** The user may have a different system text scale.
6. **Identify the root cause** before proposing a fix. Document it in the task.
7. **Fix at the correct level.** If the parent constraint is wrong, fix the parent. If the scroll model is wrong, fix the scroll model. If an inset is double-applied, fix the inset ownership. Do not add a device-specific offset.

---

## CI integration

When CI infrastructure supports it:

1. Run `flutter analyze --fatal-infos` on every PR.
2. Run `dart format --output=show --set-exit-if-changed .` on every PR.
3. Run `flutter test` (unit + widget tests) on every PR.
4. Run golden tests only in a pinned environment. Make golden diffs downloadable CI artifacts.
5. Run integration tests on a dedicated emulator/simulator step, not as part of the fast test suite.
6. Do not run physical-device tests in CI. They are a separate manual or device-farm step.

Token guard scripts and import boundary checks should also run in CI if they exist.
