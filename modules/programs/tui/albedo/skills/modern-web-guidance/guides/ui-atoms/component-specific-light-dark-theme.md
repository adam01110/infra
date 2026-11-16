# Component-specific light/dark themes

`color-scheme` is usually set on the root, but it can also be set on individual elements to put them in a different color scheme from the rest of the page. Use this for components that should always appear in one scheme.

Example use cases:

- Elements often kept dark even on light pages for aesthetic reasons, such as code blocks, media players and photo galleries.
- Areas holding media designed for a light background (images, videos, illustrations, print previews), kept light even when the page is dark.
- Elements whose color scheme follows a user-level setting, such as component previews.
- Embeds that don't support both light and dark modes.
- Design tools, maps, visualizations and games.

## When to change colors and when to force `color-scheme`

Not every element with light-on-dark text in light mode (or dark-on-light in dark mode) needs a different `color-scheme`. A primary button rendered blue with white text in light mode does not warrant `color-scheme: dark`.

As a rule of thumb, elements with their own `color-scheme` are complex surfaces that establish their own visual context, not simple shallow containers. Before overriding, ask:

- Should uncustomized built-in browser UI (form controls, scrollbars) inside it follow the override, or the page's scheme? If the page's, don't use `color-scheme`.
- Should `light-dark()` colors resolve as on the rest of the page, or according to the override? If as on the page, don't use `color-scheme`.
- Should descendants be in that scheme? If not, don't use `color-scheme`.

## Basic implementation

Component overrides are typically, though not necessarily, used on pages that also support several color schemes through a global `color-scheme`. For page-wide dark mode, see the `dark-mode` guide.

Once a page-wide `color-scheme` is in place and your color tokens respond to it (for example through `light-dark()`), set `color-scheme` on a component to override the mode for that subtree:

```css
pre, code, .dark {
  color-scheme: dark;
}
```

Some browsers adapt components to a different color scheme on their own. To force the specified scheme in all cases, use `only`: `color-scheme: only dark;` instead of `color-scheme: dark;`.

`light-dark()` currently works only for colors, so non-color values cannot adapt through it.

## Best practices

- Do not set `color-scheme` on elements without a background. Doing so risks pairing background and text colors from different schemes, which makes text unreadable.
- Reusing the page-wide dark mode's color pairs is easiest, but components can define their own. For example, a dark component on a light page might be slightly less dark than the same component on a dark page.

## Known issues

### Inheritance of `light-dark()` colors

`light-dark()` resolves at computed-value time. An inherited `<color>` property set to a `light-dark()` color therefore passes only one of the two colors to descendants, not the `light-dark()` expression itself. This applies to:

- Built-in inherited color properties such as `color`, `accent-color`, `fill`, `stroke`, `text-shadow` and `caret-color`.
- Registered custom properties with `syntax: <color>` and `inherits: true`.
- Any other `<color>` property set to `inherit`.

So:

- Do not register custom properties that hold design tokens (such as `--surface-color`) as `<color>`. Tokens need to keep their `light-dark()` expression live so descendants can re-resolve it under a different `color-scheme`.
- When setting `color-scheme` on an element, re-specify any inherited `<color>` properties that may hold `light-dark()` values, directly or through design tokens, even if you set them to the same token.
- Do not use `inherit` on `<color>` properties of an element with a `color-scheme` override. Its descendants may use it.
- Use registered `<color>` properties for the opposite case: when you want to snapshot an ancestor's resolved color so it does not re-resolve under the descendant's `color-scheme`, such as capturing the page background to use elsewhere.
- To animate a color, use a separate `@property`-registered `<color>` property on the animated element; registration is required for color interpolation. This is a per-element animation target, not a design token, so it does not conflict with the rule above.

