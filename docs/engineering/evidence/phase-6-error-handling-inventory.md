# Phase 6 — Error Handling & Catch Policy Inventory

**Date:** 2026-11-11  
**Scope:** Inventory and categorization of broad and empty `catch` blocks across `lib/`  

---

## 1. Classification Categories

Per `playbook/08-non-ui-engineering-backlog.md §3`, catch blocks are classified into three architectural tiers:

1. **Category A — Safe Best-Effort Fallback:** Transient platform operations (e.g. Google Play Referrer attribution on sideloaded APK, haptics, theme preference fallback, cache read failures).
2. **Category B — Recoverable User/Network Error:** HTTP calls and auth checks that should map cleanly to `AppException` and present user feedback.
3. **Category C — Defect / Investigation Needed:** Uncaught runtime exceptions that should be forwarded to structured logging or crash reporting (Sentry/Crashlytics).

---

## 2. Inventory by Feature Area

### Attribution & Play Referrer (`lib/core/attribution/`)
- `install_referrer_client.dart` lines 80, 101, 115:
  - *Pattern:* `catch (unexpectedError)`, `catch (_)`
  - *Classification:* **Category A (Safe Fallback)**
  - *Behavior:* On sideloaded APKs or Huawei/Amazon devices without Google Play Services, the install referrer client fails. Catching safely prevents app crashes on first launch.

### Verification & NFC Passport (`lib/features/verification/`)
- `nfc_passport_service_impl.dart` lines 43, 97, 145, 189, 251, 297, 341:
  - *Pattern:* `catch (e)`
  - *Classification:* **Category B (Mapped)**
  - *Behavior:* Maps native ISO 7816 / ICAO 9303 NFC hardware errors to `NfcError` domain entity.

### Profile & Security Settings (`lib/features/profile/`)
- `security_providers.dart` line 54, `passcode_setup_sheet.dart` line 56:
  - *Pattern:* `catch (_)`
  - *Classification:* **Category A (Biometric/Keyring fallback)**
  - *Behavior:* Hardware keystore or passcode unavailability gracefully falls back to password authentication.

### Theme & Typography (`lib/app/theme/`)
- `app_theme.dart` lines 143, 152, 172, 181:
  - *Pattern:* `catch (_)`
  - *Classification:* **Category A (Font fallback)**
  - *Behavior:* GoogleFonts runtime fetch failure safely falls back to standard platform system fonts (Roboto on Android, San Francisco on iOS).

---

## 3. Recommended Remediation Proposal

1. **Introduce Structured Logger:**
   Create `lib/core/utils/app_logger.dart` wrapping `dart:developer.log` with log level filtering, redaction of sensitive passport/MRZ data, and breadcrumb tracking.
2. **Crashlytics / Sentry Integration:**
   Route uncaught errors in `PlatformDispatcher.instance.onError` to crash reporting in production.
3. **Specific Catches:**
   Progressively replace `catch (e)` with `on PlatformException catch (e)` or `on AppException catch (e)` across verification screens.
