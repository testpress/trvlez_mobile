# Phone device and configuration matrix

The matrix describes logical configurations, not a promise that a named hardware model perfectly represents all phones. Run the applicable Android and iOS rows; report whether a result is emulator, simulator, or physical device.

| Class | Representative logical viewport | Required state |
| --- | --- | --- |
| Compact Android phone | 360 x 640–720 | gesture and 3-button navigation when bottom UI is affected |
| Regular Android phone | 393 x 852 | standard portrait baseline |
| Tall Android phone | 412 x 915 | status/navigation insets and long-content checks |
| Compact iPhone | 375 x 667 | status/home-indicator handling as applicable |
| Regular iPhone | 393 x 852 | standard portrait baseline |
| Tall iPhone | 430 x 932 | dynamic-island/home-indicator-safe content checks |

For relevant screens also test: system text scale normal and enlarged, long/localized content, keyboard open with a low focused field, loading/empty/error, orientation if supported, and display-size changes where the platform exposes them. Exact simulator/emulator profiles may differ; record the actual logical viewport and OS/runtime version.

Use physical Android and iOS devices for release-critical flows, camera/NFC/permissions, real system bars, and final visual sign-off. Do not substitute an emulator result for physical evidence.

