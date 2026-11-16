# Typography

## General practices

- Use unitless `line-height` values (such as `1.5`) so line height scales correctly when `font-size` is inherited.
- Use `overflow-wrap: break-word` (or `anywhere`) to contain long URLs.
- Size fonts in `rem` rather than `px`, so text follows the user's browser font-size preference (the root font size). Use `em` or percentages for sizing relative to context.
- Don't set a fixed `height` or `block-size` on elements that contain text, such as buttons, badges, tabs and cards. Let the content set the height, adding `min-block-size` if you need a minimum. Otherwise text overflows or is clipped when users increase text spacing; WCAG 1.4.12 Text Spacing requires no loss of content or functionality at a line height of 1.5, paragraph spacing of 2em, letter spacing of 0.12em and word spacing of 0.16em.

## Readability

- Cap paragraph line length at 80 characters.
- Avoid `text-align: justify`, which creates rivers of whitespace and makes text harder to read. If you must justify, add `hyphens: auto` to reduce the gaps between words. `hyphens: auto` only hyphenates text whose language is declared with the `lang` attribute, such as `<html lang="en">`.
- Don't use ornate or cursive typefaces for main reading content.
- Don't use all caps for emphasis. Use bold for visual emphasis, and `<em>` / `<strong>` when the emphasis is semantic.
- Use emphasis sparingly. It loses meaning when it's everywhere, so apply it only where it changes how the content should be read.
- Support user zoom: text must resize up to 200% without loss of content or functionality, and reflow at a 320 CSS px viewport width without horizontal scrolling (WCAG 1.4.10 Reflow). Avoid `white-space: nowrap` and fixed widths on running text.

```css
body {
  line-height: 1.5;
  text-align: start; /* Works for both LTR and RTL. */
}
article {
  /* About 80 characters: 1ch is the width of "0", wider than most characters. */
  max-width: 60ch;
}
```

## Text wrapping

- Use `text-wrap: balance` for headlines and headline-like content (such as `<th>`).
- Use `text-wrap: pretty` for long-form body text (paragraphs, blockquotes, etc.).
- Apply `balance` and `pretty` to specific elements, not to `*`, because they have a performance cost.
- Avoid `text-wrap: balance` on elements with a visible box (background, border, shadow, etc.). It doesn't change the container's width, only how text wraps within it, so it can leave empty space at the end of the box.

## Responsive typography

- For font sizes that scale with the viewport but stay within a range, combine viewport-relative and font-relative units in `clamp()`, for example `clamp(2rem, 1rem + 5vw, 4rem)`. The ratio of the two units controls how fast the size changes. Use font-relative minimum and maximum values, and keep the maximum at no more than 2.5 times the minimum. Viewport units don't grow when users zoom, so the text grows only once its minimum overtakes the viewport-based value. With the maximum capped at 2.5 times the minimum, browser zoom (up to 500%) can still enlarge the text to 200% (WCAG 1.4.4 Resize Text requires text to resize up to 200% without loss of content or functionality).
- Don't use `vw` alone for font size without `clamp()`; it makes text too small or too large on extreme screen sizes.
