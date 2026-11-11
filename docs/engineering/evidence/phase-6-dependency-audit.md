# Phase 6 — Dependency Health & Outdated Packages Audit

**Date:** 2026-11-11  
**Command:** `dart pub outdated`  
**Flutter SDK:** 3.44.4 stable, Dart 3.12.2  

---

## 1. Executive Summary

- **Direct dependencies:** 13 direct dependencies are currently locked to older patch/minor versions.
- **Discontinued packages:** 2 discontinued transitive packages detected (`golden_toolkit 0.15.0`, `flutter_secure_storage_macos 3.1.3`, `js 0.6.7`).
- **Dev dependencies:** All up-to-date.
- **Major constraint blockers:**
  - `flutter_riverpod 2.6.1` (v3.5.0 available): Riverpod 3.x is a major architectural migration and should not be upgraded prematurely.
  - `go_router 17.2.3` (v18.1.4 available): Minor breaking changes in route matches.
  - `flutter_secure_storage 9.2.4` (v11.2.0 available): Major bump replaces deprecated macOS platform packages.
- **Local path dependency:** `dmrtd` is a sibling path dependency (`../dmrtd`) for NFC passport reading.

---

## 2. Direct Dependencies Status

| Package | Current | Upgradable (in range) | Resolvable | Latest | Risk / Action |
|---|---|---|---|---|---|
| `app_settings` | 7.0.0 | 7.0.0 | 9.0.1 | 9.0.1 | Low (API settings navigation) |
| `camera` | 0.12.0+1 | 0.12.2 | 0.12.2 | 0.12.2 | Patch upgrade safe |
| `dio` | 5.11.0 | 5.11.1 | 5.11.1 | 5.11.1 | Patch upgrade safe |
| `flutter_riverpod` | 2.6.1 | 2.6.1 | 3.4.3 | 3.5.0 | **Hold on 2.6.x** — major breaking API shifts in 3.x |
| `flutter_secure_storage` | 9.2.4 | 9.2.4 | 11.2.0 | 11.2.0 | Recommended for future upgrade |
| `flutter_svg` | 2.3.0 | 2.3.3 | 2.3.3 | 2.3.3 | Patch upgrade safe |
| `go_router` | 17.2.3 | 17.5.0 | 17.5.0 | 18.1.4 | Minor upgrade to 17.5.0 safe |
| `image` | 4.9.1 | 4.12.0 | 4.12.0 | 4.12.0 | Performance improvements in image manipulation |
| `image_picker` | 1.2.2 | 1.2.4 | 1.2.4 | 1.2.4 | Patch upgrade safe |
| `meta` | 1.18.0 | 1.18.0 | 1.18.0 | 1.19.0 | Low |
| `share_plus` | 12.0.2 | 12.0.2 | 13.3.1 | 13.3.1 | Minor upgrade |
| `shared_preferences` | 2.5.5 | 2.5.6 | 2.5.6 | 2.5.6 | Patch upgrade safe |
| `video_player` | 2.11.1 | 2.14.1 | 2.14.1 | 2.14.1 | Minor upgrade safe |

---

## 3. Discontinued Package Remediation Proposal

1. **`golden_toolkit` (0.15.0):** Package author discontinued maintenance in favor of native Flutter golden testing or `alchemist`.
   - *Resolved:* `test/core/widgets/app_card_golden_test.dart` runs in the pinned Flutter 3.44.4 / deterministic-font environment. Keep `golden_toolkit` unless a measured limitation requires another approach; baseline changes remain reviewed visual changes.
2. **`flutter_secure_storage_macos`:** Transitive dependency from `flutter_secure_storage 9.2.4`.
   - *Proposal:* Resolved automatically when updating `flutter_secure_storage` to 11.x.
3. **`dmrtd` sibling path dependency:**
   - *Proposal:* Host `dmrtd` in a dedicated private Git repository and pin commit SHA in `pubspec.yaml`:
     ```yaml
     dmrtd:
       git:
         url: git@github.com:trvlez/dmrtd.git
         ref: <pinned-commit-sha>
     ```
