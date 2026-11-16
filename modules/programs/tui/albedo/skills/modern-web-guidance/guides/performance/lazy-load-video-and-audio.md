# Lazy load video and audio

Media elements (`<video>` and `<audio>`) and their resources, such as `<video poster>` images and preloaded metadata, use significant network and storage bandwidth during initial page load. Even with `preload="metadata"` or `preload="none"` on a `<video>`, the browser fetches its `poster` image immediately, and `preload="metadata"` still starts range requests for media headers on every player on the page.

`loading="lazy"` on offscreen `<video>` and `<audio>` elements makes the browser defer all of their network requests, including `poster` downloads, `preload` hints and `autoplay`, until the element is within a browser-calculated distance of the visual viewport.

## How to implement

1. Add `loading="lazy"` to `<video>` and `<audio>` elements below the fold. On above-the-fold media, omit `loading` so it defaults to `eager`.
2. Give every `<video>` explicit integer `width` and `height` attributes (in CSS pixels). An unloaded video defaults to 300×150; without explicit sizing a lazy video may never intersect the visible viewport and so never load, or it shifts the layout (CLS) when it loads.
3. Give every `<audio loading="lazy">` the `controls` attribute. Without browser controls, `<audio>` has no visible box, so it can never intersect the viewport and never loads or autoplays.
4. Coordinate `preload` and `poster`:
   - On `<video loading="lazy">`, both the `poster` fetch and the `preload` behavior (`none`, `metadata` or `auto`) wait until the video approaches the viewport.
   - Pair `loading="lazy"` with `preload="none"` when the user must press play after scrolling to the media, or with `preload="metadata"` when duration and first-frame data should load automatically once the player enters the viewport.
5. Lazy `autoplay`: with `loading="lazy"` and `autoplay` on a muted `<video>` (or an opt-in `<audio controls>`), downloading and playback wait until the element approaches the viewport. Respect `@media (prefers-reduced-motion: reduce)` before autoplaying motion media.

If autoplaying media plays audio for more than 3 seconds, provide a way to pause or stop it, or to change its volume independently, to meet WCAG 1.4.2 Audio Control.

## Example

```html
<!-- Above-the-fold hero video: no loading attribute (defaults to eager),
     so the poster and initial media load immediately. -->
<video
  controls
  width="1280"
  height="720"
  poster="/images/hero-poster.jpg"
  preload="metadata"
>
  <source src="/media/keynote.webm" type="video/webm">
  <source src="/media/keynote.mp4" type="video/mp4">
  <track src="/media/keynote-en.vtt" kind="captions" srclang="en" label="English">
</video>

<!-- Below-the-fold player: integer width and height give the unloaded video
     a box that can intersect the viewport and prevent layout shift. The
     poster and preload="metadata" wait until it is near the viewport. -->
<video
  controls
  loading="lazy"
  width="800"
  height="450"
  poster="/images/tutorial-poster.jpg"
  preload="metadata"
>
  <source src="/media/tutorial.webm" type="video/webm">
  <source src="/media/tutorial.mp4" type="video/mp4">
  <track src="/media/tutorial-en.vtt" kind="captions" srclang="en" label="English">
</video>

<!-- Below-the-fold autoplaying loop: downloading and playback wait until
     the video approaches the viewport. Autoplay needs muted and playsinline. -->
<video
  controls
  loading="lazy"
  autoplay
  loop
  muted
  playsinline
  width="640"
  height="360"
  poster="/images/feature-loop-poster.jpg"
>
  <source src="/media/feature-loop.webm" type="video/webm">
  <source src="/media/feature-loop.mp4" type="video/mp4">
  <track src="/media/feature-loop-en.vtt" kind="captions" srclang="en" label="English">
</video>

<!-- Below-the-fold audio: controls is required, or the lazy <audio> is
     invisible, never intersects the viewport and never loads. -->
<figure>
  <figcaption id="episode-title">Episode 42: Browser Architecture Deep Dive</figcaption>
  <audio
    controls
    loading="lazy"
    preload="metadata"
    src="/media/episode-42.mp3"
    aria-labelledby="episode-title"
    aria-details="episode-transcript"
  ></audio>
  <details id="episode-transcript">
    <summary>View transcript</summary>
    <p>Transcript content for Episode 42...</p>
  </details>
</figure>
```

