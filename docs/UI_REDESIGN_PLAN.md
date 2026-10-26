# Screen-by-Screen UI Redesign Implementation Plan

> **Source of Truth Reference Design:** `/home/kumaraguhan/Downloads/trvlez_app`  
> **Target Codebase:** `/home/kumaraguhan/workspace/trvlez_mobile`  
> **Status:** Planning & Audit Phase (No UI modifications implemented in this step)

---

## 1. Executive Summary & Design System Foundations

### 1.1 Objective & Scope
The objective of this plan is to guide an incremental, screen-by-screen UI redesign of the TrvlEz mobile application (`trvlez_mobile`) to achieve visual parity with the approved reference design system in `trvlez_app`. 

The redesign is **strictly visual and structural**:
- **Allowed:** Spacing, sizing, typography, colors, borders, surface decorations, button shapes, flex layout adjustments, icon alignments, and responsive layout scaling.
- **Strictly Prohibited:** Changes to business logic, domain models, API endpoints, serialization/DTOs, state management (Riverpod providers/notifiers), navigation parameters/routes, form validation logic, error handling mappers, or device platform integrations (Camera, NFC, Secure Storage).

### 1.2 Already Redesigned Screens
The following screens were previously refactored and aligned with `trvlez_app`:
- [x] **Welcome Screen**: [`lib/features/auth/presentation/screens/welcome_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/welcome_screen.dart)
- [x] **Login Screen**: [`lib/features/auth/presentation/screens/login_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/login_screen.dart)
- [x] **Registration Screen**: [`lib/features/auth/presentation/screens/registration_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/registration_screen.dart)
- [x] **Forgot Password Screen**: [`lib/features/auth/presentation/screens/forgot_password_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/forgot_password_screen.dart)

### 1.3 Design System & Semantic Token Rules
All redesigned screens must strictly conform to `.agents/rules/DESIGN_SYSTEM.md` and `flutter-semantic-layout-tokens`:
1. **Zero Magic Numbers:** No inline `EdgeInsets.all(16)`, `SizedBox(height: 24)`, `BorderRadius.circular(12)`, or `Size(...)`. Use `context.space.*`, `context.sizes.*`, and `context.shape.*`.
2. **Zero Hardcoded Colors & Typography:** No `Color(0x...)`, `Colors.*`, or raw `TextStyle(...)`. Consume semantic colors via `context.colors.*` and typography scales via `context.text.*` (or `AppTypography.fontFamily` mapped tokens).
3. **Accessibility & Tap Targets:** All interactive controls must satisfy `kMinInteractiveDimension` (min 48×48 dp) and support 200% text scaling without UI overflow.
4. **Scaffolding:** 
   - Brand Red Screens (Auth, Verification, Check-in, Anywhere, Disputes) use `BrandScreen` or `BrandVerifyScreen`.
   - Signed-in App Shell Screens (Home, Bookings, Saved, Account) use `AppPinnedHeader` with `colors.page` background and curved surface headers.

---

## 2. Shared Component Architecture & Mapping

| Reference Component (`trvlez_app`) | Current Shared Component (`trvlez_mobile`) | Notes / Required Token Alignment |
|---|---|---|
| `TzRedScreen` / `TzScreen` | [`BrandScreen`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_screen.dart) | Standard full-bleed red background scaffold with header and wordmark |
| `TzVerifyScreen` | [`BrandVerifyScreen`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_verify_screen.dart) | Red verification scaffold with title, back button, flex body, and pinned help foot |
| `TzAppBar` | [`AppPinnedHeader`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/app_pinned_header.dart) | White surface header with curved bottom corners extending into status bar |
| `TzButton` | [`AppButton`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/app_button.dart) | Primary action button supporting `brandWhite`, `primary`, and `outline` |
| `TzField` | [`BrandTextField`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_text_field.dart) | Red-screen translucent form field with floating labels and error states |
| `TzWordmark` | [`BrandWordmark`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_wordmark.dart) | Inline TRVLez brand logo with cream "ez" |
| `TzSecurityNote` | [`BrandSecurityNote`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_security_note.dart) | Lock icon and security statement line |
| `TzAltLine` | [`BrandAltLine`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/brand_alt_line.dart) | "New to TRVLez? Create account" alternative footer action |
| `VerificationStepper` | [`VerificationStepper`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/verification_stepper.dart) | 4-step circle progress track |
| `TzFindrCard` | [`FindrCard`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/findr_card.dart) | Paper palette Findr rewards & referral card (Locked, Not Joined, Active) |
| `TzSegmented` | [`AppSegmentedControl`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/app_segmented_control.dart) | Pill-style multi-tab filter switch |
| `TzEzWord` | [`EzWord`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/ez_word.dart) | Text rendering "ez" in brand red |

---

## 3. Screen-by-Screen Implementation Plan

### Phase 1: Authentication & Onboarding (Remaining Screens)

