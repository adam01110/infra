# Implement natural interactions

Interfaces feel natural when every input gets an immediate response, motion behaves like a physical object, content follows the user's finger, and nothing depends on a mouse.

## Implementation

### Give every control hover, press, and focus feedback

```css
:where(button) {
  /* Example durations. */
  transition: box-shadow 150ms ease-out, scale 150ms ease-out;
}
button:hover { box-shadow: 0 2px 8px rgb(0 0 0 / 0.2); }
a:hover { text-decoration-thickness: 2px; }
button:active { scale: 0.97; } /* Example value. */

:where(a, button, input, select, textarea, summary, [tabindex]):focus-visible {
  outline: 2px solid CanvasText;
  outline-offset: 3px;
}
```

- Use `:focus-visible` so keyboard users always see a clear focus ring, without showing it on mouse clicks.
- Remove a focus outline (`outline: none` or `outline: 0`) only when you provide an equally visible replacement with at least a 3:1 contrast ratio against the page (WCAG 1.4.11). `CanvasText` is the text color for the page's `color-scheme`, so it contrasts with the default page background in light mode, in dark mode (with `color-scheme: light dark`), and in forced colors. If you set your own page background, pick a ring color with 3:1 contrast against it. `currentColor` fails when a button's text color matches the page.
- Make each interaction state look different, including combinations: hover, press, pressing while hovering, and keyboard focus. In the example, hover adds a shadow, press a scale, and focus an outline, so any combination shows each of its parts.

### Open disclosures from their trigger

Popovers and dropdowns should visibly open from the control that triggered them: scale out from the corner touching the trigger, or slide out from its side. Menus and hovercards have their own open motion; follow the `menu` and `hovercard` guides. For other popovers, place the popover next to its trigger and set `transform-origin` to the corner that touches it. To flip dropdowns at viewport edges, see the `viewport-aware-dropdowns` guide.

```css
.dropdown {
  /* popovertarget makes the trigger the popover's anchor. */
  position-area: bottom span-right;
  inset: auto;
  margin: 0;
  /* The corner touching the trigger; change it whenever the placement changes. */
  transform-origin: top left;
}
/* Example durations. */
.dropdown:is(:popover-open, .\:popover-open) { animation: fade-in 150ms ease-out both; }
@media (prefers-reduced-motion: no-preference) {
  .dropdown:is(:popover-open, .\:popover-open) {
    /* Optional example spring curve, written inline. */
    animation: grow 300ms linear(0, 0.45 15%, 1.08 35%, 0.97 55%, 1.01 75%, 1) both, fade-in 150ms ease-out both;
  }
}
@keyframes grow { from { scale: 0.9; } }
@keyframes fade-in { from { opacity: 0; } }
```

- Keep animations on the compositor (`transform`, its individual properties, and `opacity`) and respect reduced-motion preferences; see the `motion` guide. This example animates only the opening; for exit transitions, see the `animate-to-from-top-layer` guide.
- Trigger popovers declaratively with `<button popovertarget="dropdown-id">` to get native click, keyboard, and dismiss behavior without JavaScript; see the `declarative-dialog-popover-control` guide.
- For a springy open, use a `linear()` curve that overshoots slightly (an output value above 1) before settling; see the `physics-based-easing` guide.

### Make horizontal scrollers swipeable

Any horizontally scrollable row of items, such as a carousel, gallery, or row of chips, should scroll natively and snap to its items.

```css
.scroller {
  display: flex;
  gap: 1rem;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
}
.scroller > * {
  flex: 0 0 85%; /* Example item width. */
  scroll-snap-align: start;
}
```

- Native overflow scrolling gives swiping its physics and momentum, and snapping makes each swipe come to rest on an item, with no touch listeners.
- If none of the scroller's items contains a link, button, or other focusable element, make the scroller itself focusable and labeled (`<div class="scroller" role="region" aria-label="Featured items" tabindex="0">`), so keyboard users can reach it and scroll it with the arrow keys. When items are focusable, tabbing to them already scrolls them into view.
- To highlight the item that snaps into place, see the `carousel-snap-highlights` guide. To swipe a list item aside to reveal actions, see the `swipe-to-reveal` guide. For side menus that close when swiped away, see the `navigation-drawer` guide.
- For carousel controls such as previous and next buttons and scroll markers, see the `carousel` guide.

### Add motion blur to large, fast movements (optional)

For large, rapid translations (such as a full-screen sheet sliding into view), a subtle, temporary blur softens the movement. `filter` doesn't run only on the compositor, so keep blur to large, brief movements, skip it for small controls and slow transitions, and always guard it with a reduced-motion media query.

```css
@media (prefers-reduced-motion: no-preference) {
  .sheet.is-open { animation: sheet-in 300ms ease-out both; } /* Example duration. */
}
@keyframes sheet-in {
  from { translate: 0 100%; filter: blur(6px); } /* Example blur radius. */
}
```

### Make every action reachable without a mouse

- Use `<button>` for actions and `<a>` with an `href` for navigation. Both receive keyboard focus and activate on <kbd>Enter</kbd>; buttons also activate on <kbd>Space</kbd>.
- Menus and dropdowns may open on hover, but never only on hover: they also open on click, tap, and keyboard activation, stay open while the pointer moves onto them, and close with <kbd>Esc</kbd> (WCAG 2.1.1, 1.4.13).
- Controls or details revealed in place on hover, such as card actions, also need to appear on keyboard focus and be visible by default on devices without hover:

```css
.card .actions {
  opacity: 0;

  .card:hover &,
  .card:focus-within & { opacity: 1; }

  @media (hover: none) { opacity: 1; }
}
```

For tooltips and previews triggered on hover, focus, or long-press, see the `interest-triggered-tooltips` and `interest-triggered-action-previews` guides.

## Fallback strategies

### Popover

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

Popover is mostly progressive enhancement, but its defining behaviors (top-layer promotion, light dismiss, and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you would rather not ship one.

To support the `popover` attribute in older browsers, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) only when native support is missing, detected by the `popover` property on `HTMLElement.prototype`. Loading it unconditionally ships code that browsers with native support don't need.

With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, such as `"https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js"`.

Polyfill caveats:

- In code that may run before the polyfill has loaded, use `setAttribute()` and `removeAttribute()` instead of the `popover` IDL property. Setting the property there is not mirrored to the attribute, so the polyfill never picks up that popover, and the property permanently shadows the accessor the polyfill adds.
- The polyfill can't define the real `:popover-open` pseudo-class, so it applies a `.\:popover-open` class instead. Combine the two with `:is()` or `:where()`; in a plain selector list, browsers that lack `:popover-open` discard the entire rule.

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

Baseline status for the html.elements.button.popovertarget.implicit_anchor_reference capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

Without support, `inset: auto` leaves the popover at the top-left corner of the viewport. When `CSS.supports('position-area: bottom')` is false, set the popover's `top` and `left` from the trigger's `getBoundingClientRect()` in a `beforetoggle` event listener.

### Linear easing

Baseline status for linear() easing: Widely available. It's been Baseline since 2023-12-11.
Supported by: Chrome 113 (May 2023), Edge 113 (May 2023), Firefox 112 (Apr 2023), and Safari 17.2 (Dec 2023).

Browsers without `linear()` drop the declaration that uses it, so precede it with one that uses a keyword such as `ease-out`, as the fade-in above does. Write `linear()` inline, not through a custom property; otherwise the declaration is valid at parse time and fails only at computed-value time, which discards the earlier declaration too.
