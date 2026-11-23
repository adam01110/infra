# Responsive Site Navigation

Build a site navigation bar that uses one semantic navigation tree at every size, presents a native popover when the links do not fit, becomes an inline navigation when they do, and identifies the current page.

This is site navigation, not an application menu: links stay in the `Tab` order, with no `focusgroup`, `role="menubar"`, `role="menu"`, `role="menuitem"`, `aria-haspopup="menu"`, or arrow-key handling. For application command menus, see the `menu` guide; for menubars, the `app-menus` guide; for the menu and chevron icons, the `icons` guide.

For component-driven layouts, fluid sizing, and typographic line-wrapping, see the `size-aware-styling`, `fluid-scaling`, and `improve-text-layout-and-legibility` guides.

## Core Markup

Use one `<nav>` landmark for narrow and wide layouts, inside a semantic `<header>` whose `is-wide` class selects the inline layout. The collapsed layout is the default, so it is also what users get without script.

```html
<header class="site-header">
  <div class="header-inner">
    <a class="site-logo" href="index.html">Acme</a>

    <nav class="site-nav" aria-label="Primary">
      <button
        class="menu-button"
        type="button"
        popovertarget="site-menu"
        popovertargetaction="toggle"
        aria-controls="site-menu"
      >
        <!-- Decorative menu icon: insert as described in the icons guide -->
        <span>Menu</span>
      </button>

      <ul id="site-menu" class="site-menu" popover="auto">
        <li><a href="index.html" aria-current="page">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li class="nav-dropdown">
          <button
            class="dropdown-trigger"
            type="button"
            aria-expanded="false"
            aria-controls="services-menu"
            popovertarget="services-menu"
          >
            Services
          </button>
          <ul id="services-menu" class="dropdown-list">
            <li><a href="design.html">Design</a></li>
            <li><a href="development.html">Development</a></li>
          </ul>
        </li>
      </ul>
    </nav>
  </div>
</header>
```

The button controls the menu declaratively with `popovertarget` and `aria-controls`. The `nav` stays the navigation landmark while the menu is closed. The icon is decorative and the visible "Menu" text is the accessible name, so hide the icon from assistive technologies (the `icons` guide covers inserting and hiding icons; the `declarative-dialog-popover-control` guide covers the general popover control contract). Use `popovertarget` rather than invoker commands, since one toggle needs nothing more. Place each popover (the menu list and the submenu list) immediately after its trigger so browsers add no implicit `aria-details`.

## Narrow Layout: Popover Navigation

When collapsed, keep `popover="auto"` on the navigation list. Anchor the fixed popover to the menu button and limit its height so a long navigation scrolls instead of overflowing the viewport.

There is no hard-coded breakpoint. Script collapses the navigation only when the inline row (brand, actions, and every link) does not fit, so adding a link, a translation, or larger text moves the switch point automatically. Script adds `is-wide` to the header when the row fits; without script the header stays collapsed at every width.

```css
/* Keep the row's natural width measurable */
.header-inner > * {
  flex-shrink: 0;
  white-space: nowrap;
}

.site-header {
  .menu-button {
    anchor-name: --menu-button;
  }

  .site-menu {
    position: fixed;
    inset: auto;
    inset-block-start: anchor(--menu-button bottom);
    inset-inline-end: 1rem;
    inline-size: min(80dvw, 24rem);
    max-inline-size: calc(100dvw - 2rem);
    block-size: fit-content;
    max-block-size: calc(100dvh - 6rem);
    margin-block-start: 0.5rem;
    overflow: auto;
  }
}
```

