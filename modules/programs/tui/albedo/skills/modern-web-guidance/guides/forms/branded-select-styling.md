# Branded Select Styling

The customizable select API styles a `<select>` with CSS to match a design system. Opting in with `appearance: base-select` exposes the select's internal parts, so standard CSS can style the button, the picker list of options, the arrow icon and the checkmark indicator. The browser still handles focus management, top-layer rendering and accessibility bindings, which a JavaScript rebuild of the control usually breaks along with keyboard navigation and native form integration.

## How to implement

1. Opt in: apply `appearance: base-select` to both the `<select>` and its `::picker(select)` pseudo-element (the drop-down list of options).
2. Optionally replace the default trigger with a `<button>` as the first child of the `<select>`. Put a `<selectedcontent>` element inside it to mirror the content of the selected option.
3. Style the list with `::picker(select)`: typography, background, borders, shadows. The browser renders it in the top layer, so `z-index` conflicts do not arise.
4. Style the internal icons: `select::picker-icon` for the arrow, `option::checkmark` for the indicator next to the selected option.
5. Style `<option>` elements for hover states, padding and layout.

## Example: courier-style select

A select with a monospace font and dashed borders for a "parcel" brand:

```css
.brand-select,
.brand-select::picker(select) {
  appearance: base-select;
}

/* Trigger button. */
.brand-select {
  font-family: 'Courier New', monospace;
  background-color: #fffaf0;
  color: #8b4513;
  border: 2px dashed #8b4513;
  border-radius: 4px;
  padding: 0.75rem;
  font-size: 1rem;
  cursor: pointer;
}

/* Options list. */
.brand-select::picker(select) {
  font-family: 'Courier New', monospace;
  background-color: #fffaf0;
  border: 2px dashed #8b4513;
  border-radius: 4px;
  padding: 0.5rem;
}

.brand-select::picker-icon {
  color: #8b4513;
}

.brand-select option::checkmark {
  color: #8b4513;
}

.brand-select option {
  padding: 0.5rem;
  border-radius: 4px;
  color: #8b4513;
  cursor: pointer;
}

.brand-select option:hover {
  background-color: #fdf5e6;
}
```

```html
<label for="preferences">Select shipping preference</label>
<select class="brand-select" id="preferences" name="preferences">
  <button>
    <selectedcontent></selectedcontent>
  </button>
  <option value="standard">Standard Shipping</option>
  <option value="express" selected>Express Shipping</option>
  <option value="overnight">Overnight Delivery</option>
</select>
```

## Best practices

- Use `appearance: base-select` when the design system needs a level of visual consistency that standard cross-browser select overrides cannot reach.
- Skip it when you rely on the operating system's native picker, such as the scroll-wheel picker on iOS. `base-select` replaces native mobile controls with a web-rendered top-layer menu.
- Check color contrast against WCAG (at least 3:1 with the background). The picker accepts arbitrary colors, so legibility on custom backgrounds is your responsibility.
- Test layout. `base-select` drops the default sizing of the select to its longest option, so set a fixed width or use flex or grid constraints to avoid layout shifts.
- Give the `<select>` a `name` and an associated `<label>` so the custom UI stays accessible to screen readers and submits with the form.
- Keep standard `value` attributes on options so form submission works as before.

## Fallback strategies

Browser support for customizable `<select>`: Limited availability.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025) and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without `appearance: base-select` support, the `<select>` degrades to the standard operating system drop-down:

- Older browsers strip HTML such as `<svg>` or `<div>` inside `<option>` and render only the text nodes, so make each option's text readable and meaningful on its own.
- Standard parsers may ignore the `<button>` and `<selectedcontent>` elements inside `<select>` or treat them as invalid.

If you accept plain text as a readable fallback, no JavaScript polyfill is needed. To branch on support in script, test `CSS.supports("appearance", "base-select")`.
