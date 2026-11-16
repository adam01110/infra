# Visual effects

## Depth and texture

- Layer several shadows for realistic, soft depth.
- Use `filter: drop-shadow()` instead of `box-shadow` for non-rectangular shapes and transparent PNGs.
- Use `mix-blend-mode` and `background-blend-mode` for lighting overlays, and limit their scope with `isolation: isolate`.

```css
.hero {
  background-image: url('texture.png'), linear-gradient(to bottom, #fff, #eee);
  background-blend-mode: soft-light;
}
```

## Gradients and `color-mix()`

State the interpolation color space explicitly for gradients and `color-mix()`, with `in oklab` or `in oklch`.

- Default to `in oklab` for `color-mix()`, especially when mixing neutrals. `oklch` brings no benefit for neutrals, and a Chromium bug (565837690) gives low-chroma oklch colors a powerless hue angle (`none`) that resolves to `0deg` (magenta-red), shifting the result toward a reddish or pink tint. Cartesian `in oklab` scales the `(a, b)` coordinates linearly toward `(0, 0)` without computing a polar hue angle, so the hue is preserved exactly and no tint shift occurs.
- `in oklab` stays in gamut more easily (given in-gamut endpoints), but can produce washed-out, desaturated colors midway when interpolating between two opposing saturated hues.
- `in oklch` preserves chroma better in gradients between two distinct saturated hues, but goes out of the device gamut more easily, especially for larger color differences. Avoid `in oklch` for alpha-transparency fades and for mixing neutral colors.
- Don't use `in srgb` without a specific reason, such as a color picker that must interpolate in sRGB.

### Fallback

Some pre-2024 browsers don't support a color interpolation space in gradients. To support them, put the token in a custom property that is set only where it is supported:

```css
:root {
  --in-oklab: ;
  --in-oklch: ;
}

@supports (background: linear-gradient(in oklab, white, black)) {
  :root {
    --in-oklab: in oklab;
    --in-oklch: in oklch;
  }
}
```

Then use it like this:

```css
.card {
  background: linear-gradient(to bottom var(--in-oklab), var(--accent-color), var(--darker));
}
```

- With this technique, the gradient preamble must stay non-empty without the variable (as `to bottom` does here). A preamble that consists only of the variable becomes a syntax error in older browsers.
- `color-mix()` doesn't need this: any browser that supports `color-mix()` also supports its `in <color-space>` argument.

## Patterns

Many patterns can be drawn with CSS gradients and hard stops. These can be more flexible and performant than SVGs or external images, because they can use custom properties and lengths from the surrounding context. A stop position doesn't need repeating: write `0` or `0%` and gradient color-stop fixup adjusts it to the previous stop.

Vertical stripes, each `1em` wide:

```css
background: linear-gradient(to right, var(--color-1) 50%, var(--color-2) 0) 0 / 2em;
```

Diagonal stripes, each `1em` wide:

```css
background: repeating-linear-gradient(-45deg, var(--color-1) 0 1em, var(--color-2) 0 2em);
```

Checkerboard with `1em` squares:

```css
background: repeating-conic-gradient(var(--color-1) 0 25%, var(--color-2) 0 50%) 0 / 2em 2em;
```

Polka dots of `.5em` radius. `--distance` (`2em`) is the horizontal and vertical offset between the two dot layers, so dots in the same row are `2 × --distance` apart and nearest neighbours sit diagonally, `--distance × sqrt(2)` apart:

```css
--distance: 2em;
--radius: .5em;
--polka: radial-gradient(circle, var(--color-1) var(--radius), transparent calc(var(--radius) + 1px));
background: var(--polka) 0 0, var(--polka) var(--distance) var(--distance) var(--color-2);
background-size: calc(var(--distance) * 2) calc(var(--distance) * 2);
```

Simple pie chart:

```css
.pie {
  --p: 80%;
  width: 60px;
  aspect-ratio: 1;
  border-radius: 50%;
  background: conic-gradient(var(--color-1) var(--p), transparent 0%) var(--color-2);
}
```

CSS backgrounds are not exposed to assistive technologies, so always pair a gradient chart with a text representation of the data: visible percentage text or an accessible label for a simple proportion, or a semantic `<table>` or `<dl>` for a multi-part breakdown.
