# Carousel Snap Highlights

Scroll-state container queries style elements by their scroll state, for example whether an element is stuck (sticky positioning) or snapped (scroll snapping). A carousel or gallery can then highlight the active item without intersection observers or scroll listeners.

## Core implementation

Create a scroll-snap container, make the snap targets scroll-state containers, and query that state to style their descendants.

### 1. Scroll snap container

The parent needs `scroll-snap-type`.

```html
<div class="carousel">
  <div class="carousel-item">
    <div class="card">Product 1 content</div>
  </div>
  <div class="carousel-item">
    <div class="card">Product 2 content</div>
  </div>
</div>
```

```css
.carousel {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
}
```

### 2. Snap targets as scroll-state containers

Every item tracked for snapping must be a `scroll-state` container:

```css
.carousel-item {
  scroll-snap-align: center;
  container-type: scroll-state;
}
```

### 3. Query the `snapped` state

Container queries style descendants, so apply the highlight to an element inside the snap target. The container scrolls on the x axis, so query `scroll-state(snapped: x)`.

Show the effect only inside `@media (prefers-reduced-motion: no-preference)`. Depending on the use case you might keep part of it under reduced motion, but here the cards flash from white to blue, which can be a problem for some users, so it is disabled entirely, color change included.

```css
/* The transition sits outside the queries so it applies in both states. */
.card {
  transition:
    scale 0.4s cubic-bezier(0.25, 0.8, 0.25, 1),
    background-color 0.4s,
    color 0.4s,
    box-shadow 0.4s;
}

@media (prefers-reduced-motion: no-preference) {
  /* Style the card while its parent .carousel-item is snapped on the x axis. */
  @container scroll-state(snapped: x) {
    .card {
      background: #007bff;
      color: white;
      scale: 1.15;
      box-shadow: 0 10px 25px rgba(0, 123, 255, 0.3);
    }
  }
}

/* Keeps the effect off for motion-sensitive users even if the rules above are copied elsewhere. */
@media (prefers-reduced-motion: reduce) {
  .card {
    transition: none !important;
    scale: 1 !important;
  }
}
```

The `snapped` descriptor accepts `x`, `y`, `inline`, `block` or `both`.

## Accessibility

The snapped item is not exposed to the accessibility tree. So:

- Don't use snapping as a way for people to select an option.
- Avoid using `scroll-state` with interactive elements.
- The snapped highlight must not suggest that an item is active or focused. Keep a keyboard focus ring with at least 3:1 contrast against adjacent colors that looks distinct from the snapped highlight. If the snapped item is interactive, make it accessible with the usual techniques.

Snapping comes from scrolling, which doesn't move keyboard focus. But moving focus to an element inside the scroll container can scroll the container and change the snapped item, which may or may not be the focused one. That is confusing, which is why interactive elements in the container are discouraged.

> [!NOTE]
> This is not a traditional carousel, where slides change automatically, often without a way to pause them, and which often don't convey the visible content to screen reader users. If you need a carousel that shows a single slide at a time, don't use this technique; it lacks the accessibility information such a component needs. Build a tab-like component instead that works with the keyboard alone, can be paused or stopped, and conveys name, role and state to screen readers. Accessible carousels are nuanced and context-dependent, so follow established accessibility standards and test thoroughly with users before production.

Don't make items that aren't highlighted hard to perceive. For example, don't render non-snapped gallery items in low-opacity greyscale that only reaches adequate contrast once snapped. Content must always have sufficient contrast so it is perceivable and people can tell there is more to navigate to.

For consistent behaviour across browsers and assistive technology, make the scroll container focusable (`tabindex="0"`) and give it an accessible name and a role such as `role="region"`:

```html
<div class="carousel" role="region" aria-label="Highlights" tabindex="0">
  …
</div>
```

## Fallback strategies

Browser support for Container scroll-state queries: Limited availability.
Supported by: Chrome 144 (Jan 2026) and Edge 144 (Jan 2026).
Unsupported in: Firefox and Safari.

Without scroll-state queries, all items must still be legible and usable without the highlight.

### Feature detection

Use `@supports` to apply enhancements only where supported:

```css
@supports (container-type: scroll-state) {
  /* Enhancement styles. */
}
```

### JavaScript fallback

If the highlight is essential, use `IntersectionObserver` to find the snapped item. Shrink the observed area to a thin slice in the middle of the carousel with a negative inline `rootMargin`; `"0px -49%"` counts an item as intersecting when any part of it is in the middle 2% of the carousel.

```javascript
if (!CSS.supports('container-type', 'scroll-state')) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      entry.target.classList.toggle('is-snapped', entry.isIntersecting);
    });
  }, {
    root: document.querySelector(".carousel"),
    // An item intersects if any part of it is in the middle 2% of the carousel.
    rootMargin: "0px -49%"
  });

  document.querySelectorAll('.carousel-item').forEach(item => {
    observer.observe(item);
  });
}
```

Style the fallback class with the same declarations as the `@container` rule:

```css
@media (prefers-reduced-motion: no-preference) {
  .carousel-item.is-snapped .card {
    background: #007bff;
    color: white;
    scale: 1.15;
    box-shadow: 0 10px 25px rgba(0, 123, 255, 0.3);
  }
}
```
