# Dark mode

The `color-scheme` property declares which color schemes (such as light and dark) a page supports. The browser then themes native UI such as scrollbars, form controls and the default canvas background to match, which also helps reduce white flashes during initial loading.

## Implementation

### 1. Declare supported schemes in HTML

Put a `<meta>` tag in the `<head>` so the browser knows the supported schemes before it starts rendering. It sets the initial canvas color early, which reduces the flash of unthemed content, though it may not remove the flash in every browser or loading condition.

```html
<meta name="color-scheme" content="light dark">
```

### 2. Set the page-wide color scheme on `:root` or `html`

Apply `color-scheme` to the `html` element or `:root`. Browsers use the root element to theme the whole viewport, including the root scrollbars and the initial canvas background. Set only on `body`, these surfaces may stay light, because `body` doesn't control the window's rendering.

```css
:root {
  /* Native UI follows the user's system preference. */
  color-scheme: light dark;
}
```

### 3. Define light and dark color tokens

The `light-dark()` function defines color tokens that adapt to the element's computed `color-scheme`, without separate media queries. Keep the raw color values in their own custom properties as well; they are then easier to combine in different ways and to use in fallbacks.

`light-dark()` and custom properties can also give built-in UI, such as `accent-color` or `scrollbar-color`, your own adaptive colors. This is optional; a basic implementation doesn't need it.

```css
:root {
  --color-brand-light: oklch(45% 0.23 270);
  --color-brand-dark: oklch(85% 0.15 210);
  --color-brand-text-light: white;
  --color-brand-text-dark: oklch(40% 0.23 270);

  --color-brand: light-dark(var(--color-brand-light), var(--color-brand-dark));
  --color-brand-text: light-dark(var(--color-brand-text-light), var(--color-brand-text-dark));

  color-scheme: light dark;
}

button.primary {
  /* Both adapt to the color scheme. */
  background-color: var(--color-brand);
  color: var(--color-brand-text);
}
```

System colors such as `canvas`, `canvastext`, `accentcolor` (check support) and `buttonborder` also adapt to the used color scheme and to other color modes, such as forced colors. They are usually too limited to be useful, except where you must match specific default browser UI exactly or need fallbacks and defaults.

#### Optional: tailor color pairs to context

Even when the page overrides the system default, the `prefers-color-scheme` media query can select different color pairs that suit the browser and OS chrome around the page (or the surrounding page, when the page is in an iframe). For example, use a slightly dimmer light theme when the system setting is `dark`, or a higher-contrast dark theme when it is `light`, so the surrounding UI doesn't overpower the page.

## Fine-grained browser UI customization

`color-scheme` alone adapts browser UI to the color scheme, but with OS defaults or system colors that may not match the site's design. Modern browsers offer finer customization hooks; use them before reimplementing a native control just to change its appearance.

### Accent color

Some browser UI, such as checked checkboxes and sliders, uses an accent color. It defaults to the OS setting; `accent-color` sets it to a color that suits the page, such as the brand color.

```css
html {
  accent-color: light-dark(var(--color-accent-light), var(--color-accent-dark));
}
```

Browsers render `accent-color` differently. For indicators painted over an accent-colored background, such as checkbox marks and radio dots:

- Chromium and Firefox generally pick a contrasting indicator color.
- Safari may keep a white indicator in light mode or a black indicator in dark mode and change the accent color behind it instead. This doesn't always give enough contrast for every color, so test important combinations in Safari in both light and dark schemes rather than assuming it picks the best-contrasting indicator.

### Scrollbar colors

`scrollbar-color` with `light-dark()` sets scrollbar colors that follow the color scheme.

```css
:root {
  --color-scrollbar-track: light-dark(#eee, #222);
  /* Example values: the thumb needs at least 3:1 contrast against the track. */
  --color-scrollbar-thumb: light-dark(#6b6b6b, #8a8a8a);
  scrollbar-color: var(--color-scrollbar-thumb) var(--color-scrollbar-track);
}
```

Issues with `scrollbar-color`:

- Don't animate or transition `scrollbar-color`: a [WebKit bug](https://bugs.webkit.org/show_bug.cgi?id=311752) makes the scrollbar flicker every time it changes.
- On an element whose computed `scrollbar-width` is anything other than `auto` (`thin` or `none`), or whose computed `scrollbar-color` is anything other than `auto` (including an inherited value), the legacy `::-webkit-scrollbar` pseudo-elements are disabled.
- With overlay scrollbars (the macOS default), `scrollbar-color` styles the thumb while scrolling, but the track may stay transparent. Give the thumb enough contrast against both the track color and the scroll container's background instead of relying on the track to frame it.

