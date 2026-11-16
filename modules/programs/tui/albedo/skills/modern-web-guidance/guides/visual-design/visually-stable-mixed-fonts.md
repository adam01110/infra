# Visually Stable Mixed Fonts

When font families are mixed, for instance in inline code snippets or when themes switch font families, differences in x-height (the height of lowercase letters) make one font look much smaller or larger than the other. That hurts legibility and can cause layout shifts.

`font-size-adjust` normalizes the visual size of text by adjusting the font size according to a font metric, usually the x-height.

## Implementation

1. Apply `font-size-adjust` to elements where consistent font size matters, such as containers that use web fonts or blocks with mixed font families.
2. Use the `from-font` keyword so fonts in nested elements match the proportions of the primary font automatically.
3. When the font to match against comes from a different theme (it is not an ancestor's font), use a numeric aspect value instead, such as `font-size-adjust: 0.5`, to normalize the proportions independently.

### Example: normalize x-height automatically

`from-font` is the most robust approach. It takes the x-height aspect ratio of the first available font and applies it to the fonts in child elements.

```css
.content-area {
  font-family: "MyCustomWebFont";
  /* Take the x-height ratio from MyCustomWebFont and apply it to descendants. */
  font-size-adjust: from-font;
}
.content-area span {
  font-family: "MyOtherCustomWebFont";
}
```

### Example: specify the x-height ratio

When the font to adjust is not inside the element whose font sets the size, give the value explicitly.

```css
.theme {
  font-family: Verdana, sans-serif;
}
.theme.alternate {
  font-family: Times;
  /* Aspect ratio (x-height / font-size) of the primary font. */
  font-size-adjust: 0.545; /* Verdana */
}
```

## Fallback strategies

Baseline status for font-size-adjust: Newly available. It's been Baseline since 2024-07-25.
Supported by: Chrome 127 (Jul 2024), Edge 127 (Jul 2024), Firefox 118 (Sep 2023), and Safari 17 (Sep 2023).

Browsers without `font-size-adjust` render fonts at their natural `font-size`, so provide a fallback for them:

- Detect support with `@supports not (font-size-adjust: from-font)` and provide fallback styles there, such as an adjusted `line-height` or `font-size`.
- Choose fonts whose x-heights are close to the primary font's.
- Set specific `font-size` and `line-height` overrides for the alternate and nested font families.

```css
@supports not (font-size-adjust: from-font) {
  .content-area {
    /* Manual adjustment, if needed. */
    line-height: 1.6;
    font-size: 1.2rem;
  }
}
```
