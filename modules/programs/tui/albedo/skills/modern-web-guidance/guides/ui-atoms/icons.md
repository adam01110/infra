# Using and managing icons

## Choosing an icon technique

Icon storage and rendering are separate choices. An SVG sprite, for example, can feed the CSS icon system or be referenced with `<use>`.

* CSS icon system: use when CSS should decide when and which icon to show. Use a mask for a single-color icon or a background image for a full-color one.
* SVG with `<use>`: use to reuse a symbol when its built-in styling hooks are enough. CSS can't arbitrarily style or animate the referenced SVG's contents, but inherited properties and custom properties reach it when the symbol is designed to use them. For example, a path with `fill="var(--icon-accent, currentColor)"` lets CSS color that part of the icon.
* Inline SVG: use when you need arbitrary styling or animation of the SVG's contents.
* `<img>` with CSS filters: avoid this for recoloring icons. Filters can't reliably produce an arbitrary CSS color, so recoloring is cumbersome and inflexible.

To decide, ask two questions. Does CSS need to pick or swap the icon (component defaults, state changes, theming)? If so, use the CSS icon system. Do you need to reach inside the icon beyond color? If so and you control the icon source, design the symbol with custom properties and use `<use>`; if you don't control the source, inline the SVG. Third-party icon sets rarely expose custom properties, so `<use>` with them gives you color and little else.

Whatever the method, give every icon a contrast of at least 3:1 against its background in both light and dark color schemes. See the Contrast section of the `color` guide.

### Embedded or remote icons

Both the CSS icon system and `<use>` can take icons from a data URI, an individual file, or a sprite.

* Embedding (data URIs or inline SVG) avoids a request and renders with the first paint, but bloats CSS or HTML and cannot be cached separately. It suits a small set of icons that appear on every page.
* Individual files are cached independently and loaded on demand, at one request each.
* A sprite is one cacheable request for the whole set, but downloads every icon whether used or not, and `<use>` can reference a sprite only from the same origin.

Prefer embedding for a handful of core icons and a sprite or individual files for larger sets.

