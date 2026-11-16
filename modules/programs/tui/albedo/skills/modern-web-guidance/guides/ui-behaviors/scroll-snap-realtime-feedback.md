# Scroll Snap Real-Time Feedback

Users expect immediate visual feedback from carousels and galleries. Plain scroll snap only gives feedback after the gesture ends and the element settles. The `scrollsnapchanging` event gives feedback during the gesture, so you can highlight the pending snap target before the user lifts their finger or releases the mouse.

## Implementation

### 1. Listen for `scrollsnapchanging`

Listen on the scroll container. The event fires when the browser determines that a new snap target is likely to be chosen.

```javascript
const container = document.querySelector('#gallery');
const thumbnails = document.querySelectorAll('.thumbnail');
const items = document.querySelectorAll('.gallery-item');

container.addEventListener('scrollsnapchanging', (event) => {
  // Highlight the pending snap target while scrolling.
  const pendingTarget = event.snapTargetInline;
  const index = [...items].indexOf(pendingTarget);

  if (index === -1 || !thumbnails[index]) return;

  // A cheap class toggle avoids layout thrashing during rapid events.
  // aria-current isn't changed here: it tracks the settled item and is
  // updated in the scrollsnapchange handler.
  thumbnails.forEach((thumb) => thumb.classList.remove('pending'));
  thumbnails[index].classList.add('pending');
});
```

The gallery scrolls horizontally, so this uses `snapTargetInline`. For a vertical scroller use `snapTargetBlock`.

### 2. Listen for `scrollsnapchange`

`scrollsnapchange` fires when the gesture completes and the element actually snaps. You need it to set the final active state.

```javascript
container.addEventListener('scrollsnapchange', (event) => {
  // Promote the pending item to active once scrolling completes.
  const snappedTarget = event.snapTargetInline;
  const index = [...items].indexOf(snappedTarget);

  if (index === -1 || !thumbnails[index]) return;

  thumbnails.forEach((thumb) => {
    thumb.classList.remove('pending', 'active');
    thumb.removeAttribute('aria-current');
  });
  thumbnails[index].classList.add('active');
  thumbnails[index].setAttribute('aria-current', 'true');
});
```

### 3. Sync the initial state

On load the browser may restore the scroll position (history traversal, an anchor link), and neither `scrollsnapchange` nor `scroll` fires for that. Run a one-off geometric check to sync the UI with the initial position.

```javascript
// item.offsetLeft must be relative to the container, so the container has to be
// the offsetParent (for example position: relative).
const findClosestItemIndex = () => {
  // Comparing centers assumes scroll-snap-align: center on the items.
  // For start alignment, compare scrollLeft with item.offsetLeft directly.
  const containerCenter = container.scrollLeft + container.clientWidth / 2;
  let closestIndex = 0;
  let minDistance = Infinity;

  items.forEach((item, index) => {
    const itemCenter = item.offsetLeft + item.offsetWidth / 2;
    const distance = Math.abs(containerCenter - itemCenter);
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = index;
    }
  });
  return closestIndex;
};

const initActiveItem = () => {
  const closestIndex = findClosestItemIndex();
  if (!thumbnails[closestIndex]) return;

  thumbnails.forEach((thumb) => {
    thumb.classList.remove('pending', 'active');
    thumb.removeAttribute('aria-current');
  });
  thumbnails[closestIndex].classList.add('active');
  thumbnails[closestIndex].setAttribute('aria-current', 'true');
};

if (document.readyState === 'complete') {
  initActiveItem();
} else {
  window.addEventListener('load', initActiveItem, { once: true });
}
```

## Accessibility

For a carousel or gallery with navigation controls:

1. Keep the controls in step with the scroll container. Update the matching control's state with `aria-current="true"` as the container changes, so people can tell which content is current.
2. Wrap the whole component in a `<section>` with an accessible name. Put `focusgroup="toolbar wrap"` (adjusted to the visual design) on the element that wraps the thumbnail buttons, not on the section, so only the controls form the toolbar and the gallery content keeps its own semantics. This manages focus and gives the controls roving-tabindex behaviour.
3. Make each button's name match the text or description of the content it controls, so people reading the content understand which control shows what.

