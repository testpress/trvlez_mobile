# UI Redesign Comparison Guide

> **Current app:** `/home/kumaraguhan/workspace/trvlez_mobile`  
> **Target design:** `/home/kumaraguhan/Downloads/trvlez_app`  
> **Companion plan:** [`UI_REDESIGN_PLAN.md`](./UI_REDESIGN_PLAN.md) (screen inventory & phase order)  
> **Token reference:** [`design_tokens.md`](./design_tokens.md) + Dart sources under `lib/core/design_tokens/` and `lib/app/theme/tokens/`

This guide is the **how** for remaining screen redesigns. The plan is the **what / when**. Do not copy target source into the current app; adapt visuals through our semantic tokens, shared widgets, and architecture.

---

## 0. Non-negotiable rules

1. **Visual accuracy, implementation fidelity to us.** Match the target look; never paste `d(context, N)`, bare hex, or target widget trees.
2. **Role over number.** Choose tokens by structural intent (`insetCard`, `stackFormField`), not by matching a design-px value.
3. **No business-logic changes.** Keep Riverpod providers, routes, validation, APIs, NFC/camera, and domain models intact.
4. **Prefer reuse.** Extend `lib/core/widgets/` before inventing a one-off.
5. **Propose tokens only when needed.** If no token fits, stop and add a named semantic token from primitives — never a raw literal or a value-named token (`space16`).
6. **Incremental.** One screen (or one tightly coupled sheet) per change set. Follow §6 checklist every time.

---

## 1. Critical mental model: design-px ≠ logical tokens

| Concern | Target (`trvlez_app`) | Current (`trvlez_mobile`) |
|---|---|---|
| Layout numbers | Artboard **design-px** from HTML mocks, wrapped in `d(context, N)` | Logical **dp** via `context.space` / `context.sizes` / `context.shape` |
| Typography sizes | Artboard px via `ts(context, N)` against ref width **212** | Logical sizes via `context.text.*` / `AppTypography` (already phone-sized) |
| Scaling | Per-screen artboard fit (`TzScreen` / `TzAppScale`); type often normalised | Standard Flutter layout + optional `TextScalePreset`; no artboard scaler |
| Colors | `TzColors.*` constants | `context.colors.*` ThemeExtension (light/dark) |
| State | `ChangeNotifier` + `AppStateScope` | Riverpod (`ConsumerWidget` / notifiers) |
| Routing | Navigator 1.0 named routes | GoRouter + `MainScaffold` shell |
| Features | Flat `features/<area>/*_screen.dart` | Clean-ish layers: `presentation/screens|widgets|providers` (+ data/domain where present) |

### Why you must not copy numbers

On a ~390-wide phone, target `d(context, 14)` often renders near **~26 dp**, and auth heading `ts(15)` near **~25–28 pt**. Our tokens already encode that **rendered** size (`space.insetScreen` ≈ 16, `text.headlineLarge` = 26). Pasting `14` or `15` into our screens makes UI look half-scale.

**Workflow:** read the target for **role and relative rhythm** → map to a semantic token → verify against a redesigned sibling (Login / Home), not against the design-px literal.

### Approved polish (target `tz_polish.dart`)

Preserve these **intentional** departures when redesigning light-app cards/headers (already reflected in our tokens/widgets where possible):

| Polish | Design mock | Approved / what we ship |
|---|---|---|
| Card radius | 12 / 13 / 14 / 15 | +4 → use **`shape.radiusSurface` (16)** for standard cards; Findr/large surfaces may use **`radiusCard` (24)** via existing widgets |
| Card border | `line` `#E4E4E8` | Soft border → **`colors.cardBorderSoft` / `colors.cardBorder`** |
| Card shadow | none | Soft 3% black → **`colors.cardShadow`** (blur ~6, offset y ~1 — keep inside `AppCard` / feature cards, not ad-hoc) |
| Hub header air | tighter CSS gaps | Extra air only in home header — already in redesigned Home; do **not** globally loosen every gap |

Other known differences (SVG filter wobble missing, GBP currency, filled map pin, “ez” red everywhere, help-line placement) are documented in the target’s `docs/KNOWN_DIFFERENCES.md`. Prefer those product decisions over raw mock defects.

---

## 2. Design comparison — how the target builds UI

