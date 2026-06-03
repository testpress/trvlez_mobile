# Design: Add Passport Verification Flow

## Architecture
We will use the existing Clean Architecture pattern:
- **Presentation**: `PassportCaptureScreen`, `PassportReviewScreen`, and `VerificationNotifier` for state management.
- **Data**: `VerificationRepository` for handling the simulated API upload.

## Dependencies
- `camera`: For capturing passport photos.
- `path_provider`: For temporary file storage.

## UI/UX
- Capture Screen: Full-screen camera preview with a capture button.
- Review Screen: Displays the captured image, allows retaking or uploading with simulated progress.

## Flow
Onboarding Complete -> PassportCaptureScreen -> PassportReviewScreen -> (Simulated Upload) -> Success State.
