# Implementation Tasks: Selfie Video Upload

- [x] **Setup Dependencies:** Add `camera`, `video_player`, and `path_provider` to `pubspec.yaml` and configure Android permissions.
- [x] **Backend Integration:** Implement `uploadSelfie` in `VerificationRepository` pointing to `/upload/video/init` and `/upload/video/complete`.
- [x] **State Management:** Add video recording state and upload methods to `VerificationNotifier`.
- [x] **Camera Screen:** Build `SelfieCaptureScreen` with `CameraController` and 3-10 second recording logic.
- [x] **Review Screen:** Build `SelfieReviewScreen` to playback the video using `VideoPlayerController` and trigger the upload.
- [x] **Onboarding UI:** Add a bottom sheet to "Verify Identity" for choosing between Passport and Selfie.
- [x] **Onboarding Bug Fix:** Split "Verify Identity" into two separate steps ("Upload Passport", "Selfie Verification") and fix the `isPassportComplete` boolean logic so it unlocks when `step == 'verification_started'`.
- [x] **API Bug Fix:** Fix the API routes in `VerificationRepository` from `/upload/selfie/*` to `/upload/video/*`.
