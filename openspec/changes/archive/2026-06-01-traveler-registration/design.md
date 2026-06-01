# Traveler Registration - Design

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer                             │
│  - registration_screen.dart (UI)                │
│  - registration_controller.dart (State Mgmt)    │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  Data Layer                                     │
│  - auth_repository.dart (Repository Pattern)    │
│  - auth_remote_data_source.dart (API)          │
│  - traveler_signup_dto.dart (Data Models)      │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  Network Layer                                  │
│  - api_client.dart (HTTP Client)                │
└─────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Registration Screen (`registration_screen.dart`)

**StatefulWidget with SingleTickerProviderStateMixin**

- Manages form state with `GlobalKey<FormState>`
- Controls text input for fullName, email, password
- Animates entry with FadeTransition
- Displays form fields with validation errors
- Shows loading state on submit button
- Handles success/error feedback to user

**Key Methods:**
- `onSubmit()` - Validates and submits form
- `validateFullName()`, `validateEmail()`, `validatePassword()` - Validation logic
- `showSuccessAndNavigate()` - Displays success dialog and resets form
- `buildFormCard()`, `buildSubmitButton()`, etc. - UI components

### 2. Registration Controller (`registration_controller.dart`)

**ChangeNotifier for state management**

**State Variables:**
- `isLoading` - Loading state during API call
- `errorMessage` - Error message display
- `isSuccess` - Success flag for post-registration flow

**Key Methods:**
- `signUp()` - Orchestrates account creation flow
- `clearError()` - Dismisses error banner

### 3. Auth Repository (`auth_repository.dart`)

**Repository pattern for data access**

- Abstracts remote data source
- Future extension point for caching, offline support
- Converts DTOs to domain models

**Key Method:**
- `signUp()` - Delegates to remote data source and returns SignupResult

### 4. Auth Remote Data Source (`auth_remote_data_source.dart`)

**API integration layer**

- Makes HTTP POST to `/traveler/signup`
- Converts JSON response to DTO
- Throws ApiException on failures

**Key Method:**
- `signUp()` - Calls API and parses response

### 5. Data Models

**traveler_signup_dto.dart:**
- `TravelerProfileNestedDto` - Nested traveler profile data
- `TravelerSignupResponseDto` - Server response mapping

**signup_result.dart:**
- `SignupResult` - Domain model for successful signup

## Validation Rules

| Field | Rules |
|-------|-------|
| Full Name | Required, max 255 chars |
| Email | Required, valid format (regex) |
| Password | Required, min 8 chars, max 128 chars |

## Error Handling

| Scenario | Handling |
|----------|----------|
| Validation error | Show inline error below field |
| API error | Display red error banner with dismiss button |
| Network error | Generic error message |
| Unexpected error | "An unexpected error occurred. Please try again." |

## User Flow

```
1. User fills form
   ↓
2. Clicks "Create Account"
   ↓
3. Client validation (pass/fail?)
   ├─ FAIL → Show inline errors
   └─ PASS → Continue
   ↓
4. Show loading spinner
   ↓
5. API call to server
   ↓
6. Server response (success/error?)
   ├─ SUCCESS → Show success dialog & reset form
   └─ ERROR → Show error banner, allow retry
```

## Design Consistency

- Uses `google_fonts`: Nunito, Cabin, Inter
- Primary color: Red (colorScheme.primary)
- Animations: 600ms fade-in, 200ms transitions
- Layout: Max-width 480dp form card
- Spacing: Consistent 16/24/32px gaps
- Border radius: 12-24dp for buttons/cards

## State Management Flow

```
UI Input → Validation → Controller.signUp()
  ↓
Set isLoading = true → notifyListeners()
  ↓
Repository.signUp() → API Call
  ↓
Response → Set isSuccess/errorMessage
  ↓
notifyListeners() → UI updates
```
