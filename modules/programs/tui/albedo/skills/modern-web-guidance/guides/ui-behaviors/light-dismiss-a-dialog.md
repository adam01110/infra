# Light-Dismiss a Dialog

Light dismiss lets users close a modal dialog by clicking or tapping the backdrop, the area outside the dialog. The `closedby` attribute enables it declaratively, without custom JavaScript.

## Implementation

1. Add `closedby="any"` to the `<dialog>` element.
2. Open the dialog with `dialog.showModal()`.

### Attribute values

- `any`: light dismiss (clicking the backdrop), close requests (the `Esc` key) and developer mechanisms such as `dialog.close()`.
- `closerequest`: close requests and developer mechanisms only. This is the default for modal dialogs.
- `none`: only developer mechanisms can close the dialog.

### Styling the backdrop

A dialog opened with `showModal()` gets a `::backdrop` pseudo-element that covers the whole viewport directly behind the dialog. Style it to show that the dialog is modal:

```css
dialog::backdrop {
  background-color: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(2px); /* Optional blur. */
}
```

## Example

```html
<dialog id="myDialog" closedby="any" aria-labelledby="dialogTitle">
  <form method="dialog">
    <h2 id="dialogTitle">Feedback</h2>
    <p>Click outside this box or press Esc to dismiss.</p>
    <button type="submit">Close</button>
  </form>
</dialog>

<button onclick="document.getElementById('myDialog').showModal()">Open Dialog</button>
```

## Constraints and accessibility

- Open modal dialogs with `showModal()`. This puts the dialog in the top layer, traps focus and handles the `Esc` key.
- Keep a visible close button so people always have a clear alternative way to close the dialog.
- Give the dialog an accessible name with `aria-labelledby` or `aria-label`.
- `closedby` has no light-dismiss effect on non-modal dialogs opened with `show()`, because they have no backdrop.
- Don't rely on `click` for close-related logic. Use `cancel` for logic that may prevent or precede closing, and `close` for logic that runs after the dialog has closed.

Watch for components inside the dialog that use the `Esc` key themselves, such as a menu or combobox, because `Esc` could close the dialog by accident. When such a component has focus, it should capture the `Esc` press and handle it so the dialog stays open.

## Fallback strategies

Browser support for <dialog closedby>: Limited availability.
Supported by: Chrome 134 (Mar 2025), Edge 134 (Mar 2025), and Firefox 141 (Jul 2025).
Unsupported in: Safari.

Browsers without `closedby` support need a light-dismiss fallback that checks whether a click landed outside the dialog's bounds:

```javascript
const dialog = document.querySelector('dialog');

if (!('closedBy' in HTMLDialogElement.prototype)) {
  dialog.addEventListener('click', (event) => {
    // A backdrop click targets the dialog element itself; ignore clicks on its children.
    if (event.target !== dialog) return;

    // A click on the dialog's own background or padding also targets the dialog,
    // so compare the coordinates with its bounds to tell it apart from the backdrop.
    const rect = dialog.getBoundingClientRect();
    const isDialogContent = (
      rect.top <= event.clientY &&
      event.clientY <= rect.top + rect.height &&
      rect.left <= event.clientX &&
      event.clientX <= rect.left + rect.width
    );

    if (isDialogContent) return;

    // The click was on the backdrop.
    dialog.close();
  });
}
```