If a page renders thousands of icons at once, benchmark the actual page and assets. In [Cloud Four's SVG icon stress test](https://cloudfour.com/thinks/svg-icon-stress-test/), inline SVG had a small performance advantage at that scale, but results depend on the browser and implementation.

## Primary approach: CSS-driven icon engine

Icons are design tokens: each icon is a custom property holding an image, and any element displays one by setting `--icon-start` or `--icon-end`. The engine combines three CSS features:

* Registered custom properties (`@property`) keep `--icon-start` and `--icon-end` from inheriting, so an icon set on a component does not cascade into its children.
* Container style queries (`@container style(...)`) detect that an element has an icon assigned and render it, with no class or markup changes.
* CSS masks and `currentColor` render the icon in a pseudo-element that follows the element's text color. Size, color, spacing and vertical offset come from inheritable `--icon-style-*` properties with fallbacks, so an ancestor can restyle a whole subtree. The `--icon-style-` prefix keeps these settings from colliding with the icon tokens, which also live under `--icon-*`.

### Defining icon design tokens

Define SVG icons and any `--icon-style-*` overrides as reusable custom properties, using inline SVG data URIs or root-relative URLs such as `url("/icons/trash.svg")`. Avoid plain relative URLs for icons loaded from external SVG files: a relative URL used through a custom property can resolve against the stylesheet where the icon is used rather than the one where the property is defined, and if those stylesheets sit in different directories it points at the wrong file.

Registered properties are meant to fix this, since the computed value of a registered `<url>` or `<image>` resolves against the stylesheet that declared it. Do not rely on registering the token as `<image>` with the URL in `initial-value`: Chrome and Safari resolve `initial-value` URLs against the document, so this works only in Firefox. Chrome also resolves values declared on `:root` against the document unless the syntax starts with `<url>`.

When relative URLs are unavoidable, such as stylesheets in different directories, register the token with a syntax that starts with `<url>` and declare the actual URL on `:root`. This resolves against the declaring stylesheet in every browser:

```css
@property --icon-caret {
  /* Must start with <url>; a syntax starting with <image> resolves against the document in Chrome. */
  syntax: "<url> | <image> | none";
  inherits: true;
  initial-value: none;
}

:root {
  /* Declared here, the URL resolves against this stylesheet. */
  --icon-caret: url("icons/caret.svg");
}
```

Each icon now lives in two places with much more boilerplate, so this is worth it only when a project has stylesheets in different directories and a manageable number of icons. Past a dozen or so icons, register the `--icon-*` tokens (not `--icon-style-*`) from a script with `CSS.registerProperty`, using the same syntax, instead of writing each `@property` by hand. Registered properties are global and do not work in shadow roots, so this may not fit every project. Where root-relative URLs or data URIs are an option, they are simpler and work everywhere.

```css
:root {
  /* Optional: override the built-in fallbacks (1em, currentColor, 0.3em, -0.02em). */
  --icon-style-size: 1em;
  --icon-style-spacing: 0.4em;
  --icon-trash: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'%3E%3Cpath d='M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m3 0-1 14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2L4 6h16Z'/%3E%3C/svg%3E");
  --icon-favorite: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='currentColor'%3E%3Cpath d='M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z'/%3E%3C/svg%3E");
}
```

### Rendering icons from tokens

An element shows an icon by setting `--icon-start` (leading) or `--icon-end` (trailing) to one of the tokens. Two pieces of CSS turn that into a rendered icon.

First, register `--icon-start` and `--icon-end`. The `"*"` syntax accepts any value; `inherits: false` matters, because otherwise an icon set on a button would inherit into every descendant and each would render it too.

```css
@property --icon-start {
  syntax: "*";
  inherits: false;
}

@property --icon-end {
  syntax: "*";
  inherits: false;
}
```

Second, a container style query detects that the property is set and renders the icon in a pseudo-element. The pseudo-element does not inherit the non-inheriting `--icon-start`, so the first declaration forwards it explicitly with `inherit`. Because the fill defaults to `currentColor`, the icon takes the element's text color and follows its transitions.

```css
@container style(--icon-start) {
  ::before {
    --icon-start: inherit;
    content: "" / var(--icon-style-alt, "");
    display: inline-block;
    width: var(--icon-style-size, 1em);
    height: var(--icon-style-size, 1em);
    background-color: var(--icon-style-color, currentColor);
    mask: var(--icon-start) no-repeat center / contain;
    /* Centers on the cap height, nudged slightly up for optical balance. */
    vertical-align: calc(0.5cap - var(--icon-style-size, 1em) / 2 + var(--icon-style-voffset, -0.02em));
    flex: none;
    pointer-events: none;
    forced-color-adjust: none;
  }

  /* Adds spacing only when the element has other text or content. */
  :where(:not(.icon, :empty))::before {
    margin-inline-end: var(--icon-style-spacing, 0.3em);
  }
}
```

Why each declaration is there:

* `vertical-align`: `middle` aligns to half the x-height, which sits visibly low for most icon sets. Centering on `0.5cap` keeps the icon's center fixed as `--icon-style-size` grows, and the small negative `--icon-style-voffset` compensates for the eye weighting the space above an icon more than the space below.
* `flex: none`: an empty pseudo-element has a zero minimum size, so in a flex button with a long label it shrinks first, possibly to nothing. Icon size is a design decision, not something layout pressure should negotiate.
* `pointer-events: none`: keeps the icon from trapping clicks or becoming `event.target`.
* `forced-color-adjust: none`: in forced-colors mode the browser otherwise replaces `background-color`, making a masked icon disappear. With it, the mask fill is kept and `currentColor` still follows the forced text color.
* `content: "" / var(--icon-style-alt, "")`: alternative text for generated content lets an icon-only control take its accessible name from the icon through `--icon-style-alt` (see Icon-only controls). The empty default keeps decorative icons hidden from assistive technology.

For a trailing icon, use the same pattern with `--icon-end` and `::after` instead of `--icon-start` and `::before`: `mask: var(--icon-end)`, and spacing with `margin-inline-start` instead of `margin-inline-end`.

### Standalone and icon-only elements

For standalone icons or icon-only buttons, put `.icon` directly on the empty element (the button itself for an icon-only control) and set its icon with `--icon`. `--icon` is the higher-level property; the `.icon:empty` rule maps it to `--icon-start`:

```css
.icon:empty {
  --icon-start: var(--icon);
}
```

## Usage examples

### Component defaults in the stylesheet

Icons as custom properties take part in the cascade. Set an icon on a selector and every matching element gets it, with no markup changes:

```css
.button-delete {
  --icon-start: var(--icon-trash);
}

a[href^="http"]:not([href*="example.com"]) {
  --icon-end: var(--icon-external);
}
```

```html
<button class="button-delete">Delete item</button>
```

### Changing icons with state

A state change is an ordinary CSS override, with no second element to show or hide and no class to toggle:

```css
.button-expand {
  --icon-start: var(--icon-caret-right);
}

.button-expand[aria-expanded="true"] {
  --icon-start: var(--icon-caret-down);
}
```

Presentation works the same way: set `--icon-style-size`, `--icon-style-color` or `--icon-style-spacing` on a container such as a toolbar and every icon inside updates.

### One-off icons with inline styles

An element no component rule covers can set the property inline, such as `<button style="--icon-start: var(--icon-trash)">`. Treat this as an escape hatch: once the same icon appears on the same kind of element more than once, move it into a stylesheet rule.

### Icon-only controls

Icon-only buttons use the `.icon` class and `--icon`. Name the button with `aria-label`, or let the icon supply the name through `--icon-style-alt`; without either, the generated icon is decorative. For standalone informative icons, give the `.icon` element `role="img"` and `aria-label`:

```css
.button-close {
  --icon: var(--icon-close);
  --icon-style-alt: "Close";
}
```

```html
<!-- Icon-only control; icon and name come from the stylesheet. -->
<button class="icon button-close"></button>

<!-- Icon-only control named with aria-label. -->
<button class="icon" style="--icon: var(--icon-trash);" aria-label="Delete item"></button>

<!-- Standalone informative icon. -->
<span class="icon" style="--icon: var(--icon-favorite);" role="img" aria-label="Favorite"></span>
```

## Working with SVG directly

When the CSS icon system doesn't fit, use inline SVG and `<use>` together. Inline the SVG the first time an icon appears on a page and reference it with `<use href="#id">` for every repeat; the local reference costs no request and has no cross-origin restriction. Keep external sprites (`<use href="/icons.svg#id">`) for icons shared across many pages.

`<use>` clones the referenced content into a shadow tree, so page CSS cannot select its elements. Inheritance does reach it: `color`, `currentColor`, and any custom property. Beyond SVG presentation attributes, CSS can also set many geometry attributes, so an icon you control can expose exactly the hooks you need, such as `stroke-width="var(--icon-stroke, 2)"` or `d: var(--icon-path, path(…))` on a particular path.

Browser support for the css.properties.d capability: Limited availability.
Supported by: Chrome 52 (Jul 2016), Edge 79 (Jan 2020), and Firefox 97 (Feb 2022).
Unsupported in: Safari.

Safari does not support CSS `d`, so use that customization only when the gap is acceptable. If you don't control the icon, inline it.

`<use>` gotchas:

* The `viewBox` must be on the `<symbol>` or referenced `<svg>`. The outer `<svg>` wrapping `<use>` does not pick it up from the reference, so set `width` and `height` on the wrapper and keep the `viewBox` with the symbol.
* Styles do not cross the boundary in either direction: `<style>` inside an external sprite does not apply to the page, and page stylesheets do not apply inside the referenced tree. Only inherited and custom properties pass through.
* External references are same-origin only; cross-origin sprites fail silently.
* Sprites inlined into the document share the page's `id` namespace, so namespace symbol ids to avoid collisions.

Mark decorative SVGs with `aria-hidden="true"` and give the containing control its own accessible name, as with the CSS icon system.

## Fallback strategies

### Registered custom properties

Baseline status for Registered custom properties: Newly available. It's been Baseline since 2024-07-09.
Supported by: Chrome 85 (Aug 2020), Edge 85 (Aug 2020), Firefox 128 (Jul 2024), and Safari 16.4 (Mar 2023).

Without `@property`, `--icon-start` and `--icon-end` are ordinary inheriting custom properties, so an icon set on an element also renders on its descendants. Prevent this by resetting the properties on children inside the style query (`@container style(--icon-start) { * { --icon-start: initial; } }`), as the Safari workaround below does.

### Container style queries

Baseline status for Container style queries: Newly available. It's been Baseline since 2026-05-19.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 151 (May 2026), and Safari 18 (Sep 2024).

For browsers without container style queries, use classes or component selectors as fallback hooks. Keep icon selection in custom properties; selectors that match only inline styles miss icons assigned through CSS rules.

```css
:where(.icon-start, .icon:empty)::before {
  content: image-set(linear-gradient(transparent 0 100%), var(--icon-start)) / var(--icon-style-alt, "");
  /* icon styles */
}

:where(.icon-start)::before {
  --icon-start: inherit;
}

:where(.icon:empty)::before {
  --icon-start: var(--icon);
}

:where(.icon-start:not(.icon, :empty))::before {
  margin-inline-end: var(--icon-style-spacing, 0.3em);
}
```

For trailing icons, use `.icon-end`, `--icon-end` and `::after` instead of `.icon-start`, `--icon-start` and `::before`, with `margin-inline-start` instead of `margin-inline-end` on non-empty content.

The `image-set()` pattern makes `content` invalid when the custom property is unset, so it falls back to `none` and the pseudo-element disappears without adding or removing a class. It does not remove the pseudo-element's other styles or prevent conflicts with other `::before` or `::after` rules, so use these hooks only where those pseudo-elements are free for icons.

### Safari workarounds

Two WebKit rendering bugs affect icons: [#301609](https://bugs.webkit.org/show_bug.cgi?id=301609) can keep them from appearing until user interaction, and [#320220](https://bugs.webkit.org/show_bug.cgi?id=320220) also affects their rendering. This workaround addresses both:

```css
@keyframes webkit-301609 {}

@supports ((-webkit-nbsp-mode: normal) or (-webkit-touch-callout: none) or (font: -apple-system-body)) and (content-visibility: auto) {
  @layer webkit-301609-fix {
    ::before, ::after {
      animation: webkit-301609 0s;
    }
  }
}
```

The `@supports` query targets only Safari, and `@layer` reduces conflicts with other animations.

WebKit bug #325900 can stop a direct override of `--icon-start` from taking effect in some cases, such as changing the icon on hover. This breaks the non-inheriting registered property approach. For Safari, register `--icon-start` as inheriting and reset it on descendants inside the style query:

```css
@supports ((-webkit-nbsp-mode: normal) or
           (-webkit-touch-callout: none) or
           (font: -apple-system-body)) and (content-visibility: auto) {
  /* Overrides the earlier registration. */
  @property --icon-start {
    syntax: "*";
    inherits: true;
  }

  @layer webkit-325900-fix {
    @container style(--icon-start) {
      * {
        --icon-start: initial;
      }
    }
  }
}
```

The reset stops the icon value from propagating to descendants. Keeping it in a layer lets unlayered icon declarations override the reset.
