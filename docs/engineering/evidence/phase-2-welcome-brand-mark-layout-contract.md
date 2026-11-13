# Welcome brand-mark layout contract

**Date:** 2026-11-13
**Owner:** Mobile Engineering
**Scope:** bounded animated identity mark in `WelcomeScreen`.

## Layout contract — WelcomeScreen identity mark

- **Available region:** full `WelcomeScreen` scaffold body; the mark is centred in the `Stack` and is never a scroll owner.
- **Inset owner:** the CTA/footer owns bottom system exclusion through its `SafeArea`; the decorative mark does not own a safe area.
- **Scroll owner:** none. The mark is decorative; interactive onboarding actions remain in the footer.
- **Growth and overflow policy:** the mark is an indivisible identity graphic. It may scale down inside its allocated artboard region, but it is excluded from readable-text semantics and cannot replace or hide user content. User-facing CTA and footer text retains system scaling and is tested by the screen matrix.
- **Named fixed dimensions:** `_artW` / `_artH` are the approved launch-artboard ratio; `_maxScale` bounds artwork only. They do not size a text-bearing form or action.
- **Accessibility:** one image semantic label, `TrvlEz`, represents the complete visible wordmark. The component is non-interactive and does not participate in focus traversal.
- **Adverse states:** compact and regular viewport plus 1.0, 1.3 and 2.0 automated scale matrix. Platform-maximum runtime validation is required before a release claim.
- **Locale/directionality:** current release is English-LTR. The mark has no directional reading order; CTA/footer content uses directional Flutter layout.

## Validation owner

`test/features/auth/presentation/screens/welcome_screen_test.dart` owns the deterministic matrix and semantics assertion. Runtime capture ownership remains Phase 6 evidence.
