# Build an interactive hovercard

A hovercard shows an interactive preview when a user shows interest in a link by hovering or focusing it. It appears before they navigate and either gives them what they need or confirms the link leads where they want.

For plain-text, non-interactive tooltips rather than structured link previews, see the `interest-triggered-tooltips` guide.

## 1. Triggering the hovercard

Trigger the hovercard with the Interest Invokers API, so the card appears on both hover and focus.

- Add `popover="hint"` to the card container. `hint` avoids closing unrelated popover menus that may be open.
- Add the `interestfor` attribute to the trigger link, pointing to the card's `id`.

```html
<a href="/article" interestfor="article-preview">Article title</a>

<!-- The `id` must match the `interestfor` value on the trigger. -->
<div id="article-preview" popover="hint" class="hovercard">
  <h2>The buzz on hummingbirds</h2>
  <p class="byline">By Delphi Aguilar</p>
  <div>
    <img src="bird.jpg" alt="A vibrant hummingbird">
    <p>Brief summary of the article...</p>
  </div>
</div>
```

The hovercard does not need its own link to the content; it would duplicate the trigger link.

### Accessibility

The `interestfor` specification wires hint popovers (`popover="hint"`) to assistive technology itself, based on what the target contains. A plain hint (text and images only) becomes the trigger's accessible description, or its name if the trigger has none. A rich hint (headings, links, or other interactive content) gets a minimum role of `tooltip`, the trigger gets `aria-expanded` and an `aria-details` relation while the hint is open, and the open hint comes right after the trigger in the tab order so keyboard users can reach its content.

Browsers and screen readers do not yet expose this consistently, so add explicit ARIA as well:

- Hint that repeats the trigger's accessible name (for example an icon-only button with `aria-label="Bold"` and a "Bold" tooltip): add nothing. A description identical to the name would be read twice.
- Hint on a trigger with no visible label of its own (for example an icon-only button without `aria-label`): put `aria-labelledby` on the trigger pointing at the hint, so the hint becomes the name.
- Hint whose trigger also opens it on activation (a toggletip, or any button whose only job is the hint; give it `popovertarget` with `popovertargetaction="show"`): put `role="tooltip"` on the hint and `aria-expanded` on the trigger, kept in sync with the popover's `toggle` event. A description read right after "button" suggests further actions and muddles the role; the expanded state tells the user there is content to reveal and whether it is open, and pressing the button delivers it. Place the hint right after the trigger in the DOM so reading keys reach its content once it is open.
- Hint whose trigger does something else on activation (a link, a button with its own action): put `role="tooltip"` on the hint and `aria-describedby` on the trigger, never `aria-expanded`. A trigger announced as "collapsed" suggests `Enter` would expand it, but `Enter` navigates or acts. The hint must be something the user can afford to miss: a hovercard previews the destination, a tooltip on an action button describes the action.
- Do not attach a hint that opens on activation to a control that already uses `aria-expanded` for something else (for example, a menu button). Give that hint its own trigger instead.
- Do not move focus into the target when interest is shown (no `autofocus`, no `focus()` in an `interest` listener). Interest is triggered by hover or focus alone, so moving focus would fail WCAG 3.2.1 (On Focus).

Not every screen reader reads descriptions when moving through the page (NVDA skips them in browse mode by design), so a hint exposed as a description must only carry content the user can afford to miss. Link previews and tooltips on action controls qualify; anything the user needs belongs in a toggletip or inline.

Wire this with a short script instead of hand-authoring the attributes, so the markup stays declarative and the same rules apply to every hint. The script should:

