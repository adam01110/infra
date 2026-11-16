# Adapt scrollbar to high-contrast preferences

Users who turn on a high-contrast mode in their operating system or browser expect UI such as scrollbars to be highly legible, with stark foreground-background separation rather than subtle grays or theme colors. Use the `@media (prefers-contrast: more)` media feature to give those users high-contrast scrollbar styling.

## Enhance legibility

When you customize scrollbars with `scrollbar-color` or custom properties, add an explicit override for high-contrast mode. This matters most when the main theme uses lower-contrast scrollbars for aesthetic reasons. The default thumb still needs at least 3:1 contrast against the track (WCAG 1.4.11 Non-text Contrast).

Inside `@media (prefers-contrast: more)`, set dark, distinct colors for the thumb and track:

```css
.scroller {
  --scrollbar-thumb: #707070;
  --scrollbar-track: #f1f1f1;

  scrollbar-color: var(--scrollbar-thumb) var(--scrollbar-track);
}

@media (prefers-contrast: more) {
  .scroller {
    /* Strongly distinct colors, such as solid black on white. */
    --scrollbar-thumb: #000000;
    --scrollbar-track: #ffffff;
  }
}
```

### Issues with `scrollbar-color`

- Don't animate or transition `scrollbar-color`: a [WebKit bug](https://bugs.webkit.org/show_bug.cgi?id=311752) makes the scrollbar flicker every time it changes.
- On an element whose computed `scrollbar-width` is anything other than `auto` (`thin` or `none`), or whose computed `scrollbar-color` is anything other than `auto` (including an inherited value), the legacy `::-webkit-scrollbar` pseudo-elements are disabled.
- With overlay scrollbars (the macOS default), `scrollbar-color` styles the thumb while scrolling, but the track may stay transparent. Give the thumb enough contrast against both the track color and the scroll container's background instead of relying on the track to frame it.

## Fallbacks and browser support for `scrollbar-color`

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
