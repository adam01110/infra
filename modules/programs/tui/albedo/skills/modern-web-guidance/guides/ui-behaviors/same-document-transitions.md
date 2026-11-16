# Same Document Transitions

Sites often show several views of the same thing, such as a product list and a detail page per product. Switching between them can feel disconnected: when a user clicks a thumbnail, it vanishes and a larger image appears instantly somewhere else, so it's hard to follow how the elements relate.

The View Transitions API lets you pair elements across the before and after states. When you trigger a transition with `document.startViewTransition()` in a single-page application (SPA), the browser matches elements by their shared, unique `view-transition-name`, works out the differences in position, size and styling, and animates from the old state to the new. The transition renders in the top layer, above even elements with high `z-index`.

## Implementation

### Step 1: Wrap state changes in `startViewTransition()`

Wrap the code that updates the DOM in `document.startViewTransition()`. The browser snapshots the current state, runs the update, then captures the new state.

```javascript
function navigate(view) {
  document.startViewTransition(() => updateDOM(view));
}
```

### Step 2: Assign shared transition names

`view-transition-name` tells the browser which elements to morph. Any name except `none` works. At most one element may carry a given name in the old state, and one in the new. If two or more elements share a name, the DOM updates to the new state immediately, with no transition.

Use several names to morph several pairs, for example the product image and the title as separate transitions.

A list view has many items, so they can't all share one name. In an SPA there are two ways to solve this.

1. Dynamic detail page: give each list item a unique name, and when an item is selected, apply its name to the matching element on the detail page.

```css
/* Each list item gets its own name. */
#product-1 { view-transition-name: p1 }
#product-2 { view-transition-name: p2 }
#product-3 { view-transition-name: p3 }
```

```js
function updateDOM(clickedTransitionName){
  const hero = document.getElementById("hero");
  hero.style.viewTransitionName = clickedTransitionName;
}
```

When returning to the list, clear `hero.style.viewTransitionName` after the transition's `finished` promise settles; otherwise the next transition sees two elements with the same name and is skipped.

2. Dynamic list item: give the detail-page element a name, apply the same name to the selected list item, and remove it from the list item after returning to the list.

Here the `#hero` element on the detail page and the selected `.thumbnail` on the list page share a name:

```css
#hero{
  view-transition-name: hero;
}
.thumbnail.selected {
  view-transition-name: hero;
}
```

When a thumbnail is clicked, prepare the list view first: add the `.selected` class to assign the name and make any other DOM changes. Then call `document.startViewTransition()` and apply the changes that switch from the list view to the detail view.

After returning to the list view, remove the selection classes, or the next navigation fails because of duplicate names. Do this once the transition's `finished` promise settles.

View transitions don't manage focus, so move focus to the new view's heading yourself. The headings need `tabindex="-1"`.

```javascript
// Called when a thumbnail is clicked.
function goFromListToDetail(e){
  e.currentTarget.classList.add("selected");
  const hero = document.getElementById("hero");
  const bgColor = getComputedStyle(e.currentTarget).backgroundColor;
  hero.style.background = bgColor;

  if (!document.startViewTransition) {
    document.body.classList.add("detail");
    // Focus the newly shown heading to announce the context and keep a logical tab order.
    document.getElementById("detail-heading")?.focus();
    return; // Stop here when view transitions are unsupported.
  }
  const transition = document.startViewTransition(() => {
    document.body.classList.add("detail");
  });
  // Move focus once the transition settles.
  transition.finished.finally(() => {
    document.getElementById("detail-heading")?.focus();
  });
}

// Called when navigating from the detail view back to the list.
function goFromDetailToList() {
  if (!document.startViewTransition) {
    document.body.classList.remove("detail");
    document.getElementById("list-heading")?.focus();
    return;
  }
  const transition = document.startViewTransition(() => {
    document.body.classList.remove("detail");
  });
  transition.finished.finally(() => {
    document.getElementById("list-heading")?.focus();
    // Removing .selected removes the view-transition-names.
    document.querySelectorAll(".selected").forEach(
      (element) => {
        element.classList.remove("selected");
      },
    );
  });
}
```

Which approach fits depends on the use case. The dynamic list item needs less repeated CSS but more JavaScript cleanup.

### Step 3: Fix aspect-ratio stretching

By default the browser cross-fades the old and new snapshots inside a group that stretches to fit both. When transitioning text, set the text element's width to `fit-content` in both views so its aspect ratio stays stable:

```css
#list-page .title {
  width: fit-content;
}

#detail-page #title {
  width: fit-content;
}
```

For elements whose aspect ratio changes, you may need to set the old and new pseudo-elements to 100% of the height of their `::view-transition-image-pair()`:

```css
::view-transition-old(hero),
::view-transition-new(hero){
  height: 100%;
}
```

The pseudo-elements are snapshots of the live elements, so `object-fit` and `object-position` also work on them for finer control.

## Practices

- Keep the number of shared-element transitions small. Reserve them for primary content the user is tracking, such as hero images and headings.
- Remove temporary `view-transition-name` values after the transition finishes so they don't affect later transitions.
- Don't transition elements that have running animations. View transitions animate snapshots, so those animations appear paused during the transition.
- Manage focus. A view transition changes the layout but not focus; if focus stays on an element that is hidden or removed, it is lost and keyboard and assistive technology users lose their context. Move focus to the updated page heading or view container (with `tabindex="-1"`) right after the DOM update or when `finished` resolves.
- Respect reduced-motion preferences:

```css
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none !important;
  }
}
```

## Fallback strategies

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

View transitions are a progressive enhancement. Without support, run the DOM update immediately with no animation:

```javascript
function navigate(view){
  if (!document.startViewTransition) {
    updateDOM(view);
  } else {
    document.startViewTransition(() => updateDOM(view));
  }
}
```
