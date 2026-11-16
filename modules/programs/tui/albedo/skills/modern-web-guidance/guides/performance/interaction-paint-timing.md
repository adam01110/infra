# Measure interaction and soft-navigation paint timing

Standard paint and responsiveness metrics leave a gap after the initial page load:

- `LargestContentfulPaint` (`largest-contentful-paint`) measures only the initial ("hard") document load and stops emitting entries once the user first interacts with the page.
- `PerformanceEventTiming` (`event`) and Interaction to Next Paint (INP) measure responsiveness only up to the very next frame, such as a button's active state or a loading spinner. They do not track later asynchronous paints, such as content rendered after a `fetch()` resolves or after a client-side route transition completes.
- Route changes in a single-page application (SPA) are hard to observe outside framework code. Watching URL updates over-reports, because some URL changes are not route changes (anchor link changes, several "redirects" for one route change).

The `InteractionContentfulPaint` (`interaction-contentful-paint`) and `PerformanceSoftNavigation` (`soft-navigation`) entry types fill this gap. They carry interaction causality across asynchronous tasks (`fetch`, `await`, `setTimeout`), attributing new contentful paints and SPA route transitions to the user interaction that triggered them.

## How to implement

### 1. Observe contentful paints caused by interactions

Use a `PerformanceObserver` with `type: 'interaction-contentful-paint'` and `buffered: true` to observe progressively larger contentful paints attributable to any user interaction.

Each `InteractionContentfulPaint` entry provides:

- `interactionId`: ID of the initiating interaction, matching `PerformanceEventTiming.interactionId` and `PerformanceSoftNavigation.interactionId`.
- `startTime`: when the initiating interaction started, relative to the initial hard navigation's time origin.
- `paintTime` and `presentationTime`: when the rendering phase ended, and when the painted pixels reached the screen.
- `duration`: time from interaction start to paint presentation (`presentationTime - startTime`).
- `largestContentfulPaint`: a snapshot `LargestContentfulPaint` object for the largest element painted for that interaction so far (`element`, `size`, `url`, `id`, `renderTime`, `loadTime`).

```javascript
/**
 * Calls onInteractionPaint whenever an interaction produces a larger
 * contentful paint.
 *
 * @param {(entry: PerformanceEntry) => void} onInteractionPaint
 */
export function observeInteractionPaints(onInteractionPaint) {
  // Feature-detect before observe() so unsupported browsers do not throw or
  // log console warnings.
  if (
    typeof PerformanceObserver === 'undefined' ||
    !PerformanceObserver.supportedEntryTypes?.includes('interaction-contentful-paint')
  ) {
    return null;
  }

  const observer = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      // entry.duration is the time from the interaction to this paint.
      onInteractionPaint(entry);
    }
  });

  // buffered: true includes paints from before the observer was registered.
  observer.observe({ type: 'interaction-contentful-paint', buffered: true });
  return observer;
}
```

### 2. Measure Largest Contentful Paint (LCP) for SPA soft navigations

The browser emits a soft navigation when a trusted user interaction causes both a visible URL change and a contentful paint. To calculate LCP for each soft navigation:

1. Observe both `'soft-navigation'` and `'interaction-contentful-paint'` entries with `buffered: true`.
2. When a `'soft-navigation'` entry arrives, seed its LCP candidate with `softNavEntry.getLargestInteractionContentfulPaint()`. If the application painted content before updating the URL (for example, rendering a view and then calling `history.pushState()`), those `interaction-contentful-paint` entries were emitted before the `soft-navigation` entry and carry the previous `navigationId`.
3. Correlate later `'interaction-contentful-paint'` entries with the active soft navigation by `entry.interactionId === softNavEntry.interactionId`, not by `entry.navigationId`. Matching on `interactionId` includes paints from before the URL update and excludes paints from later, unrelated interactions on the new route.

