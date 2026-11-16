# Optimize image priority

Browsers assign image loading priorities heuristically, and the defaults do not always match your page's Largest Contentful Paint (LCP) image.

`fetchpriority` on an `<img>` states the image's importance explicitly, so critical images load sooner and non-essential ones do not compete for bandwidth. `loading="lazy"` goes further: images far enough off-screen are not downloaded at all.

## How to implement

1. Identify the image most likely to be the LCP element, usually the hero image at the top of the page.
2. Add `fetchpriority="high"` to that `<img>`.
3. Add `fetchpriority="low"` to images in secondary UI or revealed only after interaction, such as mega menus, modals or off-screen carousel slides.
4. Use lazy loading carefully:
   - Never put `loading="lazy"` on the LCP image.
   - For ordinary below-the-fold images, `loading="lazy"` alone is enough to defer the request until the user scrolls near them. Do not add `fetchpriority="low"` to them; once the user scrolls there they should load at normal priority.
   - Reserve `fetchpriority="low"` for images that are technically above the fold but not initially visible, such as hidden carousel slides or mega menus. These may also use `loading="lazy"`; the browser then times the request while respecting the low priority.
5. For normal priority, omit `fetchpriority` rather than setting `auto`. This is a style convention that keeps HTML cleaner and leaves the decision to the browser's heuristics.

## Example

```html
<!-- LCP image: high priority. -->
<img src="/images/hero-lcp.jpg"
     alt="Main Banner"
     fetchpriority="high"
     width="800" height="400">

<!-- Initially hidden images above the fold: low priority, plus
     loading="lazy" if there are likely to be many images. -->
<div class="carousel">
  <!-- The first slide is visible, so it keeps the default priority. -->
  <img src="/images/gallery-alt.jpg"
       alt="Gallery Image 1"
       width="400" height="300">
  <img src="/images/gallery-alt.jpg"
       alt="Gallery Image 2"
       fetchpriority="low"
       loading="lazy"
       width="400" height="300">
</div>

<!-- Revealed only after user interaction: low priority. -->
<img src="/images/mega-menu-promo.jpg"
     alt="Special Offer"
     fetchpriority="low"
     width="300" height="150">

<!-- Ordinary below-the-fold image: loading="lazy" alone. -->
<img src="/images/footer-logo.png"
     alt="Footer Logo"
     loading="lazy"
     width="120" height="60">

<!-- Normal priority: no fetchpriority attribute. -->
<img src="/images/standard-image.jpg"
     alt="Standard Image"
     width="400" height="300">
```

## Guidelines

- Always give the LCP image `fetchpriority="high"`.
- Use `fetchpriority="high"` on at most 1–2 critical images; more causes network contention and dilutes the boost.
- Use `fetchpriority="low"` for images that are technically above the fold but initially hidden, such as hidden carousel slides and mega menu images.
- Do not put `fetchpriority="low"` on ordinary below-the-fold images that already use `loading="lazy"`; they should load at normal priority when they enter the viewport.
- Avoid `fetchpriority="auto"`; omit the attribute for the default priority.
- Do not combine `fetchpriority="high"` with `loading="lazy"`.
- Do not use the deprecated `importance` attribute. `fetchpriority` replaced it and no browser supports it.
- Do not use the deprecated `loading="auto"` value. Chrome supported it early on but removed it, and no browser supports it.

## Browser support and fallback

Baseline status for Fetch priority: Newly available. It's been Baseline since 2024-10-29.
Supported by: Chrome 103 (Jun 2022), Edge 103 (Jun 2022), Firefox 132 (Oct 2024), and Safari 17.2 (Dec 2023).

`fetchpriority` on `<img>` is a progressive enhancement. Browsers without support ignore it and use their default heuristics.
