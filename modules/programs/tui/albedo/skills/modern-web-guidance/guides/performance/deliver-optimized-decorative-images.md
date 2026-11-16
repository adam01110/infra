# Deliver Optimized Decorative Images

The CSS `image-set()` function gives the browser several candidates for one background or mask image: modern formats such as AVIF or WebP alongside resolutions such as `1x` and `2x`. The browser picks the smallest supported image with the right pixel density for the device, which improves perceived performance without losing visual quality.

If the image is likely to be the Largest Contentful Paint (LCP) element, such as a large hero banner, note that images referenced in CSS through `image-set()` are invisible to the browser's preload scanner. That can delay loading considerably and hurt LCP. For LCP candidates, use an HTML `<img>` or `<picture>` element instead, or also preload the image with `<link rel=preload>` and a `media` attribute.

## Implementation

`image-set()` works anywhere CSS expects an `<image>`, most often in `background-image`, `content` or `mask-image`. Giving both the format (`type()`) and the resolution (`1x`, `2x`) works best, but both are optional.

Order formats from most to least optimized (AVIF, then WebP, then JPEG or PNG): the browser uses the first format it supports.

```css
.gallery-item {
  background-image: image-set(
    url("gallery.avif") type("image/avif") 1x,
    url("gallery-2x.avif") type("image/avif") 2x,
    url("gallery.webp") type("image/webp") 1x,
    url("gallery-2x.webp") type("image/webp") 2x,
    url("gallery.jpg") type("image/jpeg") 1x,
    url("gallery-2x.jpg") type("image/jpeg") 2x
  );
  background-size: cover;
  background-position: center;
}
```

## Browser support and fallback

Baseline status for image-set(): Widely available. It's been Baseline since 2023-09-18.
Supported by: Chrome 113 (May 2023), Edge 113 (May 2023), Firefox 89 (Jun 2021), and Safari 17 (Sep 2023).

For older browsers without `image-set()`, declare a plain image before the `image-set()` declaration. Browsers ignore declarations they do not understand, so older ones keep the fallback and modern ones override it.

```css
.gallery-item {
  background-image: url("gallery.jpg");
  background-image: image-set(
    url("gallery.avif") type("image/avif") 1x,
    url("gallery-2x.avif") type("image/avif") 2x,
    url("gallery.jpg") type("image/jpeg") 1x,
    url("gallery-2x.jpg") type("image/jpeg") 2x
  );
}
```
