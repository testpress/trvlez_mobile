# Verification Capability Specification

## Overview

The Verification capability handles identity verification for the TrvlEz platform, specifically focusing on capturing and uploading passport documents securely.

**Current Status:** Passport Verification feature implemented.

---

## 1. Passport Verification Feature

### 1.1 Purpose

Ensure users securely verify their identity by capturing and uploading their passport after completing onboarding, before accessing the main application.

### 1.2 User Flow

```
1. User completes onboarding screen.
2. User is navigated to the Passport Capture Screen.
3. User aligns their passport within the camera frame.
4. User taps the capture button to take a photo.
5. App displays the Passport Review Screen with the captured photo.
6. User can choose to "Retake" or "Upload".
7. On "Upload", the app shows upload progress via a simulated API call.
8. On success, the user is navigated to the main application or a success state.
9. On error, the user is shown an error message and can retry the upload.
```

### 1.3 Implementation Details

#### Files
- **lib/features/verification/presentation/passport_capture_screen.dart** - Camera capture UI
- **lib/features/verification/presentation/passport_review_screen.dart** - Image review and upload UI
- **lib/features/verification/presentation/verification_notifier.dart** - State management
- **lib/features/verification/data/verification_repository.dart** - Repository handling simulated upload

#### Dependencies
- `camera`: For capturing passport photos.
- `path_provider`: For temporary file storage.

### 1.4 State Management

**VerificationNotifier (ChangeNotifier)**

**State Variables:**
```dart
File? capturedImage;
VerificationStatus status; // idle, uploading, success, error
double uploadProgress;
String? errorMessage;
```

**Methods:**
```dart
void setImage(File image);
void clearImage();
Future<void> uploadPassport();
```

### 1.5 Error Handling

| Scenario | Handling |
|----------|----------|
| Camera permission denied | Show error message on capture screen |
| Upload failure | Show error banner on review screen, allow retry |

### 1.6 Related Documents

- [Add Passport Verification Design](../../changes/archive/2026-06-03-add-passport-verification/design.md)
- [Add Passport Verification Proposal](../../changes/archive/2026-06-03-add-passport-verification/proposal.md)
- [Add Passport Verification Tasks](../../changes/archive/2026-06-03-add-passport-verification/tasks.md)

---

## 2. Approval & Sign-Off

**Status:** ✅ Implemented
**Implementation Date:** June 3, 2026
