# Proposal: Verification Pipeline Integration

## Goal
Improve the user experience during identity verification by running the final verification submission step asynchronously in the background.

## Context & Motivation
Currently, when a traveler completes their selfie video upload, the mobile app synchronously awaits the backend's `/submit` endpoint. Since the backend blocks and waits for the entire ML verification pipeline to finish before responding, the user is forced to wait on a loading screen ("Submitting for verification... This may take a moment.") for an extended period. This blocking behavior prevents them from seeing the initial upload success message and progressing to the verification status screen.

## Proposed Solution
- Modify the `VerificationNotifier` to decouple the video upload from the verification submission.
- Fire off the verification submission as a background task.
- Show an immediate "Documents Uploaded" success sheet upon successful video upload.
- Pass the global `VerificationNotifier` to the `VerificationStatusScreen` so it can actively listen to the background task's state and dynamically show the final score/result when it completes.
