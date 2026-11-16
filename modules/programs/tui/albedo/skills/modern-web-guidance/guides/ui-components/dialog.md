# Dialog

Use the native `<dialog>` element for modal and non-modal dialogs. It provides the accessibility semantics, focus handling, top-layer rendering, and `Esc` handling that custom overlays must rebuild by hand.

## Choose the overlay type

Use the first rule that matches. If unsure, use Rule 1.

### Rule 1: The overlay interrupts the user and blocks the page (default)

For confirmations, forms, sign-in, destructive actions, and any request for a "modal", "dialog", "lightbox", or "popup" that does not say otherwise.

Open a `<dialog>` as a modal, either declaratively with `command="show-modal"` (see the `declarative-dialog-popover-control` guide) or from script with `showModal()`.

```html
<button type="button" command="show-modal" commandfor="confirm">Delete</button>

<!-- No role="dialog" or aria-modal: the native modal already provides them. -->
<dialog id="confirm" aria-labelledby="confirm-title">
  <h2 id="confirm-title">Delete this item?</h2>
  <form method="dialog">
    <button value="cancel" autofocus>Cancel</button>
    <button value="delete">Delete</button>
  </form>
</dialog>
```

The browser provides the inert page, focus containment, the top layer, `::backdrop`, dismissal by `Esc` and the back gesture, and focus return to the invoker. So:

- Do not add `role="dialog"`, `aria-modal`, a focus trap, `inert` toggling, or an `Esc` handler.
- Do not open it with `show()` or the `open` attribute; those do not make it modal.
- Stop the page from scrolling behind it with the CSS below (details in the `prevent-page-scroll-under-modal-dialog` guide). Do not lock scrolling with `overflow: hidden` or `position: fixed` on `html` or `body`.

```css
/* Both rules are needed: without them, scrolling over the backdrop or inside the dialog scrolls the page. */
dialog:modal {
  overscroll-behavior: contain; /* Stops scroll chaining from the dialog to the page. */
}
dialog::backdrop {
  overflow: hidden; /* ::backdrop is not a scroll container by default, so it would ignore overscroll-behavior. */
  overscroll-behavior: contain;
}
```

Menus and tooltips are not dialogs; see Rule 3.

### Rule 2: The user keeps working in the page while the panel is open

For find bars, inspectors, palettes, and compose panes that are still dialogs semantically.

Use `<dialog popover>` for a top-layer panel with popover dismissal (`auto` light-dismisses, `manual` does not). Use `dialog.show()` only when the panel must stay out of the top layer.

```html
<button type="button" popovertarget="find">Find</button>
<dialog id="find" popover="manual" aria-labelledby="find-title">
  <h2 id="find-title">Find</h2>
  <input type="search" aria-label="Search">
  <button type="button" popovertarget="find" popovertargetaction="hide">Close</button>
</dialog>
```

The page stays interactive and is not made inert. Include a visible close button, and do not use `showModal()`, which blocks the page.

Blocking confirmations belong under Rule 1.

### Rule 3: The overlay is not a dialog

For menus, dropdowns, tooltips, hovercards, and toasts, use a semantic element with the `popover` attribute, not `<dialog>`.

```html
<button type="button" popovertarget="menu">Actions</button>
<ul id="menu" popover>
  <li><a href="/rename">Rename</a></li>
</ul>
```

## Choose how it can be dismissed

The default depends on how the dialog opens. If `closedby` is absent or invalid, `showModal()` behaves as `closerequest` and every other way of opening behaves as `none`.