### 2.1 Surfaces & scaffolds

| Pattern | Target | Current equivalent |
|---|---|---|
| Red auth | `TzRedScreen` + SVG motif + wordmark | `BrandScreen` |
| Red verify / check-in / anywhere / dispute | `TzVerifyScreen` (title, flex body, pinned foot, help line) | `BrandVerifyScreen` |
| Light signed-in | `TzAppScreen` + page `#F4F5F7` + tab bar | `MainScaffold` + `AppPinnedHeader` + `colors.page` |
| Bottom sheets | White, top radius ~18 (+ polish), grab handle, scrim | Feature sheets + `shape.radiusOverlay` (20) |

### 2.2 Spacing rhythm (target design-px clusters → intent)

| Intent | Typical target `d()` | Use in current app |
|---|---|---|
| Screen / body horizontal inset | 14–19 (auth ~19, verify ~17, light ~14) | `space.insetScreen` or `space.insetBrandScreen` (red) |
| Card padding | 10–14 | `space.insetCard` / `insetCardCompact` / `insetCardComfortable` |
| Button vertical pad | 11–12 | Prefer button widget defaults (`insetControlMd` / `Lg`); do not re-pad labels |
| Title ↔ subtitle | 2–5 | `space.stackText` / `stackTight` |
| List / chip stacks | 6–9 | `space.stackItem` / `stackTight` |
| Form fields | ~7–12 between fields | `space.stackFormField` |
| Section breaks | 12–16+ | `space.stackSection` / `stackHero` |
| Icon–label | 6–9 | `space.inlineIconLabel` |
| Button groups | ~8–12 | `space.inlineButtonGroup` |
| Page bottom clearance | large foot gaps | `space.stackPageBottom` |

### 2.3 Sizing & controls

| Intent | Target | Current token / widget |
|---|---|---|
| Primary CTA height | padded pill (~design 31 field / large padded btn) | `AppButton` → `sizes.controlLg` (48) or brandWhite `controlHero` (72) |
| Tab bar | 48 + home indicator | `sizes.controlLg` + `MediaQuery.viewPadding.bottom` (done in `MainScaffold`) |
| Icons (chrome) | ~8–12 design → scaled up | `sizes.iconSm` (18) / `iconMd` (20) / `iconDefault` (24) |
| List thumbs | ~23–44 design | `PhotoBox` + `sizes.controlMd` / avatar / thumb tokens |
| Touch targets | often undersized in mocks | Always ≥ `sizes.touchTargetMin` (48) — **override the mock** for a11y |
| Progress track height | ~4 | `sizes.indicatorProgressHeight` |
| Viewfinder | aspect ~1:1.05 | Keep ratio; constrain with `sizes.containerViewfinder` / layout, not raw width |

### 2.4 Shape

| Intent | Target | Current |
|---|---|---|
| Buttons / fields (red) | pill `999` | `shape.radiusPill` (`AppButton` brand variants, `BrandTextField`) |
| Soft chips | `99` | `shape.radiusPill` (same full pill) or `radiusControlSm` for soft rectangles |
| Controls / inputs (light) | ~12 | `shape.radiusControl` |
| Cards | 12–15 + polish 4 | `shape.radiusSurface` (16); large/header: `radiusCard` / `radiusHeader` |
| Sheets / overlays | ~18 | `shape.radiusOverlay` (20) |
| Borders | 1 / 1.5 | `shape.borderDefault` / `borderMedium` / `borderHairline` |

### 2.5 Typography

Target `TzText` roles are semantic (good), but sizes are artboard px. Map **role → our TextTheme / AppTypography**, then tint with `context.colors`:

| Target role (examples) | Approx design px | Current mapping |
|---|---|---|
| Auth / brand heading (`heading`) | ~15 | `context.text.headlineLarge` or `AppTypography.brandHeading` (26) |
| Brand subtitle | ~9.5 | `context.text.bodyLarge` + `colors.brandSecondaryBody` (or `AppTypography.brandSubtitle`) |
| Light hub greeting | ~15.5 | `context.text.headlineMedium` (20) |
| Section / app bar title | ~12–15 | `titleLarge` / `headlineSmall` |
| Body / secondary | ~8.5–11 | `bodyMedium` / `bodySmall` + `inkSecondary` / cream tokens |
| Button label | ~11.5 / 600 | `AppTypography.buttonLabel` (15 / semiBold) |
| Tab label | ~7 | `labelSmall` (10) |
| Security note | ~7.5 | `BrandSecurityNote` (do not hand-roll) |
| Micro / step labels | ~7–8.5 | `labelSmall` / `bodySmall` |

