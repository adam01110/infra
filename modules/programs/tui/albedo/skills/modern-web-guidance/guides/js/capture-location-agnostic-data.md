# Capturing Location-Agnostic Data and Partial Dates with Temporal

Some chronological values must read the same wherever the viewer is: birthdates, daily alarms, credit card expirations, monthly billing cycles. The legacy `Date` object gets these wrong. A `Date` is always a specific instant displayed in the viewer's time zone, so a saved `"1990-01-01"` can appear as `"1989-12-31"` to users west of UTC, and partial dates such as a month-only card expiry need an arbitrary placeholder day that causes overflow bugs.

Temporal's Plain types carry no time zone or offset. They represent dates and wall-clock times exactly as read off a calendar or clock:

| Type | Models | Typical uses |
|---|---|---|
| `Temporal.PlainDate` | Full calendar date (`year`, `month`, `day`) | Birthdates, event dates, subscription billing dates |
| `Temporal.PlainTime` | Wall-clock time (`hour`, `minute`, `second`, ...) | Daily alarms (9:00 AM wherever the user is), store hours |
| `Temporal.PlainDateTime` | Calendar date plus wall-clock time, no time zone | Floating local schedules; combining a `PlainDate` and `PlainTime` before attaching a zone |
| `Temporal.PlainMonthDay` | Month and day, no year | Recurring annual birthdays, anniversaries, fixed holidays |
| `Temporal.PlainYearMonth` | Year and month, no day | Credit card expirations (`2027-12`), monthly billing periods |

## How to implement

1. Choose the narrowest Plain type that matches the data:
   - `Temporal.PlainDate.from()` for full calendar dates, `Temporal.PlainTime.from()` for wall-clock times.
   - `Temporal.PlainDateTime.from()`, or `plainDate.toPlainDateTime(plainTime)`, to combine a date and a wall-clock time without binding them to a time zone.
   - `Temporal.PlainMonthDay.from()` for annual dates without a year. Convert to a `PlainDate` with `.toPlainDate({ year })` before doing date arithmetic.
   - `Temporal.PlainYearMonth.from()` for year-and-month values, so arbitrary day numbers never leak into calculations.
2. Mind the `calendar` field. ISO 8601 (`'iso8601'`) is the default when parsing ISO strings or calling `PlainDate.from({ year, month, day })`. When constructing `PlainMonthDay` or `PlainYearMonth` from property bags, or when working with non-ISO calendars, pass `calendar` explicitly (for example `{ month: 10, day: 31, calendar: 'iso8601' }`).
3. Use `.add()` with an `overflow` option for recurring calendar intervals. `plainDate.add({ months: 1 })` defaults to `{ overflow: 'constrain' }`, which clamps month-end dates such as Jan 31 to Feb 28/29. Pass `{ overflow: 'reject' }` when a nonexistent target date should throw a `RangeError` instead.

### Example: full dates, wall-clock times and `PlainDateTime`

```javascript
const birthdate = Temporal.PlainDate.from('1990-01-01');
const reminderTime = Temporal.PlainTime.from('09:00');

// Combine without string interpolation; still location-agnostic.
const localAppointment = birthdate.toPlainDateTime(reminderTime);

// No time zone conversion: the same date in every time zone.
console.log(birthdate.toLocaleString('en-GB'));
console.log(localAppointment.toString()); // "1990-01-01T09:00:00"

// A PlainDate already is a calendar date, so read its fields directly instead of
// the formatToParts() workaround legacy Date code uses to recover them from an instant.
const { year, month, day } = birthdate;
```

### Example: partial dates (`PlainMonthDay` and `PlainYearMonth`)

```javascript
// Annual event with no year. Give the calendar explicitly when building from an object.
const annualHoliday = Temporal.PlainMonthDay.from({
  month: 10,
  day: 31,
  calendar: 'iso8601',
});

const today = Temporal.Now.plainDateISO();
const isToday = annualHoliday.equals(today.toPlainMonthDay());

// Pick a year before doing arithmetic: month lengths (February) depend on leap years.
const occurrenceThisYear = annualHoliday.toPlainDate({ year: today.year });

// Monthly expiration with no day component, so no day-of-month overflow bugs.
const cardExpiry = Temporal.PlainYearMonth.from({
  year: 2027,
  month: 12,
  calendar: 'iso8601',
});
const currentMonth = today.toPlainYearMonth();
const isExpired = Temporal.PlainYearMonth.compare(cardExpiry, currentMonth) < 0;
```

