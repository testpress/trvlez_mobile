# Semantic Layout Design Tokens

This document details the layout, sizing, and shape token architecture used across `trvlez_mobile`.

## Architecture & Intent

Tokens are organized into three semantic categories implemented as Flutter `ThemeExtension`s and wired directly into `ThemeData`:
1. **`AppSpace` (`context.space.*`)**: Insets (`EdgeInsets`) and gaps (`double`).
2. **`AppSize` (`context.sizes.*`)**: Heights, widths, icons, touch targets, and component dimensions. Note: Accessed via `context.sizes.*` to avoid shadowing Flutter's `BuildContext.size`.
3. **`AppShape` (`context.shape.*`)**: Border radii (`BorderRadius`) and border stroke widths (`double`).

Primitives (`Prim.s4`, `Prim.s8`, `Prim.s16`, `Prim.r12`, etc.) remain private inside `lib/core/design_tokens/primitives.dart`. Presentation code and widgets access recurring spacing, sizing, shape, colour, and typography roles through `BuildContext`; documented component-private constants, framework constraints, and aspect ratios follow the nuanced dimension policy in `docs/engineering/playbook/04-design-system-and-reference-intake.md`.

---

## Token Glossary: Which Token For What

### 1. Spacing (`context.space.*`)

#### Insets (returns `EdgeInsets`)
| Token | Default Value | Semantic Role / Intent |
|---|---|---|
| `space.insetScreen` | `h: 16, v: 16` | Standard screen margin / edge-to-edge content inset |
| `space.insetCard` | `all: 16` | Standard card internal padding |
| `space.insetCardComfortable` | `all: 20` | Generous card internal padding |
| `space.insetCardCompact` | `all: 12` | Dense / compact card padding |
| `space.insetDialog` | `all: 24` | Modal dialog / alert container padding |
| `space.insetControlSm` | `h: 12, v: 8` | Small button or interactive chip padding |
| `space.insetControlMd` | `h: 16, v: 12` | Medium button padding |
| `space.insetControlLg` | `h: 24, v: 16` | Primary action button padding |
| `space.insetInput` | `h: 16, v: 14` | Text field / form control content padding |
| `space.insetTag` | `h: 8, v: 4` | Metadata badge / status tag padding |
| `space.insetTagSm` | `h: 6, v: 2` | Micro tag / compact status badge padding |

#### Stack Gaps (vertical spacing, returns `double`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `space.stackText` | `4.0` | Gap between title and subtitle, or closely paired text |
| `space.stackTight` | `6.0` | Tight vertical gap between related elements |
| `space.stackItem` | `8.0` | Gap between list items, chips, or related rows |
| `space.stackFormField` | `16.0` | Gap between adjacent form fields or input blocks |
| `space.stackSection` | `24.0` | Major content section separator |
| `space.stackHero` | `32.0` | Gap separating hero visual / header from body |
| `space.stackPageBottom` | `48.0` | Bottom-of-page scrolling clearance |

#### Inline Gaps (horizontal spacing, returns `double`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `space.inlineMicro` | `4.0` | Micro inline separation |
| `space.inlineIconLabel` | `8.0` | Standard spacing between an icon and its text label |
| `space.inlineButtonGroup` | `12.0` | Spacing between buttons in a segmented control or action bar |
| `space.inlineItem` | `16.0` | Horizontal spacing between distinct items in a row |
| `space.gutterGrid` | `16.0` | Column gutter for grid layouts |

---

### 2. Sizing (`context.sizes.*`)

#### Icons (returns `double`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `sizes.iconXs` | `14.0` | Inline metadata / rating star icon |
| `sizes.iconSm` | `18.0` | App bar action / chip icon |
| `sizes.iconMd` | `20.0` | List tile leading icon |
| `sizes.iconDefault` | `24.0` | Standard navigation bar / action icon |
| `sizes.iconLg` | `28.0` | Feature icon in cards |
| `sizes.iconXl` | `32.0` | Medium empty-state / circular badge icon |
| `sizes.iconFeature` | `40.0` | Highlighted feature icon |
| `sizes.iconHero` | `48.0` | Prominent status / completion hero icon |

