# Styling Checkboxes

Use semantic HTML and associate every checkbox with its label, either by nesting the `<input>` inside the `<label>` or by matching the label's `for` attribute to the input's `id`.

There are two ways to style a checkbox: tint the native control with `accent-color`, or replace its presentation with `appearance: none` on the `<input type="checkbox">`.

## Native customization with `accent-color`

Use `accent-color` for simple brand styling. The control keeps native rendering, keyboard behavior, validation, and the operating system's focus indicator.

```css
.checkbox-native {
  accent-color: #1a73e8;
  /* Size in relative units. */
  inline-size: 1.25em;
  aspect-ratio: 1;
  margin: 0;
  cursor: pointer;
}
```

## Fully custom styling with `appearance: none`

Use `appearance: none` when the design needs control over the checkbox's shape, size, states, or indicators. It removes the native visuals while the `<input>` stays the interactive target.

`appearance: none` also removes the browser's default dimensions, so set explicit relative sizes for `--checkbox-size` and `--checkbox-icon-size`. Keep the icon smaller than the box to leave room for the border and visual padding.

```css
/* Reusable SVG assets */
:root {
  --icon-check: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='3.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='20 6 9 17 4 12'></polyline></svg>");
  --icon-dash: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' stroke-width='4.5' stroke-linecap='round' stroke-linejoin='round'><line x1='5' y1='12' x2='19' y2='12'></line></svg>");
}

.checkbox-custom {
  --checkbox-size: 1.25em;
  --checkbox-icon-size: 0.7em;
  /* Default icon, so the mask stays valid while the check scales out on uncheck. */
  --checkbox-icon: var(--icon-check);

  appearance: none;
  display: inline-grid;
  place-content: center;
  inline-size: var(--checkbox-size);
  aspect-ratio: 1;
  margin: 0;
  border: 2px solid currentColor;
  cursor: pointer;

  &::before {
    content: "";
    inline-size: var(--checkbox-icon-size);
    aspect-ratio: 1;
    background-color: currentColor;
    mask: var(--checkbox-icon) no-repeat center / contain;
    scale: 0;

    @media (prefers-reduced-motion: no-preference) {
      transition: scale 150ms ease;
    }

    @media (forced-colors: active) {
      background-color: CanvasText;
    }
  }

  &:checked {
    --checkbox-icon: var(--icon-check);
  }

  &:indeterminate {
    --checkbox-icon: var(--icon-dash);
  }

  &:is(:checked, :indeterminate)::before {
    scale: 1;
  }

  &:focus-visible {
    outline: 2px solid currentColor;
    outline-offset: 2px;
  }

  &:disabled {
    cursor: not-allowed;
    opacity: 0.5;
  }
}
```

## The indeterminate state

No HTML attribute sets the indeterminate state. Set the `indeterminate` DOM property in JavaScript, and make `:indeterminate` visually distinct from both the checked and unchecked states.

```js
const selectAll = document.querySelector("#select-all");
selectAll.indeterminate = true;
```

- With `accent-color`, the browser styles the indeterminate state from the element's `accent-color`; no extra `:indeterminate` rule is needed.
- With `appearance: none`, swap `--checkbox-icon` to `var(--icon-dash)` on `.checkbox-custom:indeterminate`, as in the example above.

## Accessibility and interaction

- Style focus on custom checkboxes with `:focus-visible` rather than `:focus`, so keyboard users get a distinct outline and pointer clicks do not show one.
- Keep focus indicators visible; do not use `outline: none` on checkboxes.
- Give the focus indicator a contrast of at least 3:1 against the background.
- Give the checked and indeterminate colors a contrast of at least 3:1 against the background.
- Make the checkbox or its wrapping `<label>` a hit target of at least 44px × 44px, while the visual box stays sized in relative units:

  ```css
  label {
    display: inline-flex;
    align-items: center;
    gap: 0.65rem;
    min-block-size: 44px;
    cursor: pointer;
  }
  ```

- Provide a `:disabled` style that lowers opacity and sets `cursor: not-allowed`, so the inactive state is clear.

### `accent-color` rendering differences

Browsers treat indicators painted over the accent color (checkbox marks, radio dots) differently:

- Chromium and Firefox generally pick a contrasting indicator color.
- Safari may keep a white indicator in light mode or a black one in dark mode and adjust the accent color behind it instead. That adjustment does not always give enough contrast for every color, and Safari does not necessarily pick the indicator color with the best contrast. Test important color combinations in Safari in both light and dark color schemes.

## Fallback strategies

### `accent-color`

Browser support for accent-color: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021), and Safari 26.2 (Dec 2025).

`accent-color` is a progressive enhancement. Browsers without it ignore the property and use their default UI colors.

### CSS masks

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).
