# Efficient Background Processing

Pause heavy background work while the browser is not rendering a component, to save system resources and battery.

## Overview

With `content-visibility: auto`, the browser skips rendering for elements far outside the viewport. Whenever it starts or stops skipping an element, it fires `contentvisibilityautostatechange` on that element.

Listen for this event to pause expensive work such as `<canvas>` animations, WebGL rendering or high-frequency WebSocket polling while it is not needed, and resume it just before the browser displays the content.

### `contentvisibilityautostatechange` or `IntersectionObserver`

- Use `IntersectionObserver` for application logic tied to whether an element is actually visible in the viewport, such as lazy-loading data or infinite scroll triggers.
- Use `contentvisibilityautostatechange` for rendering-heavy work, such as complex canvas updates or heavy DOM mutations. It follows the browser's rendering lifecycle. The browser often starts rendering an element before it appears on screen (the pre-render margin), and the event tells you when that happens, so the content is ready when seen.

## Implementation

### 1. Apply `content-visibility`

Set `content-visibility: auto` on the heavy container, with a placeholder size so the scrollbar does not jump.

```css
.heavy-component {
  content-visibility: auto;

  /* Placeholder size, required to prevent layout shifts.
     - 'auto' (optional) remembers the rendered size; it needs a <length>
       to use for the first render.
     - 'none' applies no intrinsic size on that axis (width here); it can be
       used for either width or height.
     - '500px' is the estimated height; replace it with your component's
       expected height. Any CSS <length> works. */
  contain-intrinsic-size: auto none auto 500px;
}
```

### 2. Listen for state changes

Pause or resume work in a `contentvisibilityautostatechange` listener.

The event does not bubble in some browser implementations. To handle it reliably, either attach the listener directly to the element with `content-visibility: auto`, or, when delegating to a parent, use a capturing listener (`{ capture: true }`).

```javascript
const component = document.querySelector('.heavy-component');

// Option 1: direct listener (recommended).
component.addEventListener('contentvisibilityautostatechange', (event) => {
  if (event.skipped) {
    // Rendering is skipped: stop heavy mutations and animation loops.
    stopSimulation();
    pauseWebSocketPolling();
  } else {
    // About to render: resume so the content is ready when visible.
    startSimulation();
    resumeWebSocketPolling();
  }
});

// Option 2: capturing listener for event delegation.
document.addEventListener('contentvisibilityautostatechange', (event) => {
  if (event.target.matches('.heavy-component')) {
    if (event.skipped) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }
}, { capture: true });
```

## Browser support and fallback

Baseline status for content-visibility: Newly available. It's been Baseline since 2025-09-15.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 130 (Sep 2024), and Safari 26 (Sep 2025).

`content-visibility` and `contentvisibilityautostatechange` are progressive enhancements. In browsers without them, the property is ignored and content renders normally, and the event never fires, so background work keeps running unoptimized.

To pause work in older browsers too, use `IntersectionObserver` as a rough approximation. This also saves battery and CPU on older devices.

```javascript
const target = document.getElementById('target-container');

const isSupported = 'contentVisibility' in document.documentElement.style;

if (!isSupported) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        startSimulation();
      } else {
        stopSimulation();
      }
    });
  }, {
    // Start work shortly before the element reaches the viewport.
    rootMargin: '200px'
  });

  observer.observe(target);
}
```
