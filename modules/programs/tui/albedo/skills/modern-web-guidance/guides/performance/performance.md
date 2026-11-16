# Performance

## Critical rendering path

The critical rendering path determines how quickly the browser turns HTML, CSS and JavaScript into painted pixels.

Do:

- Inline critical CSS: put the styles needed for above-the-fold content in a `<style>` in the `<head>` and defer the rest of the stylesheet.
- Load every non-critical script with `async` or `defer`, so JavaScript does not block the parser. Use `defer` for scripts that depend on the DOM or on each other, and `async` for independent scripts. Prefer `type="module"` for modern JavaScript; module scripts are deferred by default, so they need no `defer` attribute, though independent module scripts can take `async`.
- Split CSS by media query with the `media` attribute on `<link>`, so stylesheets that do not apply (print styles, desktop styles on mobile) still download but do not block rendering.
- Add `preconnect` or `dns-prefetch` hints for essential third-party origins, such as font services or API endpoints, so connections (including TLS handshakes) are set up early.

Avoid:

- `@import` in CSS. It creates sequential request chains that delay construction of the CSS Object Model (CSSOM).
- Large, non-critical JavaScript in the `<head>`. A blocking script there halts DOM construction until it has downloaded, parsed and run.
- Shipping unreachable CSS or JavaScript. Have build tools tree-shake and minify CSS to drop unreachable code before deployment.

```html
<!-- Critical styles inlined in the head. -->
<style>
  body { margin: 0; font-family: system-ui; }
  .hero { min-height: 100vh; }
</style>

<!-- Non-critical CSS, deferred. -->
<link rel="preload" href="non-critical.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="non-critical.css"></noscript>

<!-- CSS that applies only at certain viewport sizes. -->
<link rel="stylesheet" href="mobile.css" media="(max-width: 768px)">

<!-- Deferred JavaScript. -->
<script defer src="app-bundle.js"></script>
```

### Resource hints

| Hint | Use | Examples |
| :--- | :--- | :--- |
| `preconnect` | Set up DNS and TLS for known third-party origins | API endpoints, font services |
| `dns-prefetch` | Lighter fallback for non-critical third-party origins | Ad servers, analytics |
| `preload` | Same-origin asset needed now for rendering | Hero images, render-blocking fonts |
| `prefetch` | Assets for the next navigation | Next-page bundle, detail views |

In short: preconnect for origins, preload for the current viewport, prefetch for future pages.

## Largest Contentful Paint (LCP) and resource fetching

LCP measures the time to render the largest visible image or text block in the viewport. Improve it by prioritizing visible elements.

Do:

- Put the LCP image in the HTML response so the preload scanner finds it immediately. Prefer an `<img>` element; use `<link rel="preload" as="image">` when the image is loaded by JavaScript or CSS. Do not let JavaScript or CSS be the only reference to the image.
- Add `fetchpriority="high"` to the LCP image. Browsers initially hold back image downloads while they fetch render-blocking CSS and JavaScript and lay out the page to find which images are in the viewport. `fetchpriority="high"` tells them to start the LCP image earlier. Put it on the `<img>` (`<img fetchpriority="high">`) and on any preload (`<link rel="preload" as="image" fetchpriority="high">`).
- Add `fetchpriority="low"` to large images or carousels that are not the LCP element and are not in the initial viewport but may still be downloaded because they are near it or hidden with CSS (for example a carousel using `overflow: scroll`). Low-priority images still download, but after the higher-priority resources the browser has queued.
- Add `loading="lazy"` to images, iframes, and video and audio elements far outside the initial viewport, so they are not fetched at all until they are in or near the viewport (the distance depends on browser heuristics and connection).

Avoid:

- Lazy-loading the LCP image, or any above-the-fold image. `loading="lazy"` delays the fetch until layout is done, which badly hurts LCP.
- Overusing `fetchpriority="high"`. Priority is zero-sum: raising too many resources creates contention and cancels the benefit.
- Complex JavaScript loaders for the hero section. Rendering the LCP element on the client adds a long request chain (HTML, then JavaScript, then execution, then the image request).

