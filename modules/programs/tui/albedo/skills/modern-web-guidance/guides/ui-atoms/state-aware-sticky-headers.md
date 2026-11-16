# State-Aware Sticky Headers

Sticky headers often need a different appearance once they are stuck, to stay readable or save space. JavaScript scroll listeners for this can hurt performance; scroll-state container queries handle it in CSS.

## Implementation steps

### 1. Create the sticky container

The sticky element also serves as the scroll-state query container.

```html
<!-- The section bounds the sticky element. -->
<div class="section">
  <div class="sticky-container">
    <div class="sticky-header">
      Section Header
    </div>
  </div>
  <div class="content">
    <!-- Content goes here -->
  </div>
</div>
```

### 2. Make it sticky and a scroll-state container

Set `container-type: scroll-state` on the `position: sticky` element, not on its scrollable ancestor. Always give it a `container-name`: these queries may be nested, and unnamed containers collide. Scroll-state can be combined with size queries, such as `container-type: scroll-state inline-size`.

```css
.sticky-container {
  position: sticky;
  top: 0;
  container-type: scroll-state;
  container-name: section-header;
  z-index: 10;
}

.sticky-header {
  background: #f0f0f0;
  padding: 20px;
  transition: background-color 0.3s, box-shadow 0.3s;
}
```

Only descendants of the scroll-state container can be styled by its query. Styles in the `@container` rule apply to children such as `.sticky-header`, never to `.sticky-container` itself.

Set `scroll-padding-top` on the scrollport to at least the sticky element's height, so focused controls appear below the sticky content. This satisfies WCAG 2.4.11 Focus Not Obscured (Minimum), which requires that focused components are not fully obscured.

```css
html {
  /* --header-height is the sticky header's height, defined wherever you size the header. */
  scroll-padding-top: var(--header-height);
}
```

### 3. Target the stuck state

```css
@container section-header scroll-state(stuck: top) {
  .sticky-header {
    background: #0056b3;
    color: white;
    box-shadow: 0 4px 6px rgb(0 0 0 / 0.15);
  }
}
```

Logical values such as `stuck: block-start` or `stuck: inline-start` query flow-relative edges instead of physical ones, which suits internationalized and right-to-left layouts.

### Dimension changes

Changing layout-affecting properties (height, padding, font-size) in the stuck state can cause flickering while scroll anchoring is active. Scroll anchoring on the in-flow content below the sticky element shifts the scroll offset to compensate for the layout change, which pushes the element back out of its stuck position and starts an oscillation.

Disable scroll anchoring on the sticky element's direct parent:

```css
.section {
  overflow-anchor: none;
}
```

Don't apply it to `:root` or `body`, which would disable scroll anchoring for the whole page. With it in place, you can change any property in the stuck state, including box-model properties and transforms.

This does not help elements stuck to the bottom: scroll anchoring only compensates for layout shifts above the current scroll position, so `overflow-anchor: none` has no effect there. Avoid changing box-model properties in the stuck state of bottom-stuck headers.

### Fallback strategies

Browser support for Container scroll-state queries: Limited availability.
Supported by: Chrome 144 (Jan 2026) and Edge 144 (Jan 2026).
Unsupported in: Firefox and Safari.

Scroll-state queries are progressive enhancement. Without support, the header still sticks (through `position: sticky`) but does not change appearance. For most uses, this is the recommended approach.

Prefer a layout whose default styling works everywhere, even when the stuck styling adds a background for readability. If stickiness is not essential and an unstyled sticky header would be worse than no stickiness, gate `position: sticky` and the related declarations behind `@supports` as well:

```css
.sticky-container {
  @supports (container-type: scroll-state) {
    position: sticky;
    top: 0;
    container-type: scroll-state;
    container-name: section-header;
    z-index: 10;
  }
}
```

If the visual change is essential, for example the stuck state adds a background or compaction without which the content is unreadable, use an `IntersectionObserver` fallback and duplicate the stuck styles under an `.is-stuck` class. This generic polyfill walks up with `getComputedStyle` to find the scroll container (defaulting to the viewport), matching the behavior of `@container scroll-state(stuck: top)`:

```javascript
function getScrollParent(node) {
  if (node == null || node === document.body || node === document.documentElement) {
    return null; // The viewport.
  }
  if (node.scrollHeight > node.clientHeight || node.scrollWidth > node.clientWidth) {
    const overflow = getComputedStyle(node).overflow;
    if (overflow !== 'visible' && overflow !== 'clip') {
      return node;
    }
  }
  return getScrollParent(node.parentNode);
}

document.querySelectorAll('.sticky-container').forEach(container => {
  const root = getScrollParent(container);
  const topOffset = parseFloat(getComputedStyle(container).top) || 0;

  const observer = new IntersectionObserver(
    ([e]) => {
      // A header below the fold also has a ratio under 1, so also require it to be at or above the stuck line.
      const stuck = e.intersectionRatio < 1 && e.boundingClientRect.top < e.rootBounds.top;
      e.target.classList.toggle('is-stuck', stuck);
    },
    {
      root: root,
      threshold: [1],
      rootMargin: `-${topOffset + 1}px 0px 0px 0px`
    }
  );

  observer.observe(container);
});
```

The same IntersectionObserver pattern can also polyfill the `scroll-state(scrollable)` query.