1. Run in every browser, once the DOM is parsed and before loading the `interestfor` polyfill, and expose a function that can be called again for content inserted later. Scan upfront: a browse-mode screen reader user needs the attributes in place before any interaction, so wiring them lazily on `focus` or `interest` is too late, and so is waiting for the polyfill, which wires its ARIA only on `load` and adds no `role="tooltip"` to plain hints.
2. For every `[interestfor]` trigger whose target has `popover="hint"`, normalize whitespace and compare the hint text with the trigger's accessible name (`aria-labelledby` targets, else `aria-label`, else text content including image `alt`, else `title`). Equal: do nothing. Otherwise set `role="tooltip"` on the hint if it has no role.
3. When the trigger has no name, point `aria-labelledby` at the hint unless it already has one. Otherwise, if the trigger also opens the hint on activation (a `popovertarget` or `commandfor` naming the hint), set `aria-expanded` to the popover's current state (`:popover-open`) unless it already has `aria-expanded`, and remember which triggers the script owns; if not, point `aria-describedby` at the hint unless it already has one.
4. Keep `aria-expanded` in sync from the popover's `toggle` event in every browser with a single capturing listener on `document`, updating every trigger with a matching `interestfor` that the script owns (the `interestfor` polyfill does not sync `aria-expanded` on plain-text hints or when a toggletip is opened via `popovertarget`).

Things that are easy to get wrong:

- `toggle` does not bubble. A bubbling listener on `document` never fires; use the capture phase (or a listener per popover).
- Sync `aria-expanded` from `toggle`, not from `interest`/`loseinterest`. The popover is the source of truth: it can be closed by `Escape`, light dismiss, or another invoker, and several triggers can share one hint.
- A hidden popover is a valid `aria-describedby` or `aria-labelledby` target. Do not force the hint open or duplicate its text to make it "visible".
- Do not add `aria-haspopup` or a live region to any hint.
- Do not override author ARIA: an existing `aria-describedby`, `aria-labelledby`, or `aria-expanded` on the trigger wins.

Use hovercards only for supplemental information, such as a preview of what the link leads to, never for information that is not available any other way.

## 2. Positioning with Anchor Positioning

