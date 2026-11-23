# Declarative Dialog and Popover Control

The Invoker Commands API opens and closes `<dialog>` and `[popover]` elements from HTML buttons, without custom JavaScript listeners.

With `commandfor` (the target's ID) and `command` (the action) on a `<button>`, the browser handles the open and close state, focus management and accessibility bindings such as `aria-expanded`. Prefer this declarative approach: it removes brittle boilerplate, works as soon as the HTML is parsed, and is accessible natively.

## Declarative popovers

One button can toggle a popover open and closed. `commandfor` names the ID of the element to control, `command="toggle-popover"` handles both states, and the target needs the `popover` attribute.

```html
<button commandfor="my-popover" command="toggle-popover">
  Toggle Popover
</button>

<div id="my-popover" popover>
  <p>Popover content goes here.</p>
</div>
```

To open and close with separate buttons, use `show-popover` (which doesn't close the popover if clicked again) and `hide-popover`.

Don't combine `popovertarget` and `commandfor` on the same `<button>` for the same popover. It toggles twice, which breaks it.

```html
<button commandfor="my-explicit-popover" command="show-popover">
  Show Popover
</button>

<div id="my-explicit-popover" popover="manual">
  <p>This popover is explicitly opened and closed by separate buttons.</p>

  <button commandfor="my-explicit-popover" command="hide-popover">
    Hide Popover
  </button>
</div>
```

Hiding a popover with a button inside it loses focus, because the button is hidden along with it. In that case, add script that returns focus to the trigger or show control so people can carry on from where they were.

## Declarative modal dialogs

Modal dialogs usually have separate open and close buttons. Use `command="show-modal"` to open the dialog as a modal, which traps focus and blocks interaction with the rest of the page, and `command="close"` to dismiss it.

```html
<button commandfor="confirm-dialog" command="show-modal">
  Open Confirmation
</button>

<dialog id="confirm-dialog">
  <p>Are you sure you want to proceed?</p>

  <!-- type="button" keeps this working if the content is later wrapped in a <form>. -->
  <button type="button" commandfor="confirm-dialog" command="close">
    Cancel
  </button>
</dialog>
```

A button with `commandfor` and `command` inside a `<form>` (including the common `<form method="dialog">` wrapper) needs an explicit `type="button"` to run its command:

- A `type="submit"` button submits the form and does not also run the command.
- A command button with no `type` inside a `<form>`, or with a `form` attribute, does nothing. This is deliberate, so that older browsers without command support don't submit the form by accident.
- Don't put a `command="close"` button inside `<form method="dialog">`; pick one strategy.

## Fallback strategies

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

Invoker commands and popovers are not yet universally supported, so older browsers need polyfills.

### Polyfill invoker commands

Feature-detect with the `commandForElement` property on `HTMLButtonElement.prototype`, not on `window` or `document`, and import the polyfill dynamically only when native support is missing; never load it unconditionally. The native `command` event doesn't bubble, so listen for it directly on the target element.

With a bundler (such as Vite or webpack) or import maps, install the package (`npm install invokers-polyfill`):

```javascript
if (!('commandForElement' in HTMLButtonElement.prototype)) {
  import('invokers-polyfill');
}
```

Without a bundler, import it from a CDN in a `<script type="module">`:

```html
<script type="module">
  if (!('commandForElement' in HTMLButtonElement.prototype)) {
    import('https://esm.run/invokers-polyfill');
  }
</script>
```

The polyfill doesn't manage the invoking button's ARIA states (such as `aria-expanded`) the way browsers do natively. Manage them yourself so the page stays accessible:

```javascript
document.getElementById('action-target').addEventListener('command', (event) => {
  const command = event.command;
  const target = event.target;
  const source = event.source; // The button that triggered the command.

  if (command === '--spin') {
    const isSpun = target.classList.toggle('is-spun');

    // Keep ARIA in step with the new state.
    source?.setAttribute('aria-pressed', isSpun);
  }
});
```

### Popover

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

The Popover API is mostly a progressive enhancement, but its defining behaviours (top-layer promotion, light dismiss and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you'd rather not ship one.

To support `popover` in older browsers, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) conditionally. Feature-detect the `popover` property on `HTMLElement.prototype` and load the polyfill only when native support is missing.

With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, for example `"https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js"`.

Polyfill caveats:

- Don't use the `popover` IDL property in code that may run before the polyfill has loaded. The value isn't mirrored to the attribute, the polyfill won't pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill can't define the real `:popover-open` pseudo-class, so it applies a `.\:popover-open` class instead. Combine the two with `:is()` or `:where()`; otherwise browsers without `:popover-open` discard the whole rule.

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