### Further customization

Most browser UI has pseudo-elements for full customization, such as:

- `::placeholder`
- `::spelling-error`
- `::grammar-error`
- `::selection`
- `::search-text`
- `::target-text`
- `::file-selector-button`

`light-dark()` colors work in any of them.

## Vary images for light and dark mode

`light-dark()` can also switch CSS image values. Both arguments must be the same type: you can't combine a color with an image. If one side must be an image, wrap the color in `image(<color>)`.

## Detecting the theme in JavaScript

Do most color-scheme branching in CSS, which adapts to changes automatically. Any script that reads `matchMedia("(prefers-color-scheme: dark)").matches` must also handle its `change` event, because the system preference can change at any time.

## Optional: a color-scheme toggle

A toggle lets users override their system default for this site. Most sites don't need a persistent toggle in the page UI; following the system color scheme is usually enough, optionally with a setting in a separate settings surface. The `dark-mode-toggle` guide covers how to build a toggle, persistent or not.

## Optional: component-specific overrides

Setting `color-scheme` on an element overrides the global theme for that element. The `component-specific-light-dark-theme` guide covers this and its pitfalls.

## Known issues with `color-scheme`

Chrome and Firefox respect `color-scheme` for iframes: they render the embedded page in the right scheme and make its `prefers-color-scheme` media query reflect the embedding context's `color-scheme`. Safari doesn't; inside iframes it resolves `prefers-color-scheme` to the system setting.

- If you control both the parent and the iframe, pass the parent's scheme to the iframe explicitly: with a URL parameter (`?theme=dark`) when creating the iframe, or with `postMessage()`, which also handles runtime changes. In the iframe, set a class on `<html>` (and/or `color-scheme` on `:root`) from that signal instead of relying on `prefers-color-scheme`.
- If you control only the embedded page, there is no reliable way to detect the embedder's `color-scheme` from inside the iframe in Safari. Offer an explicit theme parameter in your embed API (such as a query string or a `postMessage` protocol) and document it for embedders.

## Fallback strategies

### `color-scheme`

Baseline status for color-scheme: Widely available. It's been Baseline since 2022-02-03.
Supported by: Chrome 98 (Feb 2022), Edge 98 (Feb 2022), Firefox 96 (Jan 2022), and Safari 13 (Sep 2019).

`color-scheme` is a progressive enhancement: browsers that don't support it ignore it and show their default light UI. To follow the user's preference in older browsers, provide dark colors through `prefers-color-scheme` media queries:

- Switch custom properties on `:root` or `html` in the media query.
- Avoid the media query in individual components unless a component needs dark-mode customization beyond colors.

```css
:root {
  --color-brand-light: #0056b3;
  --color-brand-dark: #00e5ff;
  --color-brand-text-light: white;
  --color-brand-text-dark: #001f24;
  --color-brand: var(--color-brand-light);
  --color-brand-text: var(--color-brand-text-light);

  /* Ignored by older browsers. */
  color-scheme: light dark;
}

/* Fallback for browsers without light-dark(). Kept top-level rather than nested
   in :root, because browsers this old also lack CSS nesting. */
@media (prefers-color-scheme: dark) {
  :root {
    --color-brand: var(--color-brand-dark);
    --color-brand-text: var(--color-brand-text-dark);
  }
}

button.primary {
  background-color: var(--color-brand);
  color: var(--color-brand-text);
}
```

### `light-dark()`

Baseline status for light-dark(): Newly available. It's been Baseline since 2024-05-13.
Supported by: Chrome 123 (Mar 2024), Edge 123 (Mar 2024), Firefox 120 (Nov 2023), and Safari 17.5 (May 2024).

For browsers that support `color-scheme` but not `light-dark()`, define the light and dark colors as custom properties and set each mode's colors with the `prefers-color-scheme` media query:

```css
:root {
  --brand-accent-light: #0056b3;
  --brand-accent-dark: #00e5ff;
  --accent-color: var(--brand-accent-light);

  color-scheme: light dark;

  /* An inherited color property. */
  accent-color: var(--accent-color);
}

/* Fallback for browsers without light-dark() (top-level: they may lack CSS nesting). */
@media (prefers-color-scheme: dark) {
  :root {
    --accent-color: var(--brand-accent-dark);
  }
}

/* Optional: light-dark() gives more control over built-in UI colors. */
@supports (color: light-dark(white, black)) {
  :root {
    --accent-color: light-dark(var(--brand-accent-light), var(--brand-accent-dark));
  }
}

pre, code {
  color-scheme: dark;

  /* Set inherited color properties again on the subtree, even to the same token. */
  accent-color: var(--accent-color);
}
```