**Section 02 note:** target deliberately renders verification type **smaller** than auth (fit tall artboards). We keep **one** logical type scale and let `BrandVerifyScreen` scroll when needed — do not reintroduce artboard type floors.

### 2.6 Color

Colors already align closely. Prefer these mappings (never paste hex in screens):

| Target `TzColors` | Current `context.colors` |
|---|---|
| `red` / `redDark` | `brandPrimary` / dark `actionPrimary` |
| `cream*` family | `brandSecondary`, `brandSecondaryBody`, `brandSecondarySmall`, `brandSecondaryNote`, `brandSecondaryPlaceholder` |
| `page` / `surface` / `ink` / `ink2` / `ink3` | `page` / `surface` / `ink` / `inkSecondary` / `inkTertiary` (or text* aliases) |
| `line` / `cardBorderSoft` | `line` / `cardBorderSoft` |
| `redTint` | `surfaceRedTint` / `redTint` |
| `ok*` / `wait*` / `verified*` | `statusSuccess*` / `statusWarning*` / `statusVerified*` (and pill helpers) |
| `paper*` | `paper`, `paperInk`, `paperInk2`, `paperLine` |
| Translucent whites on red | `brandFieldBackground`, `brandCardBackground`, `brandCodeBoxBackground`, `verification*` set |
| `buttonIdle*` | idle/disabled light CTAs via `AppButton` secondary / theme — avoid inventing new greys |

### 2.7 Buttons & fields

| Target | Current |
|---|---|
| `TzButton` / `TzVerifyButton` (white pill on red, grey off, 220ms fade) | `AppButton(variant: brandWhite, active: …)` |
| `TzOutlineButton` | `AppButton(variant: brandOutline)` |
| `TzAppButton` / `TzAppOutline` (light screens) | `AppButton(variant: primary|secondary)` |
| `TzField` (31-tall pill on red) | `BrandTextField` |
| Light forms / search | `AppTextField` / existing search field widgets |
| Keypad / passcode | Prefer extending profile passcode sheet to match `TzKeypad` aesthetics with tokens |

### 2.8 Motion

| Target | Current |
|---|---|
| Button grey→white fade 220ms | `AppMotion.buttonFade` (already on `AppButton`) |
| Passcode dot fill ~120ms | Use `AppMotion.fast` / short explicit duration via motion tokens if needed |
| No Material elevation / heavy ripples on brand CTAs | Brand variants already suppress splash where appropriate |

---

## 3. Semantic token mapping cheat sheet

### 3.1 Layout — pick by role

```
Target padding inside a card          → context.space.insetCard
Target padding inside a dense row     → context.space.insetCardCompact
Target red-screen outer pad           → context.space.insetBrandScreen
Target light-screen horizontal pad    → context.space.insetScreen
Target gap title→subtitle             → context.space.stackText
Target gap between form fields        → context.space.stackFormField
Target gap between major blocks       → context.space.stackSection
Target icon then label                → context.space.inlineIconLabel
Target primary button height          → sizes.controlLg (via AppButton)
Target tab / list icon                → sizes.iconSm / iconMd
Target card corner                    → shape.radiusSurface
Target pill button/field              → shape.radiusPill
Target sheet top corners              → shape.radiusOverlay
Target 1.5px selected ring            → shape.borderMedium
```

### 3.2 When no token fits

1. Confirm the element’s **role** (not the number).
2. Check comfortable vs compact — maybe an existing token already covers it.
3. If still missing: propose one name (`sizes.previewDocWidth`, etc.), add primitive → semantic → wire in theme, update `docs/design_tokens.md`, run `python3 scripts/verify_layout_tokens.py`.
4. **Do not** add one-off screen tokens (`homeHeroTop3`) or value tokens (`gap14`).

### 3.3 Token gaps worth knowing (rarely need new tokens)

