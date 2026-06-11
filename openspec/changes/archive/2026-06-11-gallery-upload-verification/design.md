# Design: Add Gallery Upload Options for Verification

## Architecture
We use the existing Clean Architecture presentation layer components:
- **Presentation**:
  - `PassportCaptureScreen`: Triggers the gallery picker (`ImageSource.gallery`) for images.
  - `SelfieCaptureScreen`: Triggers the gallery picker (`ImageSource.gallery`) for videos.
  - Transition immediately to `PassportReviewScreen` / `SelfieReviewScreen` on selection.

## Dependencies
- `image_picker`: For selecting images and videos from the device's gallery.

## UI/UX
- Symmetrical layout alignment: A gallery button is added in the controls area of both capture screens.
- Seamless flow transition: Reuses the existing review screens directly, verifying picked assets identically.
