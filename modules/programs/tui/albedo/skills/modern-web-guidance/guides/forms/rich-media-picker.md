# Rich Media Picker (Customizable Select)

`appearance: base-select` opts a `<select>` into a customizable state with CSS alone. Its `<option>` elements can then hold rich HTML such as images, SVGs and complex layouts, while the select keeps native keyboard accessibility and form integration. Use this pattern instead of heavy custom-built select components.

## How to implement

1. Opt in: apply `appearance: base-select` to both the `<select>` and its `::picker(select)` pseudo-element. This also changes how the HTML parser handles the select's contents.
2. Define the closed-state button with `<button>` and `<selectedcontent>` inside the `<select>`. `<selectedcontent>` mirrors the content of the selected option, so no JavaScript is needed to update the button. It is required if the button should show the selected rich content.
3. Put images, SVGs and other HTML inside `<option>` elements. Without this API, browsers strip tags from options and render only plain text.
4. Style the drop-down list through `::picker(select)`. It renders in the top layer, so there are no `z-index` fights, and it is positioned with anchor positioning natively.

## Example: rich role picker

```html
<label for="role-picker">Select your role</label>
<select class="custom-select" name="role" id="role-picker">
  <button>
    <selectedcontent></selectedcontent>
  </button>

  <option value="frontend">
    <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor">
      <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
    </svg>
    <div class="option-text">
      <span class="option-title">Frontend Developer</span>
      <span class="option-desc">React, Vue, CSS</span>
    </div>
  </option>

  <option value="backend">
    <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor">
      <rect x="2" y="12" width="20" height="14" rx="2" ry="2"></rect>
    </svg>
    <div class="option-text">
      <span class="option-title">Backend Developer</span>
      <span class="option-desc">Node.js, Python</span>
    </div>
  </option>
</select>
```

```css
/* Both the select and its picker must opt in; otherwise standard rendering applies. */
select.custom-select,
select.custom-select::picker(select) {
  appearance: base-select;
}

select.custom-select {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 12px;
  background-color: #1e293b;
  border: 1px solid #334155;
  border-radius: 8px;
  color: #f1f5f9;
  cursor: pointer;
}

select.custom-select::picker(select) {
  background-color: #0f172a;
  border: 1px solid #334155;
  border-radius: 8px;
  padding: 8px;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5);
  /* Anchor positioning: match the trigger button's width. */
  width: anchor-size(width);
}

select.custom-select option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  border-radius: 4px;
  cursor: pointer;
}

select.custom-select option:hover {
  background-color: #1e293b;
}

/* Remove the default checkmark. */
select.custom-select option::checkmark {
  display: none;
}

/* Several indicators (background and bold title) mark the checked option. */
select.custom-select option:checked {
  background-color: #3b82f6;
  color: #ffffff;
}
select.custom-select option:checked .option-title {
  font-weight: 700;
}
```

## Best practices

- Use `appearance: base-select` for option layouts with icons, descriptions or images, which used to need heavy JavaScript UI frameworks.
- Do not swap in ad hoc custom elements to chase performance; the browser already handles keyboard focus natively.
- Do not set `z-index` on the picker. It renders in the top layer, above any page content regardless of `z-index`.
- Hide secondary details such as descriptions in the closed button if they take too much space: `.custom-select selectedcontent .option-desc { display: none; }`.
- Test layout. `base-select` drops the default sizing of the select to its longest option, so set a fixed width or use flex or grid constraints to avoid layout shifts.
- Give the `<select>` a `name` and an associated `<label>` so the custom UI stays accessible to screen readers and submits with the form.
- Keep standard `value` attributes on options so form submission works as before.

## Accessibility

When the picker is open, the selected option must be visibly identifiable, for example with a custom icon, a sufficiently contrasting outline that clearly differs from the focus and hover styles, or a sufficiently contrasting background color.

Give the picker a visible label that explains what information is needed, so people can choose the right option on their own (WCAG 3.3.2 Labels or Instructions requires labels or instructions when content needs user input). Every option also needs visible text; do not rely on an image or color alone.

Make each option understandable in isolation. Browsers without support show all of an option's text as one string, so the option below reads "Frontend Developer React, Vue, CSS", and without the visual design its meaning suffers:

```html
<option value="frontend">
  <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round">
    <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
    <line x1="8" y1="21" x2="16" y2="21"></line>
    <line x1="12" y1="17" x2="12" y2="21"></line>
  </svg>
  <div class="option-text">
    <span class="option-title">Frontend Developer</span>
    <span class="option-desc">React, Vue, CSS</span>
  </div>
</option>
```

Make the content make sense without its styling, adding visually hidden text where needed. Here, a visually hidden full stop and "Responsibilities include:" make unsupported browsers read "Frontend Developer. Responsibilities include: React, Vue, CSS". The full stop also tells screen readers where to pause, which helps people follow the structure of the option. This keeps the information equivalent whether or not the browser supports the feature. The `visually-hidden` class is the standard clip-path recipe:

```css
.visually-hidden {
  position: absolute;
  clip-path: inset(50%);
  overflow: hidden;
  width: 1px;
  height: 1px;
  margin: -1px;
  padding: 0;
  border: 0;
  white-space: nowrap;
}
```

The updated option:

```html
<option value="frontend">
  <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
    stroke-linecap="round" stroke-linejoin="round">
    <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
    <line x1="8" y1="21" x2="16" y2="21"></line>
    <line x1="12" y1="17" x2="12" y2="21"></line>
  </svg>
  <div class="option-text">
    <span class="option-title">
      Frontend Developer<span class="visually-hidden">.</span>
      <span class="visually-hidden">Responsibilities include:</span>
    </span>
    <span class="option-desc">React, Vue, CSS</span>
  </div>
</option>
```

Do not override an option's text with `aria-label`. People would miss any visible text left out of the label, and the label easily falls out of date when the option text changes later. Make the full option text make sense in isolation instead.

Do not put interactive elements or extra semantics inside `<option>`. Screen reader users will not hear them and so cannot tell that more information is there.

## Fallback strategies

Browser support for customizable `<select>`: Limited availability.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025) and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without `appearance: base-select` support, the `<select>` degrades to the standard operating system drop-down:

- Older browsers strip HTML such as `<svg>` or `<div>` inside `<option>` and render only the text nodes, so make each option's text readable and meaningful on its own.
- Standard parsers may ignore the `<button>` and `<selectedcontent>` elements inside `<select>` or treat them as invalid.

If you accept plain text as a readable fallback, no JavaScript polyfill is needed. To branch on support in script, test `CSS.supports("appearance", "base-select")`.