```html
<!-- LCP image. -->
<img
  src="/images/hero.webp"
  alt="Hero Product"
  fetchpriority="high"
  width="1200"
  height="600"
>

<!-- Preload for an LCP background image set in CSS. -->
<link rel="preload" as="image" href="/images/bg-hero.webp" fetchpriority="high" type="image/webp">

<!-- Offscreen carousel image that is not the LCP element. -->
<img src="/images/carousel-2.webp" fetchpriority="low" loading="lazy" alt="Slide 2">
```

## Interaction to Next Paint (INP) and the main thread

INP measures the latency of interactions across the page's whole lifecycle. Poor INP comes from long JavaScript tasks blocking the main thread.

Do:

- Split any JavaScript execution longer than 50ms, yielding to the main thread often so the browser can handle pending input.
- Yield with `scheduler.yield()`, which puts the continuation at the front of the task queue, and fall back to a Promise-wrapped `setTimeout` where it is unsupported.
- Debounce or throttle handlers for rapid events such as `scroll`, `resize` and fast `input`. For work that should run once scrolling stops, listen for `scrollend` instead of debouncing `scroll`.
- Update the UI synchronously for immediate visual feedback, then move heavy computation to a Web Worker or a deferred task.

Avoid:

- Relying only on `setTimeout(..., 0)` for repeated yielding. It puts the continuation at the back of the task queue, which can mean long delays when other tasks are pending. Use `scheduler.yield()` where available.
- Layout thrashing: interleaving DOM reads (`offsetHeight`, `getBoundingClientRect`) and writes (`style.height`) in the same loop. Batch the reads, then batch the writes.
- Heavy polling with `setInterval`, which starves the main thread.

```javascript
// Yield to the main thread, with a fallback.
async function yieldToMain() {
  if ('scheduler' in window && 'yield' in scheduler) {
    return await scheduler.yield();
  }
  return new Promise(resolve => setTimeout(resolve, 0));
}

// Process a large array without blocking input.
async function processLargeList(items) {
  for (let i = 0; i < items.length; i++) {
    processItem(items[i]);

    // Yield every 50 iterations so the browser can render and respond.
    if (i % 50 === 0) {
      await yieldToMain();
    }
  }
}
```

Rule of thumb for main-thread work:

- Under 50ms: run synchronously.
- 50–250ms: slice the task and yield with `scheduler.yield()`.
- Over 250ms: move it to a Web Worker.

## Third-party scripts

Third-party scripts (analytics, ads, chat widgets) are the main source of main-thread congestion.

- Keep third-party scripts from blocking main content: unless one is critical to page load, load it with `defer` near the end of the page rather than in the `<head>`.
- Self-host critical third-party dependencies on your own origin. This saves DNS lookups and lets you control `Cache-Control`.

```html
<!-- Near the end of the page. -->
<script defer src="https://www.example.com/third-party.js"></script>
```

## CSS rendering and containment

Rendering involves style, layout, paint and compositing work. CSS containment limits the scope of that work, which helps on large, complex pages where it causes performance problems.

Do:

- On large, complex pages, put `content-visibility: auto` on off-screen sections. The browser skips layout and paint for those subtrees until they approach the viewport.
- Pair `content-visibility` with `contain-intrinsic-size`. The placeholder width or height for unrendered containers prevents layout shifts and scrollbar jumps.
- Derive `contain-intrinsic-size` from the content. Use the `auto` keyword and a value based on what you know about the contents (text size, spacing, graphic sizes, character count). Prefer units that match those used inside the content, such as `rem`, `lh`, `cap` or `ch`, over `px`. If items in a group vary in size, use an average.
- For isolated UI components such as modals or widgets, use `contain: layout style paint` so internal changes do not trigger page-wide reflows.

Avoid:

