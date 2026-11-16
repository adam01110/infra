# Visually Texture Content

## Overview

To give an element realistic weathering or texture (grunge, noise, paper), use CSS masking (`mask-image`) with a repeating texture image. The mask makes parts of the content itself semi-transparent instead of laying a texture on top, which looks more like a physical material.

## Implementation

### Method 1: repeating raster image

The most common method, and the best one for realistic textures.

```css
.weathered-element {
  /* Prefixed properties for older browsers. */
  -webkit-mask-image: url('grunge-pattern.png');
  -webkit-mask-repeat: repeat;
  -webkit-mask-size: 300px;

  mask-image: url('grunge-pattern.png');
  mask-repeat: repeat; /* Tile the pattern to fill the area. */
  mask-size: 300px;    /* Controls the scale of the texture. */
}
```

### Method 2: CSS gradients for geometric patterns

Gradients generate patterns without any external image file.

```css
.patterned-element {
  --checkerboard-gradient:
    linear-gradient(45deg, #000 25%, transparent 25%),
    linear-gradient(-45deg, #000 25%, transparent 25%),
    linear-gradient(45deg, transparent 75%, #000 75%),
    linear-gradient(-45deg, transparent 75%, #000 75%);

  /* Checkerboard mask. */
  -webkit-mask-image: var(--checkerboard-gradient);
  -webkit-mask-size: 20px 20px;
  -webkit-mask-position: 0 0, 0 10px, 10px -10px, -10px 0px;

  mask-image: var(--checkerboard-gradient);
  mask-size: 20px 20px;
  mask-position: 0 0, 0 10px, 10px -10px, -10px 0px;
}
```

### Alpha and luminance mask modes

CSS masks default to `mask-mode: match-source`: the browser uses either the alpha channel (transparency) or the luminance (brightness) of the mask, depending on the source type.

| Mask source | Default mode | Behavior |
| :--- | :--- | :--- |
| Inline SVG `<mask>` element | `luminance` | Brightness sets opacity: white reveals content, black hides it, gray is semi-transparent. |
| Image file (PNG, SVG file, etc.) | `alpha` | Transparency sets opacity: opaque parts reveal content, transparent parts hide it. |
| CSS gradient | `alpha` | Transparency sets opacity: opaque colors (such as `black`) reveal content, transparent colors hide it. |

Override the default with the `mask-mode` property, for example `mask-mode: luminance;` or `mask-mode: alpha;`.

## Fallback strategies

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

In a browser without `mask-image` or its prefixed version, the element shows without the texture, as a clean solid fill. Make sure the content stays readable without it (progressive enhancement).

A background image or overlay can simulate the texture as a fallback, though it can't change the transparency of the content itself.

```css
@supports (not (mask-image: url(x))) and (not (-webkit-mask-image: url(x))) {
  .weathered-element {
    /* Adds the texture behind (or, with an overlay, on top of) the content. */
    background-image: url('grunge-pattern.svg');
    background-color: #fff; /* Solid base, if needed. */
  }
}
```
