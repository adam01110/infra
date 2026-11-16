# Smoothly rearrange cards, lists, and groups of elements on add, remove, or reorder

Transitions help users keep their place as items are added to, removed from or rearranged in a list. A view transition animates an element between two states when the element has a unique `view-transition-name`. When many elements share the same transition behaviour, `view-transition-class` lets you define it once in CSS instead of repeating it for every name, which keeps the stylesheet maintainable and the animation consistent across the group.

## Implementation steps

1. Give each element a unique name and a shared class.

   Every element tracked individually during the transition needs its own unique `view-transition-name`:

   ```html
   <li style="view-transition-name: item-1" class="item">Item 1</li>
   <li style="view-transition-name: item-2" class="item">Item 2</li>
   ```

   For shared styles, also give them a `view-transition-class`:

   ```css
   .item {
     view-transition-class: list-item;
   }
   ```

2. Define the shared transition.

   `::view-transition-group()` with a class selector styles every member of that class:

   ```css
   ::view-transition-group(.list-item) {
     /* Example values; any ease* keyword, cubic-bezier() or multi-stop linear() curve works. */
     animation-duration: 0.5s;
     animation-timing-function: ease-in-out;
   }

   @media (prefers-reduced-motion: reduce) {
     /* Disable all group transitions, including the default root group. */
     ::view-transition-group(*),
     ::view-transition-old(*),
     ::view-transition-new(*) {
       animation: none !important;
     }
   }
   ```

3. Define entry and exit animations for added and removed items.

   `::view-transition-new()` and `::view-transition-old()` are children of `::view-transition-image-pair()`. When one of them is the only child, the element was added or removed, so `:only-child` targets those cases. Entry effects usually ease out (for example `ease-out`) so added items decelerate into place; exit effects usually ease in (`ease-in`) so removed items accelerate away.

   ```css
   /* A lone new snapshot didn't exist before the transition: an added element. */
   ::view-transition-new(.list-item):only-child {
     animation-name: slide-in;
     /* Optional override of the group's duration (example value). */
     animation-duration: 1s;
     animation-timing-function: ease-out;
   }
   /* A lone old snapshot doesn't exist after the transition: a removed element. */
   ::view-transition-old(.list-item):only-child {
     animation-name: slide-out;
     /* Optional override of the group's duration (example value). */
     animation-duration: 1s;
     animation-timing-function: ease-in;
   }

   @keyframes slide-in {
     from {
       translate: -100vw 0;
     }
   }
   @keyframes slide-out {
     to {
       translate: -100vw 0;
     }
   }
   ```

4. Trigger the transition.

   Wrap the DOM update in `document.startViewTransition()`. The browser captures the old state, runs the update, then animates to the new state.

   ```javascript
   function updateList(newData) {
     document.startViewTransition(() => {
       // DOM changes in this callback are transitioned.
       render(newData);
     });
   }
   ```

5. Keep non-transitioned elements interactive.

   A view transition overlays snapshots of the elements and animates those, so the page is not interactive during the transition. To keep elements that aren't part of the transition interactive, turn off pointer events on the overlay:

   ```css
   ::view-transition {
     /* Elements under the overlay stay interactive. */
     pointer-events: none;
   }
   ```

   By default the `:root` element has the view transition name `root`, which produces a full-page transition. If the root doesn't change, that is a transition between two identical, non-interactive snapshots. Since only specific elements are transitioned here, disable the root transition:

   ```css
   :root {
     view-transition-name: none;
   }
   ```

## Fallback strategies

### View transitions

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

View transitions are a progressive enhancement. Without `document.startViewTransition`, run the DOM update immediately for a working, non-animated experience:

```javascript
if (document.startViewTransition) {
  document.startViewTransition(() => updateDOM());
} else {
  updateDOM();
}
```

### `view-transition-class`

Baseline status for view-transition-class: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), Firefox 144 (Oct 2025), and Safari 18.2 (Dec 2024).

Browsers that don't recognize `view-transition-class` or the `::view-transition-group(.class)` selector ignore those rules but still run the DOM update, plus the base view transition if they support it.
