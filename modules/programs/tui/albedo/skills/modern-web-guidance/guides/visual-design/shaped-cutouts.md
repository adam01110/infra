# Shaped Cutouts

## Overview

CSS masking clips an element to a custom shape, such as a notch in a card or a shaped border. Choose the masking strategy by what the element contains:

| Strategy | Best for | Effect on text |
| --- | --- | --- |
| SVG mask on the element itself | Images, icons, decorative and complex shapes | Not recommended: can crop text |
| SVG mask on an adjacent element | Cards with text, crucial content | Text stays fully readable |
| Pure CSS gradient | Simple geometric shapes | Not recommended: can crop text |

## Implementation

### SVG masks

SVG masks define shapes that add to or subtract from the visible area: white fills reveal, black fills hide. They use luminance (brightness) by default, which is why the examples use `fill="white"` and `fill="black"`. To use the SVG's transparency (alpha channel) instead, set `mask-type: alpha;` in CSS or `mask-type="alpha"` on the `<mask>` element.

#### Mask on the element itself

When the element has no text to protect (profile avatars, product images, illustrations), apply the SVG mask directly. `maskContentUnits="objectBoundingBox"` makes the mask scale to the width and height of whatever element it is applied to.

```html
<!-- Mask definition, hidden from view. -->
<svg width="0" height="0" style="position: absolute;" aria-hidden="true">
  <defs>
    <!-- objectBoundingBox maps 0 to 1 onto the element's box. -->
    <mask id="splat-mask" maskContentUnits="objectBoundingBox">
      <!-- Organic Bezier path in the shape of a paint splat. -->
      <path d="M 0.5 0.05 C 0.58 0.05, 0.58 0.21, 0.67 0.18 C 0.76 0.15, 0.79 0.08, 0.85 0.15 C 0.91 0.22, 0.83 0.32, 0.89 0.38 C 0.95 0.44, 1.03 0.45, 0.99 0.55 C 0.95 0.65, 0.82 0.62, 0.8 0.72 C 0.78 0.82, 0.89 0.92, 0.8 0.97 C 0.71 1.02, 0.64 0.88, 0.55 0.93 C 0.46 0.98, 0.44 1.06, 0.35 1.01 C 0.26 0.96, 0.31 0.81, 0.22 0.79 C 0.13 0.77, 0.01 0.88, 0.01 0.77 C 0.01 0.66, 0.16 0.62, 0.14 0.52 C 0.12 0.42, -0.02 0.39, 0.03 0.29 C 0.08 0.19, 0.23 0.27, 0.29 0.19 C 0.35 0.11, 0.3 0.01, 0.4 0.01 C 0.5 0.01, 0.42 0.05, 0.5 0.05 Z" fill="white" />
    </mask>
  </defs>
</svg>

<img src="avatar.jpg" alt="User Profile" class="shaped-avatar">

<style>
.shaped-avatar {
  width: 200px;
  height: 200px;
  object-fit: cover;

  -webkit-mask-image: url(#splat-mask);
  mask-image: url(#splat-mask);
}
</style>
```

#### Mask on an adjacent element

A mask on an element that contains text can clip the text. Instead, split the component in two:

1. An unmasked text container (`.card-body`) for all readable content.
2. An empty decorative `div` (`.card-accent`) beside it that receives the SVG mask.

Give both the same background color and they read as one custom-shaped component.

```html
<svg width="0" height="0" style="position: absolute;" aria-hidden="true">
  <defs>
    <mask id="accent-stencil" maskContentUnits="objectBoundingBox">
      <!-- White fills the whole area (fully visible). -->
      <rect width="1" height="1" fill="white" />
      <!-- Black cuts out a concave curve. Extending to x=1.1 clears the right
           edge completely, preventing subpixel lines. -->
      <path d="M 1.1,0 C 0.4,0.1 0.4,0.9 1.1,1 L 1.1,0 Z" fill="black" />
    </mask>
  </defs>
</svg>

<div class="unified-card">
  <!-- Text stays in an unmasked, rectangular element. -->
  <div class="card-body">
    <h3>Premium Membership</h3>
    <p>Get exclusive weekly updates on modern web standards and premium UI designs.</p>
  </div>
  <!-- The empty accent element is masked into the custom shape. -->
  <div class="card-accent"></div>
</div>

<style>
.unified-card {
  display: flex;
  width: 400px;
  /* A shadow on the parent follows the combined card and masked accent. */
  filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.3));
}

.card-body {
  flex: 1;
  background-color: #1e293b;
  color: #f8fafc;
  padding: 24px;
  border-top-left-radius: 16px;
  border-bottom-left-radius: 16px;
}

.card-accent {
  width: 60px;
  background-color: #1e293b; /* Same color as .card-body, so there is no visible seam. */
  border-top-right-radius: 16px;
  border-bottom-right-radius: 16px;

  -webkit-mask-image: url(#accent-stencil);
  mask-image: url(#accent-stencil);
}
</style>
```

### A single CSS gradient for simple cutouts

Simple geometric cutouts (a semicircular top notch, side indentations, straight diagonal cuts) don't need an SVG. Put a radial or linear gradient directly in `mask-image`.

```html
<div class="gradient-masked-card">
  <h3>Notched Coupon Card</h3>
  <p>This card uses a pure CSS radial gradient to cut out a semi-circular notch along its top edge.</p>
</div>

<style>
.gradient-masked-card {
  background: linear-gradient(135deg, #2563eb, #1e40af);
  color: white;
  padding: 40px 24px 24px 24px; /* Extra top padding keeps content clear of the notch. */
  border-radius: 16px;
  text-align: center;

  /* A circle centered at the top edge (50% 0%) cuts out a 20px transparent notch. */
  -webkit-mask-image: radial-gradient(circle at 50% 0%, transparent 20px, black 21px);
  mask-image: radial-gradient(circle at 50% 0%, transparent 20px, black 21px);
}
</style>
```

## Fallback strategies

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

In a browser without `mask-image` or its prefixed version:

- Shaped images degrade to normal rectangles with their default styles.
- In shaped cards, the decorative `.card-accent` stays a solid, unmasked rectangle. Because it shares the text container's background color, the card renders as a plain rectangular container.
- Keeping text outside the mask means the content stays readable, structured and accessible in older browsers.
