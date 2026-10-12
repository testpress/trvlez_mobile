# Login Capability Specification

## Overview

The Login capability provides user authentication for the TrvlEz platform. It handles traveler authentication via email/password, session token management, and persistent login across app sessions.

**Current Status:** Planned for implementation (Phase 2 of Auth feature).

---

## 1. Login Feature

### 1.1 Purpose

Allow registered travelers to authenticate with their email and password, obtain session tokens, and access the TrvlEz platform. Support persistent login via "Remember me" functionality.

### 1.2 User Flow

```
1. User launches app
2. Check if logged in (valid token exists?)
   ├─ YES → Skip login, navigate to dashboard
   └─ NO → Continue
3. User navigates to login screen
4. Fills in: Email, Password
5. Optional: Check "Remember me"
6. Clicks "Sign In"
7. Client validates input
8. If valid: Sends to server
9. If invalid: Shows inline errors
10. Server authenticates or returns error
11. Shows error banner or success
12. On success: Stores token, navigates to dashboard
13. If "Remember me": Token persists across sessions
```

### 1.3 Validation Rules

| Field | Type | Rules |
|-------|------|-------|
| Email | String | Required, valid email format |
| Password | String | Required, non-empty |

**Email Regex Pattern:**
```
^[^@\s]+@[^@\s]+\.[^@\s]+$
```

**Security Note:** Don't reveal if email exists in system (send generic error).

### 1.4 API Contract

#### Endpoint
```
POST /traveler/login
```

#### Request Body
```json
{
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
  "access_token": "jwt_string",
  "refresh_token": "jwt_string",
  "expires_at": "2026-06-02T00:00:00Z"
}
```

#### Error Response (401)
```json
{
  "error": "Invalid email or password"
}
```

#### Error Response (500)
```json
{
  "error": "Server error"
}
```

### 1.5 Implementation

#### Files (To Be Created)

**Presentation Layer:**
- `lib/features/auth/presentation/screens/login_screen.dart` - Login UI
- `lib/features/auth/presentation/login_controller.dart` - State management

**Data Layer:**
- `lib/features/auth/data/login_request_dto.dart` - Request model
- `lib/features/auth/data/login_response_dto.dart` - Response model
- Extended: `lib/features/auth/data/auth_repository.dart`
- Extended: `lib/features/auth/data/auth_remote_data_source.dart`

**Domain Layer:**
- `lib/features/auth/domain/auth_token.dart` - Token domain model

**Storage & Token Management:**
- `lib/core/storage/token_storage.dart` - Secure token storage
- `lib/core/storage/token_manager.dart` - Token lifecycle management
- `lib/core/auth/auth_service.dart` - Authentication service

#### Architecture

```
┌──────────────────────────────────────────┐
│ Presentation Layer                       │
│ LoginScreen (UI)                         │
│ LoginController (State)                  │
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
      ┌────────┴────────┐
      ↓                 ↓
┌──────────────┐   ┌──────────────────────┐
│ Network      │   │ Storage Layer        │
│ - ApiClient  │   │ - TokenStorage       │
│   (HTTP)     │   │ - TokenManager       │
└──────────────┘   └──────────────────────┘
```

### 1.6 UI Components

#### Login Screen
- **Logo Section**: TrvlEz branding (matches registration)
- **Form Card**: 
  - Max-width 480dp
  - Rounded corners (24dp)
  - Subtle shadow
  - Light background
- **Header**: "Welcome Back!" title and subtitle
- **Input Fields**:
  - Email (emailAddress keyboard)
  - Password (toggle visibility)
- **Checkbox**: "Remember me"
- **Error Banner**: Red alert with dismiss button (hidden when no error)
- **Submit Button**:
  - Loading state: Shows spinner + "Signing in..."
  - Normal state: "Sign In"
  - Disabled during loading
- **Footer**: "Don't have account? Sign Up" link

#### Animations
- **Screen Entry**: Fade-in (600ms, easeOut curve)
- **Transitions**: 200ms AnimatedContainer for button state
- **Error Banner**: AnimatedSize for smooth appear/disappear

### 1.7 Error Handling