#### Controls & Indicators (returns `double`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `sizes.controlSm` | `36.0` | Small action button / compact filter height |
| `sizes.controlMd` | `44.0` | Secondary button / list tile control height |
| `sizes.controlLg` | `48.0` | Standard primary button height |
| `sizes.controlXl` | `56.0` | Large CTA button / text field height |
| `sizes.touchTargetMin` | `48.0` | Minimum touch target dimension (WCAG AAA) |
| `sizes.avatarSm` | `28.0` | Compact user avatar |
| `sizes.avatarMd` | `36.0` | Medium user avatar |
| `sizes.avatarLg` | `48.0` | Large profile avatar |
| `sizes.avatarXl` | `80.0` | Profile hero avatar |
| `sizes.indicatorDot` | `8.0` | Stepper / carousel indicator dot diameter |
| `sizes.indicatorProgressHeight`| `4.0` | Linear progress bar height |
| `sizes.pulseIndicator` | `64.0` | Concentric NFC / scanner pulsing core |
| `sizes.appBarHeight` | `56.0` | Custom app bar height |
| `sizes.thumbPhotoSm` | `80.0` | Small photo thumbnail |
| `sizes.thumbPhotoMd` | `120.0`| Medium photo thumbnail / visual placeholder |
| `sizes.thumbPhotoLg` | `160.0`| Large photo thumbnail |
| `sizes.cardWidthCarousel` | `220.0`| Horizontal carousel card width |

---

### 3. Shape (`context.shape.*`)

#### Border Radii (returns `BorderRadius`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `shape.radiusMicro` | `2.0` | Hairline tags, progress bars |
| `shape.radiusSubtle` | `4.0` | Inner focus indicators, compact badges |
| `shape.radiusControlSm`| `8.0` | Small buttons, chip selectors, thumbnail corners |
| `shape.radiusControl` | `12.0`| Standard buttons, text fields, small cards |
| `shape.radiusSurface` | `16.0`| Standard property cards, modal dialogs |
| `shape.radiusOverlay` | `20.0`| Bottom sheets, large floating surfaces |
| `shape.radiusPill` | `9999.0`| Status pills, circular avatars, search bars |

*Note: For asymmetric / directional corners, access corner values directly: `shape.radiusSurface.topLeft`.*

#### Borders & Dividers (returns `double`)
| Token | Value | Semantic Role / Intent |
|---|---|---|
| `shape.borderHairline` | `0.5` | Subtle borders, light dividers |
| `shape.borderDefault` | `1.0` | Standard card / control outlines |
| `shape.borderMedium` | `1.5` | Selected / active card borders |
| `shape.borderFocus` | `2.0` | Accessibility focus rings, prominent borders |
| `shape.dividerDefault` | `1.0` | List separators, card dividers |

---

## Naming Grammar & Rules

1. **Named by structural role, never by raw value**:
   - ✅ `space.stackFormField`
   - ❌ `space.space16` or `space.gap16`
2. **Category separation**:
   - Insets (`EdgeInsets`): `space.inset*`
   - Vertical gaps (`double`): `space.stack*`
   - Horizontal gaps (`double`): `space.inline*`
   - Radii (`BorderRadius`): `shape.radius*`
   - Dimensions (`double`): `sizes.*`
3. **Allowed raw values**:
   - `0` / `0.0` / `EdgeInsets.zero` / `BorderRadius.zero` / `SizedBox.shrink()`
   - `double.infinity`
   - Fractional layout values (`Expanded(flex:)`, `widthFactor`)

---

## How to Request or Add a New Token

If no existing token captures your layout intent:
1. **Never fall back to a raw number or generic size name.**
2. Propose a semantic token following the naming grammar (e.g. `sizes.cardWidthCompact`).
3. Add the token to the appropriate class in `lib/core/design_tokens/` (`space_tokens.dart`, `size_tokens.dart`, or `shape_tokens.dart`).
4. Wire the value from private primitives in `lib/core/design_tokens/primitives.dart`.
5. Run the CI token verification script:
   ```bash
   python3 scripts/verify_layout_tokens.py
   ```
