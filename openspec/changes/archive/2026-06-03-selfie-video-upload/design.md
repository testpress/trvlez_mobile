# Design: Selfie Video Upload

## Architecture
- **Camera Capture:** Use `camera` plugin with `CameraController` to record `.mp4` video.
- **Timer/Constraints:** Enforce minimum 3 seconds and maximum 10 seconds of recording. If stopped before 3 seconds, show an error. Automatically stop at 10 seconds.
- **Video Playback:** Use `video_player` plugin to allow the user to review the video.
- **Upload Strategy:** 
  - Call `/upload/video/init` to get a presigned S3 upload URL.
  - Stream the file bytes using `http.StreamedRequest` to the S3 URL for memory efficiency.
  - Call `/upload/video/complete` to finalize the upload and attach the video to the verification session on the backend.
- **Onboarding Flow:** Update `onboarding_screen.dart` to check `profile.onboardingStep`. Map `verification_started` to passport completion, and `documents_uploaded` to selfie completion, ensuring buttons unlock sequentially.

## Data Models
- Use the existing `VerificationRepository` to add the `uploadSelfie` method.
- Update `VerificationNotifier` to handle the `capturedVideo` state (XFile).

## UI/UX
- **SelfieCaptureScreen:** Full-screen camera preview with a red recording button and a timer display. 
- **SelfieReviewScreen:** Video player preview with a "Retake" button and an "Upload" button showing a progress indicator.
