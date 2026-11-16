# Out-of-Order (OOO) HTML Streaming

Out-of-order HTML streaming, also called Declarative Partial Updates, replaces strictly top-to-bottom HTML processing. You define placeholders early in a document and patch them with content that arrives later in the same network stream, or through new imperative JavaScript streaming APIs.

## Overview

There are two mechanisms:

1. Declarative patching (HTML): processing instructions (`<?marker>`, `<?start>`, `<?end>`) and `<template for>` swap content into the DOM as it streams in from the server.
2. Imperative setting and streaming (JavaScript): methods such as `streamHTML()` and `setHTMLUnsafe()` set HTML on, or pipe readable streams into, DOM elements with native performance and optional script execution.

## Guidelines

- Stream critical UI first: header, hero, primary navigation and primary content. Use placeholders for expensive or lower-priority components such as comments, ads or related content.
- Wrap fallback content (loading states) in `<?start>` and `<?end>`. The browser replaces everything between them when the matching `<template for>` arrives.
- Give placeholders stable dimensions to minimize Cumulative Layout Shift (CLS). If the final size is unknown, reserve space with skeleton screens or CSS `aspect-ratio`.

## Accessibility

Out-of-order updates can confuse screen reader users, people with cognitive impairments, and people who navigate without a mouse or touch. Make sure focus is not lost when a placeholder containing the active element is replaced.

When content takes a noticeably long time to stream, provide text progress information, such as a "Loading..." message in a live region, so people do not think the page is broken.

Announcing every change while content streams is disruptive and irritating, so:

- Put the live region only on the container of the progress text. If the whole content is in a live region, screen readers announce all of the patched content when streaming finishes, which overwhelms users.
- Do not use `role="alert"` for progress information. Some screen readers, such as NVDA, say "Alert" before the live region text, which is irritating, especially when the content is not an alert.

Choose the approach based on the kind of content being streamed and the components it fills. For example:

1. Dashboard of several panels: panel content arrives in stages before the main content can be used as a whole, and some panels take a long time, often a minute or more. A live region notification is needed. Set `aria-busy="true"` on the container of the affected panels so screen reader users know the content is not ready, and set it to `false` when streaming completes.
   - Do not nest the live region inside a panel with `aria-busy="true"`; screen readers would not announce it until all content has loaded.
   - Keep focus where it is during loading. Do not move it to the content while it loads or when loading completes.
2. Single-page application: the app is one HTML document, and activating a link replaces page content by streaming instead of opening a new page. No live region is needed unless the streamed content is slow to render, but move focus to the start of the new content when streaming completes.
3. Product list that streams more items as the user scrolls: the page loads with 10 products, and scrolling adds more. During a short delay a "Loading additional products..." message is shown and then replaced. As in the dashboard case, put the message in a live region, set `aria-busy` on the updating container (resetting it to `aria-busy="false"` when the content has loaded), and keep focus where it is rather than moving it to the new content.
4. Mega menu whose submenu is streamed: whether the submenu streams while collapsed or almost immediately on expansion, it behaves as if it were not streamed. The impact on screen reader users is negligible, so no live region or focus management is needed.
5. Profile widget added to the header after an API call checks login status: the page first shows a "Login" link at the right of the header, which is replaced at once by a profile menu button for logged-in users. The change is barely noticeable, so no live region is needed and focus should not move to the new content.

## Implementation

### 1. Declarative HTML markers

Processing instructions mark where content is patched in.

```html
<!-- Insertion point. -->
<div id="sidebar">
  <?marker name="dynamic-comments">
</div>

<!-- Replacement range with a loading state. -->
<main>
  <?start name="main-content">
    <div class="skeleton" role="status">Loading main content...</div>
  <?end>
</main>

... (other content) ...

<!-- Later in the same stream: the content. -->
<template for="dynamic-comments">
  <div class="comments">...</div>
</template>

<template for="main-content">
  <article>
    <h1>The Real Content</h1>
    <p>This replaces the skeleton div automatically.</p>
  </article>
</template>
```

Once a `<template>` replaces an insertion point, that insertion point is gone and cannot be reused. A `<template>` can, however, contain new insertion points for content later in the stream:

```html
<?start name="replaced-content">
  <div class="skeleton"></div>
<?end>

<!-- Later in the stream: initial content. -->
<template for="replaced-content">
  <?start name="replaced-content">
    <div>Quickly computed result</div>
  <?end>
</template>

<!-- Later still: full content. -->
<template for="replaced-content">
  <?start name="replaced-content">
    <div>Full result</div>
  <?end>
</template>
```

