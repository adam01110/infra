# Platform Controls Dismiss Dialog

Users expect to dismiss an open modal dialog with familiar controls: the <kbd>Esc</kbd> key, the back button or back gesture on mobile, or a dismiss gesture in assistive technology.

`<dialog>` originally responded only to <kbd>Esc</kbd>, not to other platform controls such as the mobile back button or gesture. With the `closedby` attribute, modal dialogs now respond to these platform-specific close requests. This applies to dialogs opened in a modal state: imperatively with `showModal()`, or declaratively with the `show-modal` invoker command. If you already use `<dialog>` this way, nothing needs to change.

```html
<!-- Open with showModal() or the show-modal invoker command so the dialog responds to close requests, including platform-specific controls. -->
<dialog aria-labelledby="example">
  <h1 id="example">Example</h1>
  <p>Modal that can be dismissed with close requests.</p>
</dialog>
```

A modal dialog without `closedby` responds to close requests as if `closedby="closerequest"` were set, so setting it explicitly is unnecessary:

```html
<!-- Redundant: this is the default for modal dialogs. -->
<dialog closedby="closerequest" aria-labelledby="example">
  <h1 id="example">Example</h1>
  <p>Modal that can be dismissed with close requests.</p>
</dialog>
```

For light dismiss as well, set `closedby="any"`:

```html
<dialog closedby="any" aria-labelledby="example">
  <h1 id="example">Example</h1>
  <p>Modal that can be dismissed with close requests and light dismiss.</p>
</dialog>
```

## Fallback strategies

Browser support for <dialog closedby>: Limited availability.
Supported by: Chrome 134 (Mar 2025), Edge 134 (Mar 2025), and Firefox 141 (Jul 2025).
Unsupported in: Safari.

Modal `<dialog>` elements already close on <kbd>Esc</kbd>, so no fallback is needed. There is no good way to implement close requests from the mobile back button or gesture yourself, so treat the feature as a progressive enhancement; users still have other inclusive ways to dismiss the dialog. Light dismiss with `closedby="any"` is a progressive enhancement in the same way.
