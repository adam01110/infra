# Color

## Accessible color

Don't use color alone to show that a UI component exists or what state it is in, and don't mark success or errors with color only. Add an icon, text or shape so the meaning survives without color (WCAG 1.4.1 Use of Color).

```html
<!-- State shown with an icon and text, not color alone. -->
<div class="error-msg">
  <span aria-hidden="true">❌</span>
  <span>The password entered was invalid.</span>
</div>
```

### Contrast

- Text needs at least 4.5:1 contrast for normal text and 3:1 for large text (at least 24px, or at least 18.66px bold). Icons need 3:1. (WCAG 1.4.3 Contrast (Minimum) for text, WCAG 1.4.11 Non-text Contrast for icons.)
- UI component boundaries and states need at least 3:1 contrast (WCAG 1.4.11 Non-text Contrast). This covers:
  - visual elements that form a component's boundary or show that it exists (borders, backgrounds, box-shadows, underlines), such as input field borders;
  - visual elements that show an active state inside a component, such as checkbox checkmarks, switch thumbs or custom focus indicators.
- 3:1 non-text contrast can be hard to reconcile with minimal designs. Soft gradients or subtle inset/outset shadows can soften visual boundaries while still meeting the requirement.
- Use `@media (prefers-contrast: more)` only when the design has low-contrast accents (subtle borders, muted secondary text) that need reinforcing; most sites that already meet the minimums don't need it. It can strengthen colors that already pass, but it cannot fix a default that fails, because it reaches only users who have turned the setting on.

### Light and dark color schemes

Support both schemes: honor `@media (prefers-color-scheme: dark)` and pair it with the `color-scheme` property so form controls, scrollbars and other UA-rendered surfaces match. The `dark-mode` guide has the details.

### Forced Colors Mode

- In Forced Colors Mode (High Contrast on Windows), the browser replaces author colors with system color keywords, removes `box-shadow`, `text-shadow` and gradient backgrounds, and may remove `border-image`. `url()` background images can't be relied on either: they may be removed, or kept in their own colors, which may not contrast with the system colors. Define system-color fallbacks for your color tokens in `@media (forced-colors: active)`.
- Use `forced-color-adjust: none` only where color is essential information, such as a syntax highlighter or a color-picker swatch, not to preserve aesthetics. If the element contains text, set both its text and background colors to a pair that meets the minimums above. A transparent background shows whatever is behind it, usually the user's system `Canvas` color, which can be light or dark.
- Don't rely on `background-image`, `box-shadow` or `border-image` to convey borders, separators or state. In forced colors they disappear or keep their own colors, which may not contrast with the system colors, and they often disappear in print too. If you do use them, provide an alternative in forced colors mode, such as `outline` or `border` with system color keywords (`CanvasText`, `LinkText`, `ButtonText`, `Highlight`, `GrayText`, etc.).

## Generating tints

Before generating tints dynamically, check whether an existing design token fits. Predefined tokens give designers more control and keep the palette consistent.

To generate lighter or darker colors dynamically:

- Don't only change the lightness channel in `oklch`/`oklab` or `lch`/`lab`, as in `oklab(from var(--primary) 0.9 a b)`. That is correct in theory, but browsers don't implement gamut mapping yet, so the result is unpredictable.
- `color-mix()` with white or black keeps the color in gamut, though it tends to over-desaturate and produce washed-out tints and shades. Mix `in oklab` unless you have a reason to use another space. Never mix `in oklch` with neutrals: it brings no benefit there, and a Chromium bug (565837690) treats low-chroma colors (`chroma < 0.02`) as having a powerless hue that resolves to `0deg` (magenta-red), which gives an unintended reddish or pink tint.
- You can combine a lightness adjustment with mixing for a balance between the two, for example `color-mix(in oklab, oklch(from var(--primary) 0.9 c h), white 30%)`. Keep that adjustment at 30% or less, as with the `white 30%` share in the example.
