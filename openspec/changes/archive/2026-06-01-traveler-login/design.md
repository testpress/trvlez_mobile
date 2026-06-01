# Traveler Login - Design

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer                             │
│  - login_screen.dart (UI)                       │
│  - login_controller.dart (State Mgmt)           │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│  Data Layer                                     │
│  - auth_repository.dart (Repository Pattern)    │
│  - auth_remote_data_source.dart (API)          │
│  - login_request_dto.dart (Request Model)      │
│  - login_response_dto.dart (Response Model)    │
└─────────────────┬───────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        ↓                   ↓
┌──────────────┐   ┌──────────────────────┐
│ Network      │   │ Storage Layer        │
│ - api_client │   │ - secure_storage     │
│   (HTTP)     │   │ - token_manager      │
└──────────────┘   └──────────────────────┘
```

## Component Breakdown

### 1. Login Screen (`login_screen.dart`)

**StatefulWidget with SingleTickerProviderStateMixin**

- Manages form state with `GlobalKey<FormState>`
- Controls text input for email and password
- Animates entry with FadeTransition
- Displays form fields with validation errors
- Shows loading state on submit button
- Handles error/success feedback
- Provides link to registration for new users
- Optional "Remember me" checkbox

**Key Methods:**
- `onSubmit()` - Validates and submits credentials
- `validateEmail()`, `validatePassword()` - Validation logic
- `handleLoginSuccess()` - Redirects to dashboard
- `buildFormCard()`, `buildSubmitButton()`, etc. - UI components

### 2. Login Controller (`login_controller.dart`)

**ChangeNotifier for state management**

**State Variables:**
- `isLoading` - Loading state during API call
- `errorMessage` - Error message display
- `isSuccess` - Success flag for post-login flow
- `rememberMe` - "Remember me" checkbox state

**Key Methods:**
- `login()` - Orchestrates authentication flow
- `clearError()` - Dismisses error message
- `toggleRememberMe()` - Updates checkbox state

### 3. Auth Repository Extension (`auth_repository.dart`)

**Adds login method to existing repository**

```dart
Future<AuthToken> login({
  required String email,
  required String password,
  required bool rememberMe,
}) async {
  // Call remote data source
  // Store token if rememberMe enabled
  // Return auth token
}

Future<void> logout() async {
  // Clear stored token
  // Clear remember me preference
}

Future<bool> isLoggedIn() async {
  // Check if valid token exists
}
```

### 4. Auth Remote Data Source Extension (`auth_remote_data_source.dart`)

**Adds login API call**

```dart
Future<LoginResponseDto> login({
  required String email,
  required String password,
}) async {
  final responseJson = await apiClient.post(
    '/traveler/login',
    body: {
      'email': email,
      'password': password,
    },
  );
  return LoginResponseDto.fromJson(responseJson);
}
```

### 5. Data Models

**login_request_dto.dart:**
```dart
class LoginRequestDto {
  final String email;
  final String password;
  
  LoginRequestDto({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

**login_response_dto.dart:**
```dart
class LoginResponseDto {
  final String id;
  final String email;
  final String fullName;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  
  LoginResponseDto.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**auth_token.dart (domain model):**
```dart
class AuthToken {
  final String token;
  final String? refreshToken;
  final DateTime expiresAt;
  final String userId;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired;
}
```

### 6. Token Management

**token_storage.dart:**
- Secure storage using `flutter_secure_storage`
- Store: access token, refresh token, expiry, user ID
- Retrieve: check validity, auto-refresh if needed
- Delete: on logout

**token_manager.dart:**
- Refresh token logic
- Handle token expiry
- Auto-login with valid stored token
- Clear tokens on 401 response

## User Flow

```
1. User opens app
   ↓
2. Check if logged in (token exists + valid?)
   ├─ YES → Skip login, go to dashboard
   └─ NO → Continue
   ↓
3. User fills email & password
   ↓
4. Clicks "Sign In"
   ↓
5. Client validation
   ├─ FAIL → Show inline errors
   └─ PASS → Continue
   ↓
6. Show loading spinner
   ↓
7. API call: POST /traveler/login
   ↓
8. Server response
   ├─ SUCCESS → Store token, go to dashboard
   └─ ERROR → Show error banner, allow retry
   ↓
9. If "Remember me" checked → Token persists across sessions
```

## Validation Rules

| Field | Rules |
|-------|-------|
| Email | Required, valid format |
| Password | Required, non-empty |

**Note:** Don't reveal if email exists (security best practice)

## Error Handling

| Scenario | Message |
|----------|---------|
| Empty email | "Email is required" |
| Invalid email | "Please enter a valid email" |
| Empty password | "Password is required" |
| Invalid credentials | "Invalid email or password" |
| User not found | "Invalid email or password" |
| Network error | "Network error. Please check your connection." |
| Server error | "Something went wrong. Please try again." |
| Token expired | "Session expired. Please log in again." |

## API Contract

### Login Endpoint

**POST /traveler/login**

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here",
  "expires_at": "2026-06-02T00:00:00Z"
}
```

**Error Response (401):**
```json
{
  "error": "Invalid email or password"
}
```

## Session Management

### Token Storage

**Location:** Secure storage (platform-native secure enclave)

**Data Stored:**
- Access token (short-lived, ~1 hour)
- Refresh token (long-lived, ~30 days)
- Expiry timestamp
- User ID
- Remember me preference

### Auto-Login

**On App Start:**
1. Check if token exists in secure storage
2. If token valid → Auto-login, skip login screen
3. If token expired but refresh token valid → Refresh token
4. If all tokens invalid/expired → Show login screen

### Token Refresh

**When Access Token Expires:**
1. Use refresh token to get new access token
2. Update secure storage
3. Retry failed request
4. If refresh fails → Show login screen

### Logout

**On User Logout:**
1. Delete tokens from secure storage
2. Clear remember me preference
3. Clear app state
4. Navigate to login screen

## UI Design

### Login Screen Layout

```
┌─────────────────────────────────────────┐
│                                         │
│  TrvlEz Logo (Flight Icon + Text)       │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │  Welcome Back!                  │   │
│  │  Sign in to your account        │   │
│  │                                 │   │
│  │  Email Address                  │   │
│  │  [________email@example.com__] │   │
│  │                                 │   │
│  │  Password                       │   │
│  │  [________password____] [eye]   │   │
│  │                                 │   │
│  │  [x] Remember me                │   │
│  │                                 │   │
│  │  [    SIGN IN    ]              │   │
│  │  or [Loading...]                │   │
│  │                                 │   │
│  │  Don't have account? Sign Up    │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Design Consistency

- Uses same branding as registration screen
- Logo, colors, typography match registration
- Form card styling identical
- Animations consistent (600ms fade-in)
- Error styling matches registration
- Button styling matches registration

## State Management Flow

```
UI Input → Validation → Controller.login()
  ↓
Set isLoading = true → notifyListeners()
  ↓
Repository.login() → API Call
  ↓
Response → Store token in secure storage
  ↓
Set isSuccess = true → notifyListeners()
  ↓
Navigate to Dashboard
```

## Security Considerations

- ✅ Tokens stored in secure storage (encrypted)
- ✅ Passwords never logged or stored
- ✅ HTTPS-only communication
- ✅ Token expires automatically
- ✅ Refresh token separate from access token
- ⚠️ Implement token invalidation on logout
- ⚠️ Implement device fingerprinting (optional)
- ⚠️ Rate limiting on login attempts (server-side)

## Dependencies

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  provider: ^6.0.0  # Or existing state management
  google_fonts: ^5.0.0  # Existing
  http: ^1.1.0  # Existing
```

## Testing Strategy

### Unit Tests
- Email validation
- Password validation
- Token refresh logic
- Token expiry checks

### Integration Tests
- Login success flow
- Invalid credentials handling
- Network error handling
- Token persistence

### UI Tests
- Form renders correctly
- Loading spinner displays
- Error messages show
- Navigation on success
- Remember me works

## Performance Targets

- Login screen load: < 200ms
- API response timeout: 30 seconds
- Token validation: < 100ms
- Navigation on success: < 500ms
- Auto-login (if token valid): < 200ms
