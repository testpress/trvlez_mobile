# Verification Capability Specification

## Overview

The Verification capability handles identity verification for the TrvlEz platform, specifically focusing on capturing and uploading passport documents securely.

**Current Status:** Passport Verification, Selfie Video Verification, and Gallery Upload options implemented.

---

## 1. Passport Verification Feature

### 1.1 Purpose

Ensure users securely verify their identity by capturing and uploading their passport after completing onboarding, before accessing the main application.

### 1.2 User Flow

```
1. User completes onboarding screen.
2. User is navigated to the Passport Capture Screen.
3. User can choose to either:
   - Align their passport within the camera frame and tap the capture button to take a photo.
   - Tap the gallery icon to pick a passport photo from the device's gallery.
4. App displays the Passport Review Screen with the selected photo.
5. User can choose to "Retake" or "Upload".
6. On "Upload", the app shows upload progress via a simulated API call.
7. On success, the user is navigated to the main application or a success state.
8. On error, the user is shown an error message and can retry the upload.
```

### 1.3 Implementation Details

#### Files
- **lib/features/verification/presentation/screens/passport_capture_screen.dart** - Camera capture UI and Gallery Picker integration
- **lib/features/verification/presentation/screens/passport_review_screen.dart** - Image review and upload UI
- **lib/features/verification/presentation/verification_notifier.dart** - State management
- **lib/features/verification/data/verification_repository.dart** - Repository handling simulated upload

#### Dependencies
- `camera`: For capturing passport photos.
- `image_picker`: For selecting passport photos from the device's gallery.
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
- [Gallery Upload Options Design](../../changes/archive/2026-06-11-gallery-upload-verification/design.md)
- [Gallery Upload Options Proposal](../../changes/archive/2026-06-11-gallery-upload-verification/proposal.md)
- [Gallery Upload Options Tasks](../../changes/archive/2026-06-11-gallery-upload-verification/tasks.md)

---

## 2. Selfie Video Verification Feature

### 2.1 Purpose

Ensure users securely verify their identity by capturing and uploading a live video of themselves after completing the passport upload.

### 2.2 User Flow

```
1. User completes passport upload.
2. User taps "Selfie Verification" on the onboarding screen.
3. User is navigated to the Selfie Capture Screen.
4. User can choose to either:
   - Record a 3 to 10-second video of themselves.
   - Tap the gallery icon to pick a pre-recorded selfie video from the device's gallery.
5. App displays the Selfie Review Screen to playback the selected video.
6. User can choose to "Retake" or "Upload".
7. On "Upload", the app shows upload progress while streaming the video to the backend.
8. On success, the user is navigated back to the onboarding screen which shows the Verification as pending review.
9. On error, the user is shown an error message and can retry the upload.
```

### 2.3 Implementation Details

#### Files
- **lib/features/verification/presentation/screens/selfie_capture_screen.dart** - Video capture UI and Gallery Picker integration
- **lib/features/verification/presentation/screens/selfie_review_screen.dart** - Video review and upload UI
- **lib/features/verification/presentation/verification_notifier.dart** - State management
- **lib/features/verification/data/verification_repository.dart** - Repository handling AWS S3 video upload

#### Dependencies
- `camera`: For capturing selfie videos.
- `video_player`: For video playback during review.
- `image_picker`: For selecting selfie videos from the device's gallery.

### 2.4 State Management

**VerificationNotifier (ChangeNotifier) Updates**

**State Variables:**
```dart
XFile? capturedVideo;
```

**Methods:**
```dart
void setVideo(XFile video);
void clearVideo();
Future<void> uploadSelfie();
```

### 2.5 Related Documents

- [Selfie Video Upload Design](../../changes/archive/2026-06-03-selfie-video-upload/design.md)
- [Selfie Video Upload Proposal](../../changes/archive/2026-06-03-selfie-video-upload/proposal.md)
- [Selfie Video Upload Tasks](../../changes/archive/2026-06-03-selfie-video-upload/tasks.md)
- [Selfie Video Upload Spec](../../changes/archive/2026-06-03-selfie-video-upload/specs/spec.md)
- [Gallery Upload Options Design](../../changes/archive/2026-06-11-gallery-upload-verification/design.md)
- [Gallery Upload Options Proposal](../../changes/archive/2026-06-11-gallery-upload-verification/proposal.md)
- [Gallery Upload Options Tasks](../../changes/archive/2026-06-11-gallery-upload-verification/tasks.md)

---

## 3. Traveler Verification Tracking Feature

### 3.1 Purpose

Provide travelers with a clear, universal home dashboard where they can track their ongoing verification process, understand any pending steps, and see actionable feedback if their verification fails.

### 3.2 User Flow

```
1. User logs in.
2. User is always navigated to the Home Screen.
3. The Home Screen displays a dynamic Verification Banner based on the traveler's status:
   - "Complete Your Profile" (routes to Onboarding)
   - "Upload Your Documents" (routes to Onboarding)
   - "Verification In Progress" (routes to Verification Status Screen)
   - "Verification Unsuccessful" (routes to Verification Status Screen)
4. Tapping a post-submission banner opens the Verification Status Screen.
5. The Verification Status Screen displays:
   - An animated icon showing the current review state (processing, verified, failed).
   - A step-by-step checklist of progress.
   - If failed, action buttons to resubmit documents or contact support.
```

### 3.3 Implementation Details

#### Files
- **lib/features/home/presentation/screens/home_screen.dart** - Universal landing page
- **lib/features/home/presentation/widgets/verification_banner.dart** - Dynamic context-aware banner
- **lib/features/verification/presentation/screens/verification_status_screen.dart** - Detailed tracking view
- **lib/features/profile/domain/traveler_verification_state.dart** - Enum mapping for the exact backend states

#### Dependencies
- None specific to this feature.

### 3.4 State Management

**HomeNotifier (ChangeNotifier)**

**State Variables:**
```dart
Profile? profile;
VerificationStatus? verificationStatus;
```

**Methods:**
```dart
Future<void> loadProfile();
```
*Note: Evaluates both the `TravelerOnboardingStep` and `VerificationSessionStatus` to determine the accurate visual state (e.g., detecting if a submitted session has failed).*

### 3.5 Related Documents

- [Traveler Verification Status Design](../../changes/archive/2026-06-03-traveler-verification-status/design.md)
- [Traveler Verification Status Proposal](../../changes/archive/2026-06-03-traveler-verification-status/proposal.md)
- [Traveler Verification Status Tasks](../../changes/archive/2026-06-03-traveler-verification-status/tasks.md)

---

## 4. Approval & Sign-Off

**Status:** ✅ Implemented
**Implementation Date:** June 11, 2026
