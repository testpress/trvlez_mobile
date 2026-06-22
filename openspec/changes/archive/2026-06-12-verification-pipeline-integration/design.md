# Design: Verification Pipeline Integration

## Architecture Changes

### VerificationNotifier
- Extract the synchronous `_repository.submitVerification()` call out of the `uploadSelfie()` method.
- Create a new asynchronous method `_submitVerificationAsync()` that handles the backend submission in the background and updates `_phase` and `_submitResult`.
- `uploadSelfie()` now simply uploads the video to S3 and changes the phase to `uploadSuccess` immediately before triggering `_submitVerificationAsync()`.

### VerificationStatusScreen
- Add `VerificationNotifier` as a dependency.
- In `initState`, add a listener to the `VerificationNotifier`.
- Modify `_effectiveState` to prioritize the `submitResult` from the global `VerificationNotifier` over the legacy `_jobResult` polling fallback.
- Update `_activeVerificationScore` and `_activeErrorMessage` getters to pull data from the notifier's `submitResult` if available.

### Router (`router.dart`)
- Update the `/verification/status` route definition to pass the globally instantiated `verificationNotifier` into the `VerificationStatusScreen`.
