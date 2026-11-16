# Equal-Width Text Lines

Poster-style lockups, where each line is scaled to span the container's full width, make striking headings. With `text-fit`, the browser scales each line during layout, so the fit stays correct through resizes, copy changes and font loading.

For a single line that fills its container (such as a heading or pull quote), apply `text-fit` to that element directly. This guide covers multi-line lockups.

## Basic implementation

Line breaks in a lockup are either forced (each line is its own block) or free (the browser wraps). A lockup can be all forced, all free, or a mix.

For forced lines, wrap each line in a `<span>` with `display: block` and `white-space: nowrap`.

Guidelines:

- Put `text-fit: grow per-line-all <percentage>` on the heading itself.
- Use `per-line-all`, not `per-line`. `per-line` skips the last line and any line ending in a forced break, so with one block per line it scales nothing.
- `grow` can't be combined with `shrink`. Set the base `font-size` to either a minimum or a maximum, whichever makes the better fallback or is easier to calculate, and use `grow` or `shrink` to match. Without a reason to use `shrink`, prefer `grow` with `font-size` as the minimum; it is safer in most cases.
- Always cap the growth or shrinkage with the percentage (such as `300%`) as a guardrail.
- The container needs a definite inline size. `text-fit` never changes intrinsic size, so it does nothing on `fit-content` / `max-content` widths or on content-sized flex and grid items.
- Trim the leading above the first line and below the last; the `precise-text-alignment` guide explains how.
- Keep `line-height` small (`1` or less); otherwise the gaps between lines of different font sizes become unwieldy.
- The computed `font-size` doesn't change, so `em`-based spacing doesn't scale with the text.
- If there are free lines, apply `text-wrap: balance` or `text-wrap: pretty` to avoid an over-emphasized orphan.

### Spacing

When all lines are forced, you get more control over spacing:

- Apply `text-box: trim-both cap alphabetic` to each line block so its box hugs its own glyphs. The trim uses the scaled metrics. The `precise-text-alignment` guide has more detail.
- Space the lines with flexbox or grid and `gap` on the heading, not with `line-height`. The gaps are then uniform instead of growing with each line's font size.

When some lines are free, don't use `text-box`. It trims only the first and last lines, so the outer lines would hug their glyphs while the interior gaps keep their leading. Let `line-height` govern all spacing.

## Visual design

- Lockups look best with a large difference in font size between lines. Text with mostly uniform lines produces sizes that are neither equal nor clearly different, which defeats the design principle of contrast. Force short lines to get that difference: wrap the words to emphasize in a block and let the rest wrap (a mixed lockup). This matters most together with `text-wrap: balance`.
- With Western scripts, prefer combining lockups with `text-transform: uppercase`. Ascenders and descenders tend to trap space or overlap adjacent lines, which looks worse.
- When forcing short lines, choose words whose emphasis strengthens the message.
- Limitation: enlarged text also gains visual weight, and its strokes look heavier. There is currently no way to compensate, for example by reducing `font-weight` on larger lines, because the scaling doesn't affect font-relative units like `em`, so there is no unit to calculate with.

## Fallback strategies

### `text-box`

Browser support for text-box: Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

`text-box` needs no separate fallback. Keep the small `line-height` on forced-line lockups too: it has no effect where `text-box` trims, and where `text-box` is unsupported it keeps the gaps tight, at the cost of gaps that scale with each line's font size.

### `text-wrap: balance`

Baseline status for text-wrap: balance: Newly available. It's been Baseline since 2024-05-13.
Supported by: Chrome 114 (May 2023), Edge 114 (Jun 2023), Firefox 121 (Dec 2023), and Safari 17.5 (May 2024).

### `text-fit`

Browser support for text-fit: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Forced lines have a short, faithful fallback: measure each line at its base size and scale it by its ratio to the container, with the same cap.

```css
@supports not (text-fit: grow per-line-all) {
  .lockup > span {
    /* Shrink-wrap each line so its width is the text width. */
    width: fit-content;
    /* The script measures --text-fit-scale; the cap mirrors the text-fit percentage. */
    font-size: min(var(--text-fit-scale, 1) * 1em, 300%);
  }
}
```

```js
if (!CSS.supports('text-fit', 'grow per-line-all')) {
  const fit = lockup => {
    const lines = [...lockup.querySelectorAll(':scope > span')];
    // Unscale first: on a refit, offsetWidth would otherwise include the previous scale.
    for (const line of lines) line.style.removeProperty('--text-fit-scale');
    // Do all reads, then all writes. Interleaving them (for example reading
    // lockup.clientWidth inside the write loop) forces one reflow per line.
    const scales = lines.map(line => lockup.clientWidth / line.offsetWidth);
    lines.forEach((line, i) => line.style.setProperty('--text-fit-scale', scales[i]));
  };
  for (const lockup of document.querySelectorAll('.lockup')) {
    // Refit on resize and when web fonts finish loading.
    new ResizeObserver(() => fit(lockup)).observe(lockup);
    document.fonts.addEventListener('loadingdone', () => fit(lockup));
  }
}
```

Free lines have no faithful fallback, because their line breaks aren't known until layout. Fall back progressively to a balanced heading with a fluid base size such as `clamp(2rem, 1rem + 5cqi, 5rem)`. In a mixed lockup, the script above still fits the forced lines; a wrapping block measures as wide as the container, so it keeps a scale of 1 and gets only the fluid base size.

If text fitting is critical, consider a JavaScript library such as `fitty`, loaded only when `text-fit` is unsupported.
