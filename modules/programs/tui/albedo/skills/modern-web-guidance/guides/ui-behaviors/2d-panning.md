# Two-Dimensional Panning

When a user scrolls a two-dimensional scroll container, browsers usually apply an axis-locking heuristic ("railing"): if a gesture starts with much more movement along one axis than the other, the scroll locks to that axis and ignores perpendicular movement, often for the rest of the gesture.

Railing prevents sideways drift in one-dimensional reading, but it gets in the way on 2D panning surfaces such as interactive maps, zoomed images, infinite canvases, node graphs and large data grids. Because the lock lasts for the whole gesture, it affects any panning in two directions, whether both axes move at once (diagonal) or one after another in a single gesture (curved, circular or L-shaped paths). The CSS `scroll-axis-lock` property turns the heuristic off on a native scroll container, giving unrestricted 2D panning while keeping compositor-thread scrolling, momentum, native scrollbars and keyboard navigation.

## Implementation

### 1. Disable axis locking and contain overscroll

Apply `scroll-axis-lock: none` to the element that is the 2D scroll container (`overflow: auto` or `overflow: scroll`). Under the default `auto`, a 2D container already scrolls on both axes, but the railing heuristic engages when a gesture starts mostly along one axis. `none` stops railing for touchscreens, trackpads and mouse wheels.

Pair it with `overscroll-behavior: none` (or `contain`) on the same container, so reaching an edge doesn't chain scrolling to the page or trigger browser overscroll navigation such as horizontal back/forward swipes or pull-to-refresh.

### 2. Keep it keyboard accessible

A 2D panning surface such as a map or zoomed image often has no focusable children. Add `tabindex="0"`, an appropriate `role`, an accessible label and a visible `:focus-visible` indicator so keyboard users can focus the container and pan it with the arrow keys.

## Example

```html
<!-- Focusable and labelled so keyboard users can pan in all directions with the arrow keys. -->
<div class="pan-viewport" tabindex="0" role="region" aria-label="Interactive canvas">
  <div class="pan-surface">
    <!-- 2D overflowing content: map tiles, zoomed image, canvas nodes or grid. -->
  </div>
</div>
```

```css
.pan-viewport {
  /* Example size; adjust to your layout. */
  inline-size: 100%;
  block-size: 500px;

  /* A scroll container that can overflow on both axes. */
  overflow: auto;

  /* Stops railing, so 2D gestures never lock to one axis. */
  scroll-axis-lock: none;

  /* Contains scrolling and prevents swipe navigation at the edges (none or contain). */
  overscroll-behavior: none;
}

.pan-viewport:focus-visible {
  outline: 3px solid #005fcc;
  outline-offset: 2px;
}

.pan-surface {
  /* Example size, larger than .pan-viewport on both axes. */
  inline-size: 3000px;
  block-size: 3000px;
}
```

## Constraints

- Set `scroll-axis-lock` on the scroll container itself. It isn't inherited, so setting it on a wrapper does nothing for descendant scroll containers.
- Because it isn't inherited, a one-dimensional sidebar or inspector nested inside `.pan-viewport` keeps the default `scroll-axis-lock: auto` and its railing.
- Keep `auto` on vertical feeds, articles and one-dimensional lists, where railing prevents unintended perpendicular drift.
- Don't set `touch-action` unconditionally. It controls whether the browser handles touch gestures at all (and has no effect on trackpad or wheel input), so restricting it disables native compositor touch scrolling. Use it only inside `@supports not (scroll-axis-lock: none)` with the JavaScript pointer fallback below, and use `touch-action: pinch-zoom` rather than `none` so users can still pinch-zoom (WCAG 1.4.4 Resize Text).
- Pan with `scrollLeft` and `scrollTop`, never with a CSS `transform` on the surface. Translating the surface stops the element working as a scroll container, breaking native scrollbars, boundary clamping, arrow-key scrolling, `scroll` events, `IntersectionObserver` and scroll-driven animations.