```css
:root {
  --accent-color: light-dark(blue, skyblue);
  --surface-color: light-dark(white, #222);
  --text-color: light-dark(#111, white);

  color-scheme: light dark;
  accent-color: var(--accent-color);
  color: var(--text-color);
}

body {
  /* Switches with the scheme despite being inherited, because --surface-color is not registered. */
  background: var(--surface-color);
}

pre, code {
  color-scheme: dark;
  background: var(--surface-color);

  /* Without this, accent-color would be blue, not skyblue. */
  accent-color: var(--accent-color);

  /* Without this, color would be #111, not white. */
  color: var(--text-color);
}
```

### `color-scheme` and iframes

Chrome and Firefox respect `color-scheme` for iframes: they render embedded pages in the right scheme and make the embedded page's `prefers-color-scheme` reflect the embedding context's `color-scheme`. Safari does not; inside iframes it resolves `prefers-color-scheme` to the system setting.

- If you control both parent and iframe, pass the parent's scheme explicitly: as a URL parameter (`?theme=dark`) when creating the iframe, or with `postMessage()`, which also handles runtime changes. In the iframe, set a class on `<html>` and/or `color-scheme` on `:root` from that signal instead of relying on `prefers-color-scheme`.
- If you control only the embedded page, Safari offers no reliable way to detect the embedding context's `color-scheme` from inside the iframe. Expose an explicit theme parameter in your embed API (such as a query string or `postMessage` protocol) and document it for embedders.

## Fallback strategies

### `color-scheme`

Baseline status for color-scheme: Widely available. It's been Baseline since 2022-02-03.
Supported by: Chrome 98 (Feb 2022), Edge 98 (Feb 2022), Firefox 96 (Jan 2022), and Safari 13 (Sep 2019).

`color-scheme` is progressive enhancement: browsers without support ignore it and use their default light UI. To follow the user's preference in older browsers, use `prefers-color-scheme` media queries to supply dark colors.

- Switch custom properties on `:root` or `html` with the media query.
- Avoid the media query on individual components unless a component needs dark-mode customization beyond colors.

```css
:root {
  --color-brand-light: #0056b3;
  --color-brand-dark: #00e5ff;
  --color-brand-text-light: white;
  --color-brand-text-dark: #001f24;
  --color-brand: var(--color-brand-light);
  --color-brand-text: var(--color-brand-text-light);

  /* Required fallback for browsers without light-dark() support. */
  @media (prefers-color-scheme: dark) {
    --color-brand: var(--color-brand-dark);
    --color-brand-text: var(--color-brand-text-dark);
  }

  /* Ignored by older browsers. */
  color-scheme: light dark;
}

button.primary {
  background-color: var(--color-brand);
  color: var(--color-brand-text);
}
```

### `light-dark()`

Baseline status for light-dark(): Newly available. It's been Baseline since 2024-05-13.
Supported by: Chrome 123 (Mar 2024), Edge 123 (Mar 2024), Firefox 120 (Nov 2023), and Safari 17.5 (May 2024).

For browsers that support `color-scheme` but not `light-dark()`, define light and dark versions of each color as custom properties and set the active one with a `prefers-color-scheme` media query:

```css
:root {
  --brand-accent-light: #0056b3;
  --brand-accent-dark: #00e5ff;
  --accent-color: var(--brand-accent-light);

  /* Required fallback for browsers without light-dark() support. */
  @media (prefers-color-scheme: dark) {
    --accent-color: var(--brand-accent-dark);
  }

  /* Optional: light-dark() gives more control over built-in UI colors. */
  @supports (color: light-dark(white, black)) {
    --accent-color: light-dark(var(--brand-accent-light), var(--brand-accent-dark));
  }

  /* Required: adapts native UI to the user's system preference. */
  color-scheme: light dark;

  /* Example inherited color property. */
  accent-color: var(--accent-color);
}

pre, code {
  color-scheme: dark;

  /* Inherited color properties must be set again, even to the same design tokens. */
  accent-color: var(--accent-color);
}
```
