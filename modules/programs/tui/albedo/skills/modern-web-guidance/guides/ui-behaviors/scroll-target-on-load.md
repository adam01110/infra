# Set a scroll target for the initial render

The CSS property `scroll-initial-target` scrolls a specific descendant into the visible area of its scroll container as soon as the container renders, with no JavaScript. The older approaches, `Element.scrollIntoView()` or a URL fragment (`#item-id`), both have limitations and are tricky to get right.

## How to implement

1. Make sure the target is inside a scroll container, meaning an ancestor whose overflow allows scrolling, such as `overflow: auto`. Any ancestor works, including the root `<html>` element.
2. Apply `scroll-initial-target: nearest` to the descendant you want in view.

## Example: vertical media feed

The feed starts scrolled to a featured item instead of the top of the list.

```css
/* The item that should be visible on initial load. */
.item.target {
  scroll-initial-target: nearest;
}
```

## Usage notes

- Use it for "start in the middle" experiences, such as a calendar opening on the current day or a gallery opening on a specific image.
- It moves only the visual viewport, not keyboard focus. If the target should also be the starting point for keyboard users, call `element.focus()` yourself.
- The position is set instantly during layout, with no scroll animation. Don't use it when you want a smooth scroll on load.
- Set it on only one element per scroll container. If several elements have `scroll-initial-target: nearest`, the browser uses the first one in DOM tree order.
- Give media fixed dimensions (`aspect-ratio`, or `height` and `width`). The scroll position is computed during initial layout, and media that loads later would shift the target.
- A URL fragment (for example `example.com/#top`) and the container-level `scroll-start` property both take precedence over `scroll-initial-target`.

## Fallback strategy

Browser support for scroll-initial-target: Limited availability.
Supported by: Chrome 133 (Feb 2025) and Edge 133 (Feb 2025).
Unsupported in: Firefox and Safari.

In unsupported browsers, fall back to JavaScript. Run it on `DOMContentLoaded` so the element scrolls into view as soon as HTML parsing finishes, rather than waiting for images and other resources. A script at the end of `<body>` also works and needs no event listener.

```javascript
document.addEventListener("DOMContentLoaded", () => {
  if (!CSS.supports("scroll-initial-target", "nearest")) {
    const feedTarget = document.querySelector(".item.target");
    if (feedTarget) {
      // block: center centers the featured item in view.
      feedTarget.scrollIntoView({ behavior: "instant", block: "center" });
    }
  }
});
```