> [!NOTE]
> This is not a traditional carousel, where slides change automatically, often without a way to pause them, and which often don't convey the visible content to screen reader users. If you need a carousel that shows one slide at a time and advances automatically, don't use this technique; it lacks the accessibility information such a component needs. Build a tab-like component instead that works with the keyboard alone, can be paused or stopped, and conveys name, role and state to screen readers. Accessible carousels are nuanced and context-dependent, so follow established accessibility standards and test thoroughly with users before production.

For consistent behaviour across browsers and assistive technology, make the scroll container focusable (`tabindex="0"`) and give it an accessible name that describes its content and a role such as `role="region"`.

## Fallback strategies

Browser support for Scroll snap events: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

Baseline status for Scroll snap: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 69 (Sep 2018), Edge 79 (Jan 2020), Firefox 68 (Jul 2019), and Safari 11 (Sep 2017).

Without `scrollsnapchanging` there is no eager feedback during the gesture, and without a fallback the linked UI falls out of sync with the content. Always provide one: emulate `scrollsnapchanging` with a `scroll` listener, `requestAnimationFrame` and a distance calculation that finds the closest snap target while the user scrolls. Clear stale `pending` classes on every update.

```javascript
if ('onscrollsnapchanging' in HTMLElement.prototype) {
  // Use the native scroll snap events above.
} else {
  // Reuses container, thumbnails, items and findClosestItemIndex from the steps above.
  let scrollTimeout;
  let rafId = null;

  const promotePendingToActive = () => {
    const closestIndex = findClosestItemIndex();
    if (!thumbnails[closestIndex]) return;
    thumbnails.forEach((thumb) => {
      thumb.classList.remove('pending', 'active');
      thumb.removeAttribute('aria-current');
    });
    thumbnails[closestIndex].classList.add('active');
    thumbnails[closestIndex].setAttribute('aria-current', 'true');
  };

  container.addEventListener('scroll', () => {
    if (rafId) return;
    rafId = requestAnimationFrame(() => {
      rafId = null;
      const closestIndex = findClosestItemIndex();
      if (!thumbnails[closestIndex]) return;

      thumbnails.forEach((thumb) => thumb.classList.remove('pending'));
      thumbnails[closestIndex].classList.add('pending');
    });

    // Debounced promotion for browsers without scrollend.
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(promotePendingToActive, 100);
  }, { passive: true });

  // Where supported, the Baseline scrollend event promotes pending to active cleanly.
  container.addEventListener('scrollend', () => {
    clearTimeout(scrollTimeout);
    promotePendingToActive();
  });
}
```

This fallback closely emulates native snap prediction, including programmatic scrolling: methods such as `scrollIntoView()` fire `scroll` events while they run, so the UI stays in sync through the scroll animation without extra logic.

### focusgroup

Browser support for focusgroup: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Keep `focusgroup="toolbar wrap"` on the thumbnail wrapper in the markup. When `'focusGroup' in HTMLElement.prototype` is false, implement a roving tabindex on the gallery controls and add `role="toolbar"` to that wrapper yourself. Never install this fallback when native focusgroup is present.

```js
if (!('focusGroup' in HTMLElement.prototype)) {
  document.querySelectorAll('[focusgroup~="toolbar"]').forEach(group => {
    group.setAttribute('role', 'toolbar');

    const items = () => [...group.querySelectorAll('button')]
      .filter(item => item.closest('[focusgroup]') === group)
      .filter(item => !item.disabled && item.getAttribute('aria-disabled') !== 'true');

    const syncTabIndex = () => {
      const list = items();
      let current = list.indexOf(document.activeElement);

      if (current < 0) {
        current = list.indexOf(list.find(item => item.getAttribute('aria-current') === 'true'));
      }
      // Keep one tab stop even when nothing is focused or current.
      if (current < 0) current = 0;

      list.forEach((item, index) => {
        item.tabIndex = current === index ? 0 : -1;
      });
    };

    group.addEventListener('focusin', syncTabIndex);
    group.addEventListener('keydown', event => {
      if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
      const list = items();
      const current = list.indexOf(document.activeElement);
      if (current < 0) return;
      const next = (current + (event.key === 'ArrowLeft' ? -1 : 1) + list.length) % list.length;
      event.preventDefault();
      event.stopImmediatePropagation();
      list.forEach((item, index) => {
        item.tabIndex = index === next ? 0 : -1;
      });
      list[next].focus({ preventScroll: true });
    }, true);

    syncTabIndex();
  });
}
```
