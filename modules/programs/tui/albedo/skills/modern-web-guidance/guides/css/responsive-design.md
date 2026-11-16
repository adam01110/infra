# Responsive design

## General practices

- Use `@container` queries for component-driven responsive layouts that adapt to the parent container's size rather than the viewport. The `size-aware-styling` guide covers the details.
- Use dynamic viewport units (`dvh`, `dvw`) instead of `vh`/`vw`, so the layout does not break when mobile browser UI such as the address bar appears or disappears.
- Set `aspect-ratio` on media elements such as `<img>` and `<video>` to reserve their space while they load and prevent Cumulative Layout Shift (CLS).

The `css-layout` guide covers the layout mechanics behind responsive UI: flexbox, grid, container query units and viewport units.

## Responsive typography

- For font sizes that scale with the viewport but stay within a range, combine viewport-relative and font-relative units in `clamp()`, for example `clamp(2rem, 1rem + 5vw, 4rem)`. The proportion of viewport-relative to font-relative units controls how quickly the size changes.
- Use font-relative minimum and maximum values, and keep the maximum no more than 2.5 times the minimum. Viewport units do not grow when users zoom, so text only grows once its minimum overtakes the viewport-based value. With that 2.5x limit, browser zoom (which goes up to 500%) can still resize the text to 200%, as WCAG 1.4.4 Resize Text requires (text resizable up to 200% without loss of content or functionality).
- Avoid `vw` alone for `font-size` without `clamp()`: it can make text too small or too large on extreme screen sizes.

To scale type and spacing with the container instead of the viewport, see the `fluid-scaling` guide.
