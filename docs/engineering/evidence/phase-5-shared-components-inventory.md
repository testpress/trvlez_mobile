# Phase 5 — Shared Components & State Surfaces Inventory

Per Playbook Chapter 04 (`docs/engineering/playbook/04-design-system-and-reference-intake.md`) and Chapter 07 (`docs/engineering/playbook/07-accessibility-and-performance.md`), this document catalogues the canonical shared controls, surfaces, and state presentation components across the TrvlEz mobile codebase.

---

## 1. Shared Controls Catalogue

| Component | File Path | Variants | Applicable States | Min Target Size | Feedback Mechanism | Validation Test Suite |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `AppButton` | `lib/core/widgets/app_button.dart` | `primary`, `secondary`, `ghost` | Default, disabled, loading, focused, pressed | ≥ 48 dp (`controlLg`) | `ElevatedButton`, `OutlinedButton`, `TextButton` Material ink ripple | Widget matrix & theme tests |
| `AppTextField` | `lib/core/widgets/app_text_field.dart` | Default, pill (`borderRadius`), prefix/suffix icons | Default, focused, error, disabled | ≥ 48 dp (`controlLg`) | Material `TextFormField` interaction | Screen & theme matrices |
| `AppSegmentedControl<T>` | `lib/core/widgets/app_segmented_control.dart` | Pill segmented switcher | Selected, unselected | ≥ 48 dp per segment | `Material` + `InkWell` | `test/core/widgets/app_segmented_control_test.dart` |
| `BrandShutter` | `lib/core/widgets/brand_shutter.dart` | Circular camera shutter | Default, pressed | 72×72 dp (touch area ≥ 48 dp) | `Material` + `InkResponse` | `test/core/widgets/brand_shutter_test.dart` |
| `HeartButton` | `lib/core/widgets/heart_button.dart` | Circular property favorite toggle | Saved (red), unsaved (outline), pressed | 48×48 dp (`touchTargetMin`) | `Material` + `InkWell` | `test/core/widgets/heart_button_test.dart` |
| `CheckInConsentTick` | `lib/core/widgets/check_in_consent_tick.dart` | Checkbox consent toggle row | Checked, unchecked | ≥ 48 dp row height | `Material` + `InkWell` | `test/core/widgets/check_in_consent_tick_test.dart` |
| `BrandTextField` | `lib/core/widgets/brand_text_field.dart` | Brand red/dark pill input | Default, focused, error, obscured, disabled | ≥ 48 dp (`controlLg`) | Material `TextFormField` + `IconButton` | Auth & verification screen tests |

---

## 2. Shared Surfaces & Containers

| Component | File Path | Intended Role | Variants | Validation Test Suite |
| :--- | :--- | :--- | :--- | :--- |
| `AppCard` | `lib/core/widgets/app_card.dart` | Elevated/bordered content container | Flat, elevated, outlined, interactive | `test/core/widgets/app_card_golden_test.dart` |
| `AppPinnedHeader` | `lib/core/widgets/app_pinned_header.dart` | Sticky header with title, subtitle, leading, trailing | Default pinned bar | Shell & screen tests |
| `StatusPill` | `lib/core/widgets/status_pill.dart` | Compact status indicator pill | `neutral`, `success`, `warning`, `error`, `brand` | `test/core/widgets/status_pill_test.dart` |
| `BrandInfoCard` | `lib/core/widgets/brand_info_card.dart` | Translucent instruction card with bullets | Default instructional container | Verification screen tests |
| `PhotoBox` | `lib/core/widgets/photo_box.dart` | Media thumbnail with placeholder fallback | Default rounded photo container | Property card tests |
| `VerificationStepper` | `lib/core/widgets/verification_stepper.dart` | Identity verification progress tracker | 4-step horizontal stepper | Verification screen tests |
| `FindrCard` | `lib/core/widgets/findr_card.dart` | Findr loyalty and referral status card | `locked`, `processing`, `notJoined`, `active` | Findr screen tests |

---

## 3. Screen-State Presentation Surfaces (Playbook Chapter 04 Contract)

| State | Component | File Path | Behavioral & Semantics Contract | Validation Test Suite |
| :--- | :--- | :--- | :--- | :--- |
| **Loading** | `LoadingView` | `lib/core/widgets/loading_view.dart` | Centered spinner with optional progress message; scalable text (1.0-2.0); progress semantics. | `test/core/widgets/loading_view_test.dart` |
| **Empty** | `EmptyView` | `lib/core/widgets/empty_view.dart` | Explains what is absent (icon, title, subtitle) and provides next meaningful action (≥ 48 dp button). | `test/core/widgets/empty_view_test.dart` |
| **Error** | `ErrorView` | `lib/core/widgets/error_view.dart` | User-safe title and message via `AppException.userMessage`; actionable retry button (≥ 48 dp). | `test/core/widgets/error_view_test.dart` |
| **Error (Banner)** | `AppErrorBanner` | `lib/core/widgets/app_error_banner.dart` | Inline non-modal error banner with live region a11y semantics, warning icon, and dismiss button (`standard` & `brand` variants). | `test/core/widgets/app_error_banner_test.dart` |
| **Confirmation / Destructive** | `showConfirmationDialog` / `AppConfirmationDialog` | `lib/core/widgets/app_confirmation_dialog.dart` | Standardized dialog for confirming destructive or high-consequence actions (`isDestructive` variant). Follows theme styling and tokens. | `test/core/widgets/app_confirmation_dialog_test.dart` |

---

## 4. Consolidations & Eliminated Duplicates

1. **Booking Inputs & Buttons**:
   - `BookingAppButton` delegated to canonical `AppButton(variant: AppButtonVariant.primary, borderRadius: context.shape.radiusPill)`.
   - `BookingAppOutline` delegated to canonical `AppButton(variant: AppButtonVariant.secondary, borderRadius: context.shape.radiusPill)`.
   - `BookingLightField` delegated to canonical `AppTextField(borderRadius: context.shape.radiusPill)`.
2. **Referral Submission Forms**:
   - Extracted shared `ReferHotelForm` (`lib/features/findr/presentation/widgets/refer_hotel_form.dart`), eliminating ~250 lines of duplicate form logic and state across `ReferHotelScreen` and `ReferHotelBottomSheet`.
3. **Error Banners**:
   - `AuthErrorBanner` and `ProfileErrorBanner` refactored to delegate to canonical `AppErrorBanner`.
4. **Destructive & Sign-Out Dialogs**:
   - Inline ad-hoc `AlertDialog` implementations in `reservation_detail_screen.dart`, `account_screen.dart`, and `personal_details_screen.dart` replaced with `showConfirmationDialog`.
5. **Empty State Screens**:
   - Custom ad-hoc empty views in `my_trips_screen.dart` and `findr_referrals_screen.dart` replaced with `EmptyView`.

