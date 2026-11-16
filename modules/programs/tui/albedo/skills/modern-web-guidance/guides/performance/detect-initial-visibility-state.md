# Detect Initial Visibility State

For accurate performance monitoring, find out whether a page was loaded in the background, for example opened in a background tab. Such pages render late and report longer metrics such as First Contentful Paint, so filter them out of performance analytics to avoid skewing the data.

The most accurate source is the `VisibilityStateEntry` API. It records visibility changes on the performance timeline, so the history is complete no matter when your script runs.

## Detecting initial visibility and background time

Read the visibility history with `performance.getEntriesByType('visibility-state')`. Checking `document.visibilityState` when your script runs is subject to race conditions, so do not rely on it alone.

```javascript
/**
 * Determines visibility state history using the Performance API.
 */
function getVisibilityInfo() {
  const entries = performance.getEntriesByType('visibility-state');

  if (entries.length > 0) {
    // A first entry of 'hidden' means the page loaded in the background.
    const initiallyBackgrounded = entries[0].name === 'hidden';

    // High-resolution time the page was first hidden. entry.startTime is
    // the browser's own timestamp of the change, so it is exact.
    let timeBackgrounded = null;
    for (const entry of entries) {
      if (entry.name === 'hidden') {
        timeBackgrounded = entry.startTime;
        break;
      }
    }

    return {
      initiallyBackgrounded,
      timeBackgrounded
    };
  }
}
```

## Browser support and fallback

Browser support for Page visibility state performance entries: Limited availability.
Supported by: Chrome 115 (Jul 2023) and Edge 115 (Jul 2023).
Unsupported in: Firefox and Safari.

Where the API is unsupported, you can fall back to reading `document.visibilityState` or listening for `visibilitychange`. This fallback is often wrong about the initial background state. Scripts load and run asynchronously, so a page can be opened in a background tab and brought to the foreground before your script runs. `document.visibilityState` then reads `'visible'`, and the page looks as if it loaded in the foreground. The fallback timestamp is also less precise than the Performance API's. If precision matters most, do not use the fallback.

```javascript
/**
 * Fallback using document.visibilityState. Prone to race conditions when
 * the script loads asynchronously.
 */
function getFallbackVisibilityInfo() {
  // Misses an initial background state if the page was foregrounded
  // before this script ran.
  let initiallyBackgrounded = document.visibilityState === 'hidden';

  // If hidden now, approximate that it was hidden from load (time 0).
  let timeBackgrounded = initiallyBackgrounded ? 0 : null;

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden' && timeBackgrounded === null) {
      // performance.now() is when the listener ran, not the exact time the
      // visibility changed.
      timeBackgrounded = performance.now();
    }
  });

  return {
    get initiallyBackgrounded() { return initiallyBackgrounded; },
    get timeBackgrounded() { return timeBackgrounded; }
  };
}

// getVisibilityInfo() is the VisibilityStateEntry implementation above.
const visibilityInfo = 'VisibilityStateEntry' in window
  ? getVisibilityInfo()
  : getFallbackVisibilityInfo();
```
