# Calculating Event Differentials and Formatting Durations with Temporal

Use `Temporal.ZonedDateTime`, `Temporal.Duration` and `Intl.DurationFormat` to compute time elapsed or remaining between events (trial expirations, subscription countdowns, SLA windows) and show it as localized text. They give DST-safe differences, configurable unit balancing, calendar-aware duration comparison and localized formatting. The legacy `Date` object only tracks epoch milliseconds, which makes calendar-month arithmetic, DST transitions and unit balancing error-prone, and manual math or libraries were the usual workaround.

## How to implement

1. Get `Temporal.ZonedDateTime` endpoints. `Temporal.Now.zonedDateTimeISO()` returns the current time in the system time zone; pass an IANA time zone, `Temporal.Now.zonedDateTimeISO(timeZone)`, when the event's zone differs from the user's system default.
2. Compute differences with `.since()` and `.until()`:
   - `now.since(start, options)` gives the time elapsed since a past event.
   - `now.until(end, options)` gives the time remaining until a future event.
   - `largestUnit` (such as `'year'`, `'month'`, `'day'`, `'hour'`) and `smallestUnit` (such as `'minute'`) balance and round the resulting `Temporal.Duration`.
3. Balance or compare standalone `Temporal.Duration` objects:
   - Create one with `Temporal.Duration.from({ minutes: 90 })` and rebalance it with `duration.round({ largestUnit: 'hour' })`. Supply `relativeTo` when balancing across calendar months, years or DST transitions.
   - Compare two with `Temporal.Duration.compare(d1, d2, { relativeTo })`. A `PlainDate` or `ZonedDateTime` `relativeTo` is required whenever either duration contains calendar units (`years`, `months`, `weeks`) or crosses a DST boundary.
4. Format for the audience:
   - `duration.toLocaleString(locale, options)` delegates to `Intl.DurationFormat` and produces localized user-facing text.
   - `duration.toString()` produces a machine-readable ISO 8601 duration (such as `P1M2DT4H`); use it only for machines.

### Example: trial expiration with localized formatting

```javascript
// The event's zone; Temporal.Now.timeZoneId() gives the system zone.
const tz = 'America/New_York';
const now = Temporal.Now.zonedDateTimeISO(tz);

// Combine separate date and time strings with Temporal methods,
// not a template-literal ISO string.
const startDateStr = '2025-01-01';
const startTimeStr = '12:00:00';
const endDateStr = '2025-01-31';
const endTimeStr = '12:00:00';

const start = Temporal.PlainDate.from(startDateStr).toPlainDateTime(startTimeStr).toZonedDateTime(tz);
const end = Temporal.PlainDate.from(endDateStr).toPlainDateTime(endTimeStr).toZonedDateTime(tz);

// ZonedDateTime differences default to largestUnit: 'hour', because days are not
// a fixed length across DST. Pass 'day' or a calendar unit ('week', 'month', 'year')
// for a human-scale breakdown instead of something like PT720H. smallestUnit rounds
// away seconds and sub-second noise so the formatted text stays readable.
const timeActive = now.since(start, { largestUnit: 'year', smallestUnit: 'minute' });
const timeRemaining = now.until(end, { largestUnit: 'year', smallestUnit: 'minute' });

// 'en-US' gives deterministic output; pass undefined to use the user's locale.
console.log(`Active: ${timeActive.toLocaleString('en-US', { style: 'narrow' })}`);
console.log(`Remaining: ${timeRemaining.toLocaleString('en-US', { style: 'long' })}`);

// ISO 8601 for API payloads or <time datetime="...">.
console.log(`ISO 8601: ${timeRemaining.toString()}`);

const isExpired = timeRemaining.sign < 0;
// relativeTo is needed because the durations may contain months/years or cross DST.
const isPastHalfway = Temporal.Duration.compare(timeActive, timeRemaining, { relativeTo: now }) > 0;
```

### Example: balancing a standalone duration

```javascript
// 90 minutes -> 1 hour, 30 minutes.
const rawDuration = Temporal.Duration.from({ minutes: 90 });
const balanced = rawDuration.round({ largestUnit: 'hour' });

// duration.toLocaleString() or Intl.DurationFormat directly.
const formatter = new Intl.DurationFormat('en-US', { style: 'long' });
console.log(formatter.format(balanced)); // "1 hour, 30 minutes"
```

## Guidelines

- Use `Temporal.ZonedDateTime` for real-world events that happen in a specific time zone (subscription renewals, event countdowns). Pass an explicit zone to `Temporal.Now.zonedDateTimeISO(timeZone)` when calculating against a zone other than the system default.
- Combine separate date and time strings with Temporal methods, such as `Temporal.PlainDate.from(dateStr).toPlainDateTime(timeStr).toZonedDateTime(tz)` or `Temporal.PlainDate.from(dateStr).toZonedDateTime({ timeZone: tz, plainTime: timeStr })`, rather than interpolating an ISO string like `` `${dateStr}T${timeStr}` ``.
- Pass `largestUnit` (`'day'`, `'month'`, `'year'`) to `.since()`, `.until()` or `.round()` when you want durations balanced beyond hours; `ZonedDateTime` difference methods default to `'hour'`.
- Compare durations with `Temporal.Duration.compare(d1, d2, { relativeTo })`, giving a `relativeTo` anchor whenever either duration involves calendar units (`months`, `years`) or time-zone-aware days.
- Format durations for display with `duration.toLocaleString()` or `new Intl.DurationFormat(locale, { style })`, where `style` is `'long'`, `'short'`, `'narrow'` or `'digital'`, instead of interpolating `${duration.years}y ${duration.months}m...` by hand.
- Use `duration.toString()` for machine-readable ISO 8601 durations (such as `PT1H30M`), never as user-facing copy.
- Render a `PlainTime` as `HH:MM` (for example for `<input type="time">`) with `.toPlainTime().toString({ smallestUnit: 'minute' })`, not string `.slice(0, 5)`.
- Temporal objects are immutable: `.add()`, `.subtract()`, `.round()` and `.with()` return a new instance rather than modifying the original.
- Do not fall back to `Date` or `.getTime()` arithmetic for the differential itself; `Date` has no time-zone-aware calendar math and only millisecond precision.
- Check whether a duration points to the past (expired, `sign < 0`) or to a future pending start with the duration's `.sign` property, or with `Temporal.ZonedDateTime.compare()`.

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

`Intl.DurationFormat` is Baseline newly available since 2025-03-04: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 136 (Mar 2025) and Safari 16.4 (Mar 2023).
