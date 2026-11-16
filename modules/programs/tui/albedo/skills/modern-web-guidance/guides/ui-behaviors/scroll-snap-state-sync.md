# Scroll Snap State Sync

Keeping UI in sync with a scroller's snap position used to take scroll listeners, manual offset math and intersection observers. The `scrollsnapchange` event fires when a scroller settles on a new snap target, which makes it easy to sync a sidebar or highlight the current section in a table of contents.

## Implementation

### 1. Configure scroll snap

The browser tracks snap targets only when the container has `scroll-snap-type` and its children have `scroll-snap-align`. In a long article with a table of contents, snap section headings to the top of the viewport:

```css
main {
  scroll-snap-type: y proximity;
  overflow-y: auto;
}

h2 {
  scroll-snap-align: start;
}
```

### 2. Listen for snap changes

Listen for `scrollsnapchange` on the scroll container to react when scrolling finishes on a new element, for example to mark the current table-of-contents link. Put the links in a navigation landmark:

```html
<nav aria-label="Table of contents">
  <ul>
    <li><a href="#section-1" aria-current="location">Section 1</a></li>
    <li><a href="#section-2">Section 2</a></li>
  </ul>
</nav>
```

```javascript
const main = document.getElementById('main');
const links = document.querySelectorAll('nav a');

function setActiveLink(id) {
  for (const link of links) {
    if (link.getAttribute('href') === `#${id}`) {
      link.setAttribute('aria-current', 'location');
    } else {
      link.removeAttribute('aria-current');
    }
  }
}

// Fires when the scroller settles on a new snap target.
main.addEventListener('scrollsnapchange', (event) => {
  // snapTargetBlock for vertical snapping, snapTargetInline for horizontal.
  const snappedHeader = event.snapTargetBlock;

  if (snappedHeader) {
    setActiveLink(snappedHeader.id);
  }
});
```

## Accessibility

> [!CAUTION]
> Scroll snap events let you sync other content visually with the scroller, but they don't expose that state programmatically. Reflect relationships, active states and live content in the accessibility tree yourself.

- In a table of contents, mark the active link with `aria-current="true"` or `aria-current="location"`.
- Be careful with the `mandatory` value of `scroll-snap-type` (for example `y mandatory`): content between snap points that is taller than the screen can become unreachable.
- Give each anchor target `tabindex="-1"` so it can receive focus after a link is followed. Keyboard users can then scroll the container or move on from that content.

```html
<li><a href="#section-2">Section 2</a></li>
…
<!-- tabindex="-1" lets the heading receive focus after navigation. -->
<h2 id="section-2" tabindex="-1">Section 2</h2>
```

- For consistent behaviour across browsers and assistive technology, make the scroll container focusable (`tabindex="0"`) and give it an accessible name that describes its content, plus a role such as `role="region"` if it has no implicit role (`<main>` already has one).

## Fallback strategies

Browser support for Scroll snap events: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

Without `scrollsnapchange`, use `IntersectionObserver` to find the element at the top of the scroller. This behaves differently: it fires during the scroll, not only once the scroll has settled.

```javascript
if (!('onscrollsnapchange' in HTMLElement.prototype)) {
  const headers = main.querySelectorAll('h2');
  const observer = new IntersectionObserver(
    () => {
      // Include any top border so scrollportTop matches the observer root's
      // padding-box top.
      const scrollportTop =
        main.getBoundingClientRect().top + main.clientTop;
      const topEntry = [...headers].reduce((currentTop, header) => {
        // Compare bottoms so scrolling up works while a heading's top is offscreen.
        const { bottom } = header.getBoundingClientRect();
        // Skip targets whose bottom has passed the 1px top rootMargin.
        if (bottom <= scrollportTop + 1) return currentTop;
        if (!currentTop) return header;
        return bottom < currentTop.getBoundingClientRect().bottom
          ? header
          : currentTop;
      }, undefined);
      if (topEntry) setActiveLink(topEntry.id);
    },
    {
      root: main,
      // A 1px top inset stops adjacent sections intersecting when snapped to start.
      rootMargin: '-1px 0px 0px 0px',
      // Fire when a target enters or exits (0) and when a heading settles into view (0.9).
      threshold: [0, 0.9],
    },
  );

  headers.forEach((header) => observer.observe(header));
}
```