| Situation | Recommendation |
|---|---|
| Target uses 13 vs 14 card radius | Both map to `radiusSurface` after polish |
| Target field height 31 design-px | Use `BrandTextField` / `controlXl` — do not add `fieldHeight31` |
| Target micro gaps 2–3 | `stackText` / `inlineMicro` |
| One-off SVG asset size | Prefer flex/`AspectRatio`/existing `previewDoc*` / `thumbPhoto*` sizes |
| Nested card radius | `shape.inner(outer, padding)` |

Prefer **Dart sources** over `design_tokens.md` if they disagree (`insetBrandScreen`, `radiusCard`, `radiusHeader`, etc. exist in code).

---

## 4. Architecture adaptation

### 4.1 What to keep from the current app

- **Riverpod** for all state (`ref.watch` / notifiers). Never port `AppState` / `ChangeNotifier`.
- **GoRouter** paths and `MainScaffold` shell tabs.
- **Feature folders** under `lib/features/<name>/presentation/...`.
- **Theme access:** `import '.../theme_extensions.dart'` → `context.colors|text|space|sizes|shape`.
- **Package imports only** (`package:trvlez_mobile/...`).
- **Quality gates:** `dart format`, `flutter analyze`, `scripts/verify_layout_tokens.py`, existing tests.

### 4.2 How to read a target screen and rewrite it

1. Open target screen + any `tz_*_parts.dart` helpers it uses.
2. Sketch the **structure**: scaffold type, header, scroll vs fit, foot CTA, sheets.
3. Map scaffold → `BrandScreen` / `BrandVerifyScreen` / `AppPinnedHeader` body.
4. Map each visual block → existing core/feature widget (§5).
5. Replace every `d()`/`ts()`/hex with tokens/roles.
6. Wire **existing** callbacks/providers — copy only layout/visual composition.
7. Run §6 checklist.

### 4.3 File placement conventions

| Target habit | Current habit |
|---|---|
| Logic + UI in one screen file | Screen thin; widgets in `presentation/widgets/`; state in `providers/` |
| Shared UI in giant `tz_*_parts.dart` | Shared in `lib/core/widgets/`; feature-only UI stays in feature |
| Inline decoration via `tzCard()` | `AppCard` or shared decoration using tokens |

### 4.4 Undrawn / derived screens

Target `docs/NEW_SCREENS.md` lists flows never formally designed (parts of booking, anywhere, disputes, etc.). For those: **reuse approved patterns** from the nearest sibling (same scaffold, spacing, buttons) — same rule the target used. Still map through our tokens/widgets.

---

## 5. Reusable components

### 5.1 Shell & brand (prefer these first)

| Current | Use for | Notes |
|---|---|---|
| `BrandScreen` | Auth red flows | Motif via `backgroundAsset`; pad `insetBrandScreen` |
| `BrandVerifyScreen` | Verification, check-in, anywhere, disputes | Title, back/close, foot, help line |
| `AppPinnedHeader` | Signed-in headers | Curved bottom (`radiusCard`), status-bar extension |
| `BrandWordmark` / `EzWord` / `EzText` | Wordmarks & “ez” brand mark | “ez” stays cream on red, red on light |
| `BrandSecurityNote` / `BrandAltLine` | Foot security + alt links | |
| `AppButton` | All CTAs | `brandWhite` / `brandOutline` on red; `primary`/`secondary` on light |
| `BrandTextField` / `AppTextField` | Forms on red / light | |
| `VerificationStepper` | KYC 4-step track | |
| `BrandInfoCard` / `BrandPointerPair` / `BrandShutter` | How-to cards, pointers, camera shutter | Square shutter = passport; round = selfie |
| `AppSegmentedControl` | Upcoming/Past, Saved segments | |
| `FindrCard` / `JoinFindrSheet` | Loyalty paper card + join | |
| `PhotoBox` / `HeartButton` / `StatusPill` | Lists, saved, bookings | |
| `AppCard` | Light bordered surfaces | Soft border + shadow via colors |
| `LoadingView` / `ErrorView` | Async states | Keep behavior; restyle only if needed |
| Check-in suite (`CheckIn*`) | Check-in visuals | Extend rather than duplicate |

### 5.2 Target → current quick map

