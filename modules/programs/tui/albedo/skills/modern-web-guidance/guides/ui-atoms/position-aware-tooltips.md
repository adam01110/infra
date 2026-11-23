# Position Aware Tooltips

With CSS anchor positioning, the browser can flip a tooltip or popover to a fallback position when it would otherwise overflow the viewport. When it flips, you may need to restyle the positioned content, for instance to move an arrow that points from the tooltip to its anchor.

Anchored container queries let you query an element's active positioning state and style accordingly. For general anchored dropdown and flyout positioning with viewport collision flipping, without directional arrow restyling, see the `viewport-aware-dropdowns` guide.

## The problem

A tooltip shown above its anchor by default has a downward arrow at its bottom. If it flips below the anchor, for example after the user scrolls, the arrow points the wrong way and sits on the wrong side.

## The solution: anchored container queries

`container-type: anchored` makes the positioned element a query container that knows its own anchor-positioned state. `@container anchored()` queries then style its descendants or pseudo-elements.

### 1. Create the tooltip and trigger

Use the Popover API. Invoking the popover through `popovertarget` creates an implicit anchor connection with the trigger button, so no explicit `anchor-name` or `position-anchor` is needed.

```html
<button popovertarget="tooltip" id="anchor" aria-describedby="tooltip">anchor</button>
<div id="tooltip" popover role="tooltip"></div>
```

Reset the popover's default inset and margin for anchor positioning, only where anchor positioning is supported:

```css
@supports (anchor-name: --my-anchor) {
  [popover] {
    inset: auto;
    margin: unset;
  }
}
```

### 2. Set up the container

Apply `container-type: anchored` to the positioned element. It also needs `position-try-fallbacks` to enable flipping.

```css
#tooltip {
  position: fixed;
  position-area: block-start;
  position-try-fallbacks: flip-block;
  container-type: anchored;
}
```

### 3. Style based on the fallback

`@container anchored(fallback: <value>)` applies styles while a specific fallback is active.

Like all container queries, it styles only descendants of the container. `::before` and `::after` on the container count as descendants and are a common way to draw arrows. To also be able to style the tooltip box itself (step 4), add a child element and draw the arrow in its `::before`:

```html
<div id="tooltip" popover role="tooltip">
  <div class="tooltip-content">Tooltip</div>
</div>
```

```css
.tooltip-content::before {
  /* Default downward arrow for the top position. */
  content: "▼" / "";
  position: absolute;
  inset-block-end: 0;
  inset-inline-start: 1rem;
}

/* Upward arrow while the flip-block fallback (bottom) is active. */
@container anchored(fallback: flip-block) {
  .tooltip-content::before {
    content: "▲" / "";
    inset-block-start: 0;
    inset-block-end: auto;
  }
}
```

### 4. Styling the container itself

To change properties of the tooltip box itself (such as `margin` or `background-color`) when it flips, use an inner wrapper: apply `container-type: anchored` to the outer positioned element and target the inner element inside the `@container` block.

```css
@container anchored(fallback: flip-block) {
  .tooltip-content {
    border-radius: 0 0 .5rem .5rem;
    margin-block-start: 0.25rem;
  }
}
```

### 5. Constraining long content (optional)

For long tooltip text, use an inner container so the visible tooltip always fits between the trigger and one edge of the viewport. This example does that when the tooltip flips on the block axis with `flip-block`. `--trigger-height` stands for the trigger's block size; set it to that value (for example `2.5rem`) where you style the trigger or tooltip.

```html
<button popovertarget="tooltip" id="anchor" aria-describedby="tooltip">anchor</button>
<div id="tooltip" popover role="tooltip">
  <div class="tooltip-content-inner"></div>
</div>
```

```css
.tooltip-content-inner {
  max-block-size: calc(50dvb - var(--trigger-height));
  /* overflow-block is Firefox-only so far; overflow-y covers other browsers. */
  overflow-y: auto;
  overflow-block: auto;
}
```

## Best practices

- Prefer logical fallbacks such as `flip-block` and `flip-inline` in `position-try-fallbacks`. They keep queries simple and handle RTL and other writing modes automatically.
- Draw arrows with pseudo-elements. Arrows are decorative, and `::before` or `::after` can be styled through anchored container queries without extra DOM.

## Accessibility considerations

A tooltip can cover a control when that control receives focus, which fails WCAG 2.4.11 Focus Not Obscured (Minimum) (Level AA): a focused item must not be completely obscured. There is no generic fix, but you can adjust the tooltip's position or whether it is shown.

Keyboard navigation does not close a `popover=auto` tooltip, so make sure tooltips do not cover interactive elements as they receive keyboard focus. If a tooltip is likely to cover a focused element, move the tooltip or dismiss it when it is no longer relevant.

## Fallback strategies

Browser support for Anchor position container queries: Limited availability.
Supported by: Chrome 143 (Dec 2025) and Edge 143 (Dec 2025).
Unsupported in: Firefox and Safari.

Positioning the arrow by the active fallback is a progressive enhancement; there is no other way to react to the fallback position. To hide the arrow in browsers without anchored container queries, move step 3's default `content` declaration into `@supports (container-type: anchored)`:

```css
@supports (container-type: anchored) {
  .tooltip-content::before {
    content: "▼" / "";
  }
}
```

### Popover support and fallbacks

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

The Popover API is mostly progressive enhancement, but its defining behaviors (top-layer promotion, light dismiss, and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you would rather not ship one.

To support the `popover` attribute in older browsers, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) conditionally: check for the `popover` property on `HTMLElement.prototype` and load the polyfill only when native support is missing, never unconditionally.

With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, such as `"https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js"`.

Polyfill caveats:

- Do not use the `popover` IDL property in code that may run before the polyfill has loaded. The value is not mirrored to the attribute, the polyfill does not pick up the popover, and the property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill cannot define the real `:popover-open` pseudo-class, so it applies a `.\:popover-open` class instead. Combine the two with `:is()` or `:where()`; otherwise browsers that lack `:popover-open` discard the whole rule:

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

Browsers without the Popover API also lack anchor positioning, so there the tooltip appears in the center of the screen.
