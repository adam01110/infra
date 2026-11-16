# Animated Select Picker

With `appearance: base-select`, a `<select>` picker becomes styleable and animatable like any other element. Combine it with `@starting-style` and `transition-behavior: allow-discrete` to animate the top-layer picker in and out with CSS alone, without a JavaScript animation library.

## How to implement

1. Opt in: apply `appearance: base-select` to both the `<select>` and its `::picker(select)` pseudo-element.
2. Optionally set `interpolate-size: allow-keywords` (usually on `:root`) so the browser can transition between keyword and length sizes such as `height: auto` and `height: 0`.
3. Give `::picker(select)` entry and exit styles. Include `display` and `overlay` in `transition` and set `transition-behavior: allow-discrete`, so the picker stays rendered in the top layer while it transitions between `display: none` and `display: block`.
4. Use `@starting-style` to set the styles the browser starts from before the opening transition, for example `opacity: 0` for a fade-in.
5. Transition the arrow with `:open::picker-icon`, for example a rotation or translation.

## Example: scale and fade

```html
<label for="theme-select">Visual Theme</label>
<select id="theme-select" class="animated-select" name="theme">
  <!-- With base-select, this button is the visible trigger;
       <selectedcontent> mirrors the chosen option. -->
  <button>
    <selectedcontent></selectedcontent>
  </button>
  <option value="system">
    <!-- Decorative SVGs get aria-hidden="true" so screen readers do not announce them twice. -->
    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
      <line x1="8" y1="21" x2="16" y2="21"></line>
      <line x1="12" y1="17" x2="12" y2="21"></line>
    </svg>
    System Default
  </option>
  <option value="light">
    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <circle cx="12" cy="12" r="5"></circle>
      <line x1="12" y1="1" x2="12" y2="3"></line>
      <line x1="12" y1="21" x2="12" y2="23"></line>
      <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
      <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
      <line x1="1" y1="12" x2="3" y2="12"></line>
      <line x1="21" y1="12" x2="23" y2="12"></line>
      <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
      <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
    </svg>
    Light UI
  </option>
</select>
```

```css
.animated-select,
.animated-select::picker(select) {
  appearance: base-select;
}

:root {
  interpolate-size: allow-keywords;
}

.animated-select {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 0.875rem 1rem;
  font-size: 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 0.2s ease;
}

.animated-select::picker-icon {
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.animated-select:open::picker-icon {
  transform: rotate(180deg);
}

.animated-select::picker(select) {
  /* Set a text color with the background so options stay readable
     on pages with a dark color scheme. */
  background: white;
  color: black;
  border-radius: 12px;
  box-shadow: 0 10px 25px -3px rgba(0,0,0,0.1);
  padding: 0.5rem;
  margin-top: 0.25rem;
  width: anchor-size(width);

  transition:
    display,
    overlay,
    opacity cubic-bezier(0.16, 1, 0.3, 1),
    height cubic-bezier(0.16, 1, 0.3, 1);
  transition-duration: 0.4s;
  /* Declared after the shorthand so it is not reset, and kept out of
     the shorthand so older browsers do not drop the whole transition. */
  transition-behavior: allow-discrete;
  opacity: 0;
  height: 0;
}

.animated-select:open::picker(select) {
  opacity: 1;
  height: auto;
}

/* Starting point for the transition when the picker opens. */
@starting-style {
  .animated-select:open::picker(select) {
    opacity: 0;
    height: 0;
  }
}

.animated-select option svg,
.animated-select selectedcontent svg {
  flex-shrink: 0;
  width: 1.25rem;
  height: 1.25rem;
}

/* More than one indicator (weight and background), so the checked
   state is not conveyed by color alone. */
.animated-select option:checked {
  font-weight: 700;
  background-color: #f1f5f9;
  color: black;
}

@media (prefers-reduced-motion: reduce) {
  .animated-select::picker(select),
  .animated-select::picker-icon {
    transition: none !important;
  }
}
```

## Best practices

- Use `@starting-style` when an animation must start exactly as an element goes from `display: none` to visible.
- Keep `allow-discrete` out of the `transition` shorthand: older browsers ignore the entire `transition` declaration if it is there. Use a separate `transition-behavior: allow-discrete` declaration, unless dropping the transition in those browsers is what you want.
- Do not add ad hoc scroll locking. The top-layer picker managed by `base-select` should keep its natural light-dismiss behavior.
- Do not set `overflow: hidden` on `::picker(select)`. The picker must stay scrollable so options that do not fit, for example at high zoom or in a short viewport, can still be reached.
- Respect reduced motion: wrap or disable the animations with a `prefers-reduced-motion` media query for people affected by motion sickness.
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
