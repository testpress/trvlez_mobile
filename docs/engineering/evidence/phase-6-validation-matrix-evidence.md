# Phase 6 — Screen Matrix Validation & Accessibility Evidence

**Status: automated evidence complete; runtime and assistive-technology evidence pending.**

Per Playbook Chapter 02 (`docs/engineering/playbook/02-screen-construction-workflow.md`), Chapter 05 (`docs/engineering/playbook/05-visual-validation-standard.md`), Chapter 06 (`docs/engineering/playbook/06-testing-device-matrix.md`), and Chapter 07 (`docs/engineering/playbook/07-accessibility-and-performance.md`), this document records the validation matrix adoption, accessibility compliance, and layout defect remediations achieved in Phase 6.

---

## 1. Screen Families Matrix & Accessibility Adoption

| Screen Family | Screen / Surface | Test File | `testAppWithProviders` / `TestApp` | Matrix Scenarios Tested | Accessibility Guidelines Asserted | Defects Caught & Resolved |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| **Auth** | `LoginScreen` | `test/features/auth/presentation/screens/login_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x; keyboard | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None (baseline conformant) |
| **Auth** | `RegistrationScreen` | `test/features/auth/presentation/screens/registration_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x; keyboard | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None |
| **Auth** | `WelcomeScreen` | `test/features/auth/presentation/screens/welcome_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None |
| **Profile** | `PersonalDetailsScreen` | `test/features/profile/presentation/screens/personal_details_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 70px overflow in `VerifiedIdentityCard` header (fixed with `Wrap`); missing back button tooltip |
| **Profile** | `ProfileSetupScreen` | `test/features/profile/presentation/screens/profile_setup_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x; keyboard | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 87px dropdown overflow (fixed with `isExpanded: true`); unconstrained nationality text (fixed with `Expanded`) |
| **Profile** | `SecurityScreen` | `test/features/profile/presentation/screens/security_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 44dp `SettingsRow` touch target (enforced ≥ 48dp); missing switch semantic label |
| **Booking** | `BookingReviewScreen` | `test/features/booking/presentation/screens/booking_screens_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | Verified | 16px trailing label overflow in `BookingPaymentRow` (fixed with `Flexible`) |
| **Findr Forms** | `FindrReferralsScreen` | `test/features/findr/presentation/findr_referrals_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None |
| **Findr Forms** | `ReferHotelBottomSheet` | `test/features/findr/presentation/widgets/refer_hotel_bottom_sheet_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x; keyboard | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None |
| **Reservations** | `ReservationDetailScreen` | `test/features/reservations/presentation/screens/reservation_detail_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 126px confirmation code row overflow (fixed with `Wrap`); 28px `ReservationInfoCard` value overflow (fixed with `Flexible`) |
| **Reservations** | `MyTripsScreen` | `test/features/reservations/presentation/screens/my_trips_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 4.6px date row overflow (fixed with `Wrap`); 31dp check-in banner touch target (enforced ≥ 48dp); TabBar tab height 47.5dp (enforced 48dp) |
| **Reservations** | `PreArrivalFormScreen` | `test/features/reservations/presentation/screens/pre_arrival_form_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | None |
| **Verification** | `VerificationLandingScreen` | `test/features/verification/presentation/screens/verification_landing_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | `BrandVerifyScreen` help link touch target below 48dp (enforced ≥ 48dp); missing back button tooltip |
| **Verification** | `PassportReviewScreen` | `test/features/verification/presentation/screens/passport_review_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 44px (1.3x) and 296px (2.0x) bottom overflow on compact viewport (made `isScrollable: true` with `AspectRatio` passport card) |
| **Verification** | `NfcIntroScreen` | `test/features/verification/presentation/screens/nfc_intro_screen_test.dart` | Yes | Compact & regular; 1.0x, 1.3x, 2.0x | `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` | 45px overflow on compact viewport (made `isScrollable: true` with `SizedBox` spacers) |

---

## 2. Shared Interactive Components Accessibility Guideline Assertions

