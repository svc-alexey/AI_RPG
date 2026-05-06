# DESIGN.md — AI RPG Design System

## Brand

Aether — тёмное фэнтези с тёплым медным акцентом. Визуальные атрибуты: приглушённый огонь, древний пергамент, кованый металл. Никакого холода, синевы, sci-fi.

## Color Palette (AetherPalette)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0A0908` | Scaffold background |
| `backgroundElevated` | `#0F0D0B` | Card fill, dialog background |
| `backgroundTop` | `#141210` | AppBar, top surfaces |
| `panel` | `#12100E` | Navigation panels |
| `panelSoft` | `#1A1816` | Chip fill, disabled button |
| `panelBorderSolid` | `#1A1816` | Card border, divider |
| `accent` | `#C87941` | Primary buttons, active elements, hero numbers |
| `accentHover` | `#D4956A` | Button hover, link hover |
| `accentSoft` | `#C879411F` (~12% alpha) | Selected chip, subtle accent bg |
| `gold` | `#BFA76F` | Sale badges, premium indicators, secondary accent |
| `textPrimary` | `#E8E4E0` | Body text, headings |
| `textMuted` | `#7A7570` | Secondary text, descriptions |
| `textDim` | `#6B6660` | Tertiary text, captions, legal |
| `narrativeText` | `#C8C4C0` | Story content, flavour text |
| `success` | `#34D399` | Success status, completed transactions |
| `error` | `#FFB4AB` | Error states, failed transactions |

## Typography

| Token | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| `displayLarge` | Playfair Display | 72px | 300 | Hero numbers (balance) |
| `displayMedium` | Playfair Display | 58px | 300 | Section heroes |
| `headlineLarge` | Playfair Display | 50px | 400 | Page titles |
| `headlineMedium` | Playfair Display | 42px | 400 | Card headlines |
| `headlineSmall` | Playfair Display | 30px | 500 | Prices, featured numbers |
| `titleLarge` | Inter | 18px | 600 | Plan names, section headers |
| `titleMedium` | Inter | 16px | 600 | Card titles, button text |
| `bodyLarge` | Inter | 15px | 400 | Primary body text |
| `bodyMedium` | Inter | 14px | 400 | Secondary text, descriptions |
| `bodySmall` | Inter | 12px | 400 | Captions, dates, legal |
| `labelLarge` | Inter | 14px | 600 | Button labels, chips |

## Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Icon-text gap |
| `sm` | 8px | Card internal padding |
| `md` | 12px | List item gap |
| `lg` | 16px | Section padding, card gap |
| `xl` | 20px | Large section padding |
| `xxl` | 24px | Screen horizontal padding |
| `block` | 24px | Section vertical gap |

## Component Tokens

### Cards
- `CardTheme`: border-radius 16px, fill `backgroundElevated`, no elevation, border `panelBorderSolid` at 0.9 alpha
- Featured card: border `accent` 1.5px, boxShadow `accent` at 15% opacity, blur 40px
- Minimal card: transparent fill, dashed border `textDim` at 30% alpha

### Buttons
- `FilledButton`: accent fill, text `background`, 52px min height, border-radius 12px
- `OutlinedButton`: transparent fill, border `panelBorderSolid`, text `textPrimary`, 52px min height
- `TextButton`: no fill, no border, text `accentHover`
- Disabled state: `panelSoft` fill, `textDim` text

### Chips
- border-radius 999px (pill), fill `backgroundElevated`, selected fill `accentSoft`

### Inputs
- border-radius 12px, fill `backgroundElevated`, border `panelBorderSolid`
- Focused: border `accent` 1.2px

## Motion

- Page transitions: fade + slide-up, 200-300ms
- List items: staggered fade-in, 100-200ms per item, bottom→top
- Number counters: animated count-up, 800ms for large values
- Button press: scale 0.97, 100ms
- Loading: shimmer (NOT circular spinner in center)
- Success: brief green glow on card border, 400ms

## Anti-Patterns (DO NOT USE)

- Purple/violet/indigo backgrounds or blue gradients
- 3-column icon+title+description grids (SaaS template)
- Centered text on everything
- Uniform card grids without visual hierarchy
- Emoji as design elements
- Colored left-borders on cards
- `system-ui` or `-apple-system` font stacks
- Generic copy ("Welcome to X", "Unlock the power of...")
- Placeholder-as-label pattern in forms
