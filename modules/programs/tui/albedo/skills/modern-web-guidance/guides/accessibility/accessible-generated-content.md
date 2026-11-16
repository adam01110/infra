# Accessible generated content

- Keep meaningful text (labels, state, instructions) in the DOM, not in CSS `content` (WCAG failure F87). The alt text argument below is harm reduction for decoration that ends up carrying meaning, not a licence to put meaning in CSS.
- Give generated images alt text with the alternative text argument of `content`: `content: url(cloud.svg) / "Save";`.
- Silence purely decorative generated text with an empty alternative: `content: "text" / "";`.
- Leave the alternative off decorative images. Generated images are already presentational, so `content: url(cloud.svg) / "";` is redundant.
- Describe an emoji only when the description differs from its official name: `content: "🎉" / "Yay!";` is fine, `content: "🎉" / "celebration";` is not.

Use the alternative text argument only when the text differs from the primary value and is not already in the DOM. Here the screen reader reads "Save save":

```html
<button class="save">Save</button>
```

```css
/* Wrong: duplicates the button text */
button.save::before {
  content: url(cloud.svg) / "Save";
}
```

## Fallback strategies

Baseline status for alt text for generated content: Newly available, Baseline since 2024-07-09.
Supported by Chrome 77 (Sep 2019), Edge 79 (Jan 2020), Firefox 128 (Jul 2024) and Safari 17.4 (Mar 2024).

Browsers without the `/` syntax drop the whole declaration as invalid. If your Baseline target includes them, precede it with a single-value `content` declaration:

```css
.more-link::after {
  /* Older browsers render the glyph; their screen readers still announce it. */
  content: " →";
  content: " →" / "";
}
```

For non-empty alternative text (`content: url(...) / "..."`), a single-value `content: url(...)` fallback keeps the image visible in older browsers but loses its alt text. If older browsers need the label, put it in the DOM instead (for example a visually hidden `<span>` or `aria-label`) and use a plain `content: url(...)` without `/`.
