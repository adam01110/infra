# Precise Text Alignment

## The problem

Browsers add space above and below glyphs to accommodate line height and font metrics such as ascenders and descenders. This extra leading prevents exact vertical alignment with standard CSS. Typical symptoms:

- Misaligned icons: text looks lower or higher than an adjacent icon even with `align-items: center`.
- Inaccurate padding: a button with `padding: 12px` looks as if it has more space at the top or bottom because of the font's internal leading.
- Flush alignment: the top of a capital letter can't be aligned exactly with the top of a container or adjacent image without magic-number negative margins.

## The solution

`text-box-trim` and `text-box-edge` (shorthand `text-box`) trim this leading according to font metrics. Trimming to the cap height (top of capital letters) and the alphabetic baseline (bottom of most letters) makes the element's box match its visible text.

- Apply `text-box-trim: trim-both` (or the `text-box` shorthand) to the element that contains the text.
- Choose the trim metrics with `text-box-edge`. For most UI alignment, use `cap alphabetic`.
- Use it to center text visually in flex or grid containers, and to make `padding` values match the visible gap between the text and the container edge.
- Don't use it on long-form body text, which needs its normal line spacing for readability. It suits headings, buttons and UI labels.

## Use cases

### Trim leading in badges

Fonts differ in how much space they build in above and below the text, which makes it hard to match a design or center text in a badge. When the padding should hug the text exactly, use `text-box: trim-both cap alphabetic`. This is especially useful in dense components such as badges and tags, because the padding then starts right at the text edge on every side.

```css
.badge {
  padding: 10px;
  background: hotpink;
  border-radius: 10px;
  /* Trim the top to the cap height and the bottom to the alphabetic baseline. */
  text-box: trim-both cap alphabetic;
}
```

### Center text with icons

When flexbox aligns text and icons, the extra leading often makes the text look slightly off-center. Trimming makes layout use the visible letter height.

```css
.button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

/* text-box doesn't inherit, so apply it to the text element itself. */
.button-text {
  /* The flex container now centers on the visible letters. */
  text-box: trim-both cap alphabetic;
}
```

### Align text flush with a top edge

To align a heading exactly with the top of an adjacent image or decorative element, use `trim-start cap alphabetic`. The end edge must still be given even though it isn't trimmed.

```css
.hero {
  display: flex;
  align-items: flex-start;
}

h1 {
  /* The bottom edge must be specified even though only the top is trimmed. */
  text-box: trim-start cap alphabetic;
}
```

## Best practices

- Use the `text-box` shorthand for brevity: `text-box: <trim-direction> <edges>`.
- Always specify both edges, even when trimming only one (unless you use the default `text` edge).
- Combine with `line-height` to control spacing. Trimming removes the leading before the first line and after the last line, but `line-height` still sets the distance between lines in multi-line text.
- Apply it only where precise alignment is required, not to every element.
- Fonts have different internal metrics. `cap alphabetic` is a reliable default, but some fonts or use cases align lowercase text better with `ex` (x-height).
- Trimming affects only the first and last lines of a block; interior lines are unchanged.

## Fallback strategies

Browser support for text-box: Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

`text-box` is a progressive enhancement. Browsers that don't support it ignore the properties and render text with its default leading, so the layout still works, just less precisely. No fallback code is needed.
