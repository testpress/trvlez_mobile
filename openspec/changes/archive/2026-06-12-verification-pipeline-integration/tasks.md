# Tasks: Verification Pipeline Integration

- [x] Update `VerificationNotifier.uploadSelfie` to decouple video upload from submission.
- [x] Create `_submitVerificationAsync` in `VerificationNotifier` to run the ML pipeline call in the background.
- [x] Modify `VerificationStatusScreen` to accept `VerificationNotifier` as an optional parameter.
- [x] Update `VerificationStatusScreen` state logic to listen to `VerificationNotifier` and use its `submitResult` for real-time score updates.
- [x] Update `router.dart` to inject the global `verificationNotifier` instance into `VerificationStatusScreen`.
- [x] Clean up any unused imports resulting from the refactor (e.g., `VerificationStatus` in `verification_notifier.dart`).
