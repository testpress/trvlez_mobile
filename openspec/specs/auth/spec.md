# Auth Capability Specification

## Overview

The Auth capability provides user authentication and account management for the TrvlEz platform. This includes user registration, login, and account management features.

**Current Status:** Registration feature implemented and deployed.

---

## 1. Registration Feature

### 1.1 Purpose

Allow new travelers to create accounts with email and password, enabling them to access the TrvlEz platform.

### 1.2 User Flow

```
1. User navigates to registration screen
2. Fills in: Full Name, Email, Password
3. Clicks "Create Account"
4. Client validates input
5. If valid: Sends to server
6. If invalid: Shows inline errors
7. Server creates account or returns error
8. Shows success dialog or error banner
9. On success: Clears form, ready for next signup
```

### 1.3 Validation Rules

| Field | Type | Rules |
|-------|------|-------|
| Full Name | String | Required, 1-255 characters |
| Email | String | Required, valid email format |
| Password | String | Required, 8-128 characters |

**Email Regex Pattern:**
```
^[^@\s]+@[^@\s]+\.[^@\s]+$
```

### 1.4 API Contract

#### Endpoint
```
POST /traveler/signup
```

#### Request Body
```json
{
  "full_name": "string",
  "email": "string",
  "password": "string"
}
```

#### Success Response (200)
```json
{
  "id": "uuid",
  "email": "string",
  "full_name": "string",
  "traveler_profile": {
    "id": "uuid",
    "onboarding_step": "string",
    "nationality": "string|null",
    "phone": "string|null"
  }
}
```

#### Error Response (4xx, 5xx)
```json
{
  "error": "string (human-readable message)"
}
```

### 1.5 Implementation

#### Files
- **lib/features/auth/presentation/registration_screen.dart** - UI Screen
- **lib/features/auth/presentation/registration_controller.dart** - State Management
- **lib/features/auth/data/auth_repository.dart** - Repository Pattern
- **lib/features/auth/data/auth_remote_data_source.dart** - API Integration
- **lib/features/auth/data/traveler_signup_dto.dart** - Data Models
- **lib/features/auth/domain/signup_result.dart** - Domain Model

#### Architecture

```
┌──────────────────────────────────────────┐
│ Presentation Layer                       │
│ RegistrationScreen (UI)                  │
│ RegistrationController (State)           │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ Data Layer                               │
│ AuthRepository (Repository Pattern)      │
│ AuthRemoteDataSource (API)               │
│ DTOs (Data Transfer Objects)             │
└──────────────┬───────────────────────────┘
               │
               ↓
┌──────────────────────────────────────────┐
│ Network Layer                            │
│ ApiClient (HTTP)                         │
└──────────────────────────────────────────┘
```

### 1.6 UI Components

#### Registration Screen
- **Logo Section**: TrvlEz branding with plane icon
- **Form Card**: 
  - Max-width 480dp
  - Rounded corners (24dp)
  - Subtle shadow
  - Light background
- **Header**: Title and subtitle
- **Input Fields**:
  - Full Name (TextCapitalization.words)
  - Email (emailAddress keyboard)
  - Password (toggle visibility)
- **Error Banner**: Red alert with dismiss button (hidden when no error)
- **Submit Button**:
  - Loading state: Shows spinner + "Creating account..."
  - Normal state: "Create Account"
  - Disabled during loading
- **Footer**: "Already have account? Sign In" link

#### Animations
- **Screen Entry**: Fade-in (600ms, easeOut curve)
- **Transitions**: 200ms AnimatedContainer for button state
- **Error Banner**: AnimatedSize for smooth appear/disappear

### 1.7 Error Handling

| Scenario | Handling |
|----------|----------|
| Empty fields | Inline validation error below field |
| Invalid email | "Please enter a valid email address" |
| Short password | "Password must be at least 8 characters" |
| Email exists | Error banner: "Email already exists" |
| Network error | Error banner with generic message |
| Server error | Error banner with server message |
| Validation error | Highlighted field with message |

**Recovery:**
- User can dismiss error banner with × button
- Form remains filled (not cleared on error)
- User can retry submission
- Form clears only on success

### 1.8 Loading States

**During API Call:**
- Text inputs disabled
- Submit button disabled (appears faded)
- Spinner shows in button
- Text changes to "Creating account..."

**On Completion:**
- All UI re-enables
- Success or error shown
- On success: Form resets

### 1.9 Success Flow

**On Account Creation:**
1. Show green SnackBar: "Account created successfully!"
2. Wait 500ms
3. Show AlertDialog:
   - Title: "Welcome to TrvlEz!"
   - Message: "Your account has been created. The login screen will be available soon."
   - OK button
4. On OK click:
   - Close dialog
   - Reset form (clear all fields)
   - Ready for next registration

### 1.10 State Management

