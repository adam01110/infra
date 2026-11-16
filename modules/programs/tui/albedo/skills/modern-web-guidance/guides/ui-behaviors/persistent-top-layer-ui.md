# Persistent Top Layer UI

Moving an open `<dialog>`, popover or fullscreen element with `appendChild()` or `insertBefore()` removes it from the DOM and re-inserts it. The removal resets its state, so open modals, popovers and fullscreen elements close abruptly.

To reparent a top-layer element without closing it, use the atomic `moveBefore()` API.

## Reparent open top-layer elements

`moveBefore()` takes the node to move and a reference node to insert before, or `null` to append it to the end of the new parent.

```javascript
const newParent = document.getElementById('new-container');
const dialogElement = document.getElementById('my-dialog');

// Keeps the <dialog> or popover open. null appends to the end of newParent.
newParent.moveBefore(dialogElement, null);
```

## Fallback strategies

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

`moveBefore()` is a progressive enhancement, so feature-detect it before calling it and fall back to traditional reparenting in older browsers.

In unsupported browsers the traditional move closes `<dialog>` elements. If the dialog must stay open, re-open it after the move.

```javascript
const targetParent = document.getElementById('target-container');
const popoverOrDialog = document.getElementById('my-top-layer-element');

if ('moveBefore' in Element.prototype) {
  targetParent.moveBefore(popoverOrDialog, null);
} else {
  // A traditional move closes <dialog>, popover and fullscreen elements.
  const isDialog = popoverOrDialog instanceof HTMLDialogElement;
  const wasModal = isDialog && popoverOrDialog.matches(':modal');
  const wasOpen = isDialog ? popoverOrDialog.open : popoverOrDialog.matches(':popover-open');
  targetParent.insertBefore(popoverOrDialog, null);

  // Restore the open state. A moved dialog keeps its open attribute but loses its
  // modal state, and showModal() throws on an open dialog, so close it first.
  if (wasOpen && isDialog) {
    if (popoverOrDialog.open) popoverOrDialog.close();
    wasModal ? popoverOrDialog.showModal() : popoverOrDialog.show();
  } else if (wasOpen) {
    popoverOrDialog.showPopover();
  }
}
```
