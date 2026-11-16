# Overflow Clipping Control

`overflow: hidden` almost always clips content at the padding box. `overflow: clip` combined with `overflow-clip-margin` lets block containers choose exactly where clipping happens.

The clipping boundary can align with an inner box-model edge or extend beyond the element's box by an offset (a safety margin). This performs well and removes the need for extra wrapper elements with padding and negative margins just to let visual effects, such as prominent child shadows, render unclipped.

Replaced elements (`<img>`, `<video>`, `<canvas>` and so on) default to `overflow: clip` and `overflow-clip-margin: content-box`, which keeps images that use `object-fit` or `border-radius` cleanly contained.

## How to implement

1. Apply `overflow: clip`. On block layout containers, `overflow-clip-margin` only takes effect with `overflow: clip`; with `hidden`, `auto` or `scroll` the browser ignores it. `overflow: clip` prevents all scrolling, both by the user and programmatically from JavaScript.
2. Align to a box edge with a keyword:
   - `content-box`: clips where the content area begins, so content stops at the padding's inner edge and the padding area stays clean. Useful for nested layout modules.
   - `padding-box` (default): clips at the inner edge of the border.
   - `border-box`: clips at the outer edge of the border, so content can sit under or partly overlap a translucent border.
3. Add an offset (the bleed): a length such as `15px` or `5px` creates a safety zone before pixels are cut, so prominent child shadows render past the boundary without changing layout geometry.
4. Combine both: a box edge and a length together (such as `content-box 15px`) offset from that edge.

## Examples

### Block containers: nested rounded curves

Give a padded parent with rounded corners `overflow-clip-margin: content-box`, and round the inner media and footer along the concentric inner content-box boundary. This avoids awkward nested curves without custom `calc()` logic.

```html
<div class="nested-curve-parent">
  <img src="avatar.jpg" alt="Nested Curve Demo">
  <div class="nested-curve-footer">Card Footer</div>
</div>
```

```css
.nested-curve-parent {
  padding: 1rem;
  border-radius: 16px;
  /* Fallback: clips the children roughly at the padding box */
  overflow: hidden;
}

.nested-curve-footer {
  background: #111;
  color: #fff;
}

@supports (overflow-clip-margin: content-box) {
  .nested-curve-parent {
    /* Non-replaced elements need overflow: clip for overflow-clip-margin to apply */
    overflow: clip;
    /* Clipping edge follows the inner content-box radius */
    overflow-clip-margin: content-box;
  }
}
```

### Block containers: child shadow bleed

Without a clip margin, a child's shadow is cut off at the parent's boundary. `overflow: clip` with a length `overflow-clip-margin` creates a visible safety zone so the shadow renders outside the parent without changing layout geometry.

```html
<div class="safety-zone-parent">
  <h4>Clipped Container</h4>
  <p>Inner content boundaries safely contained.</p>
  <!-- Child with a prominent shadow -->
  <button class="demo-glowing-btn">Submit</button>
</div>
```

```css
.safety-zone-parent {
  /* Fallback: clips overflowing content but also cuts off child shadows */
  overflow: hidden;
}

.demo-glowing-btn {
  display: block;
  box-shadow: 0 8px 13px rgba(229, 46, 113, 0.7);
}

@supports (overflow-clip-margin: 15px) {
  .safety-zone-parent {
    overflow: clip;
    /* Safety zone that lets child shadows render outside */
    overflow-clip-margin: 15px;
  }
}
```

## Best practices

- Set `overflow: clip` whenever you use `overflow-clip-margin`; on standard block layout containers the margin, whether a length or an inner box edge, has no effect without it.
- On padded containers with rounded corners, set `overflow-clip-margin: content-box` so unrounded child elements are clipped into matching nested curves without manual padding subtraction.
- When applying external visual effects such as `filter: drop-shadow()`, give `overflow-clip-margin` a length offset so the effect is not cut off at the bounding box, without changing layout geometry.
- Do not use `overflow: clip` on a container that JavaScript must scroll programmatically or that must be the scrolling context for `position: sticky` descendants, because `clip` disables scrolling entirely.

## Fallback strategies

Baseline status for overflow: clip: Widely available. It's been Baseline since 2022-09-12.
Supported by: Chrome 90 (Apr 2021), Edge 90 (Apr 2021), Firefox 81 (Sep 2020), and Safari 16 (Sep 2022).

Browser support for overflow-clip-margin: Limited availability.
Supported by: Firefox 148 (Feb 2026).
Unsupported in: Chrome, Edge, and Safari.

Where `overflow: clip` or `overflow-clip-margin` is unsupported, pick the fallback by visual intent:

- `overflow: hidden` as the base experience, so the core boundaries hold.
- `overflow: visible` on elements whose drop shadows or external corner badges must not be cut off.

### Complete progressive enhancement example

```html
<!-- 1. Nested rounded edges -->
<div class="demo-container-fallback">
  <img src="example.jpg" alt="Nested Curve Fallback">
  <div class="demo-footer-fallback">Footer</div>
</div>

<!-- 2. Child shadow bleed -->
<div class="demo-safety-parent">
  <h4>Container</h4>
  <p>Inner boundaries contained.</p>
  <button class="demo-glowing-btn">Submit</button>
</div>
```

```css
/* 1. Nested curves: the fallback clips roughly at the padding box */
.demo-container-fallback {
  overflow: hidden;
}

.demo-container-fallback img {
  object-fit: cover;
  display: block;
}

@supports (overflow-clip-margin: content-box) {
  .demo-container-fallback {
    overflow: clip;
    overflow-clip-margin: content-box;
  }
}

/* 2. Shadow bleed: the fallback overflow: hidden cuts off child shadows */
.demo-safety-parent {
  overflow: hidden;
}

.demo-glowing-btn {
  display: block;
  width: 100%;
  padding: 6px 12px;
  background: #e52e71;
  box-shadow: 0 8px 13px rgba(229, 46, 113, 0.65);
}

@supports (overflow-clip-margin: 15px) {
  .demo-safety-parent {
    overflow: clip;
    overflow-clip-margin: 15px;
  }
}
```
