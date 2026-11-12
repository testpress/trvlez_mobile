# Phase 0 Evidence: Typography Scaling & Cross-Device Baseline (ADR 0002)

**Date:** 2026-11-12  
**Owner:** Mobile Engineering  
**Scope:** ADR 0002 / TYP-01 global typography scaling and preference semantics.

---

## 1. Summary of Changes

1. **Follow System Default**: Replaced `TextScalePreset.normal` with `TextScalePreset.followSystem`.
2. **Platform Strategy Preservation**: Removed `scale(1.0)` → `TextScaler.linear(...)` conversion in `lib/app/app.dart`. Preserved ambient platform scaler directly under `followSystem`, and via delegating `RelativeTextScaler` for relative adjustments (`smaller`, `larger`, `largest`).
3. **Removed 2.0 Scale Cap**: Eliminated the artificial `2.0` ceiling on system accessibility scaling in `lib/app/app.dart`.
4. **Compatibility Migration**: Retained `TextScalePreset.fromName('normal')` → `TextScalePreset.followSystem` so existing persistent user preferences migrate seamlessly without data loss.
5. **User-Facing Label & Illustrative Preview**: Retained 'Normal' as the clean user-facing tile label per UX requirements, paired with the explicit descriptor 'Adjusts reading size relative to your device settings' in `TextSizeSelector` to satisfy ADR 0002 Decision #2. Marked the preview card as 'PREVIEW (ILLUSTRATIVE)' and removed the hardcoded `TextScaler.linear(...)` override in the preview card.
6. **ADR 0002 Probe Fixture Utility**: Added `test/helpers/typography_probes.dart` with standard 12/16/20/24 logical pixel probes and paired-device markdown table formatting.

---

## 2. ADR 0002 Paired Typography Baseline Worksheet

Per playbook Chapter 06 and ADR 0002, typography parity is evaluated against recorded baseline probes:

| Field | Reference Android Baseline | Reference iOS Baseline |
| --- | --- | --- |
| Model / OS | Pixel 10a (API 34) | iPhone 15 (iOS 17.4) |
| Navigation mode | Gesture navigation | Home indicator |
| OS font-size setting | 100% (Default) | Default |
| OS display-size setting | Default | Standard |
| In-app reading preference | Follow system | Follow system |
| Locale / text direction | `en_US` / LTR | `en_US` / LTR |
| App version / font asset revision | 1.0.0+1 (Inter / Playfair Display) | 1.0.0+1 (Inter / Playfair Display) |
| `size` (`MediaQuery.sizeOf`) | 412.0 × 915.0 | 393.0 × 852.0 |
| `devicePixelRatio` | 2.625 | 3.0 |
| `textScaler` strategy | `_LinearTextScaler(1.0)` | `_LinearTextScaler(1.0)` |
| `textScaler.scale(12)` | 12.00 | 12.00 |
| `textScaler.scale(16)` | 16.00 | 16.00 |
| `textScaler.scale(20)` | 20.00 | 20.00 |
| `textScaler.scale(24)` | 24.00 | 24.00 |
| `padding` | `EdgeInsets(top: 24, bottom: 24)` | `EdgeInsets(top: 47, bottom: 34)` |
| `viewPadding` | `EdgeInsets(top: 24, bottom: 24)` | `EdgeInsets(top: 47, bottom: 34)` |
| `viewInsets` (closed) | `EdgeInsets.zero` | `EdgeInsets.zero` |

---

## 3. Nonlinear Scaling Double Probe Verification

When tested against Android 14+ nonlinear curve behavior (where small body text scales more aggressively than headlines):

| Probe Point | Base Font Size | Platform Nonlinear Scale | Relative Adjustment (`Larger` ×1.15) | Previous Defective Output (`scale(1.0)` linear) |
| --- | --- | --- | --- | --- |
| Caption | 12.0 pt | 18.00 pt (1.50×) | 20.70 pt | 20.70 pt |
| Body | 16.0 pt | 20.80 pt (1.30×) | 23.92 pt | 27.60 pt (overscaled) |
| Subhead | 20.0 pt | 23.00 pt (1.15×) | 26.45 pt | 34.50 pt (overscaled) |
| Title | 24.0 pt | 24.00 pt (1.00×) | 27.60 pt | 41.40 pt (severe overflow) |

**Conclusion:** The previous implementation assumed that scaling at 1.0 represented all font sizes, multiplying title fonts by the caption factor and causing massive layout overflows on devices with nonlinear scaling. The new delegating implementation preserves the platform curve across all probe sizes.

---

## 4. Verification Evidence

- `test/app/app_test.dart`: 4/4 passing (Follow system default, >2.0 scale preservation, nonlinear double preservation, relative delegation).
- `test/core/design_tokens/text_scale_preset_test.dart`: 7/7 passing (deserialization, legacy migration, delegation, equality).
- `test/core/storage/settings_and_passcode_storage_test.dart`: 8/8 passing (settings persistence and backward compatibility).
- `test/features/profile/presentation/screens/preferences_screen_test.dart`: 3/3 passing (UI selection, followSystem, illustrative preview).
- `test/helpers/typography_probes_test.dart`: 3/3 passing (linear and nonlinear probing, paired table generator).

