# Coordinating Global Events with Temporal

Use `Temporal.ZonedDateTime` to schedule events across time zones. It represents a date and time in a specific time zone and handles Daylight Saving Time (DST) transitions, when local times are skipped or repeated, predictably. The legacy `Date` object makes this hard, especially around those transitions.

## How to implement

1. Create a time-zone-aware value with `Temporal.ZonedDateTime.from()` (or by attaching a zone to a `PlainDateTime` with `.toZonedDateTime(timeZone, options)`).
2. Use the `disambiguation` option to control what happens when a local time is ambiguous (repeated) or does not exist (skipped) during a clock change.
3. Convert to other locations with `.withTimeZone()`.

### Example: scheduling and conflict detection

```javascript
const date = '2025-03-09';
const time = '02:30'; // Skipped in New York when clocks spring forward.
const timeZone = 'America/New_York';
// Parse first: malformed input throws its own RangeError here instead of
// being misreported as a DST conflict below.
const local = Temporal.PlainDate.from(date).toPlainDateTime(time);

// 'reject' throws a RangeError if the time is ambiguous or does not exist.
let hasConflict = false;
try {
  local.toZonedDateTime(timeZone, { disambiguation: 'reject' });
} catch (e) {
  if (e instanceof RangeError) {
    hasConflict = true;
    console.log('This time falls in a DST transition gap or overlap.');
  } else {
    throw e;
  }
}

// 'compatible' (the default) always resolves to a valid time, even if skipped or repeated.
const hostTime = local.toZonedDateTime(timeZone, { disambiguation: 'compatible' });
console.log(`Resolved time: ${hostTime.toString()}`);

const tokyoTime = hostTime.withTimeZone('Asia/Tokyo');
// toLocaleString() for display instead of manual hour/minute padding.
console.log(`Tokyo time: ${tokyoTime.toLocaleString('en-US', { hour: 'numeric', minute: '2-digit' })}`);
```

## Guidelines

- Use `Temporal.ZonedDateTime` for events bound to a specific place, such as a meeting in a particular city.
- Use `disambiguation: 'reject'` to detect DST conflicts and warn users about them.
- Use `disambiguation: 'compatible'` (the default) to let Temporal pick a sensible time automatically when a conflict occurs.
- Do not use `Temporal.PlainDateTime` for global events; it carries no time zone, so it cannot account for DST changes.
- Use `.withTimeZone()` to get the equivalent time elsewhere. Temporal objects are immutable, so the original is not changed.
- Format user-facing times with `.toLocaleString()` options (such as `{ hour: 'numeric', minute: '2-digit' }`) instead of manual time math and padding.

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