| Target | Current |
|---|---|
| `TzRedScreen` / `TzScreen` | `BrandScreen` |
| `TzVerifyScreen` | `BrandVerifyScreen` |
| `TzAppScreen` / `TzAppBar` | `MainScaffold` + `AppPinnedHeader` |
| `TzButton` / `TzVerifyButton` | `AppButton.brandWhite` |
| `TzAppButton` | `AppButton.primary` |
| `TzField` | `BrandTextField` |
| `TzWordmark` / `TzEzWord` | `BrandWordmark` / `EzWord` |
| `TzSecurityNote` / `TzAltLine` | `BrandSecurityNote` / `BrandAltLine` |
| `VerificationStepper` | `VerificationStepper` |
| `TzFindrCard` | `FindrCard` |
| `TzSegmented` | `AppSegmentedControl` |
| `tzCard()` | `AppCard` or tokenized `BoxDecoration` |
| Capture / NFC / hourglass parts | Feature widgets + verify helpers (extend in place) |

### 5.3 Extend vs duplicate

- **Same visual, second screen** → extract or reuse core widget.
- **Slight variant** → add a named parameter / enum on the existing widget (e.g. shutter `square`).
- **Only one feature needs it** → `features/<x>/presentation/widgets/`, still tokenized.
- **Never** copy a target `tz_*_parts.dart` file wholesale.

---

## 6. Per-screen redesign checklist

Use this for every remaining screen in [`UI_REDESIGN_PLAN.md`](./UI_REDESIGN_PLAN.md).

### A. Before coding

- [ ] Identify target file(s) + artboard notes / KNOWN_DIFFERENCES relevant to the section.
- [ ] Confirm current screen path, providers, and routes (no API/nav changes planned).
- [ ] Choose scaffold: `BrandScreen` | `BrandVerifyScreen` | `AppPinnedHeader` + page bg.
- [ ] List reusable widgets you will use; note any gap (extend vs new feature widget).
- [ ] Skim a **completed** sibling (Login for red forms; Home for light lists) for patterns.

### B. Visual adaptation

- [ ] Replace layout with tokenized spacing/sizing/shape — **zero** raw layout numbers outside tokens.
- [ ] Replace typography with `context.text` / `AppTypography` + color tokens — **zero** raw `TextStyle(fontSize: …)` / hex.
- [ ] Match target hierarchy (header → body → foot), relative gaps, and CTA placement.
- [ ] Apply polish rules for light cards (soft border, soft shadow, `radiusSurface`).
- [ ] Ensure interactive targets ≥ 48×48 (`sizes.touchTargetMin`).
- [ ] Preserve SVG motifs with `BoxFit.cover` (crop, don’t stretch).

### C. Architecture / behavior

- [ ] Keep Riverpod notifiers, validation, and navigation callbacks unchanged.
- [ ] No new dependencies from the target app.
- [ ] Feature widgets stay under the feature; shared widgets only if reused ≥2 flows.
- [ ] Currency remains GBP where the product shows money.

### D. Verify

- [ ] `dart format` on touched files.
- [ ] `flutter analyze` clean for touched scope.
- [ ] `python3 scripts/verify_layout_tokens.py` (or project quality gate).
- [ ] Relevant `flutter test` for the feature.
- [ ] Manual: phone-sized viewport + large text scale (we support scaling; target clamps — **we do not clamp to 1.0**).
- [ ] Spot-check against target on device/emulator for proportions, not pixel-identical artboard numbers.

### E. Done criteria

- [ ] Looks like the target; reads like our codebase.
- [ ] Checklist in `UI_REDESIGN_PLAN.md` for that screen can be marked complete.
- [ ] No drive-by refactors outside the screen’s visual surface.

---

## 7. Worked patterns (do this, not that)

### 7.1 Red form screen (auth pattern — already done)