#### 1.1 Two-Step Verification Code Screen
- **Target File:** [`lib/features/auth/presentation/screens/two_step_code_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/two_step_code_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/authentication/two_step_code_screen.dart` (Artboard `212 x 506`, class `.a3.red`)
- **Required UI Changes:**
  - **Layout:** Bare red screen (no background motif asset, per design mandate "keep it clean").
  - **Typography:** Header text "Check your email" using `context.text.headlineLarge`, subtitle "We sent a 6-digit code to [masked-email]" using `context.text.bodyLarge` with `colors.brandSecondaryBody`.
  - **Code Boxes:** 6 equal flex boxes across row; height `sizes.controlMd` (38dp equivalent via `controlSm`/`controlMd`), border radius `shape.radiusControl` (12dp), fill `colors.brandCodeBoxBackground` (`rgba(255,255,255,0.13)`). Active awaiting box gets 1.5dp white border (`shape.borderMedium`) and brighter background.
  - **Resend Line:** Centered text; countdown displayed in `colors.brandSecondarySmall`. When expired (0:00), renders underlined "Resend code" with tap target ≥48dp.
  - **Foot:** Security note "Codes expire after 10 minutes." (`BrandSecurityNote`) and "Verify" button (`AppButton` variant `brandWhite`, disabled until 6 digits entered).
- **Dependencies:** `BrandScreen`, `AppButton`, `BrandSecurityNote`.
- **Implementation & Verification Checklist:**
  - [x] Remove any hardcoded sizes/margins and apply `context.space.*` and `context.sizes.*`.
  - [x] Verify 6-box input layout and active box border highlighting.
  - [x] Verify masked email presentation and timer countdown transition.
  - [x] Ensure tap target on "Resend code" is at least 48dp.
  - [x] Run `dart format`, `flutter analyze`, and `flutter test test/features/auth/`.

#### 1.2 New Password Screen
- **Target File:** [`lib/features/auth/presentation/screens/new_password_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/auth/presentation/screens/new_password_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/authentication/new_password_screen.dart` (Artboard `200 x 440`, class `.tzC`)
- **Required UI Changes:**
  - **Layout:** `BrandScreen` with background motif asset `assets/art/bg_create_account.svg`.
  - **Typography:** Heading "Choose a new password" (changes to "Those don't match" on mismatch) using `context.text.headlineLarge`; subtitle "You'll be signed in once it's saved" (or "Type the same one in both boxes") using `context.text.bodyLarge`.
  - **Form Inputs:** Two `BrandTextField` widgets ("Password" and "Confirm password"), placeholder "At least 8 characters" and "Enter it again". Spacing between fields set to `context.space.stackFormField`.
  - **Foot:** Security note "At least 8 characters. Make it something you don't use elsewhere." and button "Save and sign in" (`brandWhite`).
- **Dependencies:** `BrandScreen`, `BrandTextField`, `AppButton`, `BrandSecurityNote`.
- **Implementation & Verification Checklist:**
  - [x] Verify mismatch heading/subtitle dynamic states without breaking controllers.
  - [x] Ensure button transitions smoothly from disabled grey to brand white when valid.
  - [x] Run analyzer and widget tests.

---

### Phase 2: Navigation Shell & Home Hub

#### 2.1 Main Scaffold Tab Bar
- **Target File:** [`lib/features/home/presentation/widgets/main_scaffold.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/home/presentation/widgets/main_scaffold.dart)
- **Reference Screen:** `trvlez_app/lib/widgets/tz_app_screen.dart` (`_TabBar`)
- **Required UI Changes:**
  - **Dimensions:** Fixed bar height of 48dp (`sizes.controlLg`) plus device bottom inset (`MediaQuery.viewPaddingOf(context).bottom`).
  - **Borders & Background:** Surface background `colors.surface`, hairline top border `colors.cardBorderSoft` (1.0dp).
  - **Tab Items:** 4 tabs: Home (`AppIcons.home`), Bookings (`AppIcons.calendar`), Saved (`AppIcons.heart`), Account (`AppIcons.user`).
  - **Typography & Icons:** Active color `colors.brandPrimary` (red), inactive color `colors.inkTertiary`. Icon size `sizes.iconSm` (18dp), text style `context.text.labelSmall` (10dp) with `TypeScale.semiBold` when active. Minimum tap target 48dp width per tab.
- **Dependencies:** `AppColors`, `AppSize`, `AppSpace`, `AppIcons`.
- **Implementation & Verification Checklist:**
  - [x] Eliminate raw `TextStyle(fontSize: 10)` in `_TabBarItem`.
  - [x] Verify tab bar height alignment and safe area padding on iOS home indicator devices.
  - [x] Ensure tap target accessibility semantics on all 4 tabs.

#### 2.2 Home Hub Screen
- **Target File:** [`lib/features/home/presentation/screens/home_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/home/presentation/screens/home_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/home_hub_screen.dart` (Artboard `212 x 490`, class `.h3`)
- **Required UI Changes:**
  - **Pinned Header (`AppPinnedHeader`):** White container with curved bottom corners (`shape.radiusSurface`).
    - Top row: `HomeWordmarkRow` with unread notification bell icon and dark mode toggle.
    - Location row: `HomeLocationRow` ("Edinburgh, UK" with chevron indicator).
    - Greeting: Replace hardcoded `TextStyle(fontSize: 20)` with `context.text.headlineMedium` ("Good evening, Amara").
    - Verification subtitle: Replace hardcoded `TextStyle(fontSize: 12)` with `context.text.bodySmall` ("ID verified — book without re-checking" or "Verify once, book without re-checking").
  - **Check-In Banner (`CheckInBanner`):** Displayed prominently above service cards when an active check-in is ready. Red tint background (`colors.surfaceRedTint`), left door icon, hotel name, and "Open now · takes 2 minutes".
  - **Services Grid (`ServiceGrid`):** 4 cards (ezStays, ezCar, ezFlight, ezTour) with 14dp border radius, subtle card border `colors.cardBorderSoft`, 3% shadow (`colors.cardShadow`). "SOON" pills in `colors.soonCard`.
  - **Findr Card:** Embed `FindrCard` using the 3 states (Locked for unverified, Not Joined, Active with £ rewards).
  - **Next Stay Row (`NextStayRow`):** Photo thumbnail box (`PhotoBox` 44×44dp), property name, location, dates, and "ezStays" badge.
- **Dependencies:** `AppPinnedHeader`, `CheckInBanner`, `FindrCard`, `ServiceGrid`, `PhotoBox`.
- **Implementation & Verification Checklist:**
  - [x] Remove all inline `TextStyle` instances.
  - [x] Verify header padding, location picker tap, and notification bell sheet triggers.
  - [x] Verify visual hierarchy on both compact and standard phone viewports.

#### 2.3 Location Picker Sheet & Notifications Sheet
- **Target Files:**
  - [`lib/features/home/presentation/widgets/location_picker_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/home/presentation/widgets/location_picker_sheet.dart)
  - [`lib/features/home/presentation/widgets/notifications_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/home/presentation/widgets/notifications_sheet.dart)
- **Reference Screens:**
  - `trvlez_app/lib/features/signed_in/location_picker_sheet.dart`
  - `trvlez_app/lib/features/signed_in/notifications_sheet.dart`
- **Required UI Changes:**
  - **Sheet Container:** White surface with top radius `shape.radiusOverlay` (20dp), centered grab handle.
  - **Location Picker:** Clean search input with prefix search icon and clear button; location list items with checkmark indicator for selected city.
  - **Notifications:** "Notifications" title with "Clear all" link button; items styled with circular icon container, title, body, timestamp, and unread dot indicator (`colors.brandPrimary`).
- **Dependencies:** `AppColors`, `AppSpace`, `AppShape`.
- **Implementation & Verification Checklist:**
  - [x] Verify bottom sheet styling, insets, and keyboard handling.
  - [x] Ensure clear all and selection callbacks remain fully functional.

---

### Phase 3: Identity & Document Verification Flow (Section 02)

#### 3.1 Verification Landing Screen
- **Target File:** [`lib/features/verification/presentation/screens/verification_landing_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/verification_landing_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/verification_landing_screen.dart` (Artboard `250 x 648`, class `.ke`)
- **Required UI Changes:**
  - **Header:** "Welcome to" with inline `BrandWordmark`. Replace raw `fontSize: 18.0` with semantic token.
  - **Progress Bar:** Text "[N] of 4 steps completed" using `context.text.labelSmall`. Progress track height 4dp, background `colors.verificationProgressTrack`.
  - **Step Cards:** 4 cards (Upload Passport, Review Details, Selfie Verification, NFC Verification).
    - Locked cards: Subdued text, lock/step icon in `colors.verificationCardIconFill`.
    - Active card (`.card.now`): Brighter translucent fill (`colors.verificationCardActiveFill`), 1.5dp inset white ring (`shape.borderMedium`), and chevron icon.
    - Two-line subtitle reservation so card heights never shift when moving from locked to active.
  - **Foot:** Security note and "Having difficulties? Tell us what's wrong" help footer.
- **Dependencies:** `BrandVerifyScreen`, `VerificationStepper`, `BrandWordmark`, `BrandSecurityNote`.
- **Implementation & Verification Checklist:**
  - [ ] Remove raw text font size from `BrandWordmark`.
  - [ ] Verify card visual states (locked, active, completed) and smooth step transitions.
  - [ ] Confirm step calculation logic (`_calculateDoneSteps`) and backend reconciliation remain intact.

#### 3.2 Passport Instruction Screen (How-To)
- **Target File:** [`lib/features/verification/presentation/screens/passport_instruction_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/passport_instruction_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/passport_how_to_screen.dart` (Artboard `242 x 620`, class `.rv`)
- **Required UI Changes:**
  - **Scaffold:** `BrandVerifyScreen` with background `assets/art/bg_passport_howto.svg`.
  - **Typography:** Eliminate raw `TextStyle(fontSize: 20.0, 12.0)`. Title "Passport photo" and subtitle "We need both of these. Most retakes happen because the bottom two lines were cut off." using `context.text.headlineSmall` and `bodySmall`.
  - **Diagram & Pointers:** Passport diagram asset (`assets/art/passport_diagram.svg`) sized to width 170dp, height 129dp. Pointers 1 (Photo page) & 2 (Code lines) styled with `BrandPointerPair`.
  - **Guidance Card:** `BrandInfoCard` with 3 bullets (Well lit, All four corners, No fingers or shadows).
  - **Foot:** "Open camera" white action button (`AppButtonVariant.brandWhite`).
- **Dependencies:** `BrandVerifyScreen`, `VerificationStepper`, `BrandPointerPair`, `BrandInfoCard`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Convert all text styles to semantic tokens.
  - [ ] Verify camera launch and back navigation.

#### 3.3 Passport Capture Screen
- **Target File:** [`lib/features/verification/presentation/screens/passport_capture_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/passport_capture_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/passport_capture_screen.dart` (Artboard `226 x 590`, class `.lw`)
- **Required UI Changes:**
  - **Typography:** Remove hardcoded `TextStyle(fontSize: 12.0, 11.5)`.
  - **Viewfinder:** Constrained box with aspect ratio 1 : 1.05 (`aspectRatio: 1 / 1.05`), corner radius `shape.radiusControl` (12dp).
  - **Framing Overlay:** ICAO TD3 passport corner guides and dashed MRZ bounding box (`PassportFramingGuide`).
  - **Helper Text:** Row with numbers icon and "Keep the dashed box over the code lines".
  - **Foot:** Square shutter button (`BrandShutter(square: true)`) with touch target min 56dp.
- **Dependencies:** `BrandVerifyScreen`, `PassportFramingGuide`, `BrandShutter`.
- **Implementation & Verification Checklist:**
  - [ ] Verify square shutter styling vs circular selfie shutter.
  - [ ] Ensure camera preview aspect ratio and crop mathematics remain unaffected.

#### 3.4 Passport Processing Screen
- **Target File:** [`lib/features/verification/presentation/screens/passport_processing_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/passport_processing_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/passport_processing_screen.dart`
- **Required UI Changes:**
  - **Visual Indicator:** Animated hourglass graphic (`verify_hourglass.dart`) or spinning stage ring.
  - **Stage Typography:** "Checking photo quality...", "Reading passport details...", "Verifying document authenticity...".
  - **Status Rows:** Stage progress rows with checkmarks for completed sub-steps.
- **Dependencies:** `BrandVerifyScreen`, `VerifyHourglass`, `VerifyStatusRows`.
- **Implementation & Verification Checklist:**
  - [ ] Verify smooth stage transitions without UI stutter.
  - [ ] Confirm background OCR and crop processing logic is preserved.

#### 3.5 Passport Review Screen
- **Target File:** [`lib/features/verification/presentation/screens/passport_review_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/passport_review_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/passport_review_screen.dart`
- **Required UI Changes:**
  - **Preview Frame:** Cropped passport photo container with subtle border and zoom panel indicator (`VerifyZoomPanel`).
  - **Detail Rows:** Key-value rows (`VerifyDetailRow`) displaying extracted MRZ fields in high contrast.
  - **Foot Actions:** Primary "Looks good, continue" button and secondary outline "Retake photo" button.
- **Dependencies:** `BrandVerifyScreen`, `VerifyZoomPanel`, `VerifyDetailRow`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Check image aspect ratio and layout fit across screen densities.
  - [ ] Verify confirm and retake flows.

#### 3.6 Confirm Details Screen (MRZ Confirmation)
- **Target File:** [`lib/features/verification/presentation/screens/confirm_details_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/confirm_details_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/confirm_details_screen.dart` (Artboard `232 x 616`)
- **Required UI Changes:**
  - **Heading:** "Check these match your passport" and subtitle "These were read from the code lines. They must agree with the page."
  - **Details Card:** Translucent card with lock icon and read-only rows: Given names, Surname, Document number, Nationality, Date of birth, Expiry date.
  - **Foot:** "These match my passport" action button and "Need to edit? Tap a field" helper note.
- **Dependencies:** `BrandVerifyScreen`, `VerificationStepper`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify field alignment and read-only presentation.
  - [ ] Ensure payload confirmation and navigation to Selfie step.

#### 3.7 Passport Failed Screen
- **Target File:** [`lib/features/verification/presentation/screens/passport_failed_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/passport_failed_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/passport/passport_failed_screen.dart`
- **Required UI Changes:**
  - **Header:** Warning icon and "We couldn't read your passport".
  - **Explanation Card:** Bullets detailing reason (glare, blur, cropped MRZ lines).
  - **Foot:** White button "Take photo again" and "Report a problem" footer link.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify failure reason display and retake button route navigation.

#### 3.8 Selfie Instruction Screen (Intro)
- **Target File:** [`lib/features/verification/presentation/screens/selfie_instruction_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_instruction_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/selfie/selfie_intro_screen.dart`
- **Required UI Changes:**
  - **Stepper:** Current step at 2 (Selfie Verification).
  - **Header:** "Quick video selfie" and subtitle "3 seconds. Look straight ahead, natural expression."
  - **Oval Diagram:** Face oval guide illustration with lighting markers.
  - **Info Card:** Bullets: Good lighting, Remove sunglasses/hats, Hold camera at eye level.
  - **Foot:** "Start video selfie" button.
- **Dependencies:** `BrandVerifyScreen`, `VerificationStepper`, `BrandInfoCard`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify layout proportions and button action.

#### 3.9 Selfie Capture Screen (Recording)
- **Target File:** [`lib/features/verification/presentation/screens/selfie_capture_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_capture_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/verification/selfie/selfie_recording_screen.dart`
- **Required UI Changes:**
  - **Viewfinder:** Full face oval framing guide (`VerifyFaceOval`) with active stroke.
  - **Recording Shutter:** Round shutter button (`BrandShutter(square: false)`), contrasting with the square passport shutter.
  - **Recording Indicator:** Animated countdown ring (`VerifyRecordingTime`) showing 3-second elapsed time.
- **Dependencies:** `BrandVerifyScreen`, `VerifyFaceOval`, `BrandShutter`, `VerifyRecordingTime`.
- **Implementation & Verification Checklist:**
  - [ ] Verify circular shutter styling.
  - [ ] Ensure front camera recording lifecycle, timer, and file persistence remain intact.

#### 3.10 Selfie Processing, Review, Success & Failed Screens
- **Target Files:**
  - [`lib/features/verification/presentation/screens/selfie_processing_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_processing_screen.dart)
  - [`lib/features/verification/presentation/screens/selfie_review_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_review_screen.dart)
  - [`lib/features/verification/presentation/screens/selfie_success_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_success_screen.dart)
  - [`lib/features/verification/presentation/screens/selfie_failed_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/selfie_failed_screen.dart)
- **Reference Screens:** Matching selfie screens in `trvlez_app/lib/features/verification/selfie/`.
- **Required UI Changes:**
  - **Processing:** Animated pulse/hourglass matching passport processing.
  - **Review:** Video thumbnail loop with playback controls, "Submit video" primary and "Retake" secondary.
  - **Success:** Green checkmark emblem, "Selfie matched", "Continue to chip scan" button.
  - **Failed:** Failure card with retake option and support link.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`, `VerifyHourglass`.
- **Implementation & Verification Checklist:**
  - [ ] Verify visual alignment and review playback controls.

#### 3.11 NFC Flow Screens (Intro, Scan, Chip Data, Final Check, Failed)
- **Target Files:**
  - [`lib/features/verification/presentation/screens/nfc_intro_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/nfc_intro_screen.dart)
  - [`lib/features/verification/presentation/screens/nfc_scan_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/nfc_scan_screen.dart)
  - [`lib/features/verification/presentation/screens/chip_data_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/chip_data_screen.dart)
  - [`lib/features/verification/presentation/screens/verification_final_check_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/verification_final_check_screen.dart)
  - [`lib/features/verification/presentation/screens/nfc_failed_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/nfc_failed_screen.dart)
- **Reference Screens:** Matching NFC screens in `trvlez_app/lib/features/verification/nfc/`.
- **Required UI Changes:**
  - **Intro:** Phone against passport back-cover illustration, "Scan passport chip", "Start NFC scan" button and "Skip for now" link.
  - **Scan:** Pulsing radar animation (`VerifyNfcPulse`) with percentage progress text.
  - **Chip Data:** Biometric photo preview card with holographic watermark styling and digital signature status badge.
  - **Final Check:** 3 check items with animated trio indicator (`VerifyProgressTrio`).
  - **Failed:** NFC error card with repositioning tips and retry action.
- **Dependencies:** `BrandVerifyScreen`, `VerifyNfcPulse`, `VerifyProgressTrio`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify pulse and progress animations.
  - [ ] Confirm platform NFC service event handling is untouched.

#### 3.12 Verification Success Screen & Report a Problem Screen
- **Target Files:**
  - [`lib/features/verification/presentation/screens/verification_success_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/verification_success_screen.dart)
  - [`lib/features/verification/presentation/screens/report_a_problem_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/verification/presentation/screens/report_a_problem_screen.dart)
- **Reference Screens:**
  - `trvlez_app/lib/features/verification/verification_success_screen.dart`
  - `trvlez_app/lib/features/verification/report_a_problem_screen.dart` (Artboard `250 x 648`, class `.ke`)
- **Required UI Changes:**
  - **Success:** Centered shield emblem with checkmark, "Identity verified" title, and "Go to Home" button.
  - **Report a Problem:**
    - Close icon 'X' in header instead of back arrow.
    - Title "Report a problem" using `context.text.headlineSmall`.
    - Multi-select problem chips with selected border/fill.
    - Notes text field with `colors.brandCardBackground` fill and no border.
    - Safety notice card: "Never send photos of your passport by message. We will never ask you to."
    - "Send report" button.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Remove raw text font sizes in `report_a_problem_screen.dart`.
  - [ ] Verify multi-select chips and auto-ticking behavior on notes entry.

---

### Phase 4: Account, Profile & Settings

#### 4.1 Account Screen
- **Target File:** [`lib/features/profile/presentation/screens/account_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/screens/account_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/account_screen.dart` (Artboard `212 x 506`, class `.a3`)
- **Required UI Changes:**
  - **Pinned Header (`AppPinnedHeader`):** "Account" title, avatar circle with initials, name, and email subtitle.
  - **Verified Identity Card (`VerifiedCard`):** Soft red tint background (`colors.surfaceRedTint`), verified checkmark icon, passport legal name, and issue/expiry dates.
  - **Settings Groups (`SettingsGroup`):**
    - Group headings: Personal, Sharing & permissions, Payments, Security, Preferences, Support.
    - Row items with leading icon, title, optional trailing value, and chevron.
  - **Sign Out & Close Account:** Clean alert dialog for sign out and navigation row to Close Account screen.
- **Dependencies:** `AppPinnedHeader`, `VerifiedCard`, `SettingsGroup`.
- **Implementation & Verification Checklist:**
  - [ ] Verify row spacing, dividers, and tap handling.
  - [ ] Ensure profile state updates propagate cleanly.

#### 4.2 Close Account Screen
- **Target File:** [`lib/features/profile/presentation/screens/close_account_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/screens/close_account_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/close_account_screen.dart` (Artboard `212 x 506`)
- **Required UI Changes:**
  - **Header:** `AppPinnedHeader` with back button and "Close my account" title.
  - **Description:** Remove raw `TextStyle(fontSize: 18, 13)` and use `context.text.bodyMedium`.
  - **Option 1 (Deactivate):** Card with pause icon, description, and "Deactivate" button.
  - **Option 2 (Close and delete):** Card with trash icon, description, and red danger button "Close and delete".
  - **Legal Retention Note:** Amber notice box (`TzColors.waitFill` / `colors.statusWarningBackground`), warning icon, and legal data retention statement.
- **Dependencies:** `AppPinnedHeader`, `AppButton`, `AppColors`.
- **Implementation & Verification Checklist:**
  - [ ] Remove all inline `TextStyle` instances.
  - [ ] Verify button feedback and confirmation dialogs.

#### 4.3 Personal Details, Security, Preferences & Passcode Sheet
- **Target Files:**
  - [`lib/features/profile/presentation/screens/personal_details_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/screens/personal_details_screen.dart)
  - [`lib/features/profile/presentation/screens/security_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/screens/security_screen.dart)
  - [`lib/features/profile/presentation/widgets/passcode_setup_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/widgets/passcode_setup_sheet.dart)
  - [`lib/features/profile/presentation/screens/preferences_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/profile/presentation/screens/preferences_screen.dart)
- **Reference Screens:** Derived from Account settings rows & `set_passcode_screen.dart` in `trvlez_app`.
- **Required UI Changes:**
  - **Personal Details:** User details card (display name, email) and read-only legal name card with "Re-verify" button.
  - **Security:** App passcode toggle row, biometric unlock switch, and two-step verification row.
  - **Passcode Setup Sheet:** 4/6-digit numeric keypad dots presentation matching reference `TzKeypad` aesthetics with mismatch feedback.
  - **Preferences:** Theme mode selector (System, Light, Dark) and currency preferences.
- **Dependencies:** `AppPinnedHeader`, `SettingsGroup`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify clean token usage across all settings sub-screens.
  - [ ] Ensure keychain storage and secure preferences continue to work.

---

### Phase 5: Properties Catalog (ezStays) & Booking Flow (Section 05)

#### 5.1 Properties Listing Screen (ezStays)
- **Target File:** [`lib/features/properties/presentation/screens/properties_listing_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/properties/presentation/screens/properties_listing_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/ez_stays_screen.dart` (Artboard `212 x 490`, class `.h3`)
- **Required UI Changes:**
  - **Header:** Back button, "ezStays" with red "ez" brand mark (`EzWord`), search bar with clear button.
  - **Filters:** Horizontal pill chips (All, Hotels, Resorts, Villas) with active red background or subtle outline.
  - **Property Card (`PropertyCard`):**
    - Aspect ratio and border radius 14dp (`shape.radiusSurface`).
    - Top image with "Verified partner" badge and heart save button.
    - Details: Property name, location with pin icon, and price ("from £240/night" in GBP).
- **Dependencies:** `AppPinnedHeader`, `EzWord`, `PropertyCard`, `HeartButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify search debounce and category filtering.
  - [ ] Ensure currency formatting is displayed consistently in GBP (£).

#### 5.2 Property Details Screen
- **Target File:** [`lib/features/booking/presentation/screens/property_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/screens/property_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/booking/property_screen.dart`
- **Required UI Changes:**
  - **Photo Band:** Property image carousel with tag pills and save button.
  - **Selection Rows (`BookingPickRow`):** Dates picker bar and Guests count bar.
  - **Rooms List:** Room cards with price per night, occupancy capacity, and selection radio toggle.
  - **Foot Bar:** Fixed bottom bar with price total and "Review booking" button.
- **Dependencies:** `AppPinnedHeader`, `BookingPickRow`, `BookingRoomCard`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify date selection and room selection draft updates.
  - [ ] Check foot bar elevation and safe area insets.

#### 5.3 Booking Dates Screen & Room Dates / Guests Sheets
- **Target Files:**
  - [`lib/features/booking/presentation/screens/booking_dates_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/screens/booking_dates_screen.dart)
  - [`lib/features/booking/presentation/widgets/room_dates_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/widgets/room_dates_sheet.dart)
  - [`lib/features/booking/presentation/widgets/guests_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/widgets/guests_sheet.dart)
- **Reference Screens:** Matching booking screens in `trvlez_app/lib/features/booking/`.
- **Required UI Changes:**
  - **Calendar:** Continuous downward scrolling month view (no month-paging arrows, matching reference design).
  - **Range Highlighting:** Start date circle, end date circle, intermediate continuous highlight strip.
  - **Sheets:** Modal bottom sheet with increment/decrement steppers for adults and children counts.
- **Dependencies:** `AppPinnedHeader`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify range selection logic and draft state updates.

#### 5.4 Booking Review, Card & Booked Screens
- **Target Files:**
  - [`lib/features/booking/presentation/screens/booking_review_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/screens/booking_review_screen.dart)
  - [`lib/features/booking/presentation/screens/booking_card_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/screens/booking_card_screen.dart)
  - [`lib/features/booking/presentation/screens/booked_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/booking/presentation/screens/booked_screen.dart)
- **Reference Screens:** Matching screens in `trvlez_app/lib/features/booking/`.
- **Required UI Changes:**
  - **Review:** Breakdown card (rooms, dates, arithmetic: nightly × nights × rooms), cancellation terms note, and "Add payment card" button.
  - **Card:** Card number, expiry, and CVV fields styled with `AppColors`, encryption security note, "Confirm and hold card" button.
  - **Booked:** Green checkmark badge, booking reference code card, "View in Bookings" primary action, "Back to ezStays" secondary action.
- **Dependencies:** `AppPinnedHeader`, `AppButton`, `BrandSecurityNote`.
- **Implementation & Verification Checklist:**
  - [ ] Verify price arithmetic display in GBP (£).
  - [ ] Ensure card submission mock/tokenization and routing to Booked confirmation work as expected.

---

### Phase 6: Check-In Flow (Section 06)

#### 6.1 Check-In Steps Screen
- **Target File:** [`lib/features/check_in/presentation/screens/check_in_steps_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_steps_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/check_in/check_in_steps_screen.dart` (Artboards `36_whats_needed_visa` and `37_whats_needed_spain`)
- **Required UI Changes:**
  - **Scaffold:** `BrandVerifyScreen` with background `assets/art/bg_checkin_steps.svg`.
  - **Header & Subtitle:** Remove raw `TextStyle(fontSize: 22, 12)` and use `context.text.headlineSmall` and `bodySmall`.
  - **Destination Callout (`CheckInFlagCallout`):** Destination flag icon, lead header, and requirement summary.
  - **4 Steps Tiles (`CheckInStepTile`):** (1) Your identity (Done for verified user), (2) Destination requirement (Visa/Disclosure), (3) A few questions, (4) Get your key code.
  - **Foot:** "Continue" white button and `CheckInNotice` disclaimer text.
- **Dependencies:** `BrandVerifyScreen`, `CheckInFlagCallout`, `CheckInStepTile`, `CheckInNotice`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Remove all inline `TextStyle` instances.
  - [ ] Verify dynamic visa vs disclosure routing based on destination requirements.

#### 6.2 Check-In Visa Screens (Requirements, Capture & Review)
- **Target Files:**
  - [`lib/features/check_in/presentation/screens/check_in_visa_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_visa_screen.dart)
  - [`lib/features/check_in/presentation/screens/check_in_visa_capture_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_visa_capture_screen.dart)
  - [`lib/features/check_in/presentation/screens/check_in_visa_review_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_visa_review_screen.dart)
- **Reference Screens:** Matching visa screens in `trvlez_app/lib/features/check_in/`.
- **Required UI Changes:**
  - **Requirements:** Visa explanation card and upload guidelines.
  - **Capture:** Document viewfinder with visa framing guide and shutter button.
  - **Review:** Document preview card, extracted visa number field, and "Confirm visa" action.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`, `BrandShutter`.
- **Implementation & Verification Checklist:**
  - [ ] Verify camera viewfinder and review confirmation.

#### 6.3 Check-In Disclosure & Declined Screens
- **Target Files:**
  - [`lib/features/check_in/presentation/screens/check_in_disclosure_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_disclosure_screen.dart)
  - [`lib/features/check_in/presentation/screens/check_in_declined_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_declined_screen.dart)
- **Reference Screens:** Matching screens in `trvlez_app/lib/features/check_in/`.
- **Required UI Changes:**
  - **Disclosure:** Legal disclosure data cards with legal reporting details, consent switch, and "Accept and share" button.
  - **Declined:** Red screen warning state explaining that check-in must now be completed at the hotel front desk.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify consent toggles and declined state navigation.

#### 6.4 Check-In Guests, Questions, Done, Pass & Hotel View
- **Target Files:**
  - [`lib/features/check_in/presentation/screens/check_in_guests_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_guests_screen.dart)
  - [`lib/features/check_in/presentation/screens/invite_guest_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/invite_guest_sheet.dart)
  - [`lib/features/check_in/presentation/screens/check_in_questions_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_questions_screen.dart)
  - [`lib/features/check_in/presentation/screens/check_in_done_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_done_screen.dart)
  - [`lib/features/check_in/presentation/screens/check_in_pass_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/check_in_pass_screen.dart)
  - [`lib/features/check_in/presentation/screens/hotel_view_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/check_in/presentation/screens/hotel_view_screen.dart)
- **Reference Screens:** Matching check-in screens in `trvlez_app/lib/features/check_in/`.
- **Required UI Changes:**
  - **Guests & Invite Sheet:** Companion guest cards with status pills and invitation link share modal.
  - **Questions:** Arrival time selection chips and notes field.
  - **Done & Pass:** Check-in pass card (`TzPassCard`) showing key code, QR/barcode placeholder, and stay summary.
  - **Hotel View:** Hotel image, address, front desk contact details, and directions button.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`, `StatusPill`.
- **Implementation & Verification Checklist:**
  - [ ] Verify key code display and hotel view details.

---

### Phase 7: Loyalty (Findr) & Saved Properties

#### 7.1 Findr Programme Screen & Join Findr Sheet
- **Target Files:**
  - [`lib/features/findr/presentation/screens/findr_programme_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/findr/presentation/screens/findr_programme_screen.dart)
  - [`lib/core/widgets/join_findr_sheet.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/core/widgets/join_findr_sheet.dart)
- **Reference Screens:**
  - `trvlez_app/lib/features/findr/findr_programme_screen.dart` (Artboard `212 x 620`, class `.fn`)
  - `trvlez_app/lib/features/findr/join_findr_sheet.dart`
- **Required UI Changes:**
  - **Header:** Centered title "Findr" and left-aligned back arrow on `AppPinnedHeader`.
  - **Card:** `FindrCard` using paper background (`colors.paper`), paper ink typography (`colors.paperInk`), earned rewards in GBP (£), and referral metrics.
  - **Earnings List:** Section title "Recent", rows with hotel name, earnings amount, date, and status pill (`StatusPill`).
  - **Join Sheet:** Terms bullets, referral perks, and "Join programme" button.
- **Dependencies:** `AppPinnedHeader`, `FindrCard`, `StatusPill`, `JoinFindrSheet`.
- **Implementation & Verification Checklist:**
  - [ ] Verify paper palette styling and currency formatting.
  - [ ] Ensure referral link copy callback works seamlessly.

#### 7.2 Saved Screen
- **Target File:** [`lib/features/saved/presentation/screens/saved_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/saved/presentation/screens/saved_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/saved_screen.dart`
- **Required UI Changes:**
  - **Header:** "Saved" title, 3-way segmented control (ezStays, ezShop, ezChat) with red "ez" brand mark (`EzWord`).
  - **List Rows:** Property image box (`PhotoBox`), property name, location, price per night in GBP (£), and active red heart button to unsave.
  - **Empty State:** Subtle icon, "No saved stays yet", and "Browse properties" button.
- **Dependencies:** `AppPinnedHeader`, `AppSegmentedControl`, `EzWord`, `PhotoBox`, `HeartButton`.
- **Implementation & Verification Checklist:**
  - [ ] Remove all inline `TextStyle` instances.
  - [ ] Verify toggle unsave updates list without UI jumpiness.

---

### Phase 8: Check-in Anywhere & Disputes

#### 8.1 Check-in Anywhere Screens (Find, Hotel Details, Stay Details, Told, Sent)
- **Target Files:**
  - [`lib/features/anywhere/presentation/screens/find_hotel_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/anywhere/presentation/screens/find_hotel_screen.dart)
  - [`lib/features/anywhere/presentation/screens/hotel_details_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/anywhere/presentation/screens/hotel_details_screen.dart)
  - [`lib/features/anywhere/presentation/screens/stay_details_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/anywhere/presentation/screens/stay_details_screen.dart)
  - [`lib/features/anywhere/presentation/screens/what_they_are_told_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/anywhere/presentation/screens/what_they_are_told_screen.dart)
  - [`lib/features/anywhere/presentation/screens/anywhere_sent_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/anywhere/presentation/screens/anywhere_sent_screen.dart)
- **Reference Screens:** Matching anywhere screens in `trvlez_app/lib/features/anywhere/`.
- **Required UI Changes:**
  - **Scaffold:** `BrandVerifyScreen` across all screens in the flow.
  - **Search & Results:** Search field and hotel results cards with "On TRVLez" partner tags.
  - **Forms:** Stay dates and guest inputs styled with `BrandTextField`.
  - **Preview & Confirmation:** "What they are told" card previewing disclosure info sent to property, followed by "Sent" confirmation screen.
- **Dependencies:** `BrandVerifyScreen`, `BrandTextField`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify form validation and step progression.

#### 8.2 Disputes Screens (Reason, Detail, Raised, Status)
- **Target Files:**
  - [`lib/features/disputes/presentation/screens/dispute_reason_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/disputes/presentation/screens/dispute_reason_screen.dart)
  - [`lib/features/disputes/presentation/screens/dispute_detail_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/disputes/presentation/screens/dispute_detail_screen.dart)
  - [`lib/features/disputes/presentation/screens/dispute_raised_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/disputes/presentation/screens/dispute_raised_screen.dart)
  - [`lib/features/disputes/presentation/screens/dispute_status_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/disputes/presentation/screens/dispute_status_screen.dart)
- **Reference Screens:** Matching dispute screens in `trvlez_app/lib/features/dispute/`.
- **Required UI Changes:**
  - **Reason:** Reason selection panels with chevron indicator (no unnecessary button, chevron acts as action).
  - **Detail:** Explanation textarea with character limit guidance and "Submit dispute" button.
  - **Raised & Status:** Case reference number card, status badge, and dispute resolution timeline.
- **Dependencies:** `BrandVerifyScreen`, `AppButton`.
- **Implementation & Verification Checklist:**
  - [ ] Verify dispute submission and case tracking states.

---

### Phase 9: Trips & Reservations Management

#### 9.1 My Trips Screen (Bookings List)
- **Target File:** [`lib/features/reservations/presentation/screens/my_trips_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/reservations/presentation/screens/my_trips_screen.dart)
- **Reference Screen:** `trvlez_app/lib/features/signed_in/bookings_screen.dart` (Artboard `212 x 490`, class `.h3`)
- **Required UI Changes:**
  - **Header:** Title "Bookings" (or "My Trips"), 2-way segmented control (Upcoming / Past) replacing raw Material TabBar.
  - **Booking Card:**
    - Property photo box (`PhotoBox` 44×44dp), property name, location, and status pill (`StatusPill`).
    - Check-in action strip: "Check in online · Open now · Start" (when open) or "Check-in opens [Date]" (when closed).
    - Date strip: Calendar icon, date range, building icon, and "ezStays" badge.
    - Dispute row: Subtle strip with chevron ("Something wrong with this stay?").
- **Dependencies:** `AppPinnedHeader`, `AppSegmentedControl`, `PhotoBox`, `StatusPill`.
- **Implementation & Verification Checklist:**
  - [ ] Remove all inline `TextStyle` instances.
  - [ ] Verify check-in button routing and dispute triggering.

#### 9.2 Reservation Detail & Pre-Arrival Form Screens
- **Target Files:**
  - [`lib/features/reservations/presentation/screens/reservation_detail_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/reservations/presentation/screens/reservation_detail_screen.dart)
  - [`lib/features/reservations/presentation/screens/pre_arrival_form_screen.dart`](file:///home/kumaraguhan/workspace/trvlez_mobile/lib/features/reservations/presentation/screens/pre_arrival_form_screen.dart)
- **Reference Screens:** Booking details & Check-in steps design patterns
- **Required UI Changes:**
  - Remove raw `TextStyle` declarations and apply semantic typography tokens.
  - Reservation info cards, property summary cards, and status badges styled using `AppColors` and `AppShape`.
- **Dependencies:** `AppPinnedHeader`, `AppButton`, `StatusPill`.
- **Implementation & Verification Checklist:**
  - [ ] Ensure all form controllers, submission callbacks, and state updates remain functional.

---

## 4. Quality Assurance, Testing & Definition of Done

For every screen refactored under this plan, the following quality checklist must be satisfied before marking the screen complete:

1. **Static Analysis & Linting:**
   - [ ] Code formatted with `dart format .`.
   - [ ] Clean analyzer report (`flutter analyze` returns zero errors and zero warnings).
   - [ ] Zero raw layout numbers (satisfies `flutter-semantic-layout-tokens`).
   - [ ] Zero inline `TextStyle` or `Color(0x...)` magic literals.
2. **Accessibility & Usability:**
   - [ ] All interactive buttons and touch targets meet minimum 48×48 dp dimensions.
   - [ ] Verified at 200% text scale without overflow or clipped text.
   - [ ] Contrast ratios meet WCAG AA standards (≥4.5:1 for normal text, ≥3:1 for large text).
3. **Behavioral Integrity:**
   - [ ] All existing business logic, validation, state management, and API calls work exactly as before.
   - [ ] No regression in unit or widget tests (`flutter test`).
4. **Visual Parity:**
   - [ ] Proportions, border radii, card padding, and button shapes match `trvlez_app` reference implementation.
