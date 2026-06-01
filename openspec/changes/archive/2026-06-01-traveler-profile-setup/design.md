# Traveler Profile Setup - Design

## Architecture Overview

Following Clean Architecture and feature-first module guidelines, the profile setup flow is isolated within `lib/features/profile/` and structured as follows:

```
┌─────────────────────────────────────────────────────────────┐
│  Presentation Layer (presentation/)                         │
│  - profile_setup_screen.dart (UI Form & Local State)         │
│  - profile_notifier.dart (ChangeNotifier State Controller)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Domain Layer (domain/)                                     │
│  - profile.dart (Pure Domain Model Entity)                  │
└──────────────────────────────▲──────────────────────────────┘
                               │
                               │ (converts to domain)
                               │
┌─────────────────────────────────────────────────────────────┐
│  Data Layer (data/)                                         │
│  - profile_repository.dart (Repository Orchestrator)        │
│  - profile_remote_data_source.dart (API Methods)            │
│  - profile_dto.dart (JSON Serialization & Mapper)           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  Core Infrastructure (core/)                                │
│  - network/api_client.dart (HTTP GET/PATCH client)          │
│  - storage/token_storage.dart (Secure Token Access)         │
└─────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Presentation Layer

#### Profile Setup Screen (`profile_setup_screen.dart`)
- **StatefulWidget** managing the form status with a global key `GlobalKey<FormState>`.
- Displays individual input controllers for phone number, nationality, and gender.
- Handles date-picker selections, converting chosen `DateTime` dates to legible UI formats.
- Pre-fills input fields on `initState` by registering a post-frame callback:
  ```dart
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final notifier = Provider.of<ProfileNotifier>(context, listen: false);
    await notifier.loadProfile();
    if (notifier.profile != null) {
      _phoneController.text = notifier.profile!.phone ?? '';
      _nationalityController.text = notifier.profile!.nationality ?? '';
      _selectedGender = notifier.profile!.gender;
      _selectedDateOfBirth = notifier.profile!.dateOfBirth;
      // update text representations
    }
  });
  ```
- Animates submit interactions, displays validation constraints inline, and raises full-screen loading widgets or error banners based on status.

#### Profile Notifier (`profile_notifier.dart`)
- **ChangeNotifier** state management class maintaining immutable states for UI consumption.
- **State Variables:**
  - `_isLoading` (boolean) - API operations status indicator.
  - `_errorMessage` (String?) - Captures domain exception messages or server-side response errors.
  - `_profile` (Profile?) - Currently loaded/saved traveler profile entity.
- **Key Methods:**
  - `loadProfile()` - Triggers repository get method, updates loading flags, and notifies listeners.
  - `updateProfile(...)` - Sends patch payloads to update the remote data, returning a boolean indicating status.

### 2. Domain Layer

#### Profile Model (`profile.dart`)
- A **pure, immutable domain entity** representing a traveler's setup info.
- Fields: `id`, `phone`, `nationality`, `gender`, `dateOfBirth` (`DateTime?`), and `onboardingStep`.
- Implements `copyWith(...)` for immutability-safe mutations.
- Overrides equality operators (`==`) and `hashCode` using Dart value comparisons.
- Zero dependencies on Flutter UI elements.

### 3. Data Layer

#### Profile Repository (`profile_repository.dart`)
- Serves as the single domain-exposed abstraction of profile data.
- Handles date parsing logic, stripping full timestamp formats into ISO 8601 simple dates (`YYYY-MM-DD`) before saving.
- Transforms raw network transfer DTOs (`ProfileDto`) into clean domain models (`Profile`).

#### Profile Remote Data Source (`profile_remote_data_source.dart`)
- Integrates remote API calls using safe token headers from secure storage.
- Invokes:
  - `GET /traveler/profile` for retrieval.
  - `PATCH /traveler/profile` for partial, selective updates.

#### Profile DTO (`profile_dto.dart`)
- Represents raw API serialization contract.
- Fields match API JSON keys (e.g. `date_of_birth` and `onboarding_step`).
- Implements `fromJson()`, `toJson()`, and `toDomain()` converting local values to domain equivalents.

## API Integration Contract

### 1. Fetch Profile
- **Endpoint:** `GET /traveler/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Response Format (200 OK):**
  ```json
  {
    "id": "traveler_uuid_123",
    "phone": "+1234567890",
    "nationality": "American",
    "gender": "male",
    "date_of_birth": "1995-05-15",
    "onboarding_step": "profile_setup"
  }
  ```

### 2. Update Profile
- **Endpoint:** `PATCH /traveler/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Request Payload:**
  ```json
  {
    "phone": "+1234567890",
    "nationality": "American",
    "gender": "male",
    "date_of_birth": "1995-05-15"
  }
  ```
- **Response Format (200 OK):** Returns the fully updated profile JSON matching the Fetch contract.

## Validation Rules

| Field | Input Control | Rules |
| :--- | :--- | :--- |
| **Phone Number** | Text Input | Required, must be numeric, length between 7 and 15 digits |
| **Nationality** | Text Input | Required, alphabetic characters only, maximum 100 characters |
| **Gender** | Dropdown Select | Required, value must be one of: `male`, `female`, `other` |
| **Date of Birth** | Date Picker Selection | Required, selected date must be in the past |

## Error Handling Scenarios

| Scenario | UX Treatment | Trigger Point |
| :--- | :--- | :--- |
| **Form Validation Failure** | Displays inline error messages in red directly below input fields. | Form validation call on submit. |
| **Fetch Profile Failure** | Displays full-screen message banner with a "Retry" button. | Screen mounting or post-frame load failure. |
| **Patch Update API Failure** | Show persistent dismissible error banner at the top of the form layout. | Reject response inside `ProfileNotifier.updateProfile`. |
| **Network Offline** | Display standard offline warning, preventing submission action. | `ApiClient` timeout or `SocketException`. |

## User Interaction Flow

```
1. User enters Profile Setup screen
   │
   ├─► Show Loading Indicator
   │
   ├─► GET /traveler/profile
   │     ├─► Success: Pre-populate form controllers with returned data
   │     └─► Error: Show retry layout
   │
2. User edits fields (Phone, Nationality, Gender dropdown, Date of Birth picker)
   │
3. User clicks "Save & Continue"
   │
   ├──► Run Form validation?
   │      ├─► Fail: Stop & render inline validation text
   │      └─► Pass: Continue
   │
   ├──► Set isLoading = true (Spinner rendering)
   │
   ├──► PATCH /traveler/profile API Call
   │      │
   │      ├─► Success (200 OK):
   │      │     ├─► Update notifier profile model
   │      │     ├─► Navigate to next onboarding step (e.g. ID verification)
   │      │
   │      └─► Error:
   │            ├─► Set isLoading = false
   │            ├─► Show top error banner with server error message
```

## Design and Accessibility

- **Theme Alignment**: Extends `google_fonts` typography patterns and matches primary theme guidelines.
- **Aesthetic**: Employs clean card layouts, custom outline inputs, explicit focus rings, and soft margins.
- **Touch Targets**: Dropdowns and picker fields offer target regions exceeding 48dp for simple click interactions.
- **Inputs**: Form uses intelligent input formatting (e.g., number keyboard for phone numbers).
