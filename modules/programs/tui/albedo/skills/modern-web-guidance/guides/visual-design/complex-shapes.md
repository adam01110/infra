# Complex Shapes

## Overview

To clip an element to a complex, free-form shape such as a brush stroke or organic texture, use CSS masking (`mask-image`). `clip-path` suits geometric shapes and vector paths; `mask-image` takes images (such as PNGs with transparency) or SVG to define the visible area. Because masks support semi-transparency, they can produce soft edges and textures that `clip-path` cannot.

## Implementation

### Using an image's transparency

An image's transparency can act as the mask: opaque parts are visible and transparent parts are hidden. The image can be a PNG, SVG or other image with transparency, or a generated image such as a CSS gradient.

```css
.shaped-element {
  /* Prefixed properties for older browsers. */
  -webkit-mask-image: url('mask.svg');
  -webkit-mask-size: cover;
  -webkit-mask-repeat: no-repeat;

  mask-image: url('mask.svg');
  mask-size: cover;      /* Scale the mask to cover the element. */
  mask-repeat: no-repeat; /* Don't tile the mask. */
}
```

### Using an SVG `<mask>` in the HTML

You can also reference a `<mask>` element in an inline SVG on the page. Set `maskContentUnits="objectBoundingBox"` so the mask scales with the element: coordinates inside the mask are then fractions from `0` to `1` (such as `0.5` for 50%) rather than pixels.

SVG masks use luminance by default: white reveals, black hides, and gray gives partial transparency. To use the alpha channel of the SVG shapes instead, set `mask-type: alpha;` in CSS or `mask-type="alpha"` on the `<mask>` element.

```html
<!-- White reveals, gray is semi-transparent, black or transparent hides. -->
<svg width="0" height="0">
  <defs>
    <mask id="custom-shape" maskContentUnits="objectBoundingBox">
      <circle cx="0.5" cy="0.5" r="0.5" fill="white" />
      <circle cx="0.5" cy="0.5" r="0.25" fill="gray" />
    </mask>
  </defs>
</svg>

<div class="masked-content">
  <!-- Content to be masked -->
</div>

<style>
.masked-content {
  -webkit-mask-image: url(#custom-shape);
  mask-image: url(#custom-shape);
}
</style>
```

## Fallback strategies

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

In a browser without `mask-image` or its prefixed version, the element isn't clipped and shows as a normal rectangle. Make sure the content stays readable and the layout holds without the mask (progressive enhancement). Optionally, use feature detection to apply a simpler `clip-path` shape instead:

```css
@supports (not (mask-image: url(x))) and (not (-webkit-mask-image: url(x))) {
  .shaped-element {
    /* Simple rounded rectangle as the fallback shape. */
    clip-path: inset(5% round 15px);
  }
}
```
