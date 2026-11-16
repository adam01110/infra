# Directional Navigation Transitions

Single-page applications (SPAs) simulate navigation by replacing page content without loading a new page. By default the content just swaps with no transition. A directional transition, with new content sliding in from the direction the user is moving, reinforces the spatial relationship between views and helps users build a mental map of the app. For example, a product site might slide right for "forward" and left for "back", and a slideshow might slide up and down for next and previous.

## Implementation steps

1. Detect whether the user is moving forward or backward in the app flow. How you detect it depends on your use case.
2. Pass the direction in the `types` array of `document.startViewTransition()`.
3. Apply direction-specific animations in CSS with the `:active-view-transition-type()` pseudo-class.

## Define keyframes

Define slide animations to and from each direction. For performance, animate position with `transform` or the individual transform properties `translate`, `scale` and `rotate`, not with inset properties. `opacity` is generally cheap too; before animating any other property, check that it doesn't trigger layout or paint.

```css
/* Slide out to the left. */
@keyframes slide-to-left {
  to { transform: translateX(-100%); }
}

/* Slide in from the right. */
@keyframes slide-from-right {
  from { transform: translateX(100%); }
}

/* Slide out to the right. */
@keyframes slide-to-right {
  to { transform: translateX(100%); }
}

/* Slide in from the left. */
@keyframes slide-from-left {
  from { transform: translateX(-100%); }
}
```

## Shared animation settings

Put settings shared by every transition on `::view-transition-group(root)`. Use a non-linear timing function such as an `ease` keyword or `cubic-bezier()`; `linear` makes directional slides feel mechanical and abrupt.

```css
::view-transition-group(root){
  animation: 0.4s ease-in-out both;
}
```

## Apply directional animations

Use `:active-view-transition-type()` to target the transition snapshots when the `forward` or `backward` type is active:

```css
html:active-view-transition-type(forward)::view-transition-old(root) {
  animation-name: slide-to-left;
}
html:active-view-transition-type(forward)::view-transition-new(root) {
  animation-name: slide-from-right;
}

html:active-view-transition-type(backward)::view-transition-old(root) {
  animation-name: slide-to-right;
}
html:active-view-transition-type(backward)::view-transition-new(root) {
  animation-name: slide-from-left;
}
```

## Trigger the transition

Pass the type to `startViewTransition()` when navigating:

```javascript
// Placeholders: your own direction logic and DOM-update callback.
const transitionType = yourTransitionTypeLogic();
const updateDOM = () => yourUpdateDOMLogic();

document.startViewTransition({
  update: updateDOM,
  types: [transitionType] // Matches the :active-view-transition-type() selectors.
});
```

## Accessibility

Disable or simplify the animation for users who prefer reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(root) {
    animation: none !important;
  }
}
```

## Fallback strategies

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

Baseline status for Active view transition: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), Firefox 147 (Jan 2026), and Safari 18.2 (Dec 2024).

View transitions are a progressive enhancement. In unsupported browsers `document.startViewTransition` is `undefined`, so feature-detect it and run the DOM update immediately without animation:

```javascript
/**
 * Navigates to a new view with a directional transition.
 * @param {Function} updateDOM - Callback that updates the DOM.
 * @param {string} direction - 'forward' or 'backward'.
 */
function navigate(updateDOM, direction) {
  if (!document.startViewTransition) {
    updateDOM();
    return;
  }

  document.startViewTransition({
    update: updateDOM,
    types: [direction] // Matches the :active-view-transition-type() selectors.
  });
}
```
