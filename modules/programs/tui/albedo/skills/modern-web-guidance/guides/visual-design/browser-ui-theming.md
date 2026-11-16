# Theming browser-generated UI

Most browser-generated UI can be customized with CSS. Even where that needs modern features, it degrades gracefully in older browsers, so it rarely needs a polyfill or fallback.

Before re-creating browser UI (form controls, scrollbars, selections, error messages, and so on), confirm both of these:

1. The browser UI cannot be customized enough for your needs, even with modern CSS.
2. The customization is important enough to justify the cost of re-creating built-in UI, chiefly losing the accessible semantics, keyboard handling, IME support and assistive-technology integration that native UI provides for free.

Customizations that are possible:

- `::selection` customizes highlighted text colors.
- Keep `user-select: none` off content text: it breaks copy and paste, translation tools, and assistive-technology "read from here" gestures. Limit it to interface chrome such as drag handles, toolbars and redundant button labels.
- `accent-color` applies the page's accent color to browser-generated UI.
- `color-scheme` makes browser UI follow light or dark mode.
- `scrollbar-color` customizes scrollbar colors. Keep the thumb visibly distinct from the track (contrast of at least 3:1).
- Leave `scrollbar-width` at `auto` unless the page offers another accessible way to scroll the content. `scrollbar-width: thin` still shows a thumb, but its target size is too small for some users to operate.
- Style validity with `:user-invalid` / `:user-valid` rather than `:invalid` / `:valid`. They match only after the user has interacted with the field, so required fields aren't flagged as errors on page load. When targeting `input` broadly, exclude range sliders (for example `input:not(input[type="range"]):user-valid`) so moving a slider doesn't give it validity borders or backgrounds.
- Buttons and text fields (including `<textarea>`) can generally be styled like normal elements.
- `font-size` scales controls, and other text properties control their typography.
- Text needs a contrast of at least 4.5:1 against its background for regular text, or at least 3:1 for large-scale text (18 point, or 14 point bold).
- Non-text content needs a contrast of at least 3:1 between adjacent colors.

## Text fields (`<input>` and `<textarea>`)

For colors, borders, backgrounds, typography and most other styling, treat these as normal text containers.

- Style placeholders with `:placeholder-shown` and `::placeholder`.
- `field-sizing: content` makes a text field size to its content.
- On `<textarea>`, use `resize: vertical` to disable horizontal resizing.
- Don't use `resize: none` on `<textarea>` unless you provide another way to resize, such as `field-sizing: content` or custom resize buttons.

### Multiple-choice controls (select, radios, checkboxes)

- One option out of many, shown in a dropdown: use `<select>` with `appearance: base-select` and `::picker(select)`. The `branded-select-styling` guide covers this in detail.
- One or more options laid out inline on the page: put an `<input type="checkbox">` or `<input type="radio">` inside a `<label>` for each option and style the selected one with `label:has(:checked)`. This works better than the customizable select's listbox version, which is still buggy and has much narrower browser support.
- Style checkboxes, radios and switches with `appearance: none` plus generated content (`::before` / `::after`) or background images that draw the checked state.

### Non-text `<input>` types (buttons, sliders, file inputs)

- File inputs: style the button with `::file-selector-button`.
- Use `<button>` instead of `<input>` with `type="button"`, `"submit"` or `"reset"`, and style it as a regular element.
- Sliders: for finer control, use `appearance: none` with the thumb pseudo-elements (`::-webkit-slider-thumb`, `::-moz-range-thumb`, etc.) and the track pseudo-elements (`::-webkit-slider-runnable-track`, `::-moz-range-track`, etc.).