### 2. Imperative JavaScript streaming

There are 24 methods (6 actions, 4 variants each) that update the DOM either from a string or from a stream.

| Action | Static (safe) | Streaming (safe) | Static (unsafe) | Streaming (unsafe) |
| :--- | :--- | :--- | :--- | :--- |
| Set | `setHTML()` | `streamHTML()` | `setHTMLUnsafe()` | `streamHTMLUnsafe()` |
| Replace | `replaceWithHTML()` | `streamReplaceWithHTML()` | `replaceWithHTMLUnsafe()` | `streamReplaceWithHTMLUnsafe()` |
| Before | `beforeHTML()` | `streamBeforeHTML()` | `beforeHTMLUnsafe()` | `streamBeforeHTMLUnsafe()` |
| Prepend | `prependHTML()` | `streamPrependHTML()` | `prependHTMLUnsafe()` | `streamPrependHTMLUnsafe()` |
| Append | `appendHTML()` | `streamAppendHTML()` | `appendHTMLUnsafe()` | `streamAppendHTMLUnsafe()` |
| After | `afterHTML()` | `streamAfterHTML()` | `afterHTMLUnsafe()` | `streamAfterHTMLUnsafe()` |

Safe and unsafe:

- Safe methods (such as `setHTML()`) apply a built-in sanitizer by default that strips dangerous content such as `<script>`. A custom `Sanitizer` passed in the options applies in addition to the default one.
- Unsafe methods (such as `setHTMLUnsafe()`) do not sanitize by default, though you can still pass a custom `Sanitizer`. Scripts in the new content run only if you pass `{ runScripts: true }`. Use unsafe methods only with trusted content, and only where a safe method would not work.

Static and streaming:

- Static methods take a string (or `TrustedHTML`) and apply it immediately.
- Streaming methods return a `WritableStream`. Pipe content into it, for example from a `fetch` response, and the browser renders it incrementally as chunks arrive.

#### Example: streaming a fetch response

This example uses the unsafe variant with `runScripts` because it assumes a trusted, same-origin partial whose scripts must run. For untrusted content, or when scripts are not needed, pipe into `streamHTML()` instead.

```javascript
const main = document.querySelector('main');
const response = await fetch('/api/partial-update');

await response.body
  .pipeThrough(new TextDecoderStream())
  .pipeTo(main.streamHTMLUnsafe({ runScripts: true }));

// Alternatively, textStream() streams text directly, without the
// TextDecoderStream step.
await response
  .textStream()
  .pipeTo(main.streamHTMLUnsafe({ runScripts: true }));
```

## Use cases

- Island architecture: hydrate independent interactive components on top of static HTML without a full framework runtime.
- Deferred expensive blocks: send the page shell immediately and stream database-heavy components as they become available.
- SPA updates: stream large UI transitions with `streamHTML()` instead of waiting for a full JSON payload and building the DOM by hand.

## Pitfalls

- Do not use OOO streaming for everything. Over-fragmenting a page makes the stream more complex and can delay content if the browser spends too long patching small nodes.
- Respect Trusted Types. Where Trusted Types are enforced, pass a sanitized policy object to `*Unsafe` methods if required.
- Do not assume script execution order. Scripts inside a `<template for>` run as soon as they are patched into the document, in no guaranteed order relative to other deferred templates.
- Have a fallback or polyfill strategy. Use `html-setters-polyfill` and `template-for-polyfill` to support your required browsers until the feature is Baseline.

## Browser support and fallback

Browser support for <template for>: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Browser support for HTML setter methods: Limited availability.
Supported by: Chrome 157 (Nov 2026) and Edge 157 (Nov 2026).
Unsupported in: Firefox and Safari.

Despite the support line above, which covers the HTML setter methods as a group, no major browser supports the streaming setters (the `stream*` methods) natively yet. Feature-detect them and use `html-setters-polyfill`.

Browser support for HTML processing instructions: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

The polyfills `template-for-polyfill` and `html-setters-polyfill` emulate the API in unsupported browsers.

Browsers without HTML processing instruction support parse `<?marker>`, `<?start>` and `<?end>` as comments, and `template-for-polyfill` still recognizes those comments as markers. So use the same processing instruction syntax for every browser; do not rewrite the markers as HTML comments or elements for unsupported browsers.