The `anchor()` declaration places the menu below the button; see [Fallbacks](#fallbacks) for browsers without anchor positioning. For collision-aware positioning near viewport edges, see the `viewport-aware-dropdowns` guide.

## Wide Layout: Inline Navigation

When the row fits, hide the menu button and reset the popover presentation so the same list sits in the header as inline navigation.

```css
.site-header.is-wide {
  .menu-button {
    display: none;
  }

  .site-menu {
    position: static;
    display: flex;
    align-items: center;
    gap: 0.25rem;
    inline-size: auto;
    max-inline-size: none;
    block-size: auto;
    max-block-size: none;
    overflow: visible;
    margin: 0;
    padding: 0;
    border: 0;
    background: transparent;
    box-shadow: none;
  }

  .site-menu::backdrop {
    display: none;
  }
}
```

CSS changes the presentation, but JavaScript decides which layout applies and keeps the `popover` attribute in sync with it:

- Measure the inline row: apply the inline layout, compare `scrollWidth` with `clientWidth` on the header's inner row, then set or clear `is-wide`.
- During the measurement, add a temporary `is-measuring` class that sets `transition: none` on descendants, and remove it in `requestAnimationFrame`. Otherwise the menu animates from its inline styles on every resize and flickers.
- Keep the `popover` attribute only in the collapsed layout and remove it in the inline layout. Removing it closes an open popover, so note whether the menu was open and call `showPopover()` again if the layout is still collapsed; otherwise a resize closes the open menu.
- Run one shared function from `ResizeObserver`s on the header and the navigation list, so font loading and text changes are caught without special cases.
- While inline, remeasure on every notification; while collapsed, only when the header's width has grown. Switching to inline just to measure on every shrink makes the layout thrash. The tradeoff: a collapsed menu whose content shrinks by itself (for example a shorter translation) stays collapsed until the header grows.
- Do not infer the layout from whether the trigger is hidden.

## Nested Site Navigation

Trigger nested site navigation with a `<button>` that has `aria-expanded` and `aria-controls`, followed immediately by the submenu list. Do not use `<details>` and `<summary>`: `<summary>` should map to a `button` role, but browsers implement this inconsistently, so screen readers announce it variously (for example as "summary" or "disclosure triangle").

The same list must be an inline disclosure when narrow and a floating popover when wide. A top-layer popover cannot render in flow, so `popover` is set only in the wide layout, where `popovertarget` opens it natively. Leave `popover` off the submenu in the markup: without script it stays a nested list inside the menu, matching the narrow layout. Also hide the narrow submenu from script rather than in the markup.

Sync the submenu from the same function that handles the navigation list. When inline, set `popover="auto"` on the submenu, clear `hidden`, and let the native `toggle` event drive `aria-expanded`. When narrow, remove `popover`, set `hidden`, and let a click handler toggle `hidden` and `aria-expanded`:

```js
const wide = inner.scrollWidth <= inner.clientWidth; // measured with is-wide set
if (wide) submenu.setAttribute("popover", "auto");
else submenu.removeAttribute("popover");
submenu.hidden = !wide;
trigger.setAttribute("aria-expanded", "false");
```

Use `setAttribute()` / `removeAttribute()` rather than the `popover` IDL property, which can race with the popover polyfill when one is loaded.

Do not add document-level click-outside, `Escape`, or focus-restoration handlers. The native popover provides those in the wide layout, and the narrow disclosure needs only the click handler. The declarative `popovertarget` makes the button the submenu's implicit anchor, so wide-layout positioning can use `position-area` without a separate `anchor-name` or `position-anchor` declaration.

### Hover preview

In the wide layout:

- Open the submenu with `submenu.showPopover({ source: trigger })` on `pointerenter` of the parent `<li>` when `matchMedia("(hover: hover)").matches` and `event.pointerType !== "touch"`.
- Hide it on `pointerleave` if it is still only hover-previewed. If the user clicks the trigger during a preview, clear the preview flag and call `event.preventDefault()` so the click pins the submenu open instead of toggling it closed.
- Do not open it when the trigger receives keyboard focus; only `Enter` or `Space` toggles it.
- Close the open submenu when focus moves outside the submenu's whole list item (`focusout` with a non-null `relatedTarget` outside it), so `Tab` or `Shift`+`Tab` away closes it.

Position the wide submenu below its trigger with anchor positioning (`position-area: block-end span-inline-end` and `position-try-fallbacks: flip-block, flip-inline`); for collision-aware positioning of a plain popover, see the `viewport-aware-dropdowns` guide. Add a `::before` bridge across any margin gap above the submenu (with `overflow: visible` on the popover) so moving the pointer from the trigger into the submenu does not fire `pointerleave`, and set `height: auto` so Safari does not stretch the positioned popover to its placement area:

```css
.site-header.is-wide {
  .dropdown-list[popover] {
    position: absolute;
    position-area: block-end span-inline-end;
    position-try-fallbacks: flip-block, flip-inline;
    inset: auto;
    height: auto;
    inline-size: max-content;
    min-inline-size: 12rem;
    margin-block-start: 0.5rem;
    overflow: visible;
  }

  .dropdown-list::before {
    content: "";
    position: absolute;
    inset-inline: 0;
    inset-block-end: 100%;
    block-size: 0.5rem;
  }

  /* Also hides the list before script sets popover, so an open narrow disclosure cannot widen the measured row */
  .dropdown-list:not(:is(:popover-open, .\:popover-open)) {
    display: none;
  }

  .dropdown-list:is(:popover-open, .\:popover-open) {
    display: grid;
  }
}
```

## Indicating the Current Page

Mark the current page with `aria-current="page"`, set at build time or with JavaScript, and style it with `[aria-current="page"]`. The visual treatment is a design decision; do not assume a particular pseudo-element, border, or orientation. Do not indicate the current page with color alone (WCAG 1.4.1), and give the indicator a contrast of at least 3:1 against the background.

## Transitions and Accessibility

Animation is optional; add it when the abrupt open and close feels out of place. For both the mobile menu and the wide floating submenu, use `@starting-style`, include `display` and `overlay` in `transition`, and declare `transition-behavior: allow-discrete` as a separate property after `transition`. Putting `allow-discrete` in the `transition` shorthand makes older browsers drop the whole declaration. Animate only `opacity` and `translate`, and respect `prefers-reduced-motion`. The `animate-element-entry-exit` guide has the reusable pattern.

### Optional: Narrow submenu slide-down

In the narrow layout the submenu is an inline list toggled with `hidden`. It opens instantly by default and works fully that way. To slide it open and closed:

- Keep the `[hidden]` list rendered with `display: grid` and `block-size: 0`, then transition `block-size` to `auto` with `interpolate-size: allow-keywords`. Clip the slide with `clip-path: inset(-6px)` so the focus ring is not cut off; `overflow: clip` would clip the ring. `6px` is an example: use at least the ring's outline width plus offset.
- Set `content-visibility: hidden` on the `[hidden]` list, include `content-visibility` in `transition`, and declare `transition-behavior: allow-discrete` separately after `transition` so the content stays rendered until the close finishes.
- Scope it to the collapsed layout and `prefers-reduced-motion: no-preference`; outside it, `[hidden]` must stay `display: none`. In the wide layout the submenu is a popover and must not be clipped.
- The `animate-to-intrinsic-sizes` guide covers the general technique.

Use logical properties for sizing, spacing, and positioning. Use `dvw` and `dvh` for viewport-relative limits, provide visible `:focus-visible` indicators, and adapt custom borders and current-page indicators under `forced-colors: active`.

## Fallbacks

### Popover

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

Popover is mostly progressive enhancement, but its defining behaviors (top-layer promotion, light dismiss, and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you prefer not to ship one.

To polyfill, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) only when native support is missing, detected by the `popover` property on `HTMLElement.prototype`. With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, for example `https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js`.

Polyfill caveats:

- Do not use the `popover` IDL property in code that may run before the polyfill has loaded. The value is not mirrored to the attribute, the polyfill does not pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill cannot define the real `:popover-open` pseudo-class, so it adds a `.\:popover-open` class. Combine the two with `:is()` or `:where()`; in a plain selector list, browsers without `:popover-open` discard the whole rule.

```css
[popover]:is(:popover-open, .\:popover-open) {
  display: block;
}
```

Until the polyfill loads, unsupported browsers render popovers as ordinary visible content. Hide them with CSS in the meantime:

```css
@supports not selector(:popover-open) {
  [popover]:not(.\:popover-open) {
    display: none;
  }
}
```

### Anchor positioning

Baseline status for the css.types.anchor capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

For the mobile menu, put a fixed fallback declaration before the `anchor()` declaration. No `@supports` is needed: browsers discard the unsupported `anchor()` declaration and keep the one before it. The menu then still opens as a popover at a fixed offset from the top of the viewport.

```css
.site-header {
  .site-menu {
    /* Example-only offset: use roughly your header height. Browsers without anchor() keep this one. */
    inset-block-start: 4.75rem;
    inset-block-start: anchor(--menu-button bottom);
  }
}
```

For the wide floating submenu, a popover without anchor positioning falls back to centered viewport placement, detached from its navbar trigger. Override the submenu to `position: fixed; margin: 0` inside `@supports not (position-area: block-end)`, and when `event.newState === "open" && !CSS.supports("position-area", "block-end")` in the submenu's `toggle` handler, compute `top` and `left` from `trigger.getBoundingClientRect()` and `submenu.getBoundingClientRect()` (placing it below the trigger, flipping above if `top + size.height > innerHeight`, and clamping `left` to `[0, innerWidth - size.width]`).

### Transitions

Baseline status for @starting-style: Newly available. It's been Baseline since 2024-08-06.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 129 (Aug 2024), and Safari 17.5 (May 2024).

Baseline status for transition-behavior: Newly available. It's been Baseline since 2024-08-06.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 129 (Aug 2024), and Safari 17.4 (Mar 2024).

Browser support for interpolate-size: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

Baseline status for content-visibility: Newly available. It's been Baseline since 2025-09-15.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 130 (Sep 2024), and Safari 26 (Sep 2025).

Put the optional narrow slide-down rules (the ones that override `[hidden]` with `display: grid`) inside `@supports (interpolate-size: allow-keywords)`. Without that gate, browsers lacking keyword interpolation snap the list closed instead of sliding; with it, they keep native `[hidden]` behavior. Without `@starting-style` or `transition-behavior: allow-discrete`, the optional popover entry and exit transitions fall back to opening and closing immediately.

Without script, nothing adds `is-wide`, so the header stays collapsed: the menu button opens the native popover and the submenu is a nested list. Do not write a separate no-script layout or a `no-js` class.
