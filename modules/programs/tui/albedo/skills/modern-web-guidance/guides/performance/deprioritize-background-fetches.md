# Deprioritize background fetches

Simultaneous network requests compete for bandwidth. Deprioritize non-critical data such as analytics, logging or background sync so that user-initiated and critical fetches finish sooner.

## How to implement

1. Identify `fetch()` calls for non-essential data that does not affect the immediate user experience.
2. Add `priority: 'low'` to their init options.

```javascript
// Critical UI data keeps the default priority.
const criticalData = await fetch('/api/data');

// Background analytics at low priority, to avoid network contention.
fetch('/api/analytics', {
  method: 'POST',
  body: JSON.stringify(eventData),
  priority: 'low'
});
```

## Guidelines

- Use `priority: 'low'` for analytics, beacons and telemetry that the current view does not need but that you send now. Data that can wait until the user leaves the page is better queued with `fetchLater()`; see the `full-session-analytics` guide.
- Use `priority: 'low'` when prefetching data the user might need later, so it does not slow down what they need now.
- Do not use `priority: 'low'` for fetches critical to the user experience.
- The option key is `priority`. Do not use the deprecated `importance` key.

## Browser support and fallback

Baseline status for Fetch priority: Newly available. It's been Baseline since 2024-10-29.
Supported by: Chrome 103 (Jun 2022), Edge 103 (Jun 2022), Firefox 132 (Oct 2024), and Safari 17.2 (Dec 2023).

The `priority` option is a progressive enhancement. Browsers without support ignore it and use the default priority, so basic use needs no feature detection or fallback.
