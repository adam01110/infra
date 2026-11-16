# Handling dynamic user-triggered changes to sort order

Use this pattern when a user action reorders a list, card grid or table and no item is mid-interaction. It covers applying the new order to the DOM (moving nodes, animating, announcing, performance), not computing the order or what triggers it.

## Reorder the existing nodes

Move the existing DOM nodes into the new order rather than recreating them. Recreating nodes with `innerHTML`, or a re-render that replaces them, discards focus, scroll position inside items and image state, and breaks view transitions, which match old and new elements by identity.

Use `moveBefore()` rather than `append()` so moved items keep state such as `<iframe>` content, running animations and focus inside them.

```javascript
// orderedNodes is the container's existing child elements in their new order.
function reorder(container, orderedNodes) {
  // Moving each node to the end in turn is enough; no need to compute minimal moves.
  for (const node of orderedNodes) container.moveBefore(node, null);
}
```

Don't fake a new order with CSS `order` or `flex-direction: row-reverse`. Visual order and DOM order must match so keyboard and screen reader order follow what the user sees.

### Table rows

For a `<table>`, move the `<tr>` elements within their `<tbody>` with the same function: `reorder(tbody, orderedRows)`. Never reorder header rows in `<thead>` or recreate the `<tbody>`.

## Optional: animate with view transitions

Animation is an enhancement; the reorder works without it. To animate, wrap the reorder in a view transition and give every item a unique `view-transition-name` so each animates from its old position to its new one; without names the list snaps. `view-transition-name: match-element` avoids generating a name per item.

Disable the animation for users who prefer reduced motion.

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

```css
.item {
  /* Derives a unique name from each element's identity. */
  view-transition-name: match-element;
}

@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none;
  }
}
```

```javascript
function reorderWithTransition(list, orderedNodes) {
  const update = () => reorder(list, orderedNodes);

  // Prefer a transition scoped to the list so the rest of the page stays interactive,
  // then a document-level transition, then a plain update.
  if (list.startViewTransition) {
    list.startViewTransition(update);
  } else if (document.startViewTransition) {
    document.startViewTransition(update);
  } else {
    update();
  }
}
```

- Rapid changes: starting a new view transition skips the one in flight, which is what you want when the user flips through options quickly. Always apply the final state in the update callback so the DOM ends in the right order even when the animation is skipped.
- Large lists: every named element is captured as an image, so naming hundreds of items is expensive. `match-element` names every matching element too and is no cheaper than explicit names. Skip the transition for lists larger than a few hundred items.
- Interactivity: a document-level view transition blocks pointer events on the whole page while it runs; `list.startViewTransition()` affects only the list's subtree. Prefer the scoped form and keep the animation short either way. Names only need to be unique within the scope. For table rows, scope the `<table>` or a wrapper around it. The `scoped-component-transitions` guide covers scoped transitions in detail.

## Announce the change once

A reorder moves many nodes, but the user performed one action. Don't put `aria-live` on the list, which would announce every moved item. Instead:

- Add one visually hidden `role="status"` element and set its text once per reorder, after starting the update. It must already be in the DOM before its text changes.
- Describe the result, not the mechanism: "Sorted by price, low to high, 24 items".
- Keep focus on the control that triggered the change; don't move it into the list.
- Make the current order readable from the control itself, so a screen reader user who lands on it hears what is selected without searching the page. Native controls (`<select>`, radios) already do this; for toggle buttons use `aria-pressed` and label the current state, not the action.

```html
<p id="reorder-status" role="status" class="visually-hidden"></p>
```

```css
/* Hidden visually but available to screen readers; display: none would hide it from them too. */
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip-path: inset(50%);
  white-space: nowrap;
}
```

```javascript
const status = document.getElementById('reorder-status');

reorderWithTransition(list, orderedNodes);
// One message per reorder, not per item.
status.textContent = `Sorted by price, low to high, ${orderedNodes.length} items`;
```

## Performance on large lists

- The cost is layout and rendering, not computing the order. Reorder in a single pass with no layout reads (`offsetTop`, `getBoundingClientRect()`) inside the loop.
- In long lists, give items `content-visibility: auto` with `contain-intrinsic-size` so off-screen items skip rendering work.
- Above roughly a thousand items, virtualize the list instead of keeping every node in the DOM, and skip the view transition.
- For expensive reorders (very large lists, or an order set through several inputs), apply the order only when the user confirms it, for example with an Apply button, rather than on every input change.

## Fallbacks

Browser support for Element-scoped view transitions: Limited availability.
Supported by: Chrome 147 (Apr 2026) and Edge 147 (Apr 2026).
Unsupported in: Firefox and Safari.

If your Baseline target lacks `element.startViewTransition()`, use `document.startViewTransition()`, and if it lacks that too, reorder without animation. The list still sorts correctly and the announcement is unchanged; the animation enhances the feature but isn't core to it.

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

If your Baseline target lacks `moveBefore()`, use `append()`. The resulting DOM order is identical; items may lose focus, iframe or animation state inside them, which matters only when items hold such state.

```javascript
function reorder(container, orderedNodes) {
  const move = Object.hasOwn(Element.prototype, 'moveBefore')
    ? (node) => container.moveBefore(node, null)
    : (node) => container.append(node);

  for (const node of orderedNodes) move(node);
}
```