Position the hovercard against its trigger with CSS anchor positioning. With `interestfor`, the trigger is an implicit anchor for the popover. A popover also needs `inset: auto` and `margin: 0` for anchored placement; set those only inside `@supports`, as in [Option 2](#option-2-progressive-enhancement-with-supports-no-polyfill) below, so browsers without anchor positioning keep the centered popover.

```css
[popover].hovercard {
  /* Position the card below the trigger, aligned with its inline-start edge
     and spanning toward the inline-end, flipping if it overflows the viewport. */
  position-area: block-end span-inline-end;
  position-try-fallbacks: flip-block, flip-inline, flip-block flip-inline;
}
```

## 3. Animating entry and exit

By default, interest is shown and lost after a half-second delay for keyboard and mouse users. This keeps the popover from opening while the user tabs through the page or moves the mouse around, and from closing while the mouse travels from the trigger to the popover. Adjust the timing with the `interest-delay` property.

```css
[interestfor]{
  /* Shorthand for interest-delay-start and interest-delay-end */
  interest-delay: 0.2s 0.1s;
}
```

If users are likely to move through several triggers in quick succession, set the start delay to `0s` while an interest-triggered popover is already open. To avoid `:has()` performance problems, anchor it on a nearby container with few child nodes and target the triggers as directly as possible.

```css
.container:has( > li > a:interest-source) [interestfor] {
  interest-delay-start: 0s;
}
```

Define the entry animation with `@starting-style`, and animate the exit from the top layer with `transition-behavior: allow-discrete` plus `display` and `overlay` in the transition. Apply the transitions only under `@media (prefers-reduced-motion: no-preference)`. Declare `transition-behavior: allow-discrete` as a separate property after `transition`, not inside the shorthand, so older browsers do not drop the whole `transition` declaration.

```css
[popover].hovercard {
  opacity: 0;
  transform-origin: top;
}

[popover].hovercard:popover-open {
  opacity: 1;
  transform: translateY(0) scale(1);
}

@starting-style {
  [popover].hovercard:popover-open {
    opacity: 0;
    transform: translateY(-10px) scale(0.95);
  }
}

@media (prefers-reduced-motion: no-preference) {
  [popover].hovercard {
    transition:
      opacity,
      transform,
      display,
      overlay;
    transition-duration: 0.4s;
    /* Separate after transition so the shorthand doesn't reset it or fail in older browsers */
    transition-behavior: allow-discrete;
  }
}
```

## 4. Optional: morph into the next page

Cross-document view transitions can morph the hovercard into the destination page (see the `consistent-cross-document-transitions` guide for implementation).

Give elements in the hovercard the same `view-transition-name` as their counterparts on the next page, and the browser animates them across the navigation. Naming several elements (titles, images, bylines) gives a multi-element morph. Assign the names only on the open popover with `:popover-open`, which avoids duplicate names and link-specific names.

```css
/* Opt-in to cross-document transitions on both pages */
@view-transition {
  navigation: auto;
}

/* Don't show transitions when loading this page */
::view-transition-group(*) {
  animation-duration: 0s;
}

/* Names apply only while the popover is open, so only its elements are selected. */
[popover].hovercard:popover-open {
  view-transition-name: --hovercard;
  view-transition-class: morph;

  h2 {
    view-transition-name: --title;
    view-transition-class: morph;
  }

  img {
    view-transition-name: --image;
    view-transition-class: morph;
  }
}
```

To keep the transition stable and free of flicker, make the destination page use `<link rel="expect">` with `blocking="render"` to wait until critical content is parsed before rendering the first frame.

```html
<!-- On the destination page: -->
<head>
  <!-- Block rendering until the hero image and title are parsed,
       ensuring the view transition snapshot is taken at the right time. -->
  <link rel="expect" href="#main-content" blocking="render">
</head>
<body>
  <main id="main-content">
    <h1>The buzz on hummingbirds</h1>
    <img src="bird.jpg" alt="A vibrant hummingbird">
  </main>
</body>
```

```css
/* On the destination page: */
main {
  view-transition-name: --hovercard;
  view-transition-class: morph;
}
h1 {
  view-transition-name: --title;
  view-transition-class: morph;
}
img {
  view-transition-name: --image;
  view-transition-class: morph;
}

/* By default no transition */
::view-transition-group(*) {
  animation-duration: 0s;
}
/* Short transition for morphing elements */
::view-transition-group(.morph) {
  animation-duration: 0.4s;
}
/* Disable transition if no `old` view */
::view-transition-new(.morph):only-child {
  animation-duration: 0s;
}
```

## Fallback strategies

The trigger is a standard `<a href="...">` link, so if you treat the hovercard as progressive enhancement, browsers without support still navigate on click. When hovercards must work across browsers, load polyfills conditionally.

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

### `popover="hint"`

Browser support for popover="hint": Limited availability.
Supported by: Chrome 151 (Jul 2026), Edge 151 (Jul 2026), and Firefox 153 (Jul 2026).
Unsupported in: Safari.

`@oddbird/popover-polyfill` does not polyfill `popover="hint"` in browsers that already support native `popover` (`auto` and `manual`). There the unrecognized `"hint"` value falls back to `popover="manual"` (the HTML invalid-value default), so a hovercard opened by keyboard focus can stay open when a second one opens on pointer hover, unless the invoker explicitly dismisses it when interest is lost.

### Interest invokers

Browser support for Interest invokers: Limited availability.
Supported by: Chrome 149 (Jun 2026) and Edge 149 (Jun 2026).
Unsupported in: Firefox and Safari.

Polyfill interest invokers with the `interestfor` npm package, loaded only when native support is missing, detected by the `interestForElement` property on `HTMLButtonElement.prototype`. Prefer bundling the polyfill over loading it from a CDN.

```html
<script type="module">
  if (!("interestForElement" in HTMLButtonElement.prototype)) {
    // CDN used only for the example; prefer bundling.
    await import("https://unpkg.com/interestfor@latest");
  }
</script>
```

### CSS caveats of the `interestfor` polyfill

The polyfill cannot provide the native pseudo-classes and properties, so the CSS changes slightly:

- It cannot define real `:interest-source` and `:interest-target` pseudo-classes, so it applies `.interest-source` and `.interest-target` classes. Combine each pair with `:is()` to cover native and polyfilled states.

```css
/* Styles to apply when the effect is being previewed */
:is(:interest-source, .interest-source) { /* ... */ }
:is(:interest-target, .interest-target) { /* ... */ }
```

- For `interest-delay`, `interest-delay-start`, and `interest-delay-end`, the polyfill needs matching custom properties, because it cannot read the unknown properties directly in all browsers.

```css
/* Adjust the start and end delay for interest invokers */
[interestfor] {
  --interest-delay-start: 0.2s;
  interest-delay-start: var(--interest-delay-start);
  --interest-delay-end: 0.1s;
  interest-delay-end: var(--interest-delay-end);
}
```

To zero the start delay while an interest-triggered popover is open (for triggers users move through quickly), set the custom property:

```css
.container:has([interestfor]:is(:interest-source, .interest-source)) [interestfor] {
  --interest-delay-start: 0s;
}
```

### Anchor positioning

Browser support for Anchor positioning: Limited availability.
Supported by: Chrome 157 (Nov 2026), Edge 157 (Nov 2026), and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without anchor positioning, tethered elements such as `[popover]` overlays fall back to their default user-agent placement (centered in the viewport for popovers). Depending on whether the element must stay tethered, either load the polyfill conditionally or gate the positioning rules with `@supports`.

#### Option 1: Polyfill (`@oddbird/css-anchor-positioning`)

When the positioned element must stay tethered to its trigger in unsupported browsers, load the `@oddbird/css-anchor-positioning` package only when native support is missing. Detect support with `CSS.supports("anchor-name: --a")` (or `"anchorName" in CSSStyleDeclaration.prototype`).

With a bundler or import map:

```js
if (!CSS.supports("anchor-name: --a")) {
  import("@oddbird/css-anchor-positioning");
}
```

Without a bundler, import it from a CDN in a module script:

```html
<script type="module">
  if (!CSS.supports("anchor-name: --a")) {
    import("https://unpkg.com/@oddbird/css-anchor-positioning");
  }
</script>
```

Polyfill caveats:

- No implicit anchors. The polyfill does not support implicit anchor associations (such as those created by `popovertarget`, `commandfor`, `interestfor`, or `showPopover({ source })`). Set a unique explicit `anchor-name` on each trigger and a matching `position-anchor` on the positioned element.
- No `position-area` with `position-try-fallbacks`. On polyfilled elements that need fallbacks, position with `anchor()` functions on the inset properties (`top`, `left`, `right`, `bottom`) and `inset: auto` instead of `position-area`.
- Do not wrap polyfilled rules in `@supports`. Browsers without native anchor positioning evaluate `@supports (position-area: ...)` and `@supports (anchor-name: --a)` as false and discard the block before the polyfill can read it.

```css
.trigger {
  /* Each trigger and positioned element pair shares a unique anchor name. */
  anchor-name: --my-trigger;
}

[popover].anchored-overlay {
  position-anchor: --my-trigger;
  /* anchor() insets instead of position-area, for elements that need fallbacks under the polyfill. */
  inset: auto;
  top: anchor(bottom);
  left: anchor(left);
  margin: 0;
}
```

#### Option 2: Progressive enhancement with `@supports` (no polyfill)

Without the polyfill, do not set `inset: auto` or `margin: 0` unconditionally on a `[popover]` that relies on `position-area` or `anchor()`. In browsers without anchor positioning, `inset: auto` overrides the user-agent centering (`inset: 0; margin: auto`) while `position-area` is ignored, leaving the popover stranded at `(0, 0)` or overlapping its trigger.

Instead, put `inset: auto` and `margin: 0` inside `@supports` for the specific feature used (for example `@supports (position-area: block-end)` or `@supports (top: anchor(bottom))`), so unsupported browsers keep the default centered placement, or add a matching `@supports not (...)` fallback layout such as a fixed bottom sheet:

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
  /* Optional: replace the default centering with a fixed bottom bar. */
  [popover].anchored-overlay {
    position: fixed;
    inset: auto 0 0 0;
    width: auto;
    margin: 0;
  }
}
```

### Cross-document view transitions

Browser support for Cross-document view transitions: Limited availability.
Supported by: Chrome 126 (Jun 2024), Edge 126 (Jun 2024), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Cross-document view transitions are progressive enhancement. Browsers without `@view-transition { navigation: auto; }` ignore it (and `blocking="render"` with `<link rel="expect">` on the destination page degrades gracefully), so clicking the link performs a normal navigation without the morph.
