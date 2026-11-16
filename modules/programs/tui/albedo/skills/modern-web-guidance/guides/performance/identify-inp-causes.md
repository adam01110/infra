# Identify causes of poor INP

Poor responsiveness makes a page feel slow or even broken. Interaction to Next Paint (INP) is a metric built on the Event Timing API. It reports the worst interaction on the page, ignoring some outliers, as the measure of responsiveness.

Unresponsiveness is hard to diagnose because it depends on what users do and on their device and network conditions, which makes it far less repeatable than page load. Lab data covers only a small subset of real user scenarios, so measure the causes of slow INP in the field.

The Event Timing API splits INP into three subparts:

- Input delay: work already running when the interaction happens.
- Processing duration: time spent in the interaction's own event handlers.
- Presentation delay: time spent rendering the next frame after the interaction.

These tell you whether the problem is other code, the interaction's JavaScript, or the browser's rendering work, so you do not jump straight to the interaction code.

You can dig further into the JavaScript, style recalculation and layout work that delays an interaction. A full trace with the JS Self-Profiling API is heavyweight and can itself cause performance problems. The Long Animation Frames API is lightweight enough for the field; it identifies slow JavaScript and separates style recalculation from layout costs during INP interactions:

- Script-level forced style and layout (`forcedStyleDuration` and `forcedLayoutDuration`): synchronous style recalculation (such as calling `getComputedStyle()` after DOM changes) and forced layout or reflow (such as reading `getBoundingClientRect()` or `offsetWidth` after changes) inside a running script, during input delay or processing duration.
- Frame-level rendering style and layout (`styleDuration` and `layoutDuration`): time spent recalculating styles and updating layout during the frame's rendering update. This explains high presentation delay.

Separate style from layout because their causes and fixes differ. High style duration points to expensive selector matching or broad style invalidation; fix it by simplifying selectors or narrowing rule scope. High layout duration points to expensive geometry calculations or synchronous layout thrashing; fix it by batching DOM reads before writes, simplifying the DOM, or using CSS containment.

## How to implement

Calculating INP from the raw Event Timing API is complicated and full of nuances, so use a RUM tool or library.

`web-vitals` is a small open-source library from Google that measures the Core Web Vitals, including INP, and other performance metrics. Its `onINP()` function in the attribution build reports the slowest interaction with its INP subparts, the scripts that ran during it, and style and layout durations from the Long Animation Frames API.

```javascript
// The attribution build adds Long Animation Frame data to the INP metric.
import { onINP } from 'web-vitals/attribution';

onINP((metric) => {
  const { attribution } = metric;
  const longestScript = attribution.longestScript;

  // Rendering-phase style and layout time across all LoAF entries that
  // overlap the interaction (mainly explains presentationDelay).
  let renderStyleDuration = 0;
  let renderLayoutDuration = 0;
  for (const entry of attribution.longAnimationFrameEntries) {
    renderStyleDuration += entry.styleDuration ?? 0;
    renderLayoutDuration += entry.layoutDuration ?? 0;
  }

  // Placeholder transport; fetchLater() also fits (see the
  // full-session-analytics guide).
  navigator.sendBeacon(
    '/analytics',
    JSON.stringify({
      name: 'INP',
      value: metric.value,
      // INP subparts.
      inputDelay: attribution.inputDelay,
      presentationDelay: attribution.presentationDelay,
      processingDuration: attribution.processingDuration,
      interactionTarget: attribution.interactionTarget,
      // The script function responsible for the longest processing.
      invokerType: longestScript?.entry?.invokerType,
      sourceURL: longestScript?.entry?.sourceURL,
      sourceFunctionName: longestScript?.entry?.sourceFunctionName,
      sourceCharPosition: longestScript?.entry?.sourceCharPosition,
      // The subpart (input delay, processing, presentation delay) the
      // longest script overlapped most.
      subpart: longestScript?.subpart,
      intersectingDuration: longestScript?.intersectingDuration,
      // Forced style and layout inside the longest script, with
      // forcedStyleAndLayoutDuration as a combined fallback.
      forcedStyleDuration: longestScript?.entry?.forcedStyleDuration,
      forcedLayoutDuration: longestScript?.entry?.forcedLayoutDuration,
      forcedStyleAndLayoutDuration: longestScript?.entry?.forcedStyleAndLayoutDuration,
      // Rendering-phase style and layout across the interaction's frames,
      // with totalStyleAndLayoutDuration as a combined fallback.
      renderStyleDuration,
      renderLayoutDuration,
      totalStyleAndLayoutDuration: attribution.totalStyleAndLayoutDuration
    })
  );
});
```

## Guidelines

- Start with the INP subparts to see whether the delay comes from JavaScript already running (input delay), the interaction's event handlers (processing duration), or the rendering that follows (presentation delay).
- Then try to identify the biggest blocking JavaScript, especially for input delay and processing duration.
- When processing duration or presentation delay is high, separate style recalculation (`styleDuration`, `forcedStyleDuration`) from layout (`layoutDuration`, `forcedLayoutDuration`). High style time indicates expensive selectors or broad invalidation; high layout time indicates DOM geometry bottlenecks or synchronous layout thrashing.
- For this detail, prefer the Long Animation Frames API to alternatives such as the JS Self-Profiling API, which has higher runtime overhead.
- If no other RUM solution is in place, use the `web-vitals` library. It identifies the INP interaction and reports its subparts and the scripts that ran during it (through the Long Animation Frames API).
- Send the information to an analytics service rather than only logging it locally.

## Browser support and fallback

Baseline status for Event timing performance entries: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 76 (Jul 2019), Edge 79 (Jan 2020), Firefox 89 (Jun 2021), and Safari 26.2 (Dec 2025).

The Event Timing API is required to calculate INP and its subparts. Browsers without it cannot measure INP.

Browser support for Long animation frames performance entries: Limited availability.
Supported by: Chrome 123 (Mar 2024) and Edge 123 (Mar 2024).
Unsupported in: Firefox and Safari.

The Long Animation Frames API only adds optional detail, so it is safe to use without a fallback. The performance problems it finds usually apply to other browsers too.

If your Baseline target supports long animation frames (`long-animation-frame` entries) but not the separate style and layout durations (`styleDuration` and `layoutDuration` on `PerformanceLongAnimationFrameTiming`, or `forcedStyleDuration` and `forcedLayoutDuration` on `PerformanceScriptTiming`), fall back to the combined timings:

- `script.forcedStyleAndLayoutDuration` on `PerformanceScriptTiming` for forced synchronous style and layout inside scripts.
- `metric.attribution.totalStyleAndLayoutDuration` from `web-vitals/attribution`, or `(entry.paintTime || entry.startTime + entry.duration) - entry.styleAndLayoutStart` on each `PerformanceLongAnimationFrameTiming` entry, for combined rendering style and layout.
