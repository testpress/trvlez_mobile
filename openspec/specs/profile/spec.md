# Profile Capability Specification

## Overview

The Profile capability manages traveler personal details and onboarding setup for the TrvlEz platform. This includes capturing phone numbers, nationality, gender identity, and dates of birth, ensuring compliance with travel regulations and pre-filling necessary booking fields.

**Current Status:** Traveler profile setup flow implemented and verified.

---

## 1. Traveler Profile Setup Feature

### 1.1 Purpose

Allow new travelers to complete their onboarding profile with verified personal details, loading existing data automatically to ensure a smooth, non-redundant profile editing experience.

### 1.2 User Flow

```
1. User enters the profile setup screen.
2. App retrieves any existing traveler profile using GET /traveler/profile.
3. Form fields (Phone, Nationality, Gender, DOB) are pre-filled with active database values.
4. User updates/enters their personal information:
   - Phone Number
   - Nationality
   - Gender (dropdown selection)
   - Date of Birth (interactive calendar picker)
5. Clicks "Save & Continue".
6. Client-side form validates input parameters.
7. If validation passes: Form displays loading states and invokes PATCH /traveler/profile.
8. On success: Updates the state cache and transitions the traveler to the next onboarding step.
9. On failure: Form input is preserved, and a dismissible error alert is shown at the top of the form.
```

### 1.3 Validation Rules

| Field | Type | Validation Rules |
|:---|:---|:---|
| **Phone Number** | String | Required, must be numeric digits only, length between 7 and 15 digits |
| **Nationality** | String | Required, alphabetical characters only, maximum 100 characters |
| **Gender** | String | Required, must select one of: `male`, `female`, `other` |
| **Date of Birth** | String (ISO Date) | Required, must select a date in the past |

### 1.4 API Contract

#### 1. Fetch Profile
- **Endpoint:** `GET /traveler/profile`
- **Authentication:** `Bearer <JWT_Token>`
- **Success Response (200 OK):**
  ```json
  {
    "id": "uuid_string",
    "phone": "+1234567890",
    "nationality": "American",
    "gender": "male",
    "date_of_birth": "1995-05-15",
    "onboarding_step": "profile_setup"
  }
  ```

#### 2. Update Profile
- **Endpoint:** `PATCH /traveler/profile`
- **Authentication:** `Bearer <JWT_Token>`
- **Request Body:**
  ```json
  {
    "phone": "string|null",
    "nationality": "string|null",
    "gender": "string|null",
    "date_of_birth": "string|null"
  }
  ```
- **Success Response (200 OK):** Fully updated `ProfileDto` response.
- **Error Response (4xx, 5xx):**
  ```json
  {
    "error": "human-readable message describing failure"
  }
  ```

### 1.5 Implementation

#### Files
- **lib/features/profile/domain/profile.dart** - Core domain model
- **lib/features/profile/data/profile_dto.dart** - Data Transfer Object
- **lib/features/profile/data/profile_remote_data_source.dart** - Data source mapping
- **lib/features/profile/data/profile_repository.dart** - Repository coordinator
- **lib/features/profile/presentation/profile_notifier.dart** - State management
- **lib/features/profile/presentation/profile_setup_screen.dart** - Setup Form UI

#### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Presentation Layer                                      │
│ ProfileSetupScreen (UI Form & Local State)              │
│ ProfileNotifier (State Controller)                     │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│ Domain Layer                                            │
│ Profile (Pure Domain Entity)                            │
└───────────────────────────▲─────────────────────────────┘
                            │
                            │ (mapper toDomain())
                            │
┌─────────────────────────────────────────────────────────┐
│ Data Layer                                              │
│ ProfileRepository (Repository Pattern)                  │
│ ProfileRemoteDataSource (API Connection)                │
│ ProfileDto (Serialization DTO)                          │
└─────────────────────────────────────────────────────────┘
```

### 1.6 UI Components

#### Setup Screen Layout
- **Header**: Large title "Traveler Profile" with clear instructions.
- **Form Card**:
  - Sleek container card with drop shadow.
  - Number keyboard mapping for Phone inputs.
  - Autocomplete disabled for nationality, with strict capitalizations.
  - Tap target for DOB launching standard calendar picker.
  - Dropdown box selecting from genders: `Male`, `Female`, `Other`.
- **Loading State**: Form displays skeleton loader or spinner over submit button during API calls.
- **Error States**: top-mounted Red dismissible banner.

### 1.7 Error Handling

| Scenario | UX Feedback | Actionable Recovery |
|:---|:---|:---|
| Empty phone / dob | Inline field validation warning | Highlight input and request value |
| Malformed phone numbers | "Please enter a valid phone number" | Strip non-numeric inputs |
| Network timeout | "Failed to connect. Please check internet connection." | Displays Retry button on error banner |
| Unauthorized Token | Direct user redirect to initial screen | Re-authenticates session lifecycle |

### 1.8 Loading States

- **Fetch Phase**: Displays custom full-screen loading spinner until endpoint data resolves.
- **Save Phase**: Blocks submit button, displays progress spinner, and changes text to "Saving...".

---

## 2. Future Features

- **Profile Picture Upload**: Cloud storage uploads for custom profile avatars.
- **Phone Verification**: SMS gateway multi-factor authentication check for phone updates.
- **Passport Integration**: OCR-based passport document scanning to auto-verify dates and nationalities.

---

## 3. Testing Requirements

### 3.1 Unit Tests
- [ ] Profile model instantiation and equality checks.
- [ ] DTO parsing correctness from API JSON values.
- [ ] Formatting logic converting `DateTime` instances to ISO string formats.
- [ ] Notifier state mutations on fetch/update transitions.

### 3.2 UI/Widget Tests
- [ ] Form elements render correctly.
- [ ] Text field inputs block alphabetic characters on numeric Phone input.
- [ ] Dropdowns return exactly selected values.
- [ ] Input validations display inline warnings.

---

## 4. Security Considerations

- **Secure Transmission**: Transport operations are restricted to secure HTTPS.
- **Token Isolation**: Authorization Bearer tokens are kept in encrypted secure storage, never logged.
- **PII Protection**: User phone numbers and personal attributes are omitted from client-side debugging logs.

---

## 5. Accessibility

- **Standard Target Heights**: Interactive elements and dropdown nodes observe tap targets >= 48dp.
- **Interactive Keyboard**: Utilizes specific numerical keyboard configurations for phone digit inputs.
- **Contrast Ratios**: Input labels, borders, and error messages observe AAA contrast parameters.

---

## 6. Performance Metrics

- **Initial Load Latency**: GET profile completion resolves under 300ms.
- **UI Animation Refresh**: Frame transition curves execute without noticeable lag.

---

## 7. Version History

| Version | Date | Changes |
|:---|:---|:---|
| **1.0** | 2026-06-01 | Initial traveler profile setup implementation. |

---

## 8. Related Documents

- [Profile Setup Design Details](../../changes/archive/2026-06-01-traveler-profile-setup/design.md)
- [Profile Setup Implementation Tasks](../../changes/archive/2026-06-01-traveler-profile-setup/tasks.md)
- [Profile Setup Proposal](../../changes/archive/2026-06-01-traveler-profile-setup/proposal.md)

---

## 9. Approval & Sign-Off

**Status:** ✅ Implemented and Verified  
**Release Target:** Onboarding Verification Milestone
