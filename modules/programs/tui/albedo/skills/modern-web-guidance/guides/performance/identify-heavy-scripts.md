# Identify heavy-running JavaScript

Heavy-running JavaScript hurts both page load performance and interactivity. Modern applications run JavaScript from many sources: the application and the frameworks it uses, third-party scripts such as chat widgets and video players, and analytics and marketing scripts that are easy to forget.

Finding why a page is unresponsive is hard. Tracing and profiling, and reading their results, take expertise, and lab data covers only a small subset of real user scenarios, so field data often looks very different. Interactions are especially hard to diagnose.

The Long Animation Frames API is a lightweight way to find heavy-running JavaScript in the field. A heavy script can be a single long-running script, or one that runs many times over the page lifecycle.

## How to implement

Observe long animation frames with a `PerformanceObserver`. It emits a `long-animation-frame` entry whenever a frame takes longer than 50ms to render. The entry includes the frame's duration and the scripts that ran during it.

The entry's `scripts` property is an array of `PerformanceScript` objects, one per script that ran during the frame, each with fields including its `sourceURL` and `duration`.

### Example: find the longest-running scripts behind long animation frames

```javascript
// Accumulate script entries across the page lifecycle so nothing is lost
// between observer callbacks.
const allScripts = [];

const observer = new PerformanceObserver(list => {
  allScripts.push(...list.getEntries().flatMap(entry => entry.scripts));

  // Group by sourceURL to find which scripts take the most total time,
  // even when each invocation is short.
  const scriptSource = [...new Set(allScripts.map(script => script.sourceURL))];
  const scriptsBySource = scriptSource.map(sourceURL => ([sourceURL,
      allScripts.filter(script => script.sourceURL === sourceURL)
  ]));
  const processedScripts = scriptsBySource.map(([sourceURL, scripts]) => ({
    sourceURL,
    count: scripts.length,
    totalDuration: scripts.reduce((subtotal, script) => subtotal + script.duration, 0)
  }));

  // Drop scripts under a threshold to reduce noise.
  const heavyScripts = processedScripts.filter(script => {
    return script.totalDuration > 100;
  });

  // Worst offenders first, to prioritize optimization.
  heavyScripts.sort((a, b) => b.totalDuration - a.totalDuration);

  // For local debugging. In production, send this to your analytics service.
  console.table(heavyScripts);
});

// buffered: true includes long frames from before the observer was registered.
observer.observe({type: 'long-animation-frame', buffered: true});
```

## Guidelines

- Prefer the Long Animation Frames API to alternatives such as the JS Self-Profiling API, which has higher runtime overhead.
- Summarize the key information; the entries contain a lot of detail.
- In production, send the information you need to an analytics service.

## Browser support and fallback

Browser support for Long animation frames performance entries: Limited availability.
Supported by: Chrome 123 (Mar 2024) and Edge 123 (Mar 2024).
Unsupported in: Firefox and Safari.

Browsers without the Long Animation Frames API ignore it, so it is safe to use without a fallback. The performance problems it finds usually apply to other browsers too.
