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

- **Navigation mode:** Gesture navigation (bottom inset ~48dp) vs 3-button navigation (bottom inset ~48dp, different visual) vs 2-button navigation (legacy). The inset values differ.
- **Status bar:** Standard vs notch/punch-hole. `SafeArea` top padding varies.
- **Text scale:** Default (1.0×) and enlarged (1.3× minimum; 2.0× for accessibility compliance).
- **Keyboard:** Open with a focused low field. Verify the focused field scrolls into view and bottom actions are accessible.
- **Font:** Standard system font vs user-configured custom font (affects text metrics).
- **Dark mode:** If supported by the app.
- **Display size:** Android allows users to change display density in settings, which changes the effective logical viewport. Test at default and one alternative setting.

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
- **Text scale:** Default and iOS "Accessibility Sizes" (which can go much larger than standard slider).
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
- Enable **enlarged text scale** (1.3× or higher).
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
- Test with **gesture navigation** (larger bottom inset) and **3-button navigation** (smaller bottom inset) on Android.
- Test with and without **Dynamic Island / notch** on iOS.
- **Expected:** Content does not overlap system UI. Bottom actions are not obscured. `SafeArea` is applied at the correct level (once, not doubled).

### 5. Orientation test (if supported)
- Rotate to landscape.
- **Expected:** Content remains usable. No overflow. Navigation remains accessible. If landscape is not supported, verify the app correctly locks to portrait.

---

## Test execution and evidence recording

### Running the matrix

```bash
# Step 1: Static analysis
flutter analyze --fatal-infos

# Step 2: Widget tests (includes golden tests if configured)
flutter test

# Step 3: Integration tests on a specific emulator
flutter test integration_test/app_test.dart -d emulator-5554

# Step 4: Capture screenshots on emulator
# Use the emulator's screenshot tool or:
adb exec-out screencap -p > screenshot_name.png

# Step 5: Physical device testing (manual)
# Install: flutter run -d <device_id>
# Capture: device screenshot tool
```

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
