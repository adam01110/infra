# Calculate total foreground time

Time-on-page usually counts time the page spent in the background. To measure engagement accurately, count only foreground time, using `VisibilityStateEntry` performance entries.

## Implementation

The Performance Timeline records each visibility state change as a `visibility-state` entry. Instead of listening for `visibilitychange` events and accumulating time yourself, query the whole visibility history whenever you need it.

```javascript
/**
 * Calculates total time the page was in the visible state.
 *
 * @returns {number} Total foreground time in milliseconds.
 */
function getTotalForegroundTime() {
  const entries = performance.getEntriesByType('visibility-state');

  // Unsupported browsers return an empty array: fall back to time since
  // navigation start.
  if (entries.length === 0) {
    return performance.now();
  }

  let totalForegroundTime = 0;

  for (let i = 0; i < entries.length; i++) {
    if (entries[i].name === 'visible') {
      const start = entries[i].startTime;

      // A visible period ends at the next state change, or now if it is
      // the last entry.
      const end = i + 1 < entries.length
          ? entries[i + 1].startTime
          : performance.now();

      totalForegroundTime += (end - start);
    }
  }

  return totalForegroundTime;
}
```

## Browser support and fallback

Browser support for Page visibility state performance entries: Limited availability.
Supported by: Chrome 115 (Jul 2023) and Edge 115 (Jul 2023).
Unsupported in: Firefox and Safari.

In unsupported browsers `performance.getEntriesByType('visibility-state')` returns an empty array rather than throwing, so checking whether any entries came back is the feature detection. Always check before calculating.

When the API is unsupported, return `performance.now()`. It is the total time since navigation, a reasonable upper bound for engagement time when no visibility history is available.