```javascript
/**
 * Tracks FCP and LCP for each soft navigation and reports the route's final
 * metrics when the user navigates to a new route or hides the page.
 *
 * @param {(report: {
 *   url: string,
 *   navigationId: number,
 *   interactionId: number,
 *   fcpDuration: number,
 *   lcpDuration: number | null,
 *   lcpElement: Element | null,
 *   lcpSize: number | null
 * }) => void} onSoftNavReport
 */
export function trackSoftNavigationLCP(onSoftNavReport) {
  const supported =
    typeof PerformanceObserver !== 'undefined' &&
    PerformanceObserver.supportedEntryTypes?.includes('soft-navigation') &&
    PerformanceObserver.supportedEntryTypes?.includes('interaction-contentful-paint');

  if (!supported) {
    return null;
  }

  let activeSoftNav = null;
  let activeLcpEntry = null;

  function finalizeCurrentSoftNav() {
    if (!activeSoftNav) return;

    onSoftNavReport({
      // name is the soft navigation's destination URL.
      url: activeSoftNav.name,
      navigationId: activeSoftNav.navigationId,
      interactionId: activeSoftNav.interactionId,
      // duration (presentationTime - startTime) is First Contentful Paint
      // relative to interaction start.
      fcpDuration: activeSoftNav.duration,
      // duration (presentationTime - activeSoftNav.startTime) is the soft
      // navigation's LCP relative to interaction start.
      lcpDuration: activeLcpEntry ? activeLcpEntry.duration : null,
      lcpElement: activeLcpEntry?.largestContentfulPaint?.element ?? null,
      lcpSize: activeLcpEntry?.largestContentfulPaint?.size ?? null,
    });

    activeSoftNav = null;
    activeLcpEntry = null;
  }

  const softNavObserver = new PerformanceObserver((list) => {
    for (const softNavEntry of list.getEntries()) {
      // Report the previous route before tracking the new one.
      finalizeCurrentSoftNav();

      activeSoftNav = softNavEntry;
      // Seed with paints that happened before the URL updated.
      activeLcpEntry = softNavEntry.getLargestInteractionContentfulPaint();
    }
  });

  const icpObserver = new PerformanceObserver((list) => {
    for (const icpEntry of list.getEntries()) {
      // Match by interactionId, not navigationId, so only paints caused by
      // the navigation's initiating interaction update the route's LCP.
      if (activeSoftNav && icpEntry.interactionId === activeSoftNav.interactionId) {
        activeLcpEntry = icpEntry;
      }
    }
  });

  softNavObserver.observe({ type: 'soft-navigation', buffered: true });
  icpObserver.observe({ type: 'interaction-contentful-paint', buffered: true });

  // Report the active route when the page is backgrounded or unloaded.
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden') {
      finalizeCurrentSoftNav();
    }
  });

  return { softNavObserver, icpObserver, finalizeCurrentSoftNav };
}
```

### 3. Core Web Vitals across soft navigations with `web-vitals`

To report standard Core Web Vitals (LCP, CLS and INP) for both hard and soft navigations to an analytics endpoint, use the `web-vitals` library (v6.0.0 or later) with `{ reportSoftNavs: true }` instead of slicing each metric's timeline by hand.

```javascript
import { onLCP, onFCP, onCLS, onINP } from 'web-vitals';

function sendToAnalytics(metric) {
  // Placeholder endpoint and transport; replace with your reporting path,
  // for example fetchLater() (see the full-session-analytics guide).
  navigator.sendBeacon(
    '/analytics',
    JSON.stringify({
      name: metric.name,
      value: metric.value,
      navigationType: metric.navigationType,
      navigationURL: metric.navigationURL,
    }),
  );
}

// reportSoftNavs: true reports each soft navigation as well as the initial
// hard navigation.
onLCP(sendToAnalytics, { reportSoftNavs: true });
onFCP(sendToAnalytics, { reportSoftNavs: true });
onCLS(sendToAnalytics, { reportSoftNavs: true });
onINP(sendToAnalytics, { reportSoftNavs: true });
```

## Guidelines

- Feature-detect `'interaction-contentful-paint'` and `'soft-navigation'` with `PerformanceObserver.supportedEntryTypes?.includes(...)` before calling `observer.observe()`.
- Pass `{ buffered: true }` when observing `'interaction-contentful-paint'` and `'soft-navigation'`, so early entries are not missed if analytics code initializes asynchronously.
- Call `softNavEntry.getLargestInteractionContentfulPaint()` when handling a new `soft-navigation` entry, so LCP includes paints from before the URL update.
- Match `interaction-contentful-paint` entries to a soft navigation by `interactionId`, not `navigationId`.
- Measure interaction paint latency with `entry.duration` (or `entry.presentationTime - entry.startTime`), not `entry.presentationTime` alone: every `PerformanceEntry` timestamp is relative to the initial hard load's time origin, not the soft navigation's start.
- Do not rely on `performance.getEntriesByType('soft-navigation')` to monitor long-lived SPAs; the browser buffers only the first 50 soft navigation entries. Use a `PerformanceObserver` instead.

## Browser support and fallback

Browser support for Interaction contentful paint performance entries: Limited availability.
Supported by: Chrome 151 (Jul 2026) and Edge 151 (Jul 2026).
Unsupported in: Firefox and Safari.

Browser support for Soft navigation performance entries: Limited availability.
Supported by: Chrome 151 (Jul 2026) and Edge 151 (Jul 2026).
Unsupported in: Firefox and Safari.

If your Baseline target includes browsers without `InteractionContentfulPaint` or `PerformanceSoftNavigation`, treat these APIs as a progressive enhancement for real user monitoring (RUM):

1. Feature-detect and degrade gracefully: register the observers only when `PerformanceObserver.supportedEntryTypes?.includes('interaction-contentful-paint')` and `PerformanceObserver.supportedEntryTypes?.includes('soft-navigation')` are true, so unsupported browsers run without errors.
2. Keep the standard hard-navigation observers for `'largest-contentful-paint'`, `'event'` and `'layout-shift'` running in every browser. `LargestContentfulPaint` is finalized at the first user interaction whether or not soft navigations are supported, so measuring soft navigations in supporting browsers does not change initial-load LCP.
