# Creating Persistent App Tours

Onboarding tours need overlays that stay open while users interact with the highlighted features. Unlike auto popovers, manual popovers do not close when the user clicks elsewhere on the page. Combine `popover="manual"` with CSS anchor positioning to build non-modal tour steps tethered to the features they describe.

Use this pattern to introduce new or updated content. The popovers have no explicit relationship to each other: dismissing the first does not imply the user wants to move straight to the second. They can learn about the related feature when they reach that part of the page.

## Recommended implementation

### HTML

```html
<div id="feature-target">Highlight this feature</div>

<dialog id="tour-step" popover="manual" aria-labelledby="tour-title">
  <!-- An <h1> precedes this element in the full document outline. -->
  <h2 id="tour-title">Start a review</h2>
  <p>Begin the process by starting a review of the submitted document.</p>
  <button popovertarget="tour-step" popovertargetaction="hide">Got it</button>
</dialog>
```

### CSS

```css
#feature-target {
  anchor-name: --feature-target;
}

#tour-step {
  position-anchor: --feature-target;
  padding: 1rem;
  border: 1px solid blue;
  border-radius: 0.5rem;
  background: aliceblue;
}

/* Gated so browsers without anchor positioning keep the centered popover (see Fallback strategies). */
@supports (position-area: inline-end) {
  #tour-step {
    position-area: inline-end center;
    inset: auto;
    margin: 1rem;
  }
}
```

### JavaScript

This opens an initial onboarding tour, which the user goes through before using the page: run it when onboarding starts (for example on a first visit, or from a "Take the tour" button). Supplemental new-feature tours skip the `inert` and focus steps (see [Accessibility considerations](#accessibility-considerations)).

```javascript
const tourStep = document.getElementById('tour-step');
tourStep.showPopover();

// Make the rest of the document inert during the initial onboarding tour. The tour popover
// must not be inside this element, or it becomes inert and inaccessible too.
// Remove inert again when the tour finishes.
const main = document.querySelector("main");
main.inert = true;

// Move focus into the non-modal popover so keyboard and assistive technology users perceive the new context.
tourStep.querySelector('button').focus();
```

## Implementation guidelines

- Use `popover="manual"` so the tour step does not close accidentally while the user interacts with the page.
- Give the container dialog semantics (the `<dialog>` element, or `role="dialog"` on another element) and link its heading with `aria-labelledby`.
- For an initial onboarding tour that makes the rest of the page inert (as above), move focus inside the popover right after opening, so focus is not left behind. Supplemental new-feature tours do not take focus (see below).
- Tether the tour step to the feature it explains with CSS anchor positioning.
- Provide an explicit "Close" or "Next" button inside the popover that uses `popovertargetaction="hide"`.

## Accessibility considerations

Each popover must make sense on its own. Do not make its content depend on content outside it: "New feature. Click here" relies on visual information that people may not have or be able to reach (especially when the rest of the page is `inert`). "New chat functionality. Start a chat to review items with fellow members" is understandable in isolation. Start each tour popover with a heading, which gives context and lets screen reader users navigate to it when it is used non-modally.

Tours for new features are supplemental information. Do not move focus to them on page load: hijacking focus confuses people, who usually arrive with a goal of their own, and the tour should not distract them from it.

To keep the information supplemental, place the popover in the DOM immediately before the control it describes, so screen reader users can tell how the two relate while reading the page. When the popover is dismissed, move focus to the related control.

Popover content must:

- scale and stay visible with text resized up to 200% (WCAG 1.4.4 Resize Text, Level AA);
- stay visible when text styling and spacing are adjusted with CSS (WCAG 1.4.12 Text Spacing, Level AA);
- stay visible, or still be reachable, in a viewport of 320 by 256 CSS pixels (WCAG 1.4.10 Reflow, Level AA).

Non-modal popovers can cover controls when they receive focus, which fails WCAG 2.4.11 Focus Not Obscured (Minimum) (Level AA): a focused item must not be completely obscured. There is no generic fix, so adjust the popover's position or presence. If a popover is likely to cover an interactive element when that element receives keyboard focus, move the popover so focus is not obscured, or dismiss it if it is no longer relevant.

## Fallback strategies

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
