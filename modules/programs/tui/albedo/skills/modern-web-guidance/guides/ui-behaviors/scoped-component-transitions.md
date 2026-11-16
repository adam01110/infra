# Scoped Component Transitions

`document.startViewTransition()` attaches the `::view-transition` overlay to `:root`. That blocks pointer events on the rest of the page, prevents concurrent transitions, and covers `position: fixed` headers and open `[popover]` elements, even when nested view transition groups are used to prevent overflow bleeding.

`element.startViewTransition()` on a component root scopes the transition to that subtree instead. The `::view-transition` pseudo-element tree is attached to the element itself, so stacking contexts outside it are preserved, the rest of the page stays interactive, and several components can transition at once.

## Implementation

### 1. Start a scoped transition

Call `startViewTransition()` on the component's root container instead of on `document`. That element becomes the scope: only elements in its subtree are captured, only the scope's rendering pauses during the update callback, and the `::view-transition` overlay matches the scope's size, shape and stacking context.

### 2. Name the participating elements

Give the child elements that should animate a `view-transition-name`. For dynamic list items, `view-transition-name: match-element` derives each name from the element's DOM identity; explicit names also work and only need to be unique within the scope.

Names are isolated per scope, so components in different parts of the DOM don't collide. Names can still collide with those in nested scoped transitions; add `view-transition-scope: all` to the child scope element to prevent that.

### 3. Self-participation and overflow clipping

The scope element takes part in its own transition automatically: the user-agent stylesheet gives it `view-transition-name: root` and `view-transition-group: contain`. When your DOM change affects the scope's geometry, it animates its own geometry alongside its children.

When the scope clips its overflow (`overflow: hidden`, `scroll` or `clip`), `::view-transition-group-children(root)` automatically gets `overflow: clip`, so transitioning children don't bleed outside the component.

> [!NOTE]
> Automatic clipping applies only to the scope element itself (`root`). If a captured element inside the scope clips its own overflow and contains other captured elements (for example a scrollable or clipped `<ul>` inside a `.card`), use nested view transition groups so those elements stay clipped to their captured container:
>
> ```css
> .card ul {
>   height: 200px;
>   overflow-y: auto;
>   view-transition-name: match-element;
>   view-transition-group: contain;
>   view-transition-class: list;
> }
>
> ::view-transition-group-children(.list) {
>   overflow: clip;
> }
> ```

### 4. Concurrent and nested transitions

Separate component subtrees can run `element.startViewTransition()` at the same time without skipping each other. Active scopes automatically get `view-transition-scope: all` from the UA stylesheet, so their internal names don't leak into outer transitions. Set `view-transition-scope: all` in CSS on repeated component containers to keep outer transitions from capturing internal names even while the component is idle.

If an outer transition needs to move a component while the component's inner transition is running, give a `view-transition-name` to an element wrapping the inner scope. The outer transition then captures and animates only the wrapper, and the inner transition runs to completion.

## Example

