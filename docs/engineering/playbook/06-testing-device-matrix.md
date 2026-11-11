# Phone device and configuration matrix

This chapter defines the logical configurations that cover the range of Android and iOS phones where the application must remain visually correct and usable. The matrix describes test categories, not a promise that a named hardware model perfectly represents all phones in that category.

---

## Why a device matrix

A screen that looks correct on one phone may fail on another because of different:

- **Logical viewport dimensions:** A 360 × 640 phone gives content less room than a 430 × 932 phone.
- **Aspect ratios:** A 16:9 phone is proportionally wider than a 20:9 phone at the same width.
- **System insets:** Gesture navigation, 3-button navigation, status bar with notch/punch-hole, Dynamic Island, and home indicator all consume different amounts of screen space.
- **Device pixel ratio:** Does not affect layout dimensions (logical pixels are the same) but affects rendering sharpness and can expose hairline rendering differences.
- **System text scale:** A user with accessibility text scaling changes the effective height of all text-containing elements.
- **Keyboard height:** Varies by device, input method, language, and whether predictive text/suggestions are shown.

Testing on only one configuration and declaring success is not validation — it is coincidence.

---

## Android phone matrix

| Category | Representative logical viewport | Key test scenarios |
|---|---|---|
| **Compact Android** | 360 × 640–720 dp | Smallest supported viewport. Content must not overflow. Buttons must remain tappable. Bottom actions must not be obscured by navigation bar. Test with both gesture and 3-button navigation. |
| **Regular Android** | 393 × 852 dp | Standard baseline device. Primary design comparison target. Test default text scale, dark/light theme if applicable. |
| **Tall Android** | 412 × 915 dp | Extended height. Verify content does not stretch inappropriately. Test pinned headers/footers, long content scrolling, and gesture navigation insets. |
| **Large Android** | 432 × 932 dp | Largest standard phone. Test with default and enlarged text scale. Verify long/translated strings do not cause unexpected wrapping or truncation. |

### Android-specific test states

For each viewport, test the following as relevant to the screen under change:

- **Navigation mode:** Gesture, 3-button, and legacy 2-button navigation have device- and OS-dependent inset values. Do not assume one fixed value; record the runtime `padding` and `viewPadding`.
- **Status bar:** Standard vs notch/punch-hole. `SafeArea` top padding varies.
- **Text scale:** Default (1.0×), enlarged (1.3×), and 2.0× automated minimum. Where Android or iOS exposes a larger supported accessibility range, validate the platform maximum at runtime for text-bearing screens and controls.
- **Keyboard:** Open with a focused low field. Verify the focused field scrolls into view and bottom actions are accessible.
- **Font:** Standard system font vs user-configured custom font (affects text metrics).
- **Dark mode:** If supported by the app.
- **Display size:** Android allows users to change display density in settings, which changes the effective logical viewport. Test at default and one alternative setting.
- **Locale readiness:** English-LTR is the current release baseline. Use long representative strings; when localization is enabled, include pseudolocale/long-string validation and RTL validation for directional UI.

### Android emulator setup

```bash
# List available system images
sdkmanager --list | grep system-images

# Create AVD for compact phone
avdmanager create avd \
  --name "Compact_360x640" \
  --package "system-images;android-34;google_apis;x86_64" \
  --device "Nexus 5"

# Create AVD for regular phone
avdmanager create avd \
  --name "Regular_393x852" \
  --package "system-images;android-35;google_apis;x86_64" \
  --device "pixel_8"

# Create AVD for tall phone
avdmanager create avd \
  --name "Tall_412x915" \
  --package "system-images;android-35;google_apis;x86_64" \
  --device "pixel_9_pro"

# Launch emulator
emulator -avd Regular_393x852

# Verify actual logical viewport from Flutter
# Add temporary diagnostic in the app or use DevTools:
# print(MediaQuery.sizeOf(context));
# print(MediaQuery.paddingOf(context));
```

Record the **actual** logical viewport reported by `MediaQuery.sizeOf(context)`, not the AVD device profile's advertised resolution. Emulator viewport may differ slightly from the device profile.

---

## iOS phone matrix