- `content-visibility: auto` on small, simple pages. The gain is negligible and content may jump.
- `content-visibility: auto` on above-the-fold content. The browser still renders it, and the containment only adds slight overhead.
- Applying `will-change` widely. `will-change: transform` on many elements uses excessive GPU memory, causing GPU crashes or sluggish rendering.
- Forgetting accessibility when hiding elements. `content-visibility: auto` keeps off-screen elements in the DOM for screen readers, so they are not hidden from assistive technology; some setups may still skip them until focus moves inside, so test keyboard navigation. Only if content should truly be hidden from assistive technology while off-screen, manage `aria-hidden` yourself.

```css
/* Long list of articles below the fold. */
.article-list-item {
  content-visibility: auto;
  contain-intrinsic-size: auto 600px;
}

.row {
  --row-gap: .4rem;
  --title-height: 1lh;
  --description-height: 0.85lh;

  display: grid;
  row-gap: var(--row-gap);
  content-visibility: auto;
  /* Title height + row gap + description height approximates the content
     size while rendering is skipped. */
  contain-intrinsic-block-size: auto calc(var(--title-height) + var(--row-gap) + var(--description-height));
}

/* Isolate a complex widget to prevent layout thrashing. */
.isolated-widget {
  contain: layout style paint;
}

/* Promote to a compositor layer only on hover. */
.interactive-button:hover {
  will-change: transform;
  transform: scale(1.05);
}
```

## Images and media

Images are usually the largest payload on a page. Optimize them with format negotiation, responsive sizing and reserved layout space.

Do:

- Serve modern formats with `<picture>`: AVIF or JPEG XL (best compression), then WebP, then JPEG or PNG for older browsers.
- Set `width` and `height` so the browser knows the aspect ratio immediately, reserves space and avoids CLS. Dimensions can be HTML attributes or CSS properties.
- Use `loading="lazy"` on all below-the-fold images, to defer requests for images outside the initial viewport.
- Use `srcset` and `sizes` to serve resolutions suited to screen density and viewport width, so mobile devices do not download desktop-sized images.

Avoid:

- Lazy-loading above-the-fold images; it directly hurts LCP. Visible images should load eagerly, which is the default; omit the `loading` attribute rather than writing `loading="eager"`.
- Omitting dimensions on lazy-loaded images; it causes layout shifts.
- Using `srcset` without `sizes`. The browser then assumes `100vw` and downloads the largest image.

```html
<picture>
  <source type="image/avif" srcset="hero-400w.avif 400w, hero-800w.avif 800w" sizes="(max-width: 600px) 100vw, 50vw">
  <source type="image/webp" srcset="hero-400w.webp 400w, hero-800w.webp 800w" sizes="(max-width: 600px) 100vw, 50vw">

  <!-- Fallback with dimensions and above-the-fold priority. -->
  <img
    src="hero-800w.jpg"
    alt="Descriptive text"
    width="800"
    height="600"
    fetchpriority="high"
  >
</picture>

<!-- Below-the-fold image. -->
<img
    src="footer-icon.png"
    alt="Footer Logo"
    width="100"
    height="100"
    loading="lazy"
>

<!-- Below-the-fold iframe. -->
<iframe src="https://example.com/map" width="800" height="600" loading="lazy" title="Example Map"></iframe>
```

## Service workers and caching

A service worker can serve resources from its cache and skip the network entirely.

Do:

- Use cache-first for static, versioned assets. Immutable files such as fonts and hashed JS/CSS bundles load instantly from the cache.
- Use stale-while-revalidate for dynamic, non-critical resources. For API calls where slight staleness is acceptable, respond from the cache and update it in the background.
- Use network-first for HTML documents, so users always get the latest app shell and manifest and fall back to the cache only when offline.
- Limit cache size and age with expiration rules, so the service worker does not exhaust the device's storage quota.

Avoid:

