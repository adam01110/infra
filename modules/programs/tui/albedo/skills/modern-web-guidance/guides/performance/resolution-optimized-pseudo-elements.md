# Resolution Optimized Pseudo Elements

Resolution-optimized images in pseudo-elements such as `::before` and `::after` add decorative icons or graphics without extra DOM nodes. With the `image-set()` function you offer several formats (such as AVIF or WebP) and resolutions (such as `1x` and `2x`), and the browser picks the best image for the device.

## Implementation

Use `image-set()` directly in the pseudo-element's `content` property, or in its `background-image` with `content: ""`. Giving both the format (`type()`) and the resolution (`1x`, `2x`) works best, but both are optional.

Order formats from most to least optimized (AVIF, then WebP, then PNG or JPEG): the browser uses the first format it supports.

```css
.icon-button::before {
  content: image-set(
    url("icon.avif") type("image/avif") 1x,
    url("icon-2x.avif") type("image/avif") 2x,
    url("icon.webp") type("image/webp") 1x,
    url("icon-2x.webp") type("image/webp") 2x,
    url("icon.png") type("image/png") 1x,
    url("icon-2x.png") type("image/png") 2x
  );

  display: inline-block;
  margin-right: 8px;
  vertical-align: middle;
}
```

## Browser support and fallback

Baseline status for image-set(): Widely available. It's been Baseline since 2023-09-18.
Supported by: Chrome 113 (May 2023), Edge 113 (May 2023), Firefox 89 (Jun 2021), and Safari 17 (Sep 2023).

For older browsers without `image-set()`, declare a plain image before the `image-set()` declaration. Browsers ignore declarations they do not understand, so older ones keep the fallback and modern ones override it.

```css
.icon-button::before {
  content: url("icon.png");
  content: image-set(
    url("icon.avif") type("image/avif") 1x,
    url("icon-2x.avif") type("image/avif") 2x,
    url("icon.png") type("image/png") 1x,
    url("icon-2x.png") type("image/png") 2x
  );
}
```
