# Consistent Cross-Document Transitions

Cross-document view transitions animate elements between two pages during a same-origin navigation. The browser snapshots the old page, navigates, then animates from the snapshot to the new page. If the new page hasn't finished loading critical resources (stylesheets, layout scripts, key DOM elements), the transition animates to an incomplete or unstyled state: elements morph to the wrong positions, content reflows mid-animation, or fallback fonts swap to web fonts after the transition.

To prevent this, put `blocking="render"` on critical `<link>` and `<script>` elements in the new page's `<head>`, and use `<link rel="expect">` to block rendering until specific DOM elements have been parsed. The transition then starts only once the new page's visual state is stable. Parsing continues in the background; only painting is deferred.

## Strategy

1. Opt in to cross-document view transitions with the `@view-transition` at-rule on both pages.
2. Keep critical stylesheets in the `<head>`, where they are render-blocking by default. Dynamically injected stylesheets need an explicit `blocking="render"`.
3. Put `blocking="render"` on `<script>` elements that must run before the transition animates, such as scripts that apply a theme or affect layout.
4. Use `<link rel="expect" href="#element-id" blocking="render">` to block rendering until above-the-fold content is parsed. This applies to every transition type: full-page cross-fades (so you don't animate to a blank page), morphs (so named elements exist) and script-dependent layouts (so styled content is parsed).
5. Block only on resources and elements that affect the initial viewport. Blocking on more delays the transition and hurts perceived performance.

## Implementation

### Step 1: Opt in

Both the source and destination pages need the `@view-transition` rule; without it no cross-document transition happens.

```css
/* Include in every participating page. navigation: auto enables transitions for
   standard navigations (link clicks, form submissions, back/forward). */
@view-transition {
  navigation: auto;
}

/* Turn the transitions off for users who prefer reduced motion. */
@media (prefers-reduced-motion: reduce) {
  @view-transition {
    navigation: none;
  }
}
```

### Step 2: Block rendering until critical scripts run

If a non-blocking script in the `<head>` must run before the transition animates (for example to apply a theme class or affect layout), add `blocking="render"`. Otherwise `async`, `defer` or `type="module"` scripts may run after the transition has started.

```html
<head>
  <script type=module blocking="render">
    // Apply the stored theme before rendering so the snapshot shows the right theme.
    document.documentElement.dataset.theme =
      localStorage.getItem('theme') || 'light';
  </script>
</head>
```

### Step 3: Block rendering until key DOM elements are parsed

Stylesheets and `blocking="render"` scripts in the `<head>` only guarantee that the `<head>` has been processed. They don't wait for any `<body>` content, so the browser may snapshot the new page before above-the-fold elements exist and animate to a blank or partial page.

`<link rel="expect">` blocks rendering until a specific element has been parsed. Its `href` is a fragment (for example `#hero`) matching the element's `id`; once that element's closing tag is parsed, the block is released. It only guarantees that the element exists in the DOM; it doesn't wait for subresources such as `<img>` pixels to download or decode.

Use it in each of these cases.

#### Full-page cross-fade

Even with no `view-transition-name` on individual elements, the default `root` transition cross-fades the whole page. If the new snapshot is taken before above-the-fold content is parsed, the fade goes to a blank or incomplete page. Block on an element that marks the end of the visible above-the-fold content.

```html
<head>
  <link rel="stylesheet" href="/css/styles.css">

  <!-- Wait for the main content even for a plain cross-fade, so the snapshot
       isn't taken before visible content exists. -->
  <link rel="expect" href="#main-content" blocking="render">
</head>
<body>
  <header>...</header>
  <main id="main-content">
    <h1>Page Title</h1>
    <p>Above-the-fold content the user should see immediately.</p>
  </main>
  <!-- Content below the fold doesn't need to block. -->
  <section>...</section>
</body>
```

#### Morphs between specific elements

Elements with the same `view-transition-name` on both pages morph across the navigation. If the target element hasn't been parsed when the transition starts, the browser can't find it and the morph degrades to separate exit and entry animations. Block until the named element is parsed.

Because `<link rel="expect">` doesn't wait for image data, an uncached `<img>` may be captured as an empty rectangle. To avoid blank snapshots or layout shifts in image morphs, preload or pre-decode critical transition images (for example `<link rel="preload" as="image">`, or prerender the destination page), and give images explicit sizing (`width` and `height` attributes or CSS `aspect-ratio`) plus a placeholder background color.

```html
<head>
  <link rel="stylesheet" href="/css/styles.css">

  <!-- Preload so the image can decode before the snapshot;
       rel="expect" waits only for the element, not its pixels. -->
  <link rel="preload" as="image" href="/img/product.webp" fetchpriority="high">

  <!-- Wait until the morphing element is parsed; otherwise the morph
       can degrade to a fade-out/fade-in. -->
  <link rel="expect" href="#hero" blocking="render">

  <!-- With several blocking="render" resources, rendering waits for all of them:
       here both the script and #hero, whichever finishes last. -->
  <script async blocking="render" src="/js/transition-setup.js"></script>
</head>
<body>
  <header>...</header>
  <section id="hero">
    <h1 style="view-transition-name: page-title">Product Name</h1>
    <!-- Explicit dimensions give the snapshot the right box even while decoding. -->
    <img
      style="view-transition-name: hero-image"
      src="/img/product.webp"
      width="800"
      height="600"
      alt="Product"
    >
  </section>
</body>
```

### Step 4: Responsive render blocking

Different viewport sizes show different amounts of content above the fold. Use the `media` attribute on `<link rel="expect">` to block only on what is visible at a given width.

```html
<head>
  <!-- Narrow screens show only the hero at first; wide screens also show the sidebar. -->
  <link
    rel="expect"
    href="#hero"
    blocking="render"
    media="screen and (width <= 768px)"
  >
  <link
    rel="expect"
    href="#sidebar"
    blocking="render"
    media="screen and (width > 768px)"
  >
</head>
```

### Step 5 (optional): `pagereveal` for context-dependent transitions

The render-blocking strategy doesn't need `pagereveal`. You only need it when `view-transition-name` values depend on where the user came from, for example morphing a specific list item into a detail-page heading. If names are static in CSS, or you only use the default cross-fade, skip this step.

The listener must be registered before the page renders, or the event may already have fired (as it can with a deferred script). Inline small setup scripts with `blocking="render"` to avoid an extra network round trip on cold loads, or use an external `async` script with `blocking="render"`, which registers the listener early without blocking HTML parsing.

```html
<head>
  <script async blocking="render" src="/js/transition-setup.js"></script>
</head>
```

```javascript
// transition-setup.js
window.addEventListener('pagereveal', async (event) => {
  if (!event.viewTransition) return;

  const from = navigation.activation?.from;
  if (!from) return;

  const fromUrl = new URL(from.url);

  // Assign the name from the navigation context, so the product card on the
  // list page morphs into the heading on the detail page.
  if (fromUrl.pathname === '/products/') {
    const heading = document.querySelector('main h1');
    if (!heading) return;

    heading.style.viewTransitionName = 'product-title';

    try {
      await event.viewTransition.ready;
    } catch (error) {
      // A skipped view transition rejects `ready` with InvalidStateError.
      if (error.name !== 'InvalidStateError') {
        throw error;
      }
    } finally {
      // Remove the temporary name when the transition finishes. Stale names
      // interfere with later navigations and keep the page out of the bfcache.
      await event.viewTransition.finished;
      heading.style.viewTransitionName = '';
    }
  }
});
```

## Practices

- Assign `view-transition-name` in CSS where possible. Use JavaScript (`pagereveal`) only when the name depends on navigation context.
- Keep render-blocking scripts small and fast. After a built-in timeout of about 4 seconds the browser skips the transition entirely, and if a transition was started, `viewTransition.ready` rejects with an `InvalidStateError`.
- Don't use `<link rel="expect">` on elements deep in the page that aren't in the initial viewport; it delays the transition for no visual gain.
- Don't mark analytics, ad-network, tag-manager or other third-party loaders `blocking="render"`, even if they inject content into the initial viewport. Their network latency counts toward the timeout, and their output isn't part of the page's stable state.
- Don't give the same `view-transition-name` to several elements on a page. Duplicate names make the whole transition skip.
- Consider assistive technology timing. `blocking="render"` delays initial paint and visual updates. That avoids glitches for sighted users but can delay processing or initialization for screen readers and other assistive technology that depends on the rendered accessibility tree. Weigh visual continuity against that delay for non-visual users, and keep render-blocking scripts minimal and highly optimized.
- Every render-blocking resource delays the start of the transition. Minimize render-blocking scripts, use `<link rel="expect">` only for above-the-fold elements, and prerender destination pages with the Speculation Rules API to remove loading delays entirely.
- Temporary `view-transition-name` assignments left in place after a transition can keep the page out of the bfcache. Always remove dynamically assigned names once the transition has finished.

## Fallback strategies

Browser support for Cross-document view transitions: Limited availability.
Supported by: Chrome 126 (Jun 2024), Edge 126 (Jun 2024), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Cross-document view transitions suit progressive enhancement well. Unsupported browsers ignore the `@view-transition` rule and navigate normally. Limited support is not a reason to avoid them.

Every browser that supports cross-document view transitions also supports `blocking="render"` and `<link rel="expect">`, so the render-blocking features need no separate fallback.