- Caching opaque responses indiscriminately. Responses from third-party origins without CORS headers are opaque: they use a lot of quota and their failures go unnoticed. Cache them only with network-first or stale-while-revalidate.
- Trying to cache POST requests. The Cache API stores only GET requests; queue offline submissions with background sync instead.
- Skipping asset versioning. Without updated hashes or versions, users stay stuck on stale cached assets.
- `Cache-Control: no-store` on non-sensitive pages. It keeps the page out of the back/forward cache (bfcache), which makes navigation feel much slower. Reserve it for private data; for pages that only need fresh content, use `Cache-Control: no-cache` or `Cache-Control: max-age=0`.

Example with the Workbox library:

```javascript
import { registerRoute } from 'workbox-routing';
import { CacheFirst, StaleWhileRevalidate, NetworkFirst } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';
import { CacheableResponsePlugin } from 'workbox-cacheable-response';

// HTML documents: network first.
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new NetworkFirst({ cacheName: 'pages-cache' })
);

// Static assets (JS, CSS, fonts): cache first. Only status 200 is cached,
// so opaque responses never get pinned in a cache-first cache.
registerRoute(
  ({ request }) => ['style', 'script', 'font'].includes(request.destination),
  new CacheFirst({
    cacheName: 'static-resources',
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 30 * 24 * 60 * 60 })
    ]
  })
);

// API responses: stale while revalidate. Opaque (status 0) responses are
// acceptable here because they are refreshed on every request.
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/v1/content'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] })
    ]
  })
);
```

## Web fonts

Web fonts commonly block rendering. Optimizing them reduces the flash of invisible text (FOIT) and speeds up first render.

Do:

- Preload fonts used above the fold with `<link rel="preload" as="font" type="font/woff2" crossorigin>`. Font preloads always need `crossorigin`, even for same-origin fonts.
- Subset fonts: trim weights and glyphs to the characters your application needs.

Avoid:

- Preloading every font. The contention starves other critical assets.
- `fetchpriority="high"` on fonts. Fonts already load at high priority by default.

```css
@font-face {
  font-family: 'Modern Sans';
  src: url('/fonts/modern-sans.woff2') format('woff2');
}
```

```html
<link rel="preload" href="/fonts/modern-sans.woff2" as="font" type="font/woff2" crossorigin>
```

## Video

Video is among the heaviest assets. Optimize to reduce bandwidth stalls and keep Cumulative Layout Shift (CLS) low.

Do:

- Set `width` and `height` attributes to reserve layout space and prevent CLS.
- Provide a lightweight `poster` image to show while the video buffers.
- When the video is the LCP element, preload its poster with `<link rel="preload" as="image" fetchpriority="high">` so it downloads as quickly as possible.
- Use `preload="none"` for non-critical videos, such as below-the-fold or non-autoplaying ones, to delay bandwidth use.
- Offer WebM (better compression) alongside MP4 through `<source>` negotiation.
- Use `loading="lazy"` on offscreen videos, so the `poster` and `preload` downloads wait until the video is in or near the viewport.

Avoid autoplaying video by default, and never autoplay large video files. Wait for user intent before downloading large files, or use progressive enhancement.

```html
<video
  controls
  width="1200"
  height="675"
  poster="/images/video-poster.webp"
  preload="none"
  loading="lazy"
>
  <source src="/videos/intro.webm" type="video/webm">
  <source src="/videos/intro.mp4" type="video/mp4">
  <track src="/video-caps.vtt" kind="captions" srclang="en" label="English">
</video>
```

## JavaScript code splitting

Large monolithic bundles take a long time to parse on low-end devices. Split code so only the bytes needed for the current view are downloaded.

- Split routes and heavy UI libraries with dynamic `import()`.
- Configure your bundler's chunking (for example in Vite or webpack) to separate third-party vendor code from application code.
- Do not ship one huge `app.js` bundle; it increases parse time and memory use for the initial view.

```javascript
// Load a heavy module only when the button is clicked.
document.getElementById('heavy-btn').addEventListener('click', async () => {
  const { heavyFunction } = await import('./heavy-module.js');
  heavyFunction();
});
```
