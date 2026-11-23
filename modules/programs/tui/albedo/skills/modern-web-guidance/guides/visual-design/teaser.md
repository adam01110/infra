# Teaser

## Overview

To fade out the end of a container's content, such as a teaser for payment-walled text, use a CSS mask with a linear gradient rather than a semi-transparent overlay. An overlay constrains the background design and gets in the way of interaction.

- This is for content truncated at the source, not only presentationally with CSS. To hint that a scroll container has more to scroll to, use the `scrollability-affordance-hints` guide instead. For a few lines of plain text that only need an ellipsis, use `line-clamp`.
- This is for block content. For single-line overflow, see the `single-line-overflow` guide.

## Choosing a treatment

- Use a fade when the content continues elsewhere.
- Add a blur on top of the fade for payment-walled content, where readers should see that more text exists but not be able to read it.

A mask or blur only changes how the content is painted. The content stays in the DOM, the accessibility tree, find-in-page, and copy and paste.

- Do not leave links or controls in the faded part: they stay focusable while unreadable.
- Put the call to action (a subscribe button, for example) after the masked element, not inside it, so it is not faded too.

## Fading the end of the teaser

```css
.teaser {
  /* Size the fade in lines (3lh is an example value), not as a percentage:
     a percentage grows with the content, so a long excerpt would be mostly faded. */
  mask-image: linear-gradient(to top, transparent, black 3lh);
}
```

- If CSS cuts the excerpt off instead of the markup, limit it with `max-block-size` and `overflow: clip`, so the teaser does not become a scroll container. The same mask applies.
- In vertical writing modes, point the gradient in the block direction (`to left` for `vertical-rl`, `to right` for `vertical-lr`). Set the direction in a CSS variable rather than repeating the whole gradient.

## Optional: blur the end of the faded text

Draw the blur with a pseudo-element over the end of the teaser. A mask on the pseudo-element ramps the blur in gradually, so there is no visible line where it starts.

Put the pseudo-element on a parent of the faded element, not on the faded element itself: a `backdrop-filter` inside a masked element does not blur that element's text.

```html
<div class="teaser-blur">
  <div class="teaser">…</div>
</div>
```

```css
.teaser-blur {
  position: relative;
}

/* Starts fading before the blur starts; see below. */
.teaser-blur .teaser {
  mask-image: linear-gradient(to top, transparent, black 9lh);
}

.teaser-blur::after {
  /* Example value: a small radius is enough, because the text also fades out. */
  --blur: 0.1em;
  /* How far the pseudo-element extends past the text. */
  --bleed: calc(2 * var(--blur));
  content: "";
  position: absolute;
  inset-inline: calc(-1 * var(--bleed));
  inset-block-end: calc(-1 * var(--bleed));
  /* Example value: how much of the text is blurred. Keep it shorter than the fade. */
  block-size: calc(5lh + var(--bleed));
  backdrop-filter: blur(var(--blur));
  /* Ramps the blur in from the end of the text. */
  mask-image: linear-gradient(to top, black 5lh, transparent);
}
```

- Extend the pseudo-element past the text on the inline sides and at the end. `backdrop-filter` only paints inside its element, so without this bleed the blurred text is cut off in a straight line at the text's edges.
- Make the bleed at least as large as the blur radius. A blur spreads further than its radius, so the snippet uses twice the radius.

Keep the fade on `.teaser`, so the blurred text fades into the background instead of ending at a hard edge.

- Start fading the text before the blur starts, so the fade is longer than the blur (the snippet fades over 9lh and blurs over 5lh).
  - Blurred text looks heavier than crisp text at the same opacity. If both start at the same point, the text gets more prominent where the blur begins, then fades.
  - The blur only has the already-faded text to work with, so the fade cannot be so long that the blurred part is nearly transparent.
- Keep the blur radius small. The mask cross-fades sharp text with blurred text, so a large radius shows a ghost of the sharp text through the blur.
- To make the blur radius itself grow toward the end of the text instead of cross-fading, stack 4 to 6 overlay elements over the end of the teaser.
  - Give each a larger `backdrop-filter: blur()` radius than the one before (for example `1px`, `2px`, `4px`, `8px`).
  - Give each a `mask-image` band that overlaps its neighbours, so the steps blend.
  - This costs one element and one compositing pass per step. Do not use an SVG filter (`backdrop-filter: url(…)`) to avoid the extra elements.

## Fallback strategies

### Masks

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

No fallback is needed. Do not add `-webkit-mask-image` declarations.

### The `lh` unit

Baseline status for lh unit: Widely available. It's been Baseline since 2023-11-21.
Supported by: Chrome 109 (Jan 2023), Edge 109 (Jan 2023), Firefox 120 (Nov 2023), and Safari 16.4 (Mar 2023).

No fallback is needed.

### `backdrop-filter`

Baseline status for backdrop-filter: Newly available. It's been Baseline since 2024-09-16.
Supported by: Chrome 76 (Jul 2019), Edge 79 (Jan 2020), Firefox 103 (Jul 2022), and Safari 18 (Sep 2024).

The blur is progressive enhancement: without `backdrop-filter` the text is not blurred but still fades out, so no fallback is needed.

Safari and Firefox do not apply SVG filter references (`url(…)`) in `backdrop-filter`, so an SVG-based blur renders no blur at all there.
