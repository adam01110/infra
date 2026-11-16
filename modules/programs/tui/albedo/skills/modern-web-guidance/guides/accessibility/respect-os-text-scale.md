# Respect operating system text scale

Users with low vision often set text scaling in the operating system (Dynamic Type on iOS, font size scaling on Android and ChromeOS). Mobile browsers ignore these settings by default so that legacy fixed-pixel sites do not break. A page can opt in with `<meta name="text-scale">`: the browser then scales the root font size (`1rem`) to the user's OS preference, and every `rem`- and `em`-based size, layout and spacing scales with it. Use this instead of custom JavaScript layout calculations, which are fragile.

## 1. Opt in to OS text scaling

Put the meta element in the `<head>`. It tells supporting browsers the layout is adaptive and safe to scale:

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width" />
  <meta name="text-scale" content="scale" />
  <title>Adaptive Accessibility Layout</title>
</head>
```

## 2. Use relative typography and spacing

Size fonts in `rem` or `em`, not `px`. Give line heights unitless values so they scale with each element's computed font size.

Use relative units for margins and padding that are coupled to text size or must adapt as text scales. Spacing independent of text may use fixed units, as long as scaling causes no clipping, overlap, lost content or unusable layout.

```css
body {
  /* No font-size: inherits the root size, which follows the OS setting. */
  font-family: system-ui, sans-serif;
  line-height: 1.5;
  padding: 1.5rem; /* Grows with text so large scales don't crowd. */
}

h1 {
  font-size: 2.25rem;
  margin-bottom: 1rem;
}
```

Set a base text size on `body` only when the design needs one different from the inherited browser default. Size specific elements, such as headings, in relative units: `rem` for a size relative to the root, `em` for a size relative to the parent's font size. Do not set a font size on `:root` or `html` (see section 5).

### Fluid typography

Fluid type may use viewport units such as `vw` only together with a font-relative component (`rem` or `em`). A size in viewport units alone does not fully respond to user text scaling:

```css
/* Wrong: does not fully respond to user text scaling */
.heading {
  font-size: 5vw;
}
```

Combine a font-relative value with viewport scaling, and use relative minimum and maximum bounds:

```css
.heading {
  font-size: clamp(2rem, 1.25rem + 2vw, 4rem);
}
```

The `fluid-scaling` guide covers more techniques, including container query units and `clamp()`.

Test that text resizes to at least 200% without loss of content or functionality. For fluid type, a useful rule of thumb is a maximum font size no more than 2.5 times the minimum. Also test reflow at a 320 CSS pixel viewport width (400% zoom of a 1280 CSS pixel viewport): content must stay available without two-dimensional scrolling, except where that is essential.

## 3. Use breakpoints that scale

Responsive breakpoints must not assume text stays at its default size. Where a breakpoint responds to the space available for text, prefer content-driven layouts, container queries or `em`-based media queries over fixed pixel thresholds.

Test layouts with OS text scaling and browser zoom enabled. Text must stay readable and content visible, with no overlap, clipping or horizontal scrolling.

## 4. Let content wrap and heights grow

Scaled text needs more space in both directions, so let layouts expand around content instead of fixing coordinates:

- Text containers must be able to grow. Avoid fixed `height` or `block-size` and restrictive `max-height` or `max-block-size`, which cause clipping or overflow. Prefer content-driven sizing, and use `min-height` or `min-block-size` only where a minimum is needed.
- Do not put `white-space: nowrap` on blocks that contain sentences; let text reflow onto new lines.
- Let flexbox and grid layouts wrap. For multi-column galleries, for example, use reflowing columns such as `grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr))`, so items stack when their relative width threshold is crossed.

```css
.card {
  padding: 1.5rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  /* min-height, not height, so the card grows with enlarged text. */
  min-height: 10rem;
}
```

## 5. Leave the root font size to the browser

With the `<meta name="text-scale" content="scale">` opt-in, do not set the root `font-size` in your stylesheet, on either `:root` or `html`, in absolute units, relative units or calculated values. An explicit root size can stop the browser applying text scaling:

```css
/* Wrong: can prevent text scaling */
html {
  font-size: 16px;
}
```

Do not also apply the OS scale manually with `env(preferred-text-scale)`. The meta opt-in already applies it, so doing both can scale text twice:

```css
/* Wrong: double-scales on top of the meta opt-in */
:root {
  font-size: calc(1rem * env(preferred-text-scale));
}
```

The browser applies the OS text scale itself to everything sized relative to the root font size.

## Fallback strategies

Browser support for `<meta name="text-scale">`: Limited availability.
Supported by Chrome 146 (Mar 2026) and Edge 146 (Mar 2026). Unsupported in Firefox and Safari.

Where it is unsupported, the layout degrades gracefully: the page uses the browser's default base font size (typically 16px), and users can still use page zoom or pinch-to-zoom.
