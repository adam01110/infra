# Move DOM Element Without Losing State

Reparenting an element with `appendChild()` or `insertBefore()` removes it from the DOM and then inserts it in its new place. That remove-and-insert resets internal state: `<iframe>` elements reload, CSS animations restart and inputs lose focus.

`moveBefore()` moves an element atomically, skipping the removal and insertion steps, so its state survives.

## Move an element with state

Call `moveBefore()` like `insertBefore()`: pass the node to move and a reference node to insert before, or `null` to append it to the end of the new parent.

```javascript
const newParent = document.getElementById('new-parent');
const elementWithState = document.getElementById('iframe-or-focused-input');

// null appends the element to the end of newParent.
newParent.moveBefore(elementWithState, null);
```

## Move custom elements

Moving a custom element with `moveBefore()` does not fire its `connectedCallback` or `disconnectedCallback`. If the element needs to react to a move, implement `connectedMoveCallback()`:

```javascript
class MyCustomElement extends HTMLElement {
  connectedCallback() {
    // Runs on initial insertion.
  }

  connectedMoveCallback() {
    // Runs when the element is moved with moveBefore().
    // Update state that depends on the new DOM location here.
  }
}
```

## Fallback strategies

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

`moveBefore()` is a progressive enhancement. Feature-detect it and fall back to `insertBefore()` or `appendChild()` in older browsers.

```javascript
const targetParent = document.getElementById('target-container');
const nodeToMove = document.getElementById('moving-element');

if ('moveBefore' in Element.prototype) {
  targetParent.moveBefore(nodeToMove, null);
} else {
  // A traditional move resets <iframe>, animation and focus state.
  targetParent.insertBefore(nodeToMove, null);
}
```

## Accessibility considerations

- A move should not cause a disorienting change of context, such as keyboard focus falling back to `<body>`.
- Where possible, let the user trigger the move rather than moving content automatically, to avoid unexpected changes of context.
- A move should not change the meaning of the content. Panels that can be read independently in any order can be repositioned freely. If panels must be read in sequence to make sense, moving them in the DOM can break the reading order even when the visual order still looks right, which disorients screen reader users.
- If the move is something people need to know about, such as moving a video from one area of the page to a "Favorites" list elsewhere, confirm it with a live region.
