# Custom Select Picker Layouts

`appearance: base-select` lets you style a `<select>` and its picker (`::picker(select)`) like regular HTML elements. With Grid or Flexbox you can replace the stacked vertical list with a richer layout without custom JavaScript, for example `display: grid` to lay the options out as a 2D grid of cards. This suits color pickers, emoji selectors and product variants, where a visual menu works better than a list.

## How to implement

### 1. Opt in to base styling

Apply `appearance: base-select` to both the `<select>` and its `::picker(select)` pseudo-element:

```css
select.grid-picker {
  &, &::picker(select) {
    appearance: base-select;
  }
}
```

### 2. Lay out the picker

Apply `display: grid` (or `display: flex`) to `select:open::picker(select)` and define columns and gaps as for any container:

```css
select.grid-picker:open::picker(select) {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}
```

Keep the `:open` in the selector. Setting `display` on plain `select::picker(select)` makes the picker visible even while the select is closed.

### 3. Style the options

Style the `<option>` elements as grid items or cards. They can contain images, SVGs or complex layouts.

```css
.grid-picker option {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  /* padding, border-radius, background, etc. */
}
```

### 4. Style the selected option

Select the chosen option with `option:checked`:

```css
.grid-picker option:checked {
  position: relative;
  border: 2px solid var(--primary-color);
  background-color: oklab(from var(--primary-color) l a b / 8%);
}
```

Do not convey state with color alone: combine several indicators (color, border thickness, checkmark), and give at least one of them a contrast of at least 3:1 with the background.

### 5. Optional: style the checkmark

By default the browser renders a checkmark as the first child of every `<option>`. It behaves like a `::before` with `content: "✓" / ""`, rendered before any author-provided `::before`, and it is hidden with `visibility: hidden` when the option is not selected. Style it with the `::checkmark` pseudo-element, or hide it if selection is shown by styling alone or by a custom indicator.

For example, to place it at the top-right corner of the selected option:

```css
select.grid-picker {
  > option::checkmark {
    /* Hide the checkmark on unselected options. */
    display: none;
  }

  > option:checked {
    position: relative;

    &::checkmark {
      position: absolute;
      inset-block-start: -.4em;
      inset-inline-end: -.5em;
      display: flex;
      align-items: center;
      justify-content: center;
      box-sizing: border-box;
      min-inline-size: 1.6em;
      aspect-ratio: 1;
      padding-right: 0.12em;
      padding-left: 0.05em;
      border-radius: 50%;
      background: var(--primary-color);
      color: white;
      font-size: 70%;
      font-weight: bold;
    }
  }
}
```

When you paint a container such as a circle around the checkmark, offset the glyph slightly with uneven padding for optical centering that accounts for its shape (the example uses `padding-right` and `padding-left`). Use physical padding properties, not logical ones like `padding-inline-start` or `padding-block-end`: logical properties change with writing mode, but the checkmark's shape does not.

### 6. Optional: customize the selected value display

By default the `<select>` shows a text-only version of the selected option. To show rich content for the selected value, or to show it differently (for example hiding some details), put a `<selectedcontent>` element inside a `<button>` as the select's trigger. Always wrap `<selectedcontent>` in that `<button>`; on its own it becomes part of the picker like any other content.

### Best practices

- Test layout. `base-select` drops the default sizing of the select to its longest option, so set a fixed width or use flex or grid constraints to avoid layout shifts.
- Give the `<select>` a `name` and an associated `<label>` so the custom UI stays accessible to screen readers and submits with the form.
- Keep standard `value` attributes on options so form submission works as before.

## Accessibility

A native `<select>` handles only linear Up/Down arrow navigation. In the open picker, Left and Right do nothing, and Up and Down move through items sequentially regardless of rows and columns.

To add horizontal navigation that follows the grid, handle `keydown` for the Left and Right arrow keys and move focus to the nearest option in that direction. Find it from actual geometry, such as `getBoundingClientRect()`, rather than by parsing CSS values like `grid-template-columns` or `grid-column`, which is brittle for complex grids, subgrid, RTL and other layouts. Keep it simple, though: use whatever invariants you know hold for your layout.

This only covers keyboard navigation. The `<select>` and its `::picker()` keep their default roles (`menu` or `listbox`), which cannot be overridden, and they may not contain an element with `role="grid"`: grid semantics inside `::picker()` violate its content model. Because screen reader users will not get grid roles, make sure Down and Up still move focus to the next and previous item in sequence, even with Left and Right scripted, so they can reach every option. Flowing the grid in columns or grouping columns with `<optgroup>` are two ways to achieve this. If that cannot work, you may need a custom component built with the Popover API, anchor positioning and `role="grid"` to give screen reader users the intended experience.

Give the focus indicator on options a contrast of at least 3:1 against the background or adjacent color.

## Fallback strategies

Browser support for customizable `<select>`: Limited availability.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025) and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without `appearance: base-select` support, the `<select>` degrades to the standard operating system drop-down:

- Older browsers strip HTML such as `<svg>` or `<div>` inside `<option>` and render only the text nodes, so make each option's text readable and meaningful on its own.
- Standard parsers may ignore the `<button>` and `<selectedcontent>` elements inside `<select>` or treat them as invalid.

If you accept plain text as a readable fallback, no JavaScript polyfill is needed. To branch on support in script, test `CSS.supports("appearance", "base-select")`.