| Scenario | Handling |
|----------|----------|
| Empty email | Inline validation error below field |
| Invalid email | "Please enter a valid email address" |
| Empty password | Inline validation error below field |
| Invalid credentials | Error banner: "Invalid email or password" |
| Email not found | Error banner: "Invalid email or password" (don't leak) |
| Account disabled | Error banner: "Your account has been disabled" |
| Network error | Error banner: "Network error. Check connection." |
| Server error | Error banner: "Something went wrong. Try again." |
| Token expired | Auto-refresh with stored refresh token |

**Recovery:**
- User can dismiss error banner with × button
- Form remains filled (not cleared on error)
- User can retry submission
- Form clears only on successful login

### 1.8 Loading States

**During API Call:**
- Text inputs disabled
- Submit button disabled (appears faded)
- Spinner shows in button
- Text changes to "Signing in..."

**On Completion:**
- All UI re-enables
- Success or error shown
- On success: Navigate to dashboard

### 1.9 Success Flow

**On Successful Authentication:**
1. Store access token in secure storage
2. Store refresh token (if provided)
3. Store token expiry time
4. Navigate to dashboard
5. Show welcome message (optional)

**"Remember Me" Flow:**
- If checked: Token persists across app restarts
- If unchecked: Token cleared on app close
- Preference stored in secure storage

### 1.10 State Management

**LoginController (ChangeNotifier)**

**State Variables:**
```dart
bool isLoading;           // API call in progress
String? errorMessage;     // Current error (null if none)
bool isSuccess;           // Login successful
bool rememberMe;          // Remember me checkbox state
```

**Methods:**
```dart
Future<void> login({
  required String email,
  required String password,
  required bool rememberMe,
});  // Initiates login process

void clearError();        // Dismisses error message

void toggleRememberMe();  // Updates checkbox state
```

**Flow:**
1. Set `isLoading = true` → UI updates
2. Call `repository.login()`
3. On success: Store token, set `isSuccess = true`
4. On error: Set `errorMessage = error`
5. Set `isLoading = false` → UI updates

### 1.11 Token Management

#### Secure Storage

**Using:** `flutter_secure_storage` package

**Stored Data:**
- `access_token` - JWT for API requests (short-lived)
- `refresh_token` - JWT for token refresh (long-lived)
- `user_id` - Authenticated user ID
- `token_expiry` - Timestamp of expiry
- `remember_me` - Boolean preference

**Security:**
- Encrypted storage (platform-native secure enclave)
- No logs contain tokens
- Tokens cleared on logout

#### Token Lifecycle

**Access Token:**
- Validity: 1 hour (typical)
- Usage: Include in API requests via Authorization header
- Expiry: Auto-refresh using refresh token

**Refresh Token:**
- Validity: 30 days (typical)
- Usage: Obtain new access token when expired
- Expiry: Show login screen

**Token Refresh:**
```
1. Access token expires
2. Use refresh token to request new access token
3. Server validates refresh token
4. Returns new access token
5. Update secure storage
6. Retry failed request
7. If refresh fails: Show login screen
```

#### Auto-Login

**On App Startup:**
1. Check if token exists in secure storage
2. Check if token is valid (not expired)
3. If valid: Auto-login, skip login screen
4. If expired but refresh token valid: Refresh token
5. If all tokens invalid/expired: Show login screen
6. If "Remember me" unchecked: Clear token, show login

### 1.12 Design System

**Colors** (matches registration):
- Primary: `colorScheme.primary` (Red)
- Error: `colorScheme.error` (Red/Warning)
- Surface: `colorScheme.surface` (Light background)
- OnSurface: `colorScheme.onSurface` (Dark text)

**Typography** (matches registration):
- Logo: Google Fonts Inter, 28px, Bold
- Headings: Theme.textTheme.headlineMedium
- Body: Google Fonts Cabin, 15px
- Labels: Theme.textTheme.labelLarge
- Button: Google Fonts Nunito, 16px, Bold

**Spacing** (matches registration):
- Form padding: 28px
- Field gaps: 16px
- Section gaps: 24-32px
- Card margin: 24px horizontal

**Border Radius** (matches registration):
- Form card: 24dp
- Buttons: 12dp
- Error banner: 12dp
- Checkbox: Default

### 1.13 Security Considerations

**Token Security:**
- ✅ Tokens stored in secure storage only
- ✅ No tokens in logs
- ✅ HTTPS-only communication
- ✅ Token expires automatically
- ✅ Refresh token separate from access token
- ✅ Tokens cleared on logout
- ✅ Device lockscreen integration (optional)

**Credentials:**
- ✅ Passwords never stored
- ✅ Passwords never logged
- ✅ Passwords transmitted over HTTPS only
- ✅ HTTPS certificate pinning (optional)

**Server-Side:**
- ⚠️ Rate limiting on login attempts (1 req/sec per IP)
- ⚠️ Account lockout after 5 failed attempts
- ⚠️ CAPTCHA for suspicious login patterns
- ⚠️ Two-factor authentication (future)

### 1.14 Testing Requirements

#### Unit Tests
- [ ] Email validation logic
- [ ] Password validation logic
- [ ] LoginController state transitions
- [ ] Token storage/retrieval
- [ ] Token refresh logic
- [ ] Token expiry checks
- [ ] Error mapping

#### Integration Tests
- [ ] Complete login flow with API
- [ ] Invalid credentials handling
- [ ] Network failure recovery
- [ ] Token persistence
- [ ] Token refresh on expiry
- [ ] Auto-login with stored token
- [ ] Logout flow

#### UI/Widget Tests
- [ ] Login form renders
- [ ] Loading spinner displays
- [ ] Error banner shows/hides
- [ ] Password visibility toggle
- [ ] Remember me checkbox
- [ ] Navigation on success
- [ ] Links to registration

#### Platform Testing
- [ ] Android functionality
- [ ] iOS functionality
- [ ] Web responsiveness
- [ ] Desktop layout

### 1.15 Performance Metrics

- Login screen load: < 200ms
- API response timeout: 30 seconds
- Token validation: < 100ms
- Token refresh: < 1 second
- Navigation on success: < 500ms
- Auto-login check: < 200ms
- Secure storage access: < 50ms

---

## 2. Refresh Token Flow

### 2.1 Automatic Token Refresh

```
1. App makes API request with access token
2. Server responds with 401 (Unauthorized)
3. Client detects 401 response
4. Client sends refresh token to /traveler/refresh endpoint
5. Server validates refresh token and returns new access token
6. Client stores new access token
7. Client retries original request
8. If successful: Request completes
9. If refresh fails: Show login screen
```

### 2.2 Refresh Endpoint

**POST /traveler/refresh**

**Request:**
```json
{
  "refresh_token": "jwt_string"
}
```

**Response (200):**
```json
{
  "access_token": "jwt_string",
  "expires_at": "2026-06-02T00:00:00Z"
}
```

**Error (401):**
```json
{
  "error": "Invalid refresh token"
}
```

---

## 3. Logout Flow

### 3.1 Logout Process

```
1. User taps logout button
2. Clear access token from secure storage
3. Clear refresh token from secure storage
4. Clear user ID from secure storage
5. Clear remember me preference
6. Clear all app state
7. Navigate to login screen
```

### 3.2 Server-Side Logout (Optional)

```
POST /traveler/logout
Authorization: Bearer <access_token>

Response:
{
  "success": true
}
```

---

## 4. Multi-Device Handling

### 4.1 Multiple Device Login

Each device can have its own session:
- Device A gets access token (expires in 1 hour)
- Device B gets different access token (expires in 1 hour)
- Both can be active simultaneously
- Logging out on Device A doesn't affect Device B

### 4.2 Device Tracking (Optional Future)

- Track which devices user logged in from
- Show list of active sessions
- Allow logout from other devices
- Alert on new device login

---

## 5. Future Features

### 5.1 Password Reset
- Email-based password reset
- Reset token sent to email
- Token expires in 24 hours
- Password change confirmation

### 5.2 Multi-Factor Authentication
- Email OTP
- SMS OTP
- TOTP authenticator
- Biometric verification

### 5.3 Social Login
- Google Sign-In
- Apple Sign-In
- Facebook Sign-In
- Unified user account

### 5.4 Session Management
- View active sessions
- Device fingerprinting
- Login history
- Logout from other devices

---

## 6. Dependencies

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0    # Secure token storage
  jwt_decoder: ^2.0.0               # JWT parsing and validation
  google_fonts: ^5.0.0              # Typography
  http: ^1.1.0                      # HTTP requests
  provider: ^6.0.0                  # State management (or existing)
```

---

## 7. Migration Path from Registration

**For Users Who Registered:**
1. User completes registration
2. Temporary success screen shown
3. User navigates back or app restarts
4. Login screen appears
5. User logs in with registered credentials

**Future Enhancement:**
- Auto-login after registration (no need for manual login)
- Store token on registration completion
- Skip login screen if just registered

---

## 8. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-01 | Initial login feature design |

---

## 9. Related Documents

- [Login Design Details](../../changes/archive/2026-06-01-traveler-login/design.md)
- [Login Implementation Tasks](../../changes/archive/2026-06-01-traveler-login/tasks.md)
- [Login Proposal](../../changes/archive/2026-06-01-traveler-login/proposal.md)
- [Auth Specification](../auth/spec.md)
- [Registration Specification](../auth/spec.md#1-registration-feature)

---

## 10. Approval & Sign-Off

**Status:** 🔵 PLANNED (Not yet implemented)

**Design Date:** June 1, 2026

**Planned Implementation:** Next sprint/phase

**Known Limitations:**
- No multi-factor authentication (planned for Phase 3)
- No social login (planned for Phase 2)
- No password reset (planned for Phase 2)
- No device tracking (planned for Phase 3)

**Approved By:** [Pending Design Review]

---

## 11. Support & Troubleshooting

### Common Issues

**Issue:** "Remember me" not persisting
- **Cause:** Token expired or cleared
- **Solution:** Check token expiry, re-login, ensure device connected

**Issue:** Auto-login failing
- **Cause:** Corrupted token in storage
- **Solution:** Clear app data, re-login

**Issue:** Token refresh loop
- **Cause:** Invalid refresh token
- **Solution:** Logout and login again

**Issue:** Credentials "Invalid email or password"
- **Cause:** Wrong email, wrong password, or account issues
- **Solution:** Verify email, check password caps lock, request password reset

**Issue:** "Network error" message
- **Cause:** No internet connection
- **Solution:** Check network connectivity, retry login

### Contact

For questions or issues with login feature:
- Check error message in app
- Review logs in console (non-sensitive info only)
- Verify API endpoint is responding
- Check network connectivity