```javascript
// Stop autoplaying videos when the user prefers reduced motion.
const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');

function syncReducedMotion(prefersReducedMotion) {
  for (const video of document.querySelectorAll('video[autoplay]')) {
    if (prefersReducedMotion) {
      video.removeAttribute('autoplay');
      video.pause();
    }
  }
}

syncReducedMotion(reducedMotionQuery.matches);
reducedMotionQuery.addEventListener('change', (event) => {
  syncReducedMotion(event.matches);
});
```

## Guidelines

- Always set `width` and `height` attributes on `<video>`. Unloaded videos have a 300×150 intrinsic size and never load if they do not intersect a visible part of the page.
- Always include `controls` on `<audio loading="lazy">`. Without it the element is not rendered visibly and never loads or autoplays.
- Do not lazy-load above-the-fold or Largest Contentful Paint (LCP) `<video>` elements; it delays both the `poster` and the video data.
- For eager loading, omit the `loading` attribute rather than writing `loading="eager"`.
- Do not use the `window` `load` event to detect that lazy `<video>` or `<audio>` elements have loaded. It accounts only for eager-loaded media, even when a `loading="lazy"` element starts inside the visual viewport.
- Browsers defer `loading="lazy"` media only when JavaScript is enabled. This is an anti-tracking measure: with scripting disabled, servers could otherwise infer scroll position from media requests.

## Browser support and fallback

Browser support for Lazy-loading media: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

If your Baseline target lacks `loading="lazy"` for `<video>` and `<audio>`, choose between progressive enhancement and an `IntersectionObserver` fallback depending on how strictly bandwidth must be saved.

### Progressive enhancement (recommended default)

Browsers that do not recognize `loading="lazy"` on media ignore it and load according to `preload`. Pairing `loading="lazy"` with `preload="none"` or `preload="metadata"` keeps those browsers from downloading the full media file up front, although they still fetch `<video poster>` images and `preload="metadata"` headers eagerly.

### `IntersectionObserver` fallback

Removing attributes from script is best-effort: a script that runs after parsing may find that `poster`, `preload` or `autoplay` fetches have already started.

When unsupported browsers must also defer `<video poster>` downloads, `preload="metadata"` requests or viewport-triggered playback, feature-detect with `Object.hasOwn(HTMLMediaElement.prototype, 'loading')` and fall back to `IntersectionObserver`:

```javascript
const supportsLazyMedia = Object.hasOwn(HTMLMediaElement.prototype, 'loading');

if (!supportsLazyMedia) {
  const lazyMediaElements = document.querySelectorAll(
    'video[loading="lazy"], audio[loading="lazy"][controls]',
  );

  const mediaObserver = new IntersectionObserver(
    (entries, observer) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;

        const media = entry.target;

        // Restore the deferred attributes once the element is near the viewport.
        if (media.dataset.poster) {
          media.poster = media.dataset.poster;
          delete media.dataset.poster;
        }

        if (media.dataset.preload) {
          media.preload = media.dataset.preload;
          delete media.dataset.preload;
        }

        if ('autoplay' in media.dataset) {
          // Respect reduced motion when restoring autoplay.
          if (!matchMedia('(prefers-reduced-motion: reduce)').matches) {
            media.autoplay = true;
          }
          delete media.dataset.autoplay;
        }

        if (media.dataset.src) {
          media.src = media.dataset.src;
          delete media.dataset.src;
        }

        for (const source of media.querySelectorAll('source[data-src]')) {
          source.src = source.dataset.src;
          delete source.dataset.src;
        }

        media.load();
        observer.unobserve(media);
      }
    },
    // Example distance; adjust for your layout.
    { rootMargin: '200px 0px' },
  );

  for (const media of lazyMediaElements) {
    // Hold back network fetches until intersection.
    if (media.hasAttribute('poster')) {
      media.dataset.poster = media.getAttribute('poster');
      media.removeAttribute('poster');
    }
    if (media.hasAttribute('preload') && media.getAttribute('preload') !== 'none') {
      media.dataset.preload = media.getAttribute('preload');
    }
    if (media.autoplay) {
      media.dataset.autoplay = '';
      media.autoplay = false;
    }
    media.preload = 'none';
    mediaObserver.observe(media);
  }
}
```
