# Fluid Scaling

## Overview

Fluid scaling lets a component adjust its internal proportions, such as font sizes and spacing, to its current dimensions. This gives a more cohesive design than jumping between fixed breakpoints.

Viewport units scale with the screen. Container query units scale with the parent container instead, so a component looks right wherever it is placed in a layout, which keeps components isolated and reusable.

## Implementation

### 1. Define a container

Container query units need a containment context on a parent element.

```css
.component-wrapper {
  /* inline-size: width-based scaling. 'size' covers width and height but requires explicit sizing. */
  container-type: inline-size;

  /* Optional: name the container for specific targeting */
  container-name: fluid-card;
}
```

### 2. Use container query units

Use container query units (`cqi`, `cqb`, and others) to size things relative to the container.

- `cqi`: 1% of the container's inline size (width in horizontal writing modes).
- `cqb`: 1% of the container's block size (height in horizontal writing modes).

Container units work directly on any property without an `@container` rule. They resolve against the nearest ancestor with a `container-type`.

```css
.component-title {
  /* 10% of the container's width */
  font-size: 10cqi;
}

.component-body {
  padding: 5cqi;
}
```

### 3. Constrain values with `clamp()`

Use `clamp()` to keep sizes from becoming too small or too large. Fluid sizes affect the user's ability to zoom or change their base font size, so for accessible text keep the maximum no more than 2.5 times the minimum.

Browser zoom shrinks the container in CSS pixels, so `cqi` values shrink as the user zooms in, and the font-relative `clamp()` minimum has to carry the growth. The 2.5x limit above ensures text can still be resized to 200% of its default size through browser zoom, as WCAG 1.4.4 Resize Text (Level AA) requires.

```css
.component-title {
  /* Between 1rem and 2.5rem, scaling with 5% of the container width */
  font-size: clamp(1rem, 5cqi, 2.5rem);
}
```

### Fallback strategies

Baseline status for Container queries (size): Widely available. It's been Baseline since 2023-02-14.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 110 (Feb 2023), and Safari 16 (Sep 2022).

Where container queries are not supported, fall back to viewport units or standard media queries.

```css
.component-title {
  /* Fallback for browsers without container units */
  font-size: clamp(1rem, 5vw, 2.5rem);
}

@supports (font-size: 1cqi) {
  .component-title {
    font-size: clamp(1rem, 5cqi, 2.5rem);
  }
}
```

With this fallback the text still scales, but with the screen width rather than the component's width. Test that this works for your use case.
