# Delta Spec: Selfie Video Upload

## Additions

### `lib/features/verification/presentation/selfie_capture_screen.dart`
- Added UI screen for capturing a 3 to 10-second selfie video using `CameraController`.

### `lib/features/verification/presentation/selfie_review_screen.dart`
- Added UI screen for reviewing the captured video using `VideoPlayerController` and uploading it.

## Modifications

### `lib/features/verification/data/verification_repository.dart`
- Added `uploadSelfie(XFile videoFile, Function(double) onProgress)` method to upload video to S3 via backend endpoints `/upload/video/init` and `/upload/video/complete`.

### `lib/features/verification/presentation/verification_notifier.dart`
- Added state for `capturedVideo` and methods to handle recording completion, retrying, and uploading.

### `lib/features/onboarding/presentation/onboarding_screen.dart`
- Separated "Verify Identity" into two steps: "Upload Passport" and "Selfie Verification".
- Updated `isPassportComplete` to unlock the selfie step immediately after `step == 'verification_started'`.
