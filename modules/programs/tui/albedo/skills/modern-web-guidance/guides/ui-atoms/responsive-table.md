# Responsive tables

Large data tables become unreadable on small screens as columns overflow or shrink past legibility. This guide uses sticky positioning to keep headers visible while scrolling and turns the table into a stacked layout when space is limited.

## Recommended approach

The core of a responsive table is keeping each data cell connected to its headers.

1. Use standard `<table>` markup with `<thead>`, `<tbody>` and `<th>` elements.
2. Apply `position: sticky` to both column headers and row headers, so users never lose track of what the data means however far they scroll in any direction.
3. Use `@container` queries instead of `@media` queries, so the table adapts to its own width (for example in a sidebar or a narrow dashboard widget) rather than the viewport's.
4. In the stacked layout, hide the `<thead>` and inject header labels into each cell with `::before` pseudo-elements and CSS variables.
5. Keep long cell text on one line instead of letting columns shrink below legibility. The `single-line-overflow` guide covers truncating it and revealing the full text on demand without UX friction.

## Implementation steps

### 1. Markup and layout

Use standard semantic headers. A `.table-wrapper` handles overflow and serves as the query container. Give it `tabindex="0"` so keyboard-only users can reliably scroll the table, `role="region"` to communicate its purpose, and an accessible name with `aria-labelledby` (pointing at the `id` of an element that captions or names the table) or `aria-label`.

```html
<div tabindex="0" role="region" aria-labelledby="employee-table-caption" class="table-wrapper">
  <table>
    <caption id="employee-table-caption">Current employee directory</caption>
    <thead>
      <tr>
        <th>Employee</th>
        <th>Role</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <!-- Sticky horizontally on wide layouts; a sticky card header in the stacked layout. -->
        <th>Alex Rivera</th>
        <td>Engineer</td>
        <td>Active</td>
      </tr>
    </tbody>
  </table>
</div>
```

### 2. Sticky headers

Enable scrolling and make the headers sticky. Use logical properties and explicit `z-index` values to control stacking.

```css
.table-wrapper {
  overflow: auto;
  max-inline-size: 100%;
  max-block-size: min(500px, 80vh);
  container-type: inline-size;
}

table {
  border-collapse: separate;
  border-spacing: 0;
}

/* Sticky column headers (wide layout). */
thead {
  position: sticky;
  inset-block-start: 0;
  z-index: 1; /* Above the sticky row headers. */
}

/* Sticky row headers (wide layout). */
tbody th {
  position: sticky;
  inset-inline-start: 0;
  background: white; /* Covers cells scrolling underneath. */
}
```

### 3. Stacked layout

When space is limited, hide the header row, turn rows into cards, and inject labels with pseudo-elements. Give generated content alternative text only when it is non-text content; otherwise screen readers may announce both the text and the accessible name.

```css
@container (width < 600px) {
  table, thead, tbody, tr, th, td {
    display: block;
  }

  thead {
    /* Removes the column headers from layout and from screen readers. */
    display: none;
  }

  tr {
    margin-block-end: 1.5rem;
    border: 1px solid #ccc;
  }

  /* Sticky row header at the top of each card. */
  tbody th {
    position: sticky;
    inset-block-start: 0;
    z-index: 2;
    background: #eee;
  }

  /* Column labels as CSS variables (often set from JS). */
  table {
    --label-1: "Employee";
    --label-2: "Role";
    --label-3: "Status";
  }

  /* Map a label to each column. For non-text content, add an accessible name after a / so screen readers hear the text alternative. */
  td:nth-child(2)::before {
    content: var(--label-2) ": ";
  }
  td:nth-child(3)::before {
    content: var(--label-3) ": ";
  }
}
```