Every canonical shared control and state surface now has automated accessibility assertions in its unit test suite using Flutter's accessibility guideline APIs (`androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`):

| Component | Test File | Guidelines Verified |
| :--- | :--- | :--- |
| `AppButton` | `test/core/core_widgets_test.dart` | Tap target (Android 48dp / iOS 44dp), semantic labeling |
| `HeartButton` | `test/core/widgets/heart_button_test.dart` | Android/iOS tap target, labeled semantics |
| `CheckInConsentTick` | `test/core/widgets/check_in_consent_tick_test.dart` | Android/iOS tap target, labeled semantics |
| `AppSegmentedControl` | `test/core/widgets/app_segmented_control_test.dart` | Android/iOS tap target, labeled semantics |
| `BrandShutter` | `test/core/widgets/brand_shutter_test.dart` | Android/iOS tap target, labeled semantics |
| `StatusPill` | `test/core/widgets/status_pill_test.dart` | Semantic label representation |
| `AppConfirmationDialog` | `test/core/widgets/app_confirmation_dialog_test.dart` | Android/iOS tap target, labeled semantics |
| `AppErrorBanner` | `test/core/widgets/app_error_banner_test.dart` | Android/iOS tap target, labeled semantics, live region semantics |
| `EmptyView` | `test/core/widgets/empty_view_test.dart` | Android/iOS tap target, labeled semantics |
| `LoadingView` | `test/core/widgets/loading_view_test.dart` | Progress indicator semantics, labeled semantics |
| `ErrorView` | `test/core/widgets/error_view_test.dart` | Android/iOS tap target, labeled semantics |
| `BrandVerifyScreen` | `test/features/verification/presentation/screens/verification_landing_screen_test.dart` | Header back/close tap target (≥ 48dp) with tooltip, footer help link (≥ 48dp) |

---

## 3. Golden Test Expansion

- **StatusPill Deterministic Golden Test**: `test/core/widgets/status_pill_golden_test.dart`.
- **Baseline Artifact**: `test/core/widgets/goldens/status_pill_states.png`.
- **Coverage**: All four canonical visual states (`confirmed`, `awaiting`, `completed`, `cancelled`) rendered at 1.0x and 1.5x text scaling factors using deterministic fonts configured via `test/flutter_test_config.dart`.

---

## 4. Evidence Classification

- **Widget Matrix Tests**: Automated via `testMaterialScreenMatrix` across all 5 standard phone scenarios (`compact-android-gesture-text-1.0`, `regular-android-3button-text-1.0`, `compact-android-gesture-text-1.3`, `compact-android-gesture-text-2.0`, `regular-ios-home-indicator-text-1.0`) plus keyboard inset scenarios where inputs exist.
- **Golden Tests**: Generated deterministically and committed to the repository for shared controls meeting the chapter 05 feasibility gate.
- **Physical Device / Emulator Limitations**: Deterministic widget tests do not substitute for runtime evidence. On 2026-11-13, `scripts/device_matrix.sh list-devices` could not start `adb` in the execution sandbox (`Operation not permitted`), and no iOS simulator runtime is available on this Linux host. Android-emulator and iOS-simulator captures, platform-maximum text-scale checks, TalkBack, and VoiceOver checks remain required before a release or a completed-Phase-6 claim.
- **Integration scope**: `integration_test/auth_login_flow_test.dart` covers the login form and focused-password keyboard reachability. A camera/NFC platform-plugin flow still requires a supported Android or iOS runtime before it can provide the required platform evidence.
- **Contrast audit**: The 2026-11-13 Guideline API audit corrected `AppButton`, `AppSegmentedControl`, `CheckInConsentTick`, and `AppErrorBanner`; their contract tests now include `textContrastGuideline` in the appropriate surface context. The audit also found contrast defects in legacy brand verification surfaces, including inactive step indicators and small cream copy. The verification-surface palette requires approved design-token remediation and remains open rather than being waived. `AlertDialog` contrast inspection remains a known Flutter Guideline API limitation in this test configuration, so that component retains semantic/tap assertions and needs runtime visual review.

