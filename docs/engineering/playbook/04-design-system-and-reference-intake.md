# Design system and reference intake

Use the current theme, `ThemeExtension` tokens, component themes, and [design token glossary](../../design_tokens.md) as implementation vocabulary. The client reference determines visual intent; tokens provide reusable implementation contracts.

## Intake before implementation

Version or explicitly approve each HTML/CSS, image, Figma export, or screen capture used as a reference. Record source, revision/date, target state, viewport, assets, and known unknowns. A browser CSS pixel value is an input to interpret, not a value to mechanically copy into every Flutter widget.

Extract hierarchy, spacing relationships, typography roles, colour/state semantics, image crop/aspect ratio, and responsive behaviour. Confirm dynamic states and content length rather than treating a static artboard as exhaustive.

## Token decisions

Use semantic space/size/shape/typography tokens when the value represents a repeated design role. Add a token when it has a stable name and more than one credible consumer. Keep an intentional component-private value close to the component when it does not represent a cross-product role.

Do not create a token solely to silence a raw-number check. Do not use a viewport formula to simulate a missing token. Token additions require a name, purpose, examples, affected themes, and validation at supported text scales.

## Theme ownership

Global Material and component themes own consistent defaults. Feature screens compose those defaults and may supply documented variants. A screen must not recreate typography, colour, shape, or control semantics that an existing component/theme already owns without a reference-driven reason.