| Category | Representative logical viewport | Key test scenarios |
|---|---|---|
| **Compact iPhone** | 375 × 667 dp | iPhone SE / iPhone 8 class. No home indicator, no Dynamic Island. Smallest supported iOS viewport. |
| **Regular iPhone** | 393 × 852 dp | iPhone 15 / 16 class. Standard notch or Dynamic Island. Home indicator present. |
| **Tall iPhone** | 430 × 932 dp | iPhone 15 Pro Max / 16 Pro Max class. Largest standard viewport. Dynamic Island and home indicator. |

### iOS-specific test states

- **Home indicator:** Present on Face ID devices. Consumes bottom safe area.
- **Dynamic Island / Notch:** Consumes top safe area. Affects status bar height.
- **Text scale:** Default, 2.0× automated minimum, and the iOS "Accessibility Sizes" maximum at runtime for text-bearing screens and controls.
- **Locale readiness:** English-LTR is the current release baseline. When localization is enabled, test long strings and RTL where supported.
- **Keyboard:** iOS keyboard height varies by language, QuickType suggestions, and dictation availability.
- **Safe area:** Verify top and bottom safe areas are handled correctly, not doubled.

### iOS simulator setup

```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot "iPhone 16"

# Open Simulator.app
open -a Simulator

# Set text scale via Simulator → Settings → Accessibility → Display & Text Size → Larger Text
```

---

## Physical device testing

Physical devices are required for:

- Release-critical flows.
- Camera, NFC, biometric features.
- Real system bars, gesture navigation, and haptic feedback.
- OEM font rendering and GPU composition differences.
- Final visual sign-off before release.

### Recording physical device evidence

| Field | What to record |
|---|---|
| Device | Model name and number (e.g. "Pixel 10a") |
| OS version | Android 15 / iOS 18.1 |
| Logical viewport | Exact `MediaQuery.sizeOf(context)` value |
| Device pixel ratio | `MediaQuery.devicePixelRatioOf(context)` |
| Text scale | `MediaQuery.textScalerOf(context)` |
| Navigation mode | Gesture / 3-button / 2-button (Android) or Home indicator (iOS) |
| Display size setting | Default / Modified |
| Screenshot | Named per the convention in chapter 05 |

Do not record personal device identifiers, IMEI, serial numbers, or user account information.

Do not substitute emulator evidence for physical device evidence. They are different claims with different reliability.

---

## Cross-configuration test scenarios

These scenarios should be tested across multiple viewport categories when the affected screen is changed:

### 1. Content overflow test
- Set the viewport to **Compact** (smallest).
- Navigate to the screen with **maximum-length content** (long names, translated strings, error messages).
- Enable **enlarged text scale** at 1.3× and 2.0×.
- **Expected:** No `RenderFlex` overflow. Content scrolls if needed. All text is readable. All buttons are tappable.

### 2. Keyboard interaction test
- Navigate to a form screen.
- Tap the **lowest input field** on the screen.
- **Expected:** Keyboard appears. The focused field scrolls into view. Bottom action button (if present) remains accessible. No content is permanently obscured.

### 3. Empty and error state test
- Trigger **empty state** (no data) and **error state** (network failure).
- Test at **Compact** and **Large** viewports.
- **Expected:** Empty/error views are centered or appropriately positioned. Retry button is tappable. No overflow.

### 4. Inset variation test
- Test with **gesture navigation** and **3-button navigation** on Android; use their recorded runtime insets rather than assuming which is larger.
- Test with and without **Dynamic Island / notch** on iOS.
- **Expected:** Content does not overlap system UI. Bottom actions are not obscured. `SafeArea` is applied at the correct level (once, not doubled).

### 5. Orientation test (if supported)
- Rotate to landscape.
- **Expected:** Content remains usable. No overflow. Navigation remains accessible. If landscape is not supported, verify the app correctly locks to portrait.

### 6. Non-phone and resizable-window safety

- The playbook does not require an alternate tablet, foldable, or landscape design.
- When the app is shown in a split, freeform, foldable, tablet, or rotated window, the phone composition must still avoid crashes, system-UI overlap, and hidden critical actions.
- Do not add OS/model branches to meet this condition. An optimized alternate layout is new product work and requires an approved layout contract and matrix extension.

---

## Mandatory minimum for material layout PRs

Every material screen or layout change must include evidence for at least:

