# Customize the color or thickness of a scrollbar

Customize scrollbars with the standard CSS properties `scrollbar-color` and `scrollbar-width`:

- `scrollbar-color` takes two `<color>` values: the first for the thumb (the moving part), the second for the track (the fixed background).
- `scrollbar-width` takes `auto` (the default), `thin` (a thinner variant), or `none` (hides the scrollbar while keeping the element scrollable).

## Apply `scrollbar-color` and `scrollbar-width`

Set `scrollbar-color` and `scrollbar-width` on the scrollable container. Leave `scrollbar-width` at `auto` unless the page offers another accessible way to scroll: a `thin` thumb is too small for some users to operate, and `none` removes it.

Give the thumb a contrast ratio of at least 3:1 against the track color, and against the container's background where the track may be transparent (as with macOS overlay scrollbars), so users can see the thumb and how far they've scrolled (WCAG 1.4.11 Non-text Contrast).

Keep the thumb and track colors in separate custom properties. This reads better and is easier to maintain, especially once fallbacks reuse them.

```css
.scroller {
  --scrollbar-thumb: var(--color-neutral-70);
  --scrollbar-track: var(--color-neutral-90);

  scrollbar-color: var(--scrollbar-thumb) var(--scrollbar-track);
}
```

## Fallback strategies

Baseline status for scrollbar-width: Newly available. It's been Baseline since 2024-12-11.
Supported by: Chrome 121 (Jan 2024), Edge 121 (Jan 2024), Firefox 64 (Dec 2018), and Safari 18.2 (Dec 2024).

### Fallbacks and browser support for `scrollbar-color`

Baseline status for scrollbar-color: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 121 (Jan 2024), Edge 121 (Jan 2024), Firefox 64 (Dec 2018), and Safari 26.2 (Dec 2025).

`scrollbar-color` is a progressive enhancement and does not always need a fallback. If the styling matters and the user's Baseline target is "Baseline Widely Available" or earlier, add the non-standard `::-webkit-scrollbar` pseudo-elements as a fallback:

- Put them after the base rule inside `@supports not (scrollbar-color: auto)`, so browsers that support both the standard property and the WebKit selectors don't get conflicting styles.
- If the container also sets `scrollbar-width: thin`, reset `scrollbar-width: auto` on the same selector inside that block. Otherwise browsers that support `scrollbar-width` but not `scrollbar-color` suppress the `::-webkit-scrollbar` styling.
- Custom properties holding the colors cascade into the WebKit pseudo-elements, so you don't need to duplicate the values.

```css
/* Legacy fallback for WebKit/Blink browsers. */
@supports not (scrollbar-color: auto) {
  .scroller {
    /* Undo scrollbar-width: thin (if set) so ::-webkit-scrollbar still applies. */
    scrollbar-width: auto;
  }

  .scroller::-webkit-scrollbar {
    /* WebKit renders custom colors only with an explicit size (e.g. 8px thin, 12px default). */
    width: 12px;
    height: 12px;
  }

  .scroller::-webkit-scrollbar-thumb {
    background: var(--scrollbar-thumb);
  }

  .scroller::-webkit-scrollbar-track {
    background: var(--scrollbar-track);
  }
}
```
