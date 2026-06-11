# Proposal: Add Gallery Upload Options for Verification

## Goal
Provide an alternative option for users to upload their passport and selfie video from their device's gallery instead of only relying on live camera capture, increasing flexibility and convenience.

## Context
Currently, the verification flow requires live capture of both the passport and the selfie video. Some users may have pre-captured photos of their passport or pre-recorded selfie videos on their device, or may experience device camera compatibility issues during live capture.

## Proposed Solution
- Add a gallery button to the Passport Capture Screen to allow selecting a passport image from the gallery.
- Add a gallery button to the Selfie Capture Screen to allow selecting a selfie video from the gallery.
- Once selected, immediately route the user to the respective review screen to maintain a consistent UX.
- Integrate the `image_picker` dependency to facilitate media selection.