| Config | Requirement |
| --- | --- |
| Compact viewport | Widget test at `TestViewports.compactAndroid` (or compact iPhone when iOS-specific) |
| Regular viewport | Widget test at `TestViewports.regularAndroid` (or regular iPhone) |
| Text scale | 1.0, 1.3, and 2.0 (`TestTextScales.normal`, `.large`, and `.accessibility`) |
| Platform maximum text scale | Runtime validation for text-bearing UI when the supported platform range exceeds 2.0, or a recorded product support ceiling |
| Keyboard | When the screen has inputs: platform-appropriate `TestInsetProfiles.*KeyboardOpen` and emulator/simulator keyboard-open capture |
| Emulator/simulator capture | Via `scripts/device_matrix.sh` using validated runtime-MediaQuery metadata and the chapter 05 naming convention |

Tall/large viewports, alternate nav modes, and physical devices are required when the change touches insets, pinned footers, or a reported device-pair defect. Safe-area, keyboard, pinned-footer, platform-typography, and system-UI changes require both Android emulator and iOS simulator evidence.

The current release is English and LTR. Long English strings remain part of every material-layout check. When localization or RTL ships, affected screens require long-string/pseudolocale and RTL evidence; directional padding, alignment, icon placement, and traversal order must be verified.

---

## Paired-device MediaQuery worksheet

Use this **before editing** when investigating a discrepancy between two phones (for example realme 8 vs Pixel 10a). Do not change layout until both columns are filled.

```markdown
## Paired MediaQuery — <ScreenName>

| Field | Device A (e.g. realme 8) | Device B (e.g. Pixel 10a) |
| --- | --- | --- |
| Model / OS | | |
| Navigation mode | gesture / 3-button / … | |
| `size` (`MediaQuery.sizeOf`) | | |
| `devicePixelRatio` | | |
| `textScaler` | | |
| `padding` | | |
| `viewPadding` | | |
| `viewInsets` (keyboard open/closed) | | |
| Screenshot (ch. 05 name) | | |
| Observed defect | | |

Hypothesis (constraint / inset ownership / scroll / text scale / other):
Proposed fix level (parent / scroll / SafeArea owner / token — not device offset):
```

Capture screenshots with `scripts/device_matrix.sh` after recording the table.

---

## Test execution and evidence recording

### Running the matrix

Prefer the repository script as the default path for device listing, screenshots, and integration runs:

```bash
# List connected Android devices / emulators and Flutter devices
./scripts/device_matrix.sh list-devices

# Step 1: Static analysis
flutter analyze --fatal-infos

# Step 2: Widget tests (includes golden tests when configured)
flutter test

# Step 3: Integration tests on a specific emulator/device
./scripts/device_matrix.sh run-integration emulator-5554
# equivalent: flutter test integration_test/ -d emulator-5554

# Step 4: Capture screenshots using measured runtime MediaQuery JSON.
# The script derives the filename and writes a sibling evidence sidecar.
./scripts/device_matrix.sh capture-android login default /tmp/login-android-media-query.json
./scripts/device_matrix.sh capture-ios login default /tmp/login-ios-media-query.json

# Step 5: Physical device — install, exercise states, fill evidence template / paired worksheet
flutter run -d <device_id>
```

### Runtime MediaQuery input for captures

Before capture, record the runtime values from DevTools or a temporary local diagnostic (then remove that diagnostic). Save no identifiers or user data.

```json
{
  "logicalSize": {"width": 393, "height": 852},
  "devicePixelRatio": 2.75,
  "textScale": 1.3,
  "padding": {"top": 24, "right": 0, "bottom": 24, "left": 0},
  "viewPadding": {"top": 24, "right": 0, "bottom": 24, "left": 0},
  "viewInsets": {"top": 0, "right": 0, "bottom": 0, "left": 0},
  "insetState": "gesture-nav",
  "keyboardState": "closed"
}
```

`scripts/device_matrix.sh` validates this schema, uses it for the filename, and stores it with non-identifying capture metadata. The JSON is evidence input, not a substitute for observing the running app.

### Evidence template

For each tested configuration, record:

```markdown
## [Screen Name] — [Device Category]

- **Device/emulator:** [name]
- **Logical viewport:** [width × height]
- **Text scale:** [value]
- **Navigation mode:** [gesture / 3-button / home indicator]
- **States tested:** [default, loading, error, empty, long content, keyboard]
- **Result:** [pass / fail with description]
- **Screenshot:** [filename per convention]
- **Notes:** [any rendering differences, expected variances, or issues]
```