### Example: recurring monthly intervals (`overflow: 'constrain'` vs `'reject'`)

```javascript
const billingStart = Temporal.PlainDate.from('2024-01-31');

// 'constrain' (the default) clamps Jan 31 + 1 month to the last day of February.
const nextBilling = billingStart.add({ months: 1 }, { overflow: 'constrain' });
console.log(nextBilling.toString()); // "2024-02-29" (2024 is a leap year)

// 'reject' throws a RangeError when the target day does not exist.
try {
  billingStart.add({ months: 1 }, { overflow: 'reject' });
} catch (err) {
  // RangeError: day 31 does not exist in February
}
```

### Example: interoperating with legacy `Date`

A `Date` is an instant, not a calendar date. Storing `"1990-01-01"` as a `Date` forces you to pick some instant (typically midnight UTC), and reading it back in a time zone west of UTC yields `"31/12/1989"`. When a library or API still needs a `Date`, convert explicitly through `Temporal.Instant` instead of building ISO strings by hand:

```javascript
// PlainDate -> Date: attach a time zone (time defaults to the start of that day),
// take the Instant, and pass its epoch milliseconds to Date. 'UTC' is a deliberate
// choice and must be documented: any zone works, but the stored instant depends on it.
const instant = birthdate.toZonedDateTime('UTC').toInstant();
const legacyDate = new Date(instant.epochMilliseconds);

// Date -> PlainDate: go back through Instant (legacyDate.toTemporalInstant() is
// equivalent), then project into an explicit time zone. The result depends on that
// zone, which is exactly where dates drift.
const viewedDate = Temporal.Instant.fromEpochMilliseconds(legacyDate.getTime())
  .toZonedDateTimeISO('America/New_York')
  .toPlainDate();

// Compare Plain types with .equals() (or Temporal.PlainDate.compare), not strings.
console.log(viewedDate.equals(birthdate)); // false: the date drifted to 1989-12-31
```

## Guidelines

- Use `Temporal.PlainDate` for full calendar dates, `Temporal.PlainTime` for wall-clock times, `Temporal.PlainDateTime` for local date-time pairs without a zone, `Temporal.PlainMonthDay` for recurring annual dates and `Temporal.PlainYearMonth` for year-month expirations or billing periods.
- Do not do arithmetic directly on a `Temporal.PlainMonthDay`. Convert it with `.toPlainDate({ year })` first, because month lengths vary by year.
- Use `.add()` on `Temporal.PlainDate` for recurring calendar intervals, relying on `overflow: 'constrain'` (the default) to clamp month-end dates or `overflow: 'reject'` to throw a `RangeError` on nonexistent dates.
- Specify `calendar` (such as `calendar: 'iso8601'`) when constructing `PlainMonthDay`, `PlainYearMonth` or non-ISO Plain types from objects.
- Plain types cannot represent a specific moment in physical time. For logs, event timestamps or cross-time-zone scheduling, use `Temporal.Instant` or `Temporal.ZonedDateTime`.
- Do not construct a `Date` from a hand-built ISO string such as `` `${date}T00:00:00Z` ``. Create it from the `epochMilliseconds` of a `Temporal.Instant` or `Temporal.ZonedDateTime`, and read one back with `Temporal.Instant.fromEpochMilliseconds(date.getTime())` or `date.toTemporalInstant()`, so the time zone assumption is explicit.
- Do not use `Intl.DateTimeFormat.prototype.formatToParts()` to extract or compare year, month or day. Read `.year`, `.month` and `.day` from a Plain type and compare with `.equals()`.
- Identify time zones by IANA name (such as `America/New_York`), never by a fixed UTC offset. Offsets change with daylight saving time and legislation, so a label like `"UTC-5"` is wrong for part of the year.
- Temporal objects are immutable. `.add()`, `.subtract()` and `.with()` return a new instance with a new reference instead of mutating the original, which makes them safe to store directly in reactive UI state.

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
