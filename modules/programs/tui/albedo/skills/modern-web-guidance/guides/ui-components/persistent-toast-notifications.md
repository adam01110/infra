# Creating Toast Notifications

Toast notifications are transient status messages. Unlike menus, they should not close when the user interacts with other parts of the page. `popover="manual"` suits them: it has no light dismiss, and several manual popovers can be open at once.

## When to use

Use toasts only for non-critical, supplemental information about the result of an interaction or an event, such as confirming that a form was submitted or that an email arrived. Information that needs immediate attention belongs in another component, such as an inline banner, a dialog, or a modal dialog, which everyone can identify more easily. Use toasts sparingly: making them accessible to everyone involves complex considerations, which is why some companies have dropped them in favor of those alternatives.

## Implementation guidelines

Prefer persistent toasts that stay until dismissed. The exception is frequent, low-importance events, where the friction of persistence outweighs the value of the information; in those cases, also consider whether toasts help at all, since it can be better to have none. If toasts do dismiss themselves after a short time, check whether focus is on a control inside the toast first, and pause the dismissal until focus has left the toast.

- Use `popover="manual"` so the notification stays visible until it is explicitly closed or a script times it out.
- Make the information in a toast available by other means as well, so people can still find it if the toast disappears after a short time.
- Use a container to manage the stacking of multiple toasts. Top-layer popovers ignore their parent's `z-index`, so position them individually or within a common layout group.
- Always add toasts to the same container on the page, so people using assistive technologies can find them consistently.
- Make the container a region with an accessible name so screen reader users can identify it, for example `<div role="region" aria-label="Notifications"></div>`.
- Announce each toast's content with `ariaNotify()`, so screen reader users who cannot see the screen know it appeared.
- Announce only the toast's visible text, not the names of its controls. If the toast has actions other than a close control, append "Actions available" to the announcement.
- Provide an explicit "Close" button in the toast that uses `popovertargetaction="hide"`.
- Make the dismiss button keyboard-focusable, without moving focus to it when the toast appears, so keyboard users can navigate to the toast region and dismiss notifications.
- When the user dismisses the toast that has focus, move focus to the next remaining toast in the stack or, if none remain, back to where focus was before (or to the control that triggered the toast).
- To animate entry and exit from the top layer, declare `transition-behavior: allow-discrete` as a separate property after `transition`, not inside the shorthand, so older browsers do not drop the whole `transition` declaration.
- Provide a non-animated version under the `prefers-reduced-motion` media query.
- Toast content must scale and stay visible with text resized up to 200% (WCAG 1.4.4 Resize Text, Level AA).
- Toast content must stay visible when text styling and spacing are adjusted with CSS (WCAG 1.4.12 Text Spacing, Level AA).
- Toast content must stay visible, or still be reachable, in a viewport of 320 by 256 CSS pixels (WCAG 1.4.10 Reflow, Level AA).

Avoid these situations:

- Do not show toasts while focus may be redirected at the same time. The focus change can cancel the toast announcement, and people miss the information.
- Do not put toasts inside modal dialogs. Content outside the dialog is inert and unavailable to assistive technologies, and a toast inside the dialog, apart from the usual container, is hard to find.
- Do not show toasts in the background while a modal dialog is open; they are likely to be missed. Hold the notification until the dialog is dismissed.
- Do not put controls in toasts for actions that are not also permanently available outside them. Use controls in toasts sparingly, only as shortcuts to actions already in the UI.

## Optional usability and accessibility improvements

- Surface previous toasts. A list of past toast messages helps people who have trouble remembering what a toast said, and reduces anxiety for people who dismissed one by accident.
- Let people customize which toasts they receive, so the information stays relevant and causes less distraction and confusion.
- Signal new toasts in more than one way, for example with a brief sound effect that can be turned off. This helps screen magnifier users, who may otherwise not notice that a toast appeared.

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

### ariaNotify()

Baseline status for ariaNotify(): Newly available. It's been Baseline since 2026-09-14.
Supported by: Chrome 141 (Sep 2025), Edge 141 (Oct 2025), Firefox 150 (Apr 2026), and Safari 27 (Sep 2026).

Where `ariaNotify()` is unsupported, use an ARIA live region. The container must already be in the page on load; add messages to it when needed.

```html
<!-- Live region container, present from page load -->
<div id="notification" aria-live="assertive"></div>
```

The message stays in the DOM after it is announced, and screen reader users may come across it while reading the page. Whenever the live region has content, put visually hidden text immediately before the container that explains what it is.

```html
<p class="visually-hidden">Screen reader announcements</p>
<div id="notification" aria-live="assertive">
  Dynamic announcement injected into the existing container.
</div>
```

### Anchor positioning

This applies only if you anchor a toast to a related control; toasts in a fixed container need no anchor positioning.

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

### `sibling-index()`

If you offset stacked toasts with `sibling-index()` (for example `margin-top: calc(sibling-index() * 1rem)`) and it is unsupported, space them with the next-sibling combinator instead, for example `[popover] + [popover] { margin-top: 1rem; }`.

### `transition-behavior`

Where `transition-behavior` (used for the entry and exit animation above) is unsupported, animate toasts in and out by toggling classes from JavaScript.
