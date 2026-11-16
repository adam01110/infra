# Dark mode toggles

A dark mode toggle lets users override the system color scheme for one site. The override is applied through `<meta name="color-scheme">`: `light dark` follows the system preference, and `light` or `dark` pins a scheme. Colors from `light-dark()`, system colors, and native UI all follow the CSS `color-scheme` property, so the toggle works by keeping that property in sync with the `<meta>` (see [Reflect the override in CSS](#reflect-the-override-in-css)).

## Persistent toggle, settings control, or no toggle?

Most sites do not need a persistent color scheme toggle in the site chrome (header, nav, footer, and so on). Follow the system preference by default and, if a manual override is needed at all, put it in a separate settings surface: a settings page, panel, or overlay. Pinning a scheme against the OS is a legitimate but rare intent, and rare intents belong behind progressive disclosure rather than in an always-visible control.

Persistent toggles are mostly found on sites for developers or people close to them, such as designers, who switch schemes far more often than typical users. Do not add one just because it is common on developer sites; a developer's interest in the control is not representative of typical users.

## Implementation

First follow the `dark-mode` guide so the site supports both schemes and defaults to the system preference.

### Data model

The toggle usually has three states:

1. System (no stored value): the UI follows the system color scheme. This should normally be the default.
2. Light (stored as `"light"`): the light theme regardless of the system scheme.
3. Dark (stored as `"dark"`): the dark theme regardless of the system scheme.

The state is usually stored in `localStorage` and reflected in a `<meta name="color-scheme">` element in the document head.

### Reflect the override in CSS

The `<meta>` is only a presentational hint, and any `color-scheme` declaration in author CSS overrides it. The `dark-mode` guide sets `color-scheme: light dark` on `:root`, so updating the `<meta>` alone does nothing. Map the `<meta>` back to the property so the cascade follows it:

```css
:root {
  color-scheme: light dark;

  &:has(> head > meta[name="color-scheme"][content="dark"]) {
    color-scheme: dark;
  }
  &:has(> head > meta[name="color-scheme"][content="light"]) {
    color-scheme: light;
  }
}
```

Keep the base declaration `light dark`; do not hardcode `color-scheme: light` or `dark` as the root default. The CSS must not depend on JavaScript: if no script runs, the `<meta>` stays `light dark`, the site follows the system preference, and nothing breaks.

### Persistence and avoiding a flash of the wrong scheme

Persist the override in `localStorage`, and remove the entry when the user returns to the system default.

To avoid a flash of the wrong scheme, apply the stored value in a classic inline script (not `type="module"`, not `defer`) placed right after the `<meta>` element:

```html
<meta name="color-scheme" content="light dark">
<script>
document.querySelector('meta[name="color-scheme"]').content = localStorage.getItem("color-scheme") ?? "light dark";
</script>
```

- This inline script exists only to prevent the flash, so keep it as small as possible. The rest of the toggle's JavaScript can load later.
- `localStorage` access can occasionally throw (for example when site data is blocked). Since this script does nothing else, the only effect is a console error; wrap it in `try`/`catch` if that matters. Still apply the chosen scheme to the page even when it cannot be persisted.
- Another tab can change the override. Listen for the `storage` event on `window` to stay in sync.
- Do not use `matchMedia()` to delete the stored value when the system preference changes to match it. Many operating systems switch schemes automatically by time of day, so deleting the value whenever the two coincide would make it impossible to pin a scheme.

### Branching for HTML and non-color values

Colors need no extra work: once the `<meta>` is mapped to `color-scheme`, `light-dark()` follows the override. This section covers other values, such as `font-weight` or media sources.

When the page only follows the system preference, branch with `(prefers-color-scheme: dark)`, including in `<picture>` or `<video>` sources. An override complicates this: the system preference is no longer the source of truth, and APIs that accept only media queries have no direct alternative.

Do not branch only on JavaScript-applied classes such as `.dark`; they are wrong when the script does not load and the OS default is dark. Instead, combine the media query with a `:root:has(> head > meta[name="color-scheme"][content="dark"])` (or `light`) selector. The `selector-atrule-combinations` guide shows how to write this cleanly.

The control's own options are non-color branches too. Put both states in the markup (an icon plus visually hidden action text, such as "Switch to dark theme") and hide the inactive one with these selectors. `display: none` also removes the redundant option from assistive technologies, so the control stays current without JavaScript when the system preference changes.

For media in HTML, the only current approach is to include both versions as separate elements and toggle their visibility. Hiding `<source>` elements with `display: none` does not work.

## User interface

### Two or three states?

Every variant must let the user revert to, or choose, the system scheme.

Prefer two states in space-constrained toggles, such as persistent toggles in the site chrome, where space is limited and changing settings is usually unrelated to the user's goal.

A control in a separate settings surface (page, panel, or overlay) may expose all three states ("Light", "Dark", "System"). There the user is deliberately setting future behavior, and there is room to explain the options.

Three explicit states are also warranted when the site has context-aware schemes (for example a dimmer light mode when the OS is dark), because "Light" and "System (currently light)" then genuinely differ.

### Two-state toggles

A two-state toggle is usually a temporary comfort adjustment ("it's too bright right now") rather than a long-term setting. It is enough to offer two of the three settings: system, so the user can revert, and the opposite of the current system scheme, stored as its literal value. The two states are:

1. System default: no stored value, `<meta>` content `light dark`. Displayed as its current resolved value (for example a sun icon when light).
2. Override: stored literally as `light` or `dark`.

In effect it is a tri-state control (`light dark`, `light`, `dark`) in which the explicit state matching the current system preference cannot be reached.

On toggle:

1. The target scheme is the opposite of the currently rendered scheme (the stored value if any, else the system preference). The user means "the opposite of what I see now", not "the inverse of the system default".
2. If the target differs from the current system preference, store it literally.
3. If the target matches the current system preference, the user is undoing their adjustment: remove the stored value rather than storing it, because a stored value would silently pin the scheme against future system changes.
4. Set the `<meta>` content to the stored value, or `light dark` if there is none.

Compare with the system preference only when storing, never retroactively. Keep a stored value even after the system preference changes to match it: many operating systems switch schemes by time of day, and removing the value whenever the two coincide would make it impossible to pin a scheme.

Example, with the OS starting in light:

1. The user toggles. Dark differs from the system preference, so `dark` is stored and the site turns dark.
2. The OS switches to dark. The site stays dark; the stored value now matches the system but is kept.
3. The OS switches back to light. The site stays dark.
4. The user toggles. The target (light) matches the system preference, so the stored value is removed and the site follows the system again.

### Three-state toggles

When there is more room and users are already setting long-term preferences, a three-state control is clearer, and the data model maps directly to its options: system, light, and dark.

To reduce cognitive load, show what the current system setting is on the "System" option, for example:

- an icon, such as a small sun at the bottom right of the system icon;
- text, such as "System (Currently light)".
