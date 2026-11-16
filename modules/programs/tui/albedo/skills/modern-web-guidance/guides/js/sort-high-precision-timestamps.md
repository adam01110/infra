# Sorting High-Precision Timestamps with Temporal.Instant

Log viewers, audit timelines and telemetry UIs often receive ISO 8601 timestamps recorded with microsecond or nanosecond precision by a server, database or native clock (for example `2026-04-01T12:00:00.000123456Z`). `Date` stores only milliseconds, so `new Date()` and `Date.parse()` silently truncate the sub-millisecond digits; distinct events in the same millisecond then collide and sort in an unstable order.

`Temporal.Instant` is an exact point on the UTC timeline with nanosecond precision and no time zone. `Temporal.Instant.from()` keeps the full nanosecond value of a recorded timestamp, `Temporal.Instant.compare()` sorts deterministically, and differences come back as exact `Temporal.Duration` values.

In browsers, `Temporal.Now.instant()` is deliberately clamped to millisecond or microsecond resolution to mitigate Spectre timing attacks and fingerprinting. Use `Temporal.Instant.from()` to keep nanosecond timestamps produced by external clocks, and `performance.now()` / `performance.mark()` to measure sub-millisecond intervals locally in the client.

## How to implement

1. Parse each recorded timestamp with `Temporal.Instant.from(isoString)` on the string the server, database or log line supplied. Keep the source's timestamp; do not replace it with `Temporal.Now.instant()` in the browser.
2. Sort with `Temporal.Instant.compare(a, b)` as the comparator for `Array.prototype.sort()` or `Array.prototype.toSorted()`. It compares the full nanosecond value, so sub-millisecond order is preserved.
3. Get the interval between consecutive events with `instant.since(previousInstant)`, which returns a `Temporal.Duration`. Detect identical timestamps with `a.equals(b)`.
4. Show intervals to users with `duration.toLocaleString()`, which delegates to `Intl.DurationFormat`, rather than converting them to a single `Number` of nanoseconds.
5. Serialize with `Temporal.Instant.prototype.toString()`, which emits an ISO 8601 string, always in UTC with a `Z` suffix.

## Example

```javascript
const rawEvents = [
  { nodeId: 'api-2', eventType: 'db.query', ts: '2026-04-01T12:00:00.000123456Z' },
  { nodeId: 'api-1', eventType: 'request.start', ts: '2026-04-01T12:00:00.000120000Z' },
  { nodeId: 'api-2', eventType: 'request.end', ts: '2026-04-01T12:00:00.000987654Z' },
];

// Not new Date(ts), which drops everything below the millisecond.
const events = rawEvents.map(evt => ({
  ...evt,
  timestamp: Temporal.Instant.from(evt.ts),
}));

function sequenceEvents(items) {
  // compare() returns -1, 0 or 1, as sort() expects.
  return items.toSorted((a, b) => Temporal.Instant.compare(a.timestamp, b.timestamp));
}

function analyzeTrace(sortedEvents) {
  for (let i = 1; i < sortedEvents.length; i++) {
    const prev = sortedEvents[i - 1];
    const curr = sortedEvents[i];

    // A Temporal.Duration with nanosecond precision.
    const gap = curr.timestamp.since(prev.timestamp);

    // Formats for people, e.g. "3μs 456ns". Avoid gap.total('nanoseconds'): spans over
    // ~104 days exceed Number.MAX_SAFE_INTEGER. 'en-US' gives deterministic output;
    // pass undefined to use the user's locale.
    console.log(`${prev.eventType} → ${curr.eventType}: ${gap.toLocaleString('en-US', { style: 'narrow' })}`);
  }
}

analyzeTrace(sequenceEvents(events));
```

## Guidelines

- Use `Temporal.Instant.from()` to parse high-precision timestamps recorded against a single clock (a server, database or log pipeline) that need ordering or differencing. Unlike `Temporal.PlainDateTime`, a `Temporal.Instant` is an unambiguous point on the universal timeline.
- Keep the timestamp the source recorded. Browser `Temporal.Now.instant()` is clamped to millisecond/microsecond precision; use `performance.now()` / `performance.mark()` for local sub-millisecond client intervals and `Temporal.Instant.from()` for nanosecond timestamps from server or native clocks.
- Sort with `Temporal.Instant.compare()` and test equality with `a.equals(b)`, not `Temporal.Instant.compare(a, b) === 0` or a comparison of `.toString()` output.
- Do not parse high-precision timestamp strings with `new Date()` or `Date.parse()` for ordering: they truncate to milliseconds and produce collisions.
- Do not collapse an interval to a single number for display. `duration.total('nanoseconds')` returns a `Number`, which exceeds `Number.MAX_SAFE_INTEGER` for spans longer than ~104 days and silently loses precision. Subtracting `epochNanoseconds` (a `BigInt`) is exact but discards unit structure. Keep intervals as `Temporal.Duration` and format them with `.toLocaleString()`.
- To show an event's localized wall-clock time, convert the `Instant` with `instant.toZonedDateTimeISO(timeZone)`.

## Browser support and fallback

Temporal has limited availability. Chrome 144 (Jan 2026), Edge 144 (Jan 2026) and Firefox 139 (May 2025) support it; Safari does not.

Where `Temporal` is missing, feature-detect it and dynamically load `temporal-polyfill` (~15 KB min+gz). Importing the polyfill does not set the global `Temporal`, so assign `globalThis.Temporal` yourself if your code relies on it.

```javascript
(async () => {
  if (typeof Temporal === 'undefined') {
    // In bundled projects, import 'temporal-polyfill' from npm instead of a CDN.
    const module = await import('https://esm.sh/temporal-polyfill');
    globalThis.Temporal = module.Temporal;
    // Needed only if code calls date.toTemporalInstant().
    Date.prototype.toTemporalInstant = module.toTemporalInstant;
  }
  initializeApp(); // Your entry point that uses Temporal.
})();
```
