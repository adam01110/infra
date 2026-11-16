# Defer Work Until Scroll Ends

Heavy work during scrolling, such as layout recalculation, analytics beacons or dynamic DOM updates, saturates the main thread and causes dropped frames and layout thrashing.

Debouncing the `scroll` event with `setTimeout()` to guess when scrolling has finished is unreliable: the callback can fire while the user is still scrolling. Use the `scrollend` event instead. The browser fires it once scrolling has come to rest, all scroll transitions have finished, and the touch gesture has been released.

## How to implement

1. Use a scroll container with `overflow: auto` or `overflow: scroll`.
2. In `scroll` listeners, do only light work such as simple metrics or informative styling.
3. Register a `scrollend` listener on the scroll container or on the document.
4. Run expensive work, such as fetching content or large DOM and layout updates, in the `scrollend` callback.

## Example

```css
.scroll-container {
  height: 300px;
  overflow-y: auto;
}
```

```javascript
const scroller = document.querySelector('.scroll-container');

// Light, informative feedback only.
scroller.addEventListener('scroll', () => {
  console.log('Scrolling... updates deferred');
});

// Expensive work once scrolling has come to rest.
scroller.addEventListener('scrollend', () => {
  const currentVisibleSection = findMostVisibleSection(scroller);
  fetchAdditionalData(currentVisibleSection);
});
```

## Guidelines

- Use `scrollend` instead of a debounced `scroll` handler to send layout data beacons or fetch new content.
- For carousels or slide galleries, consider pairing it with the scroll snap events `scrollsnapchange` and `scrollsnapchanging`.
- Keep layout-dependent updates out of `scroll` callbacks that drive visual effects.
- Visual viewport zooming and scrolling also fire `scrollend` correctly.

## Browser support and fallback

Baseline status for scrollend: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 114 (May 2023), Edge 114 (Jun 2023), Firefox 109 (Jan 2023), and Safari 26.2 (Dec 2025).

In unsupported browsers, debounce `scroll` with `setTimeout` and dispatch a custom `scrollend` event, so the same listener works everywhere:

```javascript
const scroller = document.querySelector('#scroller');

scroller.addEventListener('scrollend', () => {
  // Expensive work here.
});

if (!('onscrollend' in window)) {
  let scrollendTimer;
  scroller.addEventListener('scroll', () => {
    clearTimeout(scrollendTimer);
    scrollendTimer = setTimeout(() => {
      scroller.dispatchEvent(new CustomEvent('scrollend'));
    }, 100);
  });
}
```
