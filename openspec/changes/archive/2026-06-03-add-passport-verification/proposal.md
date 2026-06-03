# Proposal: Add Passport Verification Flow

## Goal
Implement a passport verification flow immediately following the onboarding process to ensure users securely verify their identity before accessing the main features of the app.

## Context
The onboarding process currently lacks an identity verification step, which is a requirement for our platform.

## Proposed Solution
- Add a new passport capture screen using the device camera.
- Add a review screen to verify and upload the captured image.
- Mock the API integration for uploading the passport.
- Integrate the flow into the existing onboarding process so users are navigated to the verification screen instead of the main app.