### `light-dark()` image values

Baseline status for light-dark() image values: Newly available. It's been Baseline since 2026-09-14.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), Firefox 150 (Apr 2026), and Safari 27 (Sep 2026).

For browsers without `light-dark()` image support, use `image-set()` as a switch. Give each option a `type()` from a custom property, and set the inactive one to an unsupported MIME type so the browser discards it. The active option gets an empty value, making it a plain `image-set()` option with no `type()`.

Define the switch once on `:root`; each use site then lists both images inline, as with `light-dark()`.

```css
:root {
  --light-type: ;
  --dark-type: type("image/do-not-use");
}

/* Fallback for browsers without light-dark() image support. */
@media (prefers-color-scheme: dark) {
  :root {
    --light-type: type("image/do-not-use");
    --dark-type: ;
  }
}

.hero {
  background-image: image-set(url(hero-light.png) var(--light-type), url(hero-dark.png) var(--dark-type));
}

@supports (background-image: light-dark(url("a"), url("b"))) {
  .hero {
    background-image: light-dark(url(hero-light.png), url(hero-dark.png));
  }
}
```

- Only the selected image is downloaded.
- Resolutions still work: `image-set(url(a-1x.png) 1x var(--light-type), url(a-2x.png) 2x var(--light-type), url(b-1x.png) 1x var(--dark-type), url(b-2x.png) 2x var(--dark-type))`.
- Don't use `type("")` for the active option: browsers treat the empty string as unsupported and drop every option.
- Unlike `light-dark()`, the switch doesn't follow a `color-scheme` set on a subtree. A manual toggle, or any subtree that sets `color-scheme`, must also flip `--light-type` and `--dark-type`.

#### Alternative: one custom property per image

Simpler when only a few images vary, but each image needs its own media-query branch, and a manual toggle must flip each one.

```css
:root {
  --hero-image: url(hero-light.png);
}

@media (prefers-color-scheme: dark) {
  :root {
    --hero-image: url(hero-dark.png);
  }
}

@supports (background-image: light-dark(url("a"), url("b"))) {
  :root {
    --hero-image: light-dark(url(hero-light.png), url(hero-dark.png));
  }
}

.hero {
  background-image: var(--hero-image);
}
```

### `image()`

No major browser supports `image()` natively yet. Use a gradient with a single color stop and no positions instead, such as `linear-gradient(blue)`.

Baseline status for the css.types.gradient.linear-gradient.single_color_stop capability: Newly available. It's been Baseline since 2025-04-04.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 136 (Mar 2025), and Safari 18.4 (Mar 2025).

For broader support, give the single stop explicit `0 100%` positions: `linear-gradient(blue 0 100%)`.

### `scrollbar-color`

Baseline status for scrollbar-color: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 121 (Jan 2024), Edge 121 (Jan 2024), Firefox 64 (Dec 2018), and Safari 26.2 (Dec 2025).

`scrollbar-color` is a progressive enhancement and does not always need a fallback. If the styling matters and the user's Baseline target is "Baseline Widely Available" or earlier, add the non-standard `::-webkit-scrollbar` pseudo-elements as a fallback:

- Put them after the base rule inside `@supports not (scrollbar-color: auto)`, so browsers that support both the standard property and the WebKit selectors don't get conflicting styles.
- If the container also sets `scrollbar-width: thin`, reset `scrollbar-width: auto` on the same selector inside that block. Otherwise browsers that support `scrollbar-width` but not `scrollbar-color` suppress the `::-webkit-scrollbar` styling.
- Custom properties holding the colors cascade into the WebKit pseudo-elements, so you don't need to duplicate the values.

```css
/* Legacy fallback for WebKit/Blink browsers. */
@supports not (scrollbar-color: auto) {
  .scroller {
    /* Undo scrollbar-width: thin (if set) so ::-webkit-scrollbar still applies. */
    scrollbar-width: auto;
  }

  .scroller::-webkit-scrollbar {
    /* WebKit renders custom colors only with an explicit size (e.g. 8px thin, 12px default). */
    width: 12px;
    height: 12px;
  }

  .scroller::-webkit-scrollbar-thumb {
    background: var(--scrollbar-thumb);
  }

  .scroller::-webkit-scrollbar-track {
    background: var(--scrollbar-track);
  }
}
```

### `accent-color`

Browser support for accent-color: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021), and Safari 26.2 (Dec 2025).

`accent-color` is a progressive enhancement: browsers that don't support it ignore it and use their default UI colors.
