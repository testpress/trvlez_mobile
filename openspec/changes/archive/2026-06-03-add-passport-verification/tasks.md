# Tasks: Add Passport Verification Flow

## 1. Setup Dependencies
- [x] Add `camera` and `path_provider` to `pubspec.yaml`.
- [x] Update AndroidManifest.xml with camera permissions.

## 2. Data Layer
- [x] Create `VerificationRepository` with simulated upload functionality.

## 3. Presentation Layer
- [x] Create `VerificationNotifier` to manage upload state and progress.
- [x] Create `PassportCaptureScreen` for camera interaction.
- [x] Create `PassportReviewScreen` for reviewing and uploading the photo.

## 4. Integration
- [x] Update `OnboardingScreen` to navigate to the verification flow upon completion.
