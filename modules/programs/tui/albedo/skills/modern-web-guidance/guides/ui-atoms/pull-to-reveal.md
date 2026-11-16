# Pull to Reveal

In the pull-to-reveal pattern, content such as a search bar or refresh control starts hidden above the top of a scrollable area, and the user pulls down (scrolls up) to reveal it. It suits search bars, filters and other secondary controls that should be reachable but not immediately visible.

The CSS property `scroll-initial-target` implements this declaratively. With `scroll-initial-target: nearest` on the main content element, the scroll container first renders with the hidden content scrolled out of view, without the JavaScript (`Element.scrollIntoView()`) or URL fragment (`#content-id`) workarounds, which have limitations and are tricky to get right.

## How to implement

1. The target element must be inside a scroll container (an element whose overflow allows scrolling, such as `overflow: auto`). This can be any ancestor, including the root `<html>` element.
2. Place the content to hide, such as a search bar, as the first descendant in the scroll container. It is scrolled out of view on initial load.
3. Place the main content, which the user should see first, immediately after it.
4. Apply `scroll-initial-target: nearest` to the main content so the container renders with it scrolled into view, hiding the element above.
5. Add `scroll-snap-type: y mandatory` to the scroll container and `scroll-snap-align: start` to both the hidden element and the main content, so the hidden element is always fully visible or fully hidden and never rests partly scrolled.

## Example code: pull to reveal search

```css
/* Snapping keeps the search bar either fully visible or fully hidden. */
.scroll-container {
  height: 100vh;
  overflow-y: auto;
  scroll-snap-type: y mandatory;
}

/* Hidden above the fold on load; snaps into place when pulled down. */
.search-bar {
  height: 60px;
  scroll-snap-align: start;
}

/* Shown first: the container scrolls here on initial render, hiding the search bar. */
.main-content {
  scroll-snap-align: start;
  scroll-initial-target: nearest;
}
```

## Best practices

- Give every pull-to-reveal action a visible button or menu item that performs the same action with a single click or the Enter key, as WCAG 2.5.1 Pointer Gestures requires for path-based gestures. Make each button at least 24×24 CSS pixels (WCAG 2.5.8 Target Size (Minimum)) and name it after the item it acts on.
- Use `scroll-initial-target: nearest` to draw attention to a specific part of a scrollable area on load while deliberately hiding peripheral UI, such as a search bar at the very top.
- The property moves only the visual scroll position, not keyboard focus. If the target should be the starting point for keyboard users, call `element.focus()` yourself.
- The position is set instantly during layout. Don't use this property if you need a smooth scrolling animation on load.
- Set `scroll-initial-target` on only one element per scroll container. If several specify `scroll-initial-target: nearest`, the browser uses the first in DOM tree order.
- A URL fragment (such as `example.com/#top`) takes precedence over `scroll-initial-target`, as would a container-level initial scroll position from the draft `scroll-start` property, which no browser ships.

## Fallback strategy

Browser support for scroll-initial-target: Limited availability.
Supported by: Chrome 133 (Feb 2025) and Edge 133 (Feb 2025).
Unsupported in: Firefox and Safari.

In browsers without support, use a JavaScript fallback. For pull to reveal, align the main content to the `start` (top) of the container.

```javascript
document.addEventListener("DOMContentLoaded", () => {
  if (!CSS.supports("scroll-initial-target", "nearest")) {
    const targetContent = document.querySelector('.main-content');
    if (targetContent) {
      // "instant" mimics the native behavior; block should match the CSS scroll-snap-align (or expected top position).
      targetContent.scrollIntoView({ behavior: 'instant', block: 'start' });
    }
  }
});
```