**RegistrationController (ChangeNotifier)**

**State Variables:**
```dart
bool isLoading;           // API call in progress
String? errorMessage;     // Current error (null if none)
bool isSuccess;           // Account created successfully
```

**Methods:**
```dart
Future<void> signUp({
  required String fullName,
  required String email,
  required String password,
});  // Initiates signup process

void clearError();        // Dismisses error message
```

**Flow:**
1. Set `isLoading = true` → UI updates
2. Call `repository.signUp()`
3. On success: Set `isSuccess = true`
4. On error: Set `errorMessage = error`
5. Set `isLoading = false` → UI updates

### 1.11 Design System

**Colors:**
- Primary: `colorScheme.primary` (Red)
- Error: `colorScheme.error` (Red/Warning color)
- Surface: `colorScheme.surface` (Light background)
- OnSurface: `colorScheme.onSurface` (Dark text)

**Typography:**
- Logo: Google Fonts Inter, 28px, Bold
- Headings: Theme.textTheme.headlineMedium
- Body: Google Fonts Cabin, 15px
- Labels: Theme.textTheme.labelLarge
- Button: Google Fonts Nunito, 16px, Bold

**Spacing:**
- Form padding: 28px
- Field gaps: 16px
- Section gaps: 24-32px
- Card margin: 24px horizontal

**Border Radius:**
- Form card: 24dp
- Buttons: 12dp
- Error banner: 12dp
- Input fields: Default (12dp)

---

## 2. Future Features

### 2.1 Login Feature
- Login screen with email/password
- Session management
- "Remember me" option
- Password reset flow

### 2.2 Account Management
- Profile editing
- Password change
- Email verification
- Two-factor authentication

### 2.3 OAuth Integration
- Google Sign-In
- Apple Sign-In
- Facebook Sign-In

### 2.4 Email Verification
- Verification email on signup
- Email confirmation requirement
- Resend verification option

---

## 3. Testing Requirements

### 3.1 Unit Tests
- [ ] Validation logic for each field
- [ ] RegistrationController state transitions
- [ ] Error handling scenarios
- [ ] DTO parsing from JSON

### 3.2 Integration Tests
- [ ] Form submission flow
- [ ] API error scenarios
- [ ] Network failure handling
- [ ] Success flow with dialog

### 3.3 UI/Widget Tests
- [ ] Form renders correctly
- [ ] Loading spinner displays
- [ ] Error banner shows/hides
- [ ] Success dialog appears
- [ ] Form resets on success

### 3.4 Platform Testing
- [ ] Android functionality
- [ ] iOS functionality
- [ ] Web responsiveness
- [ ] Desktop layout

---

## 4. Security Considerations

- ✅ Passwords sent over HTTPS only
- ✅ No password logging
- ✅ Client-side validation (UX only)
- ✅ Server-side validation required
- ⚠️ Consider password hashing on server
- ⚠️ Consider rate limiting on signup endpoint
- ⚠️ Consider CAPTCHA for bot prevention

---

## 5. Accessibility

- ✅ Form labels for all inputs
- ✅ Error messages below inputs
- ✅ Password visibility toggle
- ✅ Keyboard navigation
- ⚠️ Add semantic labels for screen readers
- ⚠️ Verify color contrast ratios
- ⚠️ Test with accessibility tools

---

## 6. Performance Metrics

- Form load time: < 200ms
- API call timeout: 30 seconds
- Form submission latency: < 3 seconds (normal network)
- Success dialog show time: 500ms delay

---

## 7. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-01 | Initial registration feature |

---

## 8. Related Documents

- [Registration Design Details](../../changes/archive/2026-06-01-traveler-registration/design.md)
- [Registration Implementation Tasks](../../changes/archive/2026-06-01-traveler-registration/tasks.md)
- [Registration Proposal](../../changes/archive/2026-06-01-traveler-registration/proposal.md)

---

## 9. Approval & Sign-Off

**Status:** ✅ Implemented and Deployed

**Implementation Date:** June 1, 2026

**Deployed To:** All platforms (Android, iOS, Web, Desktop)

**Known Limitations:**
- No login screen yet (placeholder dialog shown)
- No email verification (planned for future)
- No OAuth support (planned for future)

**Approved By:** [Pending Code Review]

---

## 10. Support & Troubleshooting

### Common Issues

**Issue:** Form fields disabled during typing
- **Cause:** Loading state active
- **Solution:** Ensure API call completes or times out

**Issue:** Error persists after dismissal
- **Cause:** Multiple errors in queue
- **Solution:** Only latest error shown; older ones cleared

**Issue:** Form not resetting after success
- **Cause:** Dialog not dismissed
- **Solution:** Click OK button in success dialog

### Contact

For questions or issues with auth feature:
- Check error message in app
- Review logs in console
- Verify API endpoint is responding
- Check network connectivity
