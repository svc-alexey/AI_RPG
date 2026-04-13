# Design System Document: Cinematic Narrative RPG

## 1. Overview & Creative North Star
### Creative North Star: "The Ethereal Archivist"
This design system is not a mere interface; it is a gateway into a collaborative storytelling experience. It rejects the "app-like" utility of modern SaaS in favor of a **High-End Editorial** aesthetic. By combining the gravitas of a leather-bound tome with the sleek translucency of a futuristic HUD, the system creates a "Cinematic Narrative" atmosphere.

The layout intentionally breaks from rigid, centered grids to embrace **intentional asymmetry** and **atmospheric depth**. We move beyond the "template" look by using overlapping imagery, extreme typographic contrast, and a "smoke and mirrors" approach to depth that favors tonal shifts over structural borders.

---

## 2. Colors
The palette is rooted in deep, earthy shadows and illuminated by "ancient gold" light sources.

- **Primary & Secondary (The Glow):** Use `primary` (#f2ca50) and `secondary` (#e9c176) sparingly to represent interaction and importance. They should feel like light reflecting off metallic gold.
- **Surface Hierarchy (The Void):** 
    - **Base:** `surface` (#151311) is our true dark.
    - **Nesting:** To define sections, use `surface-container-low` (#1d1b19) for large content areas and `surface-container-high` (#2c2927) for interactive elements like cards or input fields.
- **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined by background color shifts or the "Ghost Border" fallback.
- **The Glass & Gradient Rule:** High-importance overlays (like the RPG story cards) should use `surface-container` tiers at 60-80% opacity with a `backdrop-blur` of 20px+. Apply a subtle linear gradient from `primary` to `primary-container` on high-level CTAs to add "soul" to the action.

---

## 3. Typography
The system uses a high-contrast serif/sans-serif pairing to evoke an editorial, narrative feel.

- **Display & Headline (Newsreader):** The serif choice is our "Voice." Large `display-lg` titles should feel authoritative and cinematic. Use wide tracking (letter-spacing) for `headline-sm` to create a "premium label" effect.
- **Body & Labels (Manrope):** The sans-serif is our "Translator." It must remain ultra-legible against dark backgrounds. Use `body-md` for standard narrative text and `label-md` for metadata (e.g., "AI Master" or "12.5K Likes").
- **Intentional Contrast:** Pair a `display-md` title in `on-surface` with a small `label-sm` subtitle in `primary` (Gold) to immediately establish a high-end hierarchy.

---

## 4. Elevation & Depth
In a cinematic interface, depth is felt, not seen through lines.

- **Tonal Layering:** Achieve hierarchy by "stacking." A `surface-container-highest` card sitting on a `surface-dim` background creates a natural elevation that feels integrated into the atmosphere.
- **Ambient Shadows:** For floating elements, use extremely diffused shadows. 
    - *Formula:* `0px 20px 50px rgba(0, 0, 0, 0.5)`. 
    - Avoid hard black shadows; they break the immersion.
- **The "Ghost Border" Fallback:** If accessibility requires a stroke, use `outline-variant` (#4d4635) at 20% opacity. It should appear as a faint glimmer of light on an edge, not a container line.
- **Glassmorphism:** Use semi-transparent `surface-variant` with heavy blur to allow background imagery (nebulae, forests) to bleed through, ensuring the UI feels like a lens over the world.

---

## 5. Components

### Buttons
- **Primary:** Solid `primary` (#f2ca50) background with `on-primary` (#3c2f00) text. Corner radius: `md` (0.375rem). Use a subtle inner glow (top border 1px, 20% white) to mimic a physical button.
- **Secondary (The RPG Border):** No background. `outline` (#99907c) border at 40% opacity. Text in `on-surface`.
- **Tertiary:** Text-only in `secondary`, with a small icon (e.g., an arrow or chevron).

### Cards & Narrative Containers
- **The Narrative Card:** Forbid divider lines. Use `surface-container-high` as a base. If the card contains imagery, the text should sit on a `surface-container-lowest` translucent bar at the bottom to ensure legibility.
- **Overlapping Elements:** Suggest placing a `headline-sm` title so it slightly overlaps the edge of a card's image to break the "boxed" feel.

### Input Fields
- **Atmospheric Input:** `surface-container-lowest` background with a `Ghost Border`. Focus state should transition the border to `primary` (#f2ca50) at 50% opacity and add a faint outer `primary` glow.

### Additional: Narrative Chips
- Use `secondary-container` (#604403) for genre or tag chips. They should have a `sm` (0.125rem) radius to feel more "chiseled" and less "pill-shaped" than standard mobile UI.

---

## 6. Do's and Don'ts

### Do:
- **Do** use negative space aggressively. Let the "Deep Charcoal" breathe to create a sense of mystery.
- **Do** use imagery as a functional layer. High-quality sci-fi/fantasy art should bleed behind UI elements.
- **Do** use `Newsreader` for any text that is part of the "story," and `Manrope` for any text that is part of the "tool."

### Don't:
- **Don't** use 100% white (#ffffff). Use `on-surface` (#e8e1dd) to prevent "eye-sear" on dark backgrounds.
- **Don't** use standard "Material" shadows. If it looks like a card on a flat table, it’s wrong. It should look like a projection or a page.
- **Don't** use dividers. If two pieces of content feel too close, increase the spacing scale rather than adding a line.
- **Don't** use fully rounded (pill) buttons for primary actions; stay within the `md` to `lg` roundedness scale to maintain a "serious" tone.