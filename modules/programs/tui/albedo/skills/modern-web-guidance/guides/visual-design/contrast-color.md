# Ensure text readability with dynamic background colors

In reusable components (badges, buttons, headers, footers) and customizable themes, text has to stay readable against a background color that varies. The `contrast-color()` CSS function resolves to `black` (`rgb(0, 0, 0)`) or `white` (`rgb(255, 255, 255)`), whichever gives the higher contrast ratio against the solid `<color>` you pass it (targeting at least 4.5:1, WCAG AA).

## Determine the text color

When an element's background color is variable or injected at runtime, let the browser compute the text color: set `color` with `contrast-color()`, passing the background color or its custom property.

```css
.badge {
  --badge-bg: #e02424;
  background-color: var(--badge-bg);
  color: contrast-color(var(--badge-bg));
}
```

Use `contrast-color()` for foreground colors (text, borders) that must contrast with a given background, not for `background-color`.

## Integrate with theming

`contrast-color()` accepts any valid `<color>`, including custom properties, which makes it useful in design systems. When background themes live in shared variables and `contrast-color()` references them, foreground content updates its contrast whenever the theme changes, including to user-chosen colors.

```css
.theme-card {
  background-color: var(--theme-surface-color);
  color: contrast-color(var(--theme-surface-color));
}

.theme-container[data-theme="light"] {
  --theme-surface-color: #f4f4f4;
}
.theme-container[data-theme="dark"] {
  --theme-surface-color: #1a1a1a;
}
.theme-container[data-theme="custom"] {
  --theme-surface-color: var(--user-custom-theme);
}
```

Don't hard-code a separate text color for each interaction state when the background is dynamic; that reintroduces the mismatch `contrast-color()` prevents.

## Fallback strategies

Baseline status for contrast-color(): Newly available. It's been Baseline since 2026-04-10.
Supported by: Chrome 147 (Apr 2026), Edge 147 (Apr 2026), Firefox 146 (Dec 2025), and Safari 26 (Sep 2025).

Browsers without `contrast-color()` need a fallback. If the background color is known and fixed, hard-code a contrasting color. For variable backgrounds (such as theme custom properties whose runtime value is unknown), pick one of these five strategies according to your design and browser-support targets:

| Strategy | Best for | Considerations |
| :--- | :--- | :--- |
| Calculate contrast with `color(xyz)` | Automated CSS-only contrast calculation that meets WCAG 1.4.3 Contrast (Minimum). | Highest-quality CSS-only fallback. |
| Text shadow | A quick readability boost on any background. | Can look dirty or glowy; may not suit every design. |
| Text stroke | Keeping edge contrast while preserving font weight. | Use `paint-order`, where available, to avoid thinning letterforms. |
| Translucent overlay | Guaranteeing a minimum-contrast area behind the text. | Changes how the background looks under the text; needs a separate text element. |
| SVG filters | Contrast that reacts as the background changes. | Needs a separate text element; hacky implementation. |

### Recommended: calculate contrast with `color(xyz)`

To meet WCAG 1.4.3 Contrast (Minimum), compute the contrasting color with relative color syntax in the CIE XYZ D65 color space, whose `y` value is relative luminance. `white` is `color(xyz 0.9505 1 1.089)`, the D65 white point.

Baseline status for Relative colors: Newly available. It's been Baseline since 2024-09-16.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), Firefox 128 (Jul 2024), and Safari 18 (Sep 2024).

```css
/* Declare these on the same element that sets --color (here, the background color). */
.badge {
  --color: var(--badge-bg);
  background-color: var(--color);
  --wcag-y-threshold: 0.17913;
  --y: max(0, sign(var(--wcag-y-threshold) - y));
  color: color(from var(--color) xyz-d65 calc(var(--y) * 0.9505) var(--y) calc(var(--y) * 1.089));
}
```

### Other CSS fallbacks

If relative color syntax isn't supported or isn't enough, choose the option that best fits your design constraints.

#### Option 1: text stroke

Baseline status for Text stroke and fill (compatibility prefixes): Widely available. It's been Baseline since 2017-04-05.
Supported by: Chrome 4 (Jan 2010), Edge 15 (Apr 2017), Firefox 49 (Sep 2016), Safari 3 (Oct 2007), and Safari iOS 2 (Jul 2008).

```css
.badge--stroke {
  -webkit-text-stroke: 4px black;
}
```

#### Option 2: text stroke with `paint-order` to preserve letterforms

Baseline status for paint-order: Widely available. It's been Baseline since 2024-03-22.
Supported by: Chrome 123 (Mar 2024), Edge 123 (Mar 2024), Firefox ≤66, and Safari ≤12.

```css
.badge--stroke {
  -webkit-text-stroke: 4px black;
  paint-order: stroke fill;
}
```

#### Option 3: translucent background overlay

```css
.badge--overlay {
  position: relative;
  color: #fff;
  overflow: hidden;
}
.badge--overlay::before {
  content: "";
  position: absolute;
  inset: 0;
  background-color: rgb(0 0 0 / 0.4);
  z-index: 0;
}
.badge--overlay span {
  position: relative;
  z-index: 1;
}
```

#### Option 4: text shadow

```css
.badge--shadow {
  text-shadow: 0 1px 3px rgb(0 0 0 / 0.8);
}
```

#### Option 5: SVG filters

Baseline status for SVG filters: Widely available. It's been Baseline since 2015-07-29.
Supported by: Chrome 5 (May 2010), Edge 12 (Jul 2015), Firefox 3 (Jun 2008), and Safari 6 (Jul 2012).

1. Load this SVG filter definition. If you support Safari versions affected by [this WebKit bug](https://bugs.webkit.org/show_bug.cgi?id=320118), which blocks external and data-URL filter references, put it directly in the HTML document. Otherwise load it from an external file, either an SVG file or inlined in CSS.

```html
<!-- Technique from https://miunau.com/posts/dynamic-text-contrast-in-css/ -->
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="0" style="display: none;">
  <defs>
    <filter id="contrast-filter" color-interpolation-filters="sRGB">
      <feColorMatrix type="matrix"
        values="0.2126 0.7152 0.0722 0 0
          0.2126 0.7152 0.0722 0 0
          0.2126 0.7152 0.0722 0 0
          0 0 0 1 0"/>
      <feMorphology operator="dilate" radius="2"/>
      <feComponentTransfer>
        <feFuncR type="linear" slope="-255" intercept="128"/>
        <feFuncG type="linear" slope="-255" intercept="128"/>
        <feFuncB type="linear" slope="-255" intercept="128"/>
      </feComponentTransfer>
      <feComposite operator="in" in2="SourceGraphic"/>
    </filter>
  </defs>
</svg>
```

2. Wrap the text in a `<span>`:

```html
<div class="badge--svg">
  <span>Badge content</span>
</div>
```

3. Apply the filter to the `<span>`:

```css
.badge--svg span {
  color: var(--badge-bg);
  filter: url(#contrast-filter);
}
```
