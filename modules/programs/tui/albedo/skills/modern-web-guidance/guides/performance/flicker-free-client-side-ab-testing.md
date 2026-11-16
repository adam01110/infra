# Flicker-Free Client-Side A/B Testing

## The problem

Client-side A/B testing tools load a script that changes the DOM after the browser has started building the page, so users briefly see the original content before it flashes to the variant. The traditional workaround, an "anti-flicker snippet", hides the whole page with `opacity: 0` until the experiment script finishes or a fixed timeout (typically 4 seconds) passes. That gives up progressive rendering, allows accidental clicks on invisible content, and adds unnecessary paint cycles.

## The solution

`blocking="render"` on a `<script>` or `<link>` in the `<head>` blocks rendering, but not parsing, until the resource has been fetched and executed. Experiment scripts get the render-blocking behavior stylesheets have by default: the browser paints nothing until the variant is applied, with no opacity hack, no timeout and no flicker.

### Rules

1. Put the experiment script in the document `<head>` and add `blocking="render"`. Only scripts in the `<head>` can block rendering.
2. Give the script `type="module"` (preferred for inline scripts) or `async` (preferred for external scripts with `src`).
3. Keep the script small and fast. Rendering waits for it, so a large or slow script delays first paint directly.
4. Use `blocking="render"` only for scripts whose output must be visible in the initial render.

## Implementation

### Basic setup

Load the experiment script with both `async` and `blocking="render"`. `async` keeps the script from blocking the parser, so the DOM is built while it downloads. `blocking="render"` keeps the browser from painting until the script has run, so experiment changes are in place before the user sees anything.

```html
<head>
  <script
    src="https://cdn.example.com/experiment-sdk.js"
    async
    blocking="render"
  ></script>
</head>
```

### Experiment-specific styles

For a variant stylesheet, put `blocking="render"` on the `<link>`. Stylesheets in the `<head>` already block rendering, but stylesheets injected dynamically or added by script do not. Use `blocking="render"` when the stylesheet is added dynamically or conditionally by the experiment SDK, or to make the intent explicit.

```html
<head>
  <link
    rel="stylesheet"
    href="https://cdn.example.com/experiment-variant-b.css"
    blocking="render"
  >
</head>
```

### Inline experiment script

If the experiment logic is small enough to inline, for example fetching a configuration and applying DOM changes, use an inline module script with `blocking="render"`. Module scripts are deferred by default and do not block the parser; `blocking="render"` makes rendering wait for them.

```html
<head>
  <script type="module" blocking="render">
    const config = await fetch('/api/experiment?id=homepage-cta')
      .then(res => res.json());

    // CSS rules keyed to this attribute style the variant.
    document.documentElement.dataset.variant = config.variant;
  </script>

  <style>
    /* Control group. */
    .cta-button {
      background-color: blue;
    }

    /* Variant B. */
    [data-variant="b"] .cta-button {
      background-color: green;
    }
  </style>
</head>
```

## Guidelines

- The render-blocking script must execute quickly, since a slow one delays all rendering. Set a performance budget for it, such as under 100ms of execution time.
- Split heavy experiment logic out of the render-blocking script: a small render-blocking stub applies the variant, and heavier tracking or analytics scripts load separately with `async` or `defer` and no `blocking="render"`.
- Signal the active variant with a data attribute on `<html>` or `<body>` and style variants with selectors keyed to it. This avoids direct DOM manipulation in the render-blocking script.
- Do not put `blocking="render"` on analytics, tracking or other non-visual scripts. Only scripts that change what the user sees on first paint should block rendering.
- Do not combine `blocking="render"` with a legacy anti-flicker snippet in browsers that support it. They solve the same problem, and using both adds needless delay; the snippet belongs only in the fallback below.

## Browser support and fallback

Browser support for blocking="render": Limited availability.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Browsers without support ignore the attribute and load the script with its default behavior (`async` in the examples above), which can flicker. To prevent that, add a lightweight anti-flicker snippet that runs only when `blocking="render"` is unsupported, detected by feature test:

```html
<head>
  <script
    src="https://cdn.example.com/experiment-sdk.js"
    async
    blocking="render"
  ></script>

  <script>
    if (!Object.hasOwn(HTMLScriptElement.prototype, 'blocking')) {
      document.documentElement.classList.add('ab-loading');

      // Reveal the page if the experiment script is too slow, so slow
      // connections never get an indefinitely blank page. Match the timeout
      // to your SDK's expected load time.
      setTimeout(() => {
        document.documentElement.classList.remove('ab-loading');
      }, 4000);
    }
  </script>

  <style>
    /* Applied only when blocking="render" is unsupported. */
    .ab-loading {
      opacity: 0 !important;
    }
  </style>
</head>
```

```javascript
// In the experiment SDK's initialization callback, reveal the page.
function onExperimentReady() {
  document.documentElement.classList.remove('ab-loading');
}
```

## Other considerations

1. Performance: `blocking="render"` trades first-paint speed for visual correctness. Monitor Largest Contentful Paint (LCP) and First Contentful Paint (FCP) to make sure the experiment script is not adding too much delay.
2. Third-party reliability: if the SDK is on a third-party CDN, a CDN outage can block rendering entirely. The browser applies its own timeout heuristics, which may be longer than 4 seconds, and there is no developer-controlled timeout for `blocking="render"`. Make sure the provider has strong uptime guarantees.
3. Server-side alternatives: for performance-critical pages, consider server-side A/B testing, where the server renders the right variant directly. It removes flicker without any render-blocking cost. Use client-side `blocking="render"` only when server-side testing is not feasible.
