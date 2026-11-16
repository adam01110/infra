# Viewport-Aware Dropdowns

A revealed action panel or popover button group gives access to extra functionality in little space. The panel must stay tethered to its trigger while adapting to the viewport, a job that used to need JavaScript libraries such as Popper.js or Floating UI to calculate positions and handle collisions. CSS anchor positioning handles positioning and overflow natively and declaratively.

This guide shows anchor positioning and popover mechanics, not a specific accessible UI pattern. The trigger and panel below are a plain button that reveals a button group. If you need a true ARIA menu (`role="menu"` with arrow-key navigation), a combobox, a disclosure widget, or another named pattern, add that pattern's full semantics and keyboard contract on top of these positioning techniques.

## 1. Define the button and panel relationship

Create a trigger button that opens the panel with the Popover API.

This pattern is a button group revealed inside a popover, not an ARIA menu. Don't apply `role="menu"` or `role="menuitem"` unless you implement the matching keyboard contract, such as arrow-key navigation between items. For the same reason, don't add `aria-haspopup` to the trigger: its value (`menu`, `listbox`, `tree`, `grid`, or the legacy `true`) promises that the target exposes a matching role, which this pattern does not.

```html
<button popovertarget="action-panel">
  Open Actions
</button>
<!-- popover="auto" puts the panel in the top layer and lets the browser handle it accessibly. -->
<div id="action-panel" popover="auto" class="panel">
  <button class="action-item" type="button">Edit</button>
</div>
```

`popovertarget` creates an implicit anchor association between button and panel, so the panel can be positioned relative to the button without `anchor-name` on the button or `position-anchor` on the panel.

### 2. Position with `position-area`

Instead of manual `top`/`left` offsets, use `position-area` to place the panel on a 3x3 grid around the anchor.

```css
.panel {
  /* Below the anchor (block-end), starting at the anchor's start edge and spanning toward its end. */
  position-area: block-end span-inline-end;
}

/* Resets the popover's default centering so the position-area grid takes control.
   Gated because, without anchor positioning, these resets strand the popover at (0, 0); see Fallback strategies. */
@supports (position-area: block-end) {
  .panel {
    inset: auto;
    margin: 0;
  }
}
```

Prefer logical keywords (`span-inline-end`, `block-start`) over physical ones (`left`, `top`) so RTL and other writing modes work automatically. Don't mix physical and logical keywords in one `position-area`.

### 3. Handle viewport edges with fallbacks

Define try tactics for the browser to use when the default position overflows, so the panel is never cut off at the edge of the screen:

```css
.panel {
  /* Flip vertically on block overflow, horizontally on inline overflow, and on both axes in a corner. */
  position-try-fallbacks: flip-block, flip-inline, flip-block flip-inline;
}
```

If the dropdown or flyout has a directional arrow or border that must change with the chosen fallback position, see the `position-aware-tooltips` guide. For declarative invocation of dialogs and popovers without JavaScript, see the `declarative-dialog-popover-control` guide.

## Fallback strategies

### Popover

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

### Anchor positioning

Browser support for Anchor positioning: Limited availability.
Supported by: Chrome 157 (Nov 2026), Edge 157 (Nov 2026), and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without anchor positioning, tethered elements such as `[popover]` overlays fall back to their default user-agent placement, centered in the viewport for popovers. If the element must stay tethered to its trigger, load the polyfill conditionally; otherwise gate the positioning rules with `@supports`.

#### Option 1: Polyfill (`@oddbird/css-anchor-positioning`)

Feature-detect with `CSS.supports("anchor-name: --a")` (or `"anchorName" in CSSStyleDeclaration.prototype`) and load the polyfill only when native support is missing, never unconditionally.

With a bundler or import map:

```js
if (!CSS.supports("anchor-name: --a")) {
  import("@oddbird/css-anchor-positioning");
}
```

Without a bundler, import it from a CDN inside a `<script type="module">`:

```html
<script type="module">
  if (!CSS.supports("anchor-name: --a")) {
    import("https://unpkg.com/@oddbird/css-anchor-positioning");
  }
</script>
```

Polyfill caveats:

- It does not support implicit anchors, such as those created by `popovertarget`, `commandfor`, `interestfor`, or `showPopover({ source })`. Set a unique explicit `anchor-name` on each trigger and a matching `position-anchor` on its positioned element.
- It does not support `position-area` together with `position-try-fallbacks`. For elements that need fallbacks, position with `anchor()` functions on the inset properties (`top`, `left`, `right`, `bottom`) and `inset: auto` instead of `position-area`.
- Don't wrap polyfilled rules in `@supports`. Browsers without native anchor positioning evaluate `@supports (position-area: ...)` and `@supports (anchor-name: --a)` as false and discard the block before the polyfill can process it.

```css
.trigger {
  /* Each trigger and positioned element pair shares a unique anchor name. */
  anchor-name: --my-trigger;
}

[popover].anchored-overlay {
  position-anchor: --my-trigger;
  /* anchor() on inset properties instead of position-area, because the polyfill needs it for fallbacks. */
  inset: auto;
  top: anchor(bottom);
  left: anchor(left);
  margin: 0;
}
```

#### Option 2: Progressive enhancement with `@supports` (no polyfill)

Without the polyfill, don't set `inset: auto` or `margin: 0` unconditionally on a `[popover]` that relies on `position-area` or `anchor()`. In browsers without anchor positioning, `inset: auto` overrides the user-agent centering (`inset: 0; margin: auto`) while `position-area` is ignored, leaving the popover stranded at `(0, 0)` or overlapping its trigger.

Gate `inset: auto` and `margin: 0` inside `@supports` for the specific feature used (such as `@supports (position-area: block-end)` or `@supports (top: anchor(bottom))`) so unsupported browsers keep the default centered placement, or provide a matching `@supports not (...)` layout such as a fixed bottom sheet:

```css
@supports (position-area: block-end) {
  [popover].anchored-overlay {
    inset: auto;
    margin: 0;
    position-area: block-end span-inline-end;
    position-try-fallbacks: flip-block, flip-inline, flip-block flip-inline;
  }
}

@supports not (position-area: block-end) {
  /* Optional: replaces the default popover centering with a fixed bottom bar. */
  [popover].anchored-overlay {
    position: fixed;
    inset: auto 0 0 0;
    width: auto;
    margin: 0;
  }
}
```