```dart
// ✅ Structure
BrandScreen(
  backgroundAsset: 'assets/art/bg_log_in.svg',
  body: Form(
    child: Column(
      children: [
        Text('…', style: context.text.headlineLarge?.copyWith(color: colors.brandOnSurface)),
        Text('…', style: context.text.bodyLarge?.copyWith(color: colors.brandSecondaryBody)),
        SizedBox(height: context.space.stackSection),
        BrandTextField(...),
        SizedBox(height: context.space.stackFormField),
        BrandTextField(...),
        const Spacer(), // or scroll layout
        BrandSecurityNote(text: '…'),
        AppButton(
          label: '…',
          variant: AppButtonVariant.brandWhite,
          active: isValid,
          onPressed: isValid ? onSubmit : null,
        ),
        BrandAltLine(...),
      ],
    ),
  ),
);

// ❌ Don’t
Padding(padding: EdgeInsets.all(19), …)           // design-px copy
TextStyle(fontSize: 15, color: Color(0xFFFFFFFF)) // target type + hex
// Don’t port ChangeNotifier login state from trvlez_app
```

### 7.2 Light list / hub card

```dart
// ✅
AppCard( // or Container with tokens
  child: Padding(
    padding: context.space.insetCard,
    child: Row(
      children: [
        PhotoBox(...),
        SizedBox(width: context.space.inlineItem),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.bodyMedium?.copyWith(color: colors.ink)),
            SizedBox(height: context.space.stackText),
            Text(subtitle, style: context.text.bodySmall?.copyWith(color: colors.inkSecondary)),
          ],
        )),
        StatusPill(...),
      ],
    ),
  ),
);

// ❌ BorderRadius.circular(14) + Color(0xFFE4E4E8) from the mock
```

### 7.3 Verification step card states

Map target locked / active / done to existing color tokens:

| State | Fill / border / text |
|---|---|
| Locked | subdued title/subtitle (`verificationCardLocked*`), icon fill `verificationCardIconFill` |
| Active (“now”) | `verificationCardActiveFill` + `borderMedium` white ring + chevron |
| Done | check treatment consistent with stepper / success greens |

Reserve two-line subtitle space so height doesn’t jump (target does this).

### 7.4 Bottom sheet

Use `shape.radiusOverlay` on the sheet container, `colors.surface`, handle with `sizes.indicatorDot` width bar, padding `insetDialog` or `insetCard`, keyboard insets via `viewInsets`. Follow redesigned `location_picker_sheet` / `notifications_sheet`.

### 7.5 Primary light CTA vs red CTA

| Surface | Variant |
|---|---|
| Red scaffold | `brandWhite` / `brandOutline` |
| Light scaffold | `primary` / `secondary` |
| Destructive | `destructive` (close account, etc.) |

---

## 8. Progress snapshot

**Already redesigned (use as references):** Welcome, Login, Registration, Forgot Password, Two-Step Code, New Password; MainScaffold tab bar; Home hub; location & notifications sheets.

**Remaining:** Verification (Phase 3), Account/settings (4), Properties & booking (5), Check-in (6), Findr & Saved (7), Anywhere & Disputes (8), Trips/reservations (9). See plan for file paths and per-screen notes.

---

## 9. Related references

| Doc / path | Use for |
|---|---|
| `docs/UI_REDESIGN_PLAN.md` | Screen order, acceptance notes per screen |
| `docs/design_tokens.md` | Token glossary (verify against Dart if unsure) |
| `.agents/rules/DESIGN_SYSTEM.md` | Token tier rules |
| `.agents/skills/flutter-semantic-layout-tokens/SKILL.md` | Naming grammar & anti-patterns |
| Target `docs/KNOWN_DIFFERENCES.md` | Approved departures from PNG/HTML |
| Target `docs/NEW_SCREENS.md` | Undrawn flows — derive, don’t invent |
| Target `lib/theme/tz_polish.dart` | Card/header polish constants |
| `scripts/verify_layout_tokens.py` | CI guard against raw layout literals |

---

## 10. Quick decision tree

```
Need a spacing/size/radius?
  → Does a semantic token with the right ROLE exist?
      Yes → use it
      No  → propose token (primitives → semantic) — never raw N

Need a color?
  → context.colors.* (brand / verification / paper / status)
      Missing → add to Palette + AppColors — never hex in the screen

Need a control?
  → Existing core widget?
      Yes → reuse / extend
      No  → feature widget with tokens; promote to core if second consumer appears

Target uses d(14) or ts(9.5)?
  → Ignore the literal; identify role; map via §2–§3
```

This document should be enough to redesign remaining screens without re-auditing both codebases. Update §8 checkboxes via the plan file as screens land; update this guide only when tokens, scaffolds, or mapping rules change.
