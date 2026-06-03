# Selfie Video Upload Feature

## What are we building?
We are implementing the selfie video recording and upload feature for the traveler identity verification flow. This allows users to record a short video of themselves to verify their identity after uploading their passport.

## Why are we building it?
Identity verification requires a live video recording to prevent fraud and ensure the traveler matches the uploaded passport document. The previous flow only handled passport uploads and left the selfie step unimplemented.

## Scope
- Implement camera integration for video recording (3-10 seconds duration constraint).
- Implement a review screen to playback the recorded video before submission.
- Integrate the backend API to stream the chunked video to storage using the `/upload/video/init` and `/upload/video/complete` endpoints.
- Update the onboarding stepper to separate "Upload Passport" and "Selfie Verification" into distinct steps to prevent locking the flow prematurely.
