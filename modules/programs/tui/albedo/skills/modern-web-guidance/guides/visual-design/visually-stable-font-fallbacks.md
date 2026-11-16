# Visually Stable Font Fallbacks

A web font that finishes loading often replaces a fallback font with different proportions, even at the same `font-size`. The swap causes layout shift (Cumulative Layout Shift), and if the fallback's x-height (height of lowercase letters) differs a lot from the preferred font's, text can become hard to read.

`font-size-adjust` normalizes font size by a chosen metric (usually x-height), so text takes up the same visual space whichever font is active.

## Implementation

### 1. Get the preferred font's aspect value

Normalizing needs the aspect value of the primary font: the ratio of its lowercase letter height to its font size.

- Recommended: the `from-font` keyword lets the browser read the ratio from the primary web font.
- If you know the exact value (for example 0.545 for Verdana), you can give it directly for more precise control.

### 2. Apply `font-size-adjust` to the text container

Set it on the element or a parent. While the primary font is loading, or if it fails to load, the fallback is then scaled to match the primary font's visual size.

```css
.text-content {
  font-family: "MyWebFont", "Arial", sans-serif;
  font-size: 1rem;

  /* Scale fallbacks such as Arial to MyWebFont's x-height. */
  font-size-adjust: from-font;
}
```

### 3. Optionally normalize by another metric

x-height is the default and most common metric. You can normalize by others, such as `cap-height` (useful for all-caps headings) or `ch-width` (useful for monospaced fonts).

```css
h1 {
  /* Normalize by the height of capital letters. */
  font-size-adjust: cap-height from-font;
}
```

### 4. Verify visual stability

Check that the value aligns the fallback: temporarily block the web font, or change the `font-family` declaration in the browser's DevTools, and confirm the text layout stays stable.

## Fallback strategies

Baseline status for font-size-adjust: Newly available. It's been Baseline since 2024-07-25.
Supported by: Chrome 127 (Jul 2024), Edge 127 (Jul 2024), Firefox 118 (Sep 2023), and Safari 17 (Sep 2023).

Browsers without `font-size-adjust` render the font at its default scale, which can cause layout shifts or readability changes when fonts swap.

To mitigate this without `font-size-adjust`, tune fallback fonts by hand with the `@font-face` descriptors `size-adjust`, `ascent-override` and `descent-override`. These take more work to calculate than a single `font-size-adjust` value.