The scope element (`.card` or `.card ul`) needs no CSS to become a scope; calling `startViewTransition()` on it instead of `document` is what makes it one. If the component will be nested inside an outer view transition, see [Running an outer transition](#running-an-outer-transition) for `view-transition-scope: all`.

```css
/* 1. Name the participating children. */
.card ul li {
  view-transition-name: match-element;
}

/* 2. Optional timing (300ms is an example). */
::view-transition-group(*) {
  animation-duration: 300ms;
  animation-timing-function: ease-in-out;
}

/* 3. Respect reduced motion. */
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none !important;
  }
}
```

```javascript
// 1. Run a transition scoped to one component subtree.
function runScopedTransition(scopeEl, updateDOM) {
  const transition = scopeEl.startViewTransition(() => {
    updateDOM();
  });

  // Starting another transition on the same element skips the active one and
  // rejects `ready`; catch it to avoid unhandled rejection errors.
  transition.ready.catch(() => {});
}

// 2. Reorder by moving existing DOM nodes, which match-element requires.
// Scoped to listEl because only the list order changes, so controls outside it stay interactive.
function reorderItems(listEl, orderedIds) {
  const existing = new Map(
    Array.from(listEl.children, (li) => [li.dataset.id, li]),
  );

  runScopedTransition(listEl, () => {
    for (const id of orderedIds) {
      const li = existing.get(id);
      if (li) listEl.appendChild(li);
    }
  });
}

// 3. Remove an item with an exit animation, keeping keyboard focus.
// Scoped to cardEl so the card's own height change also transitions.
function removeItem(cardEl, itemEl) {
  const hadFocus = itemEl.contains(document.activeElement);
  const nextFocusTarget =
    itemEl.nextElementSibling?.querySelector('button') ??
    itemEl.previousElementSibling?.querySelector('button') ??
    cardEl.querySelector('button');

  runScopedTransition(cardEl, () => {
    itemEl.remove();
    if (hadFocus) {
      nextFocusTarget?.focus();
    }
  });
}
```

## Running an outer transition

A view transition started outside the intended scope (from a parent component, or from the document for a page-level transition) captures and animates the scope element and everything inside it.

To prevent that, wrap the scope element in a wrapper with its own `view-transition-name`, and set `view-transition-scope: all` on the inner scope element. The outer transition then captures and animates the wrapper but not the scope's contents.

```html
<div class="page" id="page">
  <div class="card-wrapper">
    <section class="card" id="left">
      <h2>Card A</h2>
      <ul id="left-list">
        <li>…</li>
      </ul>
    </section>
  </div>
  <div class="card-wrapper">
    <section class="card" id="right">
      <h2>Card B</h2>
      <ul id="right-list">
        <li>…</li>
      </ul>
    </section>
  </div>
</div>
```

```javascript
document.querySelector('#page').startViewTransition(() => {
  // DOM updates.
});
```

```css
.card-wrapper {
  view-transition-name: match-element;
}

/* Keeps the card's contents from being captured by an outer transition. */
.card {
  view-transition-scope: all;
}

.card ul li {
  view-transition-name: match-element;
}
```

Alternatively, let the outer transition capture the children and keep the clipping with nested view transition groups, which clip captured children at their wrapper's boundary. In that case you must copy the clip onto the resulting `::view-transition-group-children()` pseudo-element yourself:

```css
.card-wrapper {
  overflow: clip;
  view-transition-name: match-element; /* Captured by the outer transition. */
  view-transition-group: contain; /* Nests children that also have a view-transition-name. */
  view-transition-class: card; /* For targeting. */
}

/* Copy the clip onto the pseudo-element. */
::view-transition-group-children(.card) {
  overflow: clip;
}

.card ul li {
  view-transition-name: match-element;
}
```

## Constraints and accessibility

- Call `startViewTransition()` on the component root, not `document`, so outside `position: fixed` elements and `[popover]` overlays stay on top and the rest of the page stays interactive.
- With `view-transition-name: match-element`, move existing DOM nodes instead of recreating them with `innerHTML`; `match-element` tracks node identity.
- Respect reduced motion: inside `@media (prefers-reduced-motion: reduce)`, set `animation: none !important` on `::view-transition-group(*)`, `::view-transition-old(*)` and `::view-transition-new(*)`.
- When removing a focused element during a transition, keep keyboard focus by moving it to an adjacent item or control inside the update callback.
- Use nested view transition groups (`view-transition-group: contain` plus `overflow: clip` on `::view-transition-group-children()`) when a captured element inside the scope clips its overflow and contains other captured elements.
- Attach `transition.ready.catch(() => {})` when rapid interactions can restart `element.startViewTransition()` on the same scope.
- Wrap an inner scope in a separately named wrapper if an outer transition must animate the component's position while an inner transition runs.
- Don't set `view-transition-name: none` on a scope element that clips its overflow (`overflow: hidden`, `scroll` or `clip`) or changes its own geometry. Opting out of self-participation disables the automatic overflow clipping.

## Fallback strategies

Browser support for Element-scoped view transitions: Limited availability.
Supported by: Chrome 147 (Apr 2026) and Edge 147 (Apr 2026).
Unsupported in: Firefox and Safari.

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

If your Baseline target lacks element-scoped view transitions, degrade gracefully by running the update immediately without animation. Falling back to `document.startViewTransition()` is possible but not recommended for isolated component updates: a document-scoped transition blocks concurrent component transitions and covers `position: fixed` and `[popover]` elements in the top layer.

```javascript
// Detect on Element.prototype, not document.startViewTransition.
const supportsScopedTransition = 'startViewTransition' in Element.prototype;

function runWithTransition(scopeEl, updateDOM) {
  if (!supportsScopedTransition) {
    updateDOM();
    return;
  }

  const transition = scopeEl.startViewTransition(() => {
    updateDOM();
  });

  transition.ready.catch(() => {});
}
```

If you do need a `document.startViewTransition()` fallback, preserve the containers' clipping as described in [Running an outer transition](#running-an-outer-transition). That fallback still can't run several transitions concurrently and still covers `position: fixed` and `[popover]` elements in the top layer.
