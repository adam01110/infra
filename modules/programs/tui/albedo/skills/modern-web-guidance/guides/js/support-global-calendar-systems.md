# Supporting Global Calendar Systems with Temporal

The legacy `Date` object is built on the proleptic Gregorian calendar, which makes it hard to serve users of other calendars such as the Islamic (lunar), Hebrew (lunisolar) or Chinese (lunisolar) calendars without third-party libraries or manual calculation. Temporal supports multiple calendar systems natively: attach a calendar identifier to a date object and Temporal handles that calendar's arithmetic and formatting.

## How to implement

1. Attach the calendar. Calendar-sensitive operations need the date in the target calendar, so convert with `withCalendar()` when creating or converting a Temporal object such as `Temporal.PlainDate`.
2. In calendars with leap months, such as Hebrew and Chinese, identify a specific month across years by `monthCode`, not by the numeric `month` index, which shifts in leap years. Other calendars do not need this.
3. Do not assume fixed values such as 12 months in a year or 31 days in a month when iterating. Read `monthsInYear` and `daysInMonth` so the code works in every calendar.
4. Compare dates within a calendar with `Temporal.PlainDate.compare()` rather than comparing year, month and day fields manually; it orders dates correctly under that calendar's rules.

## Example: converting and iterating calendars

```javascript
function isCalendarSupported(calendarId) {
  try {
    return Intl.supportedValuesOf('calendar').includes(calendarId);
  } catch {
    // Environments without Intl.supportedValuesOf.
    return false;
  }
}

// Today in the default ISO 8601 calendar.
const isoDate = Temporal.Now.plainDateISO();

const calendarId = 'hebrew';
const targetDate = isCalendarSupported(calendarId)
  ? isoDate.withCalendar(calendarId)
  : isoDate; // Fall back to ISO.

if (targetDate.calendarId !== calendarId) {
  console.warn(`Calendar ${calendarId} not supported; falling back to ISO 8601`);
}

console.log(`Calendar: ${targetDate.calendarId}`);
console.log(`Year: ${targetDate.year}`);
console.log(`Month Code: ${targetDate.monthCode}`); // Stable across leap years.

// monthsInYear, not 12.
for (let m = 1; m <= targetDate.monthsInYear; m++) {
  console.log(`Month ${m} has ${targetDate.with({ month: m }).daysInMonth} days.`);
}

// Compare within the same calendar.
const today = Temporal.Now.plainDateISO().withCalendar(targetDate.calendarId);
const comparison = Temporal.PlainDate.compare(targetDate, today);
const relative = comparison < 0 ? 'Past' : comparison > 0 ? 'Future' : 'Today';
console.log(`Timeline: ${relative}`);

// toLocaleString with era, for era-based calendars such as 'japanese'.
const localizedDisplay = targetDate.toLocaleString(`en-u-ca-${targetDate.calendarId}`, {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
  era: 'long'
});
```

## Guidelines

- Loop through months up to `monthsInYear`, not 12.
- Identify specific months by `monthCode` in calendars with leap months (such as Hebrew or Chinese), whatever the year.
- Test for the last month with `date.month === date.monthsInYear`, not `date.month === 12`.
- `inLeapYear === true` does not mean the year is only one day longer; in lunisolar calendars it can add a whole leap month.
- Compare two dates in a calendar with `Temporal.PlainDate.compare()` instead of comparing year, month and day fields manually.
- Format dates for users with `toLocaleString()`, not string concatenation.
- Check that the environment supports the target calendar with `Intl.supportedValuesOf('calendar')` before creating calendar-specific Temporal objects.
- Some calendars, such as variants of the Islamic calendar, can depend on visual observation rather than fixed calculation. Temporal follows the environment's `Intl` implementation, which usually uses calculated approximations. For critical cultural or religious dates, verify with domain experts or use a specialized library.
- For calendars with eras (such as Japanese or Buddhist), include the era when formatting with `toLocaleString()`.

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
