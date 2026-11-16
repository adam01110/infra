# Optimize preload priority

`<link rel="preload">` tells the browser a resource will be needed soon, but the preload inherits the default priority for its resource type, which for images is low. Add `fetchpriority` to adjust the relative priority; in particular, preload images at high priority so they start earlier and get more bandwidth.

## How to implement

1. Find resources the browser discovers late but that are essential to the page's appearance, such as video poster images or CSS background images.
2. For the LCP image or other critical images not prioritized by default, use `<link rel="preload" fetchpriority="high">` so they rank above other preloads. Fonts are already high priority by default.
3. For resources not needed for the initial render, such as a background video or secondary fonts, use `<link rel="preload" fetchpriority="low">`.
4. Each `as` type has its own default priority; use `fetchpriority` to override it where needed.

## Example

```html
<!-- Video poster image that is the LCP candidate. -->
<link rel="preload" href="/images/video-poster.jpg" as="image" fetchpriority="high">

<!-- Critical LCP image referenced only from CSS. -->
<link rel="preload" href="/images/hero-background.jpg" as="image" fetchpriority="high">

<!-- Secondary font, deprioritized to avoid network contention. -->
<link rel="preload" href="/fonts/secondary-font.woff2" as="font" type="font/woff2" fetchpriority="low" crossorigin>
```

## Guidelines

- Use `fetchpriority="high"` on at most 1–2 critical image preloads; more causes network contention and dilutes the boost.
- Use `fetchpriority="high"` for Largest Contentful Paint (LCP) images.
- Limit preloads on a page to at most 2 images and 2–3 essential fonts, to prevent bandwidth contention.
- Use `fetchpriority="low"` for preloads that should start early but not at the expense of critical resources, especially non-critical fonts.
- Set the `as` attribute correctly, or the preload will not be used.
- Prefer making critical resources such as LCP images discoverable in the HTML with `<img>` over preloading background images.
- Always give font preloads the `crossorigin` attribute, even for same-origin fonts.
- Do not use the deprecated `importance` attribute; `fetchpriority` replaced it.

## Browser support and fallback

Baseline status for Fetch priority: Newly available. It's been Baseline since 2024-10-29.
Supported by: Chrome 103 (Jun 2022), Edge 103 (Jun 2022), Firefox 132 (Oct 2024), and Safari 17.2 (Dec 2023).

`fetchpriority` on `<link rel="preload">` is a progressive enhancement. Browsers without support still preload the resource at the default priority for its type. For compatibility, always set correct `as` and `type` attributes.
