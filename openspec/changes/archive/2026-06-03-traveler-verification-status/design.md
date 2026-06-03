# Updated Plan: Home Screen Always Landing + Verification Status

## Backend Flow (from source code analysis)

Here's the **exact** state machine based on the backend:

### `TravelerOnboardingStep` (on TravelerProfile)

| Value | Set When |
|-------|----------|
| `profile_pending` | Account created (default) |
| `profile_complete` | `PATCH /traveler/profile` — all required fields present (name, dob, nationality, phone) |
| `verification_started` | `POST /traveler/verification/start` — verification session created |
| `documents_uploaded` | `POST /upload/passport/complete` or `/upload/video/complete` — when **both** passport AND video are attached |
| `submitted` | `POST /traveler/verification/submit` — session moves to processing |
| `verified` | (Admin/backend process — no endpoint in traveler routes yet) |

### `VerificationSessionStatus` (on VerificationSession)

| Value | Set When |
|-------|----------|
| `upload_pending` | Session created via `/verification/start` |
| `uploaded` | **Both** passport and video files are attached (auto-set in `_attach_file_to_verification_session`) |
| `processing` | `/verification/submit` called (requires status == `uploaded`) |
| `verified` | Admin/backend marks it verified |
| `failed` | Admin/backend marks it failed |

> [!IMPORTANT]
> **Answer to your doubt:** YES — after both documents (passport + video) are successfully uploaded, `VerificationSessionStatus` is automatically set to `uploaded` by the `_attach_file_to_verification_session` helper. This happens when the second file completes — it checks if the counterpart file exists, and if so, transitions to `uploaded`. At the same time, `TravelerOnboardingStep` advances to `documents_uploaded`.
>
> Then when you call `/verification/submit`, it checks that status == `uploaded`, and transitions to `processing` + sets onboarding step to `submitted`.

> [!WARNING]
> **`profile_complete` is a real backend step** — our current mobile app skips it. The backend auto-advances from `profile_pending` → `profile_complete` when all required fields are filled in PATCH `/traveler/profile`. But our `TravelerVerificationState` enum doesn't have this value. We need to add it.

---

## Updated Architecture: Home = Always Landing Page

### Key Change from Previous Plan

**Before (what we built):** Onboarding screen for incomplete users, Home screen only after submission.

**Now (your suggestion):** **Home screen is ALWAYS the landing page.** The home screen has smart banners that link to onboarding/verification when needed.

### Navigation Flow

```
Login → /home (ALWAYS)
         │
         ├─ Banner: "Complete your profile" → /onboarding
         ├─ Banner: "Upload documents" → /onboarding  
         ├─ Banner: "Verification in progress" → /verification/status
         ├─ Banner: "Verification failed" → /verification/status (with re-submit)
         └─ No banner: Verified ✅
```

### Banner Logic (based on backend `onboardingStep`)

| `onboarding_step` | Banner Style | Message | Action |
|---|---|---|---|
| `profile_pending` | 🔵 Blue/Info | "Complete your profile to get started" | → `/onboarding` |
| `profile_complete` | 🔵 Blue/Info | "Upload your documents for verification" | → `/onboarding` |
| `verification_started` | 🔵 Blue/Info | "Continue your document upload" | → `/onboarding` |
| `documents_uploaded` | 🔵 Blue/Info | "Submit your documents for review" | → `/onboarding` |
| `submitted` | 🟡 Amber/Processing | "Your identity is being verified (1–2 business days)" | → `/verification/status` |
| `verified` | ✅ No banner (or brief green success toast) | — | — |
| `failed` | 🔴 Red/Error | "Verification unsuccessful — please re-submit" | → `/verification/status` |

---

## Proposed Changes

### Router

#### [MODIFY] [router.dart](file:///c:/Users/HP/TrvlEz/trvlez_mobile/lib/app/router.dart)

- Change redirect: authenticated users **always** go to `/home` (not conditionally)
- Remove the guard that blocks `/home` for incomplete users
- Keep `/onboarding` accessible as a sub-page (navigated to from banner)

### Domain

#### [MODIFY] [traveler_verification_state.dart](file:///c:/Users/HP/TrvlEz/trvlez_mobile/lib/features/profile/domain/traveler_verification_state.dart)

- Add `profileComplete` value (maps to `profile_complete`)
- Update `hasCompletedOnboarding` → rename to something clearer since home is always the landing now
- Add `needsOnboarding` helper (true for any pre-submission state)
- Add `needsAttention` helper (true for any state where the user needs to act)

### Home Screen

#### [MODIFY] [verification_banner.dart](file:///c:/Users/HP/TrvlEz/trvlez_mobile/lib/features/home/presentation/widgets/verification_banner.dart)

- Add banner configs for ALL onboarding states (not just post-submission)
- Blue/info style for pre-submission states linking to `/onboarding`
- Keep amber/red for processing/failed
- Banner always renders unless verified

#### [MODIFY] [home_screen.dart](file:///c:/Users/HP/TrvlEz/trvlez_mobile/lib/features/home/presentation/home_screen.dart)

- Update banner tap handler: route to `/onboarding` for pre-submission states, `/verification/status` for post-submission states
- Welcome message adapts based on state

---

## Open Questions

> [!IMPORTANT]
> **1. `failed` on TravelerOnboardingStep:** The backend's `TravelerOnboardingStep` enum does NOT include `failed` — only `VerificationSessionStatus` has it. When verification fails, what happens to the onboarding step? Does it stay at `submitted`? If so, we need to also check the verification session status via `GET /traveler/verification/status` to distinguish "submitted + processing" from "submitted + failed". Should we use that endpoint on the home screen?

> [!IMPORTANT]  
> **2. After login, profile fetch timing:** Since home is always the landing page, we need the profile data to render the correct banner. The current flow fetches profile in `AuthNotifier.checkAuthStatus()` at startup. For subsequent app opens, this should work. But for **first-time login**, the profile won't be loaded until after navigation completes. The home screen's own `loadProfile()` handles this — just want to confirm this is acceptable (brief loading spinner on first load).

---

## Verification Plan

- `flutter analyze` — 0 errors
- Test each `onboarding_step` value renders the correct banner on home
- Test banner taps navigate to the correct destination
- Test pull-to-refresh updates the banner state