## Fallback strategies

Browser support for scroll-axis-lock: Limited availability.
Supported by: Chrome 153 (Sep 2026).
Unsupported in: Edge, Firefox, and Safari.

Choose progressive enhancement or a JavaScript fallback according to what the application needs.

### Option 1: progressive enhancement (no JavaScript)

Choose this when keeping native compositor touch scrolling and inertial fling matters more than removing railing in unsupported browsers.

- Supporting browsers don't apply railing on the 2D container.
- Unsupported browsers ignore `scroll-axis-lock: none` and keep their default `auto` behaviour: native scrolling on both axes, with railing for gestures that start mostly along one axis.

### Option 2: JavaScript fallback (`wheel` and `pointermove` with `scrollLeft`/`scrollTop`)

If unrestricted 2D panning is required in every browser, intercept `wheel` and pointer drags only when unsupported, gated by `@supports not (scroll-axis-lock: none)` and `CSS.supports('scroll-axis-lock', 'none')`.

`wheel` (`e.deltaX`, `e.deltaY`) and `pointermove` (`e.clientX`, `e.clientY`) report raw 2D movement before the scrolling engine applies railing, so you can apply it directly to `scrollLeft` and `scrollTop`.

- Updating `scrollLeft` and `scrollTop`, rather than a `transform`, keeps the element a real scroll container. The browser clamps positions to `[0, scrollWidth - clientWidth]` and `[0, scrollHeight - clientHeight]`, scrollbars stay in sync, arrow-key scrolling keeps working, and `scroll` events and `IntersectionObserver` fire normally.
- Trade-offs: a `wheel` listener with `{ passive: false }` moves scrolling onto the main thread, and `touch-action: pinch-zoom` hands touch panning to the script, which loses native inertial fling after `pointerup`. `pinch-zoom` keeps pinch-to-zoom working, which `touch-action: none` would also disable.

```css
/* Disable native touch panning only when scroll-axis-lock is unsupported and the
   JavaScript pointer fallback is active. pinch-zoom keeps pinch-to-zoom working. */
@supports not (scroll-axis-lock: none) {
  .pan-viewport {
    touch-action: pinch-zoom;
  }
}
```

```javascript
// Attach the main-thread fallback only when native support is missing.
if (!CSS.supports('scroll-axis-lock', 'none')) {
  const viewport = document.querySelector('.pan-viewport');
  let lastPointer = null;

  // Trackpad and mouse wheel.
  viewport.addEventListener(
    'wheel',
    (e) => {
      if (e.ctrlKey) return; // Ctrl+wheel and trackpad pinch zoom the page.
      e.preventDefault();
      viewport.scrollLeft += e.deltaX;
      viewport.scrollTop += e.deltaY;
    },
    { passive: false },
  );

  // Touch and pointer drag.
  viewport.addEventListener('pointerdown', (e) => {
    // Ignore non-primary pointers and buttons, and presses on the native scrollbars.
    const rect = viewport.getBoundingClientRect();
    if (
      !e.isPrimary ||
      e.button !== 0 ||
      e.clientX - rect.left - viewport.clientLeft >= viewport.clientWidth ||
      e.clientY - rect.top - viewport.clientTop >= viewport.clientHeight
    ) {
      return;
    }
    lastPointer = { x: e.clientX, y: e.clientY };
    viewport.setPointerCapture(e.pointerId);
  });

  viewport.addEventListener('pointermove', (e) => {
    if (!lastPointer) return;
    viewport.scrollLeft -= e.clientX - lastPointer.x;
    viewport.scrollTop -= e.clientY - lastPointer.y;
    lastPointer = { x: e.clientX, y: e.clientY };
  });

  const endPointerPan = () => {
    lastPointer = null;
  };
  viewport.addEventListener('pointerup', endPointerPan);
  viewport.addEventListener('pointercancel', endPointerPan);
}
```
