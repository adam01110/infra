# Sanitizing Untrusted HTML

The native Sanitizer API strips dangerous content (such as `<script>` elements and `on*` attributes) from user-generated HTML before it reaches the DOM.

Client-side sanitization protects only the page that renders the content. If the same content is also rendered elsewhere (other clients, server-rendered pages, emails), sanitize it on the server too, as defence in depth, and keep the server and client rules from conflicting.

## 1. Insert HTML with `setHTML()`

`Element.setHTML()` parses, sanitizes and inserts in one step, so the content is sanitized for the exact context it is inserted into.

```javascript
const untrustedHTML = `
  <p>Hello!</p>
  <script>alert('XSS')</script>
  <img src="x" onerror="alert('XSS')">
  <div onclick="doBadThing()">Click me</div>
`;

const container = document.getElementById('output');

// The default sanitizer removes scripts and event handlers, plus other
// elements and attributes outside its built-in allowlist (such as style).
container.setHTML(untrustedHTML);
```

## 2. Custom Sanitizer configurations

Create a `Sanitizer` to define exactly which elements and attributes are allowed.

With `Element.setHTML()` and `Document.parseHTML()`, all XSS-unsafe elements and attributes are always removed. A custom `Sanitizer` can restrict further but cannot allow those.

```javascript
const mySanitizer = new Sanitizer({
  elements: ["p", "b", "i", "strong", "em"],
  attributes: ["class"],
  replaceWithChildrenElements: ['div']
});

container.setHTML(untrustedHTML, { sanitizer: mySanitizer });
```

Elements not listed in `elements` are removed together with their content. To drop a wrapper element but keep its text, list it in `replaceWithChildrenElements` (as with `div` above), which removes the element and keeps its children.

To allow some XSS-unsafe elements or attributes, use a custom `Sanitizer` with `Element.setHTMLUnsafe()` and `Document.parseHTMLUnsafe()` instead.

## 3. Parse without inserting: `Document.parseHTML()`

`Document.parseHTML()` returns a `Document` sanitized with the default or a custom configuration, so you can inspect or transform the nodes (for example to build a preview or extract text) before inserting them.

Move the resulting nodes into the page. Serializing them to a string and re-parsing with `innerHTML` can reintroduce mutation XSS (mXSS).

```javascript
const rawHTML = '<p>Hello <script>console.log("bad")</script></p>';

const doc = Document.parseHTML(rawHTML);
// doc.body now contains the sanitized nodes: <p>Hello </p>
preview.replaceChildren(...doc.body.childNodes);
```

## Browser support and fallback

Browser support for Sanitizer API: Limited availability.
Supported by: Chrome 146 (Mar 2026), Edge 146 (Mar 2026), and Firefox 148 (Feb 2026).
Unsupported in: Safari.

Where the native API is missing, load a library such as DOMPurify only in that case, so supporting browsers do not download it. Feature-detect with `in` so the check itself works in older browsers.

```javascript
let domPurifyPromise;

function loadDOMPurify() {
  // Code-split with your bundler so DOMPurify is only downloaded when needed.
  domPurifyPromise ??= import('dompurify').then((mod) => mod.default ?? mod);
  return domPurifyPromise;
}

export async function safeSetHTML(el, html) {
  const elements = ['p', 'b', 'i', 'strong', 'em'];
  const attributes = ['class'];

  if ('setHTML' in Element.prototype) {
    // setHTML() accepts a plain configuration object as the sanitizer.
    el.setHTML(html, { sanitizer: { elements, attributes } });
  } else {
    const DOMPurify = await loadDOMPurify();
    el.innerHTML = DOMPurify.sanitize(html, {
      ALLOWED_TAGS: [...elements, '#text'],
      ALLOWED_ATTR: attributes,
      // Match the native Sanitizer: strip aria-*/data-* and disallowed element content.
      ALLOW_ARIA_ATTR: false,
      ALLOW_DATA_ATTR: false,
      KEEP_CONTENT: false
    });
  }
}
```

The DOMPurify options matter because its defaults differ from the native Sanitizer. DOMPurify keeps `aria-*` and `data-*` attributes (even when `ALLOWED_ATTR` is set) and keeps the text content of elements it removes; the native Sanitizer strips `aria-*` and `data-*` and removes disallowed elements together with their content. `ALLOW_ARIA_ATTR: false`, `ALLOW_DATA_ATTR: false`, `KEEP_CONTENT: false` and allowing `#text` make DOMPurify match. DOMPurify has no equivalent of `replaceWithChildrenElements`, so leave that option out of configurations that need a matching fallback.

If the page enforces Trusted Types (`require-trusted-types-for 'script'`), assigning a string to `innerHTML` throws. `setHTML()` needs no Trusted Types policy, but the fallback does: pass `RETURN_TRUSTED_TYPE: true` to `DOMPurify.sanitize()` and allow its `dompurify` policy name in the `trusted-types` CSP directive.
