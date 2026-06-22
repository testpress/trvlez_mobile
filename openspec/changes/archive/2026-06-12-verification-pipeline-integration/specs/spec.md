# Specification: Verification Pipeline Integration

## Overview
This specification details the frontend behavior for integrating the synchronous backend ML verification pipeline in an asynchronous, non-blocking manner to improve the user experience.

## System Behavior

### Video Upload and Submission
1. **Upload Phase**: The user captures their selfie video and taps "Submit". The app uploads the video to S3 via the backend `/upload/video/complete` endpoint.
2. **Success State**: Immediately after the video upload succeeds, the app transitions to the `uploadSuccess` state and displays the "Documents Uploaded" confirmation bottom sheet.
3. **Background Processing**: Concurrently, the app silently triggers the backend `/verification/submit` endpoint in the background. This endpoint runs the full ML verification pipeline and blocks until it yields a final verification score.

### Verification Status Observation
1. **Global Notifier**: The `VerificationNotifier` is instantiated globally at the router level. It holds the asynchronous future of the `/submit` API call.
2. **Dynamic UI Updates**: The `VerificationStatusScreen` accepts the global `VerificationNotifier` instance. It listens to the background task's state changes.
3. **Score Display**: Once the backend returns the `VerificationSubmitResult` with `isVerified=true` and a `verificationScore`, the `VerificationStatusScreen` dynamically reads these fields from the notifier and renders the score indicator, skipping the need for manual polling of the job ID.

## Error Handling
- **Upload Failures**: Handled during the foreground upload step. The user is prompted to try uploading the video again.
- **Background Submission Failures**: If the background ML pipeline call fails or raises an exception, the `VerificationNotifier` state transitions to `verificationFailed` or `error`. The `VerificationStatusScreen` observes this and displays the relevant error message without requiring user interaction.
