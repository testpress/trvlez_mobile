# Updated Plan: Home Always Landing + Verification Status — Tasks

- `[x]` **Domain Layer Updates**
  - `[x]` Update `TravelerVerificationState` enum — add `profileComplete`, update helpers
  - `[x]` Add `VerificationSessionStatus` response model for `GET /traveler/verification/status`
  - `[x]` Add `getVerificationStatus()` to `VerificationRepository`
- `[x]` **Home Feature Updates**
  - `[x]` Update `VerificationBanner` — configs for ALL onboarding states
  - `[x]` Update `HomeScreen` — smart routing from banner (onboarding vs status)
  - `[x]` Update `HomeNotifier` — also fetch verification session status for failed detection
- `[x]` **Router Updates**
  - `[x]` Simplify redirect: authenticated → always `/home`
  - `[x]` Remove guard blocking `/home` for incomplete users
- `[x]` **Verification**
  - `[x]` `flutter analyze` — 0 errors