- `Esc` and the back gesture only (the modal default): set nothing, or `closedby="closerequest"`.
- Also close on click outside: `closedby="any"`.
- Only the page closes it (for example a form with unsaved changes): `closedby="none"`, plus a confirmation path (see [Closing](#closing)).

## Guidelines

### Accessible name and initial focus

- Name every dialog with `aria-labelledby` pointing at its heading, or `aria-label` when there is no visible title.
- Put `autofocus` on the primary control or first field.
- In a destructive confirmation, put `autofocus` on the safe action, such as Cancel or Keep.
- Do not write code to return focus on close; the browser returns it to the invoker.

### Opening

- Open declaratively with `command="show-modal"` and `commandfor` on a `<button>` (see the `declarative-dialog-popover-control` guide).
- From script, use `dialog.showModal()`.

### Closing

- Close with `<form method="dialog">` buttons or `command="close"`.
- Choose `closedby` deliberately: `any` (light dismiss and `Esc`), `closerequest` (`Esc` only, the modal default), or `none` (closed only by the page).
- For Cancel buttons that must respect unsaved-changes logic, use `command="request-close"` or `requestClose()`. They fire `cancel` first and ignore `closedby`.
- Treat `closedby` as progressive enhancement; `Esc` and the mobile back gesture already close modals without it.

### Hooking into close

- In a `close` listener, read `dialog.returnValue` to learn which button was used, then reset it with `dialog.returnValue = ''`. `Esc` and other close requests set no value, and browsers differ on whether they clear the previous one, so without the reset a stale value can leak. Treat `''` as "dismissed without choosing".
- Use the `cancel` event to intercept `Esc` and `request-close`, but do not rely on `preventDefault()` for repeated `Esc` presses without user activation.
- For dirty forms, use `closedby="none"` with an explicit confirmation step.
- When `cancel` is prevented, tell the user why the dialog stayed open: show a visible message and reference it with `aria-describedby` from the control that receives focus (such as Discard), so a screen reader reads it when focus moves. Otherwise moving focus to a new button announces only that button's name.
- Do not let the confirmation move controls under the pointer. Reserve the message's space (hide it with `visibility`, not `display` or `hidden`) and add the destructive button where existing buttons do not shift (for example first in a right-aligned row), so a second click on the same spot cannot discard the user's changes.

### Non-modal dialogs

- Use `<dialog popover>` (`auto` or `manual`) for a top-layer panel, and `dialog.show()` when you do not want the top layer.
- Give every non-modal dialog a visible close button.

### Backdrop and styling

- Style `::backdrop`, and use `dialog:modal` for modal-only styles.
- For animation, dragging, and reparenting, see the `animate-to-from-top-layer`, `drag`, and `persistent-top-layer-ui` guides.
- Do not set `display` on `dialog` unconditionally; it overrides the closed state. Scope it with `dialog[open]`.

### Accessibility

- Do not add `role="dialog"`, `aria-modal`, a manual focus trap, or `inert` toggling to a native modal.
- Use a native `<button>` with an accessible name for close controls.
- Use one consistent heading level for dialog titles.

## Fallback strategies

### `closedby` (`dialog-closedby`)

Browser support for <dialog closedby>: Limited availability.
Supported by: Chrome 134 (Mar 2025), Edge 134 (Mar 2025), and Firefox 141 (Jul 2025).
Unsupported in: Safari.

Without `closedby`, a modal still closes with `Esc` and the back gesture; only click-outside is lost, so it degrades gracefully. `closedby="none"` is ignored the same way: `Esc` fires `cancel` and then closes the dialog. So keep the unsaved-changes guard in a `cancel` handler, not in `closedby="none"` alone, so that it also protects where `closedby` is missing. If your Baseline target needs light dismiss, add this where `closedby` is missing:

```js
if (!('closedBy' in HTMLDialogElement.prototype)) {
  // Test the pointer position, not event.target: the <dialog> is also the target for clicks
  // on its own padding and the gaps between its children.
  const outside = (e, dialog) => {
    const r = dialog.getBoundingClientRect();
    return e.clientX < r.left || e.clientX > r.right || e.clientY < r.top || e.clientY > r.bottom;
  };
  for (const dialog of document.querySelectorAll('dialog[closedby="any"]')) {
    let pressedOutside = false;
    dialog.addEventListener('pointerdown', (e) => { pressedOutside = outside(e, dialog); });
    // Require both press and release outside, so a text-selection drag ending on the backdrop does not dismiss.
    dialog.addEventListener('pointerup', (e) => { if (pressedOutside && outside(e, dialog)) dialog.close(); });
  }
}
```

### `overscroll-behavior`

Browser support for overscroll-behavior: Limited availability.
Supported by: Chrome 144 (Jan 2026), Edge 144 (Jan 2026), and Firefox 150 (Apr 2026).
Unsupported in: Safari.

Treat scroll containment as progressive enhancement and do not feature-detect it: `@supports` reports the property as supported even where non-scrollable containers ignore it. Where it is not enforced, the dialog still contains scrolling whenever its own content overflows, and `showModal()` still makes the page inert. Do not fall back to `overflow: hidden` or `position: fixed` on `html` or `body`, which removes the root scrollbar and shifts the layout.

### Invoker Commands (`command` / `commandfor`)

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

If your Baseline target does not include Invoker Commands, keep the same markup and load the `invokers-polyfill` package only where native support is missing, detected on the interface:

```js
if (!('commandForElement' in HTMLButtonElement.prototype)) {
  import('invokers-polyfill');
}
```

### Popover

Only Rules 2 and 3 use Popover.

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
