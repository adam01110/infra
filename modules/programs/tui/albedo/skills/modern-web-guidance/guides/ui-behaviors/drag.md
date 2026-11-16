# Build a Draggable Element

Add dragging to an existing floating element such as a panel, palette, toolbar, inspector or dialog. Dragging doesn't change how the element is displayed, dismissed, stacked or focused.

## Use a dedicated handle

When the element contains selectable text, buttons, inputs or links, start drags from a dedicated handle so those contents keep working. Make the handle focusable for keyboard movement, give it a `button` role so screen readers convey its name, and give it an accessible name that mentions the arrow-key interaction.

Put `cursor: grab`/`grabbing`, `touch-action: none`, and both `-webkit-user-select: none` and `user-select: none` on the handle only, not the whole draggable element, so text elsewhere stays selectable and touch gestures behave normally:

```css
.drag-handle {
  cursor: grab;
  touch-action: none;
  -webkit-user-select: none;
  user-select: none;
}

.drag-handle.dragging {
  cursor: grabbing;
}
```

## Preserve pointer position and reachability

Use a viewport-relative positioning model such as `position: fixed` when clamping movement to the viewport.

- Start a drag only for the primary button (`event.button === 0`).
- Record the pointer offset on `pointerdown` and apply it on every move, so the element doesn't jump when grabbed away from its corner.
- Keep the drag going after the pointer leaves the handle. By default use `setPointerCapture()` and clear the dragging state on `lostpointercapture`. If the handle may be removed or re-rendered mid-drag, capture is lost, so use document-level `pointermove`, `pointerup` and `pointercancel` listeners instead.
- Optionally wait for about 4px of movement before entering the dragging state, so a click on the handle doesn't trigger drag styling.

With pointer capture the move listeners can stay on the handle:

```js
const handle = document.querySelector('.drag-handle');
const draggable = handle.closest('.draggable');
let offsetX = 0;
let offsetY = 0;

handle.addEventListener('pointerdown', (event) => {
  const control = event.target.closest('button, input, select, textarea, a');
  if (event.button !== 0 || (control && control !== handle)) return;

  const rect = draggable.getBoundingClientRect();
  offsetX = event.clientX - rect.left;
  offsetY = event.clientY - rect.top;
  handle.setPointerCapture(event.pointerId);
});

handle.addEventListener('pointermove', (event) => {
  if (!handle.hasPointerCapture(event.pointerId)) return;
  handle.classList.add('dragging');
  moveTo(event.clientX - offsetX, event.clientY - offsetY);
});

handle.addEventListener('lostpointercapture', () => {
  handle.classList.remove('dragging');
});

function moveTo(left, top) {
  const maxLeft = Math.max(0, window.innerWidth - draggable.offsetWidth);
  const maxTop = Math.max(0, window.innerHeight - draggable.offsetHeight);

  draggable.style.left = `${Math.max(0, Math.min(left, maxLeft))}px`;
  draggable.style.top = `${Math.max(0, Math.min(top, maxTop))}px`;
}
```

Clamp every pointer and keyboard position through the same helper so the element stays reachable, and re-clamp its current position when the viewport or element size changes. For layout-heavy elements, consider translating during the drag to avoid per-frame layout, then commit the final position to `left` and `top` on release.

## Keyboard movement

When the handle has focus, move the element with the arrow keys and call `preventDefault()` for those keys. Use the same clamping helper as for the pointer. A 15px step is a reasonable start; adjust it to the component's size and the precision it needs.

## Dialogs and popovers

A `<dialog>` or `[popover]` can use the same mechanism with its header in addition to a separate drag handle. Set `margin: 0` before assigning `left` and `top`, because the default margins interfere with manual positioning. For opening, closing, focus and dismissal, see the `declarative-dialog-popover-control` and `platform-controls-dismiss-dialog` guides.

## Accessibility requirements

Expose the handle to assistive technology as a dedicated button rather than scripting a dialog header to be draggable, so screen reader users get a proper role and accessible name. For example, with a native button:

```html
<button type="button" aria-label="Notes panel handle. Use arrow keys to move.">
  <!-- handle icon -->
</button>
```

The element must also be movable or operable with a single pointer without dragging, such as clicks or taps. The UI depends on the use case:

- Kanban boards: a "move to column" menu or buttons.
- Maps: directional pan buttons.
- Sliders: clicking the track, and sometimes a linked `<input>` for the value.
- Floating panels and dialogs: a background grid where clicking a cell moves the element there, or a drag handle that is a menu button with items such as "Dock left", "Move left", "Dock top", "Move up", "Dock right", "Move right", "Dock bottom" and "Move down".

Tell screen reader users when the element moves, with a visually hidden live region. Include the region in the page on load so it is registered:

```html
<div class="visually-hidden" aria-live="polite"></div>
```

Update it after each move:

```html
<div class="visually-hidden" aria-live="polite">
  [Name of element] moved [new position]
</div>
```

Describe the position in words ("docked left", "moved left", "moved up") rather than raw coordinates, or leave it out if there is no meaningful description. The message can be cleared after about a second, once it has been announced.

The keyboard interaction may not be obvious, so add a help button in the draggable element that reveals the keystrokes.

## Fallback strategies

When dragging only repositions a component, treat it as a progressive enhancement. Without JavaScript, keep the element, its content and its controls visible, readable and working in a sensible default position. Don't show a drag handle that doesn't work: hide a standalone grip control by default and reveal it when JavaScript initializes, and if a header doubles as the handle, attach its drag affordances when JavaScript initializes.

Browser support for user-select: Limited availability.
Supported by: Chrome 54 (Oct 2016), Edge 79 (Jan 2020), and Firefox 69 (Sep 2019).
Unsupported in: Safari.

Declare `-webkit-user-select: none` before `user-select: none` so text selection stays suppressed during drags in Safari.
