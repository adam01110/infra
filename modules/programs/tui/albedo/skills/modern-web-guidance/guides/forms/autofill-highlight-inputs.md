# Customize the styling of autofilled form fields

The CSS `:autofill` pseudo-class replaces the browser's default highlight on autofilled `<input>`, `<select>` and `<textarea>` elements. It matches fields filled by the browser or by the user picking an autofill suggestion, and stops matching once the user edits the field, even if the value stays the same.

It never matches checkbox, radio, file or button inputs, form-associated custom elements, or `contenteditable`, because browsers do not autofill those. A native control inside a custom element's shadow DOM does match: style it from inside the shadow root, or with `::part(name):autofill`.

## How to implement

- Add at least one non-color indicator, such as a thicker inset ring. The browser's default highlight is color only.
- Keep the focus outline (no `outline: none`). If the autofill style uses `outline`, give `:autofill:focus-visible` an outline that differs in more than color (thickness, style or offset) so focus stays perceivable.
- Leave layout-affecting properties such as `border-width` and `padding` alone. The state toggles with user activity, so changing them shifts content.

```css
input:autofill {
  /* A thicker inset ring: non-color indicator without layout shift. */
  box-shadow: inset 0 0 0 2px var(--autofill-ring-color);
  border-color: var(--autofill-ring-color);
}
```

### Overriding the background and text color

Prefer keeping the browser's background and text color. Users have learned that the default highlight means "this was autofilled", and replacing it breaks that association. Every browser also sets `background-color`, `background-image` and `color` on autofilled fields with `!important` in its user agent stylesheet, so overriding them needs workarounds.

If the design requires it:

```css
input:autofill {
  /* An inset box-shadow paints over the UA's !important background. */
  box-shadow:
    inset 0 0 0 2px var(--autofill-ring-color),
    inset 0 0 0 100vmax var(--autofill-background-color);
  /* The UA does not set -webkit-text-fill-color. */
  -webkit-text-fill-color: var(--autofill-text-color);
  /* The caret still follows the UA's color. */
  caret-color: var(--autofill-text-color);
}
```

Caveats:

- The UA text color is `FieldText`: black in a light color scheme, white in a dark one. Keep the fill legible against it (for example with `light-dark()`) so the field stays readable if the text color override does not apply.
- The fill is painted over the browser's color, not your page background, so `--autofill-background-color` must be opaque.
- The rule replaces any other `box-shadow` on the field, such as a `box-shadow` focus ring. Repeat those shadows in the same declaration.
- `-webkit-text-fill-color` changes painted text only. `color`, and therefore `currentColor`, still resolve to the UA's `FieldText`.

## Fallback strategies

Browser support for `:autofill`: Limited availability.
Supported by: Chrome 110 (Feb 2023), Edge 110 (Feb 2023) and Safari 15 (Sep 2021).
Unsupported in: Firefox.

Firefox matches `:autofill` only on autofilled username and password fields (bug 1923525). There is no workaround; other fields keep the default tint.

Chrome before 110 and Safari before 15 support only `:-webkit-autofill`. If they are in your Baseline target, wrap both names in `:is()` so an unrecognized pseudo-class does not invalidate the whole rule:

```css
input:is(:autofill, :-webkit-autofill) {
  /* same declarations as above */
}
```

This is progressive enhancement: unsupported browsers keep their default highlight. Do not add a JavaScript fallback.
