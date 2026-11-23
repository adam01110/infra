# Sortable Table

Use this pattern to let users sort a data table by clicking its column headers. Start from a complete, semantic `<table>` that is readable without JavaScript, then enhance it.

This guide covers the header controls, sort state, sorting logic and applying the new order to the DOM. For keeping state inside rows while they move, see the `move-dom-element-without-losing-state` guide; for other narrow-screen table patterns, the `responsive-table` guide; and for sorting lists and card grids that aren't tables, the `dynamic-sort` guide.

## Header markup

- Put a `<button type="button">` inside each sortable `<th scope="col">`. Don't make the `<th>` itself clickable, and don't use `<a>` or `role="button"`.
- Set `aria-sort="ascending"` or `aria-sort="descending"` on the `<th>` of the currently sorted column only, and remove it from every other header. Don't set `aria-sort="none"`, and don't put `aria-sort` on the button.
- Leave non-sortable columns as plain `<th>` text without a button, with padding, alignment and font weight matching the sortable headers. Remove cell padding only on `th:has(> button)`, because the button supplies it.
- Keep the table's `<caption>` as its accessible name, and keep data rows in a `<tbody>` so sorting reorders only body rows, never the `<thead>` row.
- Show the sort direction with a decorative icon (`aria-hidden="true"`, `currentColor`; see the `icons` guide). Drive its appearance from `th[aria-sort]` in CSS, not from extra classes or JavaScript. The icon is hidden from assistive technology, so `aria-sort` on the `<th>` must always carry the state.
- Give the button at least a 24px target and a `:focus-visible` outline, and make it fill the cell.

## Wire buttons with invoker commands

Point `commandfor` at the table and use a custom `--sort` command (custom commands must start with `--`). Handle it with one `command` listener on the table rather than a click listener per button; `event.source` is the activated button.

```html
<th scope="col" data-type="number">
  <button type="button" commandfor="planets" command="--sort">
    Moons
  </button>
</th>
```

```html
<p id="sort-status" role="status" class="visually-hidden"></p>
```

```javascript
const table = document.getElementById('planets');
const tbody = table.tBodies[0];
const status = document.getElementById('sort-status'); // A visually hidden role="status" element.

table.addEventListener('command', (event) => {
  if (event.command === '--sort') sortBy(event.source);
});

// `button` is the header button that was activated.
function sortBy(button) {
  const th = button.closest('th');
  const direction = th.getAttribute('aria-sort') === 'ascending' ? 'descending' : 'ascending';

  for (const header of table.tHead.rows[0].cells) header.removeAttribute('aria-sort');
  th.setAttribute('aria-sort', direction);

  const rows = sortRows([...tbody.rows], th.cellIndex, th.dataset.type, direction);
  reorderWithTransition(rows);
  // One message per sort; the status element must already be in the DOM.
  status.textContent = `Sorted by ${button.textContent.trim()}, ${direction}, ${rows.length} rows`;
}
```

- The first activation sorts ascending and each repeat toggles the direction. Switching to another column starts ascending again.
- Keep focus on the activated header button.

## Compare values correctly

- Compare text with `Intl.Collator` (`numeric: true, sensitivity: 'base'`), not `<` or `localeCompare` in a loop.
- Compare numbers, dates and currency as numbers. When the displayed text is formatted (for example `12,104` or `$1.2k`), read the raw value from a `data-value` attribute or `<time datetime>`.
- Declare each column's type with `data-type` instead of guessing from content.
- `Array.prototype.sort` is stable, so equal rows keep their previous relative order.

```javascript
const collator = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' });

function sortRows(rows, index, type, direction) {
  const factor = direction === 'ascending' ? 1 : -1;
  // Prefers the raw value when the displayed text is formatted. This reads the DOM on
  // every comparison; for large tables, read each row's value once before sorting.
  const value = (row) => row.cells[index].dataset.value ?? row.cells[index].textContent.trim();
  return rows.sort((a, b) =>
    factor * (type === 'number' ? value(a) - value(b) : collator.compare(value(a), value(b)))
  );
}
```

## Reorder the existing rows

Move the existing `<tr>` elements within the `<tbody>`. Rebuilding the table or `<tbody>` with `innerHTML` or a re-render discards focus and state inside rows and breaks view transitions, which match old and new elements by identity. Never move the header row.

```javascript
// Moving every row to the end in sorted order is enough; no need to compute minimal moves.
function reorder(container, orderedRows) {
  for (const row of orderedRows) container.moveBefore(row, null);
}
```

Don't fake the order with CSS `order`; DOM order must match visual order for keyboard and screen reader users.

## Optional: animate the reorder

Animation is an enhancement; sorting works without it. The `dynamic-sort` guide covers when to animate, reduced-motion handling and rapid-click behaviour. Skip the animation for large tables.

```css
tbody tr {
  /* Derives a unique name from each row's identity. */
  view-transition-name: match-element;
}

@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none;
  }
}
```

```javascript
// Scoped to the table so the rest of the page stays interactive during the animation.
function reorderWithTransition(rows) {
  table.startViewTransition(() => reorder(tbody, rows));
}
```

Don't put `aria-live` on the table, which would announce every moved row. Use the single `role="status"` element, hidden visually with `clip-path: inset(50%)` and a 1px size rather than `display: none`.

## Narrow screens

Wrap the table in a horizontally scrollable container (`overflow-x: auto`) with `role="region"`, an accessible name from the caption through `aria-labelledby`, and `tabindex="0"` so keyboard users can scroll it. Give the table a `min-inline-size` so columns don't collapse.

## Common mistakes

- Re-rendering the `<tbody>` or `<table>` on sort, which discards focus and state and breaks view transitions.
- Putting `aria-live` on the table, or announcing each row.
- Leaving `aria-sort` on more than one header.
- Relabelling the button with the action ("Sort ascending"). Keep the column name; `aria-sort` conveys the state.
- Sorting formatted strings when the underlying values are numbers or dates.

## Fallbacks

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

If your Baseline target lacks invoker commands, the `command` event never fires and the header buttons do nothing. Feature-detect support and, only when it is missing, add a `click` listener to each header button that runs the same sort function. Mouse, touch and keyboard activation then behave the same, so the fallback is faithful.

```javascript
// Only without invoker commands: in supporting browsers a click also fires `command`,
// so an unconditional click listener would sort twice and undo the first sort.
if (!('commandForElement' in HTMLButtonElement.prototype)) {
  for (const button of table.tHead.querySelectorAll('button[command="--sort"]')) {
    button.addEventListener('click', () => sortBy(button));
  }
}
```

Do not fall back to `pointer-events: none` on the buttons. They stay focusable and keyboard-activatable, so keyboard users reach controls that silently do nothing.

Either way the buttons do nothing without JavaScript, so if the table must stay fully readable without it, add them from script.

Browser support for Element-scoped view transitions: Limited availability.
Supported by: Chrome 147 (Apr 2026) and Edge 147 (Apr 2026).
Unsupported in: Firefox and Safari.

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

If your Baseline target lacks element-scoped view transitions, fall back to `document.startViewTransition()`, and without that, reorder with no animation. If it lacks `moveBefore()`, use `append()`: the DOM order is the same, though rows may lose focus or other state inside them. The `dynamic-sort` guide has these fallbacks in code. The table still sorts and the announcement is unchanged.
