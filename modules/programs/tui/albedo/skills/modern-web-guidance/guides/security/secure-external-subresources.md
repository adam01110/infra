# Secure external subresources with Subresource Integrity, CORS, and Referrer Policy

When loading scripts, stylesheets, fonts or images from third-party CDNs or other origins, verify their integrity with Subresource Integrity (`integrity` in HTML, `integrity()` in CSS `url()`), set cross-origin credential handling (`crossorigin`, `cross-origin()`), and limit the outgoing `Referer` header (`referrerpolicy`, `referrer-policy()`). For document-level Content Security Policy and outbound connection allowlists, see the `security` and `restrict-outbound-connections` guides.

## 1. Generate integrity digests for immutable assets

With Subresource Integrity (SRI), the browser executes or renders an external asset only if its bytes match the hash your application declares.

- Compute digests at build or release time from known-good local asset bytes (or copy the official digest the package author publishes) and hardcode them into your HTML, CSS or JavaScript. Never fetch a third-party URL in the browser at runtime to compute its `integrity` hash: that trusts whatever bytes the remote server returns and defeats SRI.
- Format integrity metadata as `<algorithm>-<base64-digest>`, with `sha384-` by default, or `sha512-` or `sha256-`.
- Reference third-party assets by immutable, version-pinned or content-addressed URLs (such as `https://cdn.example.com/ui@2.4.0/app.min.js`), not floating URLs (`latest/app.min.js`). Floating URLs expose the site to silent supply-chain changes and break SRI as soon as the remote file changes. If you must load a third-party script that updates in place (such as a vendor analytics tag), omit `integrity` on that URL and restrict it with Content Security Policy (`strict-dynamic` / nonces) or iframe sandboxing instead.
- Every browser that supports SRI implements `sha256-`, `sha384-` and `sha512-`. If a URL can legitimately return one of several known-good payloads (an A/B test, a staged CDN rollout, a content-negotiated build), list several digests of the same algorithm separated by whitespace (`integrity="sha384-variantA... sha384-variantB..."`). The browser accepts the response if it matches any listed digest of the strongest algorithm present.
- Serve cross-origin subresources with CORS headers. The browser can only verify a cross-origin response that is CORS-readable: `Access-Control-Allow-Origin: *` for anonymous requests, or the exact requesting origin plus `Access-Control-Allow-Credentials: true` for credentialed ones.

```bash
# Generate a sha384- SRI hash at build time from a known-good local file
printf "sha384-%s\n" "$(openssl dgst -sha384 -binary app.min.js | openssl base64 -A)"
```

```javascript
// Build-time helper (Node.js 19+, Deno, Bun): SRI string from known-good local bytes.
export async function computeIntegrityMetadata(bytes) {
  const rawBytes =
    typeof bytes === 'string' ? new TextEncoder().encode(bytes) : bytes;
  const digestBuffer = await crypto.subtle.digest('SHA-384', rawBytes);
  const binary = Array.from(new Uint8Array(digestBuffer), (b) =>
    String.fromCharCode(b),
  ).join('');
  return `sha384-${btoa(binary)}`;
}
```

## 2. HTML scripts, stylesheets and preloads

As a baseline, set a document-level `Referrer-Policy: strict-origin-when-cross-origin` response header (or `<meta name="referrer" content="strict-origin-when-cross-origin">` in `<head>`), so any subresource or CSS `url()` without its own referrer setting still drops the path and query on cross-origin requests.

On external `<script>`, `<link rel="stylesheet">`, `<link rel="preload">` and `<link rel="modulepreload">` elements, set `integrity`, `crossorigin` and `referrerpolicy` together:

- `integrity="sha384-..."` blocks executing or applying the resource if its bytes do not match. For a blocked `<link rel="stylesheet">`, `linkElement.sheet` stays `null` and an `error` event fires.
- `crossorigin="anonymous"` (the default choice for public CDN assets) or `crossorigin="use-credentials"` is required whenever `integrity` is set on a cross-origin resource. Without `crossorigin`, the browser fetches in `no-cors` mode, gets an opaque response it cannot hash-verify, and blocks the resource.
- `referrerpolicy="no-referrer"` (the default choice for third-party CDNs) or `referrerpolicy="strict-origin-when-cross-origin"` overrides the document policy so no origin or path information leaks to the third-party host in the `Referer` header.

```html
<!-- Document-level baseline referrer policy in <head> (or via Referrer-Policy HTTP header) -->
<meta name="referrer" content="strict-origin-when-cross-origin" />

<!-- External stylesheet with SRI, anonymous CORS, and no referrer -->
<link
  rel="stylesheet"
  href="https://cdn.example.com/ui@2.4.0/styles.css"
  integrity="sha384-bs0EksOYBbU/g0IAHMXbSyH1Mgw83GKn+EZlSI+VE+zVchXmSbLwhVLrPzsOWnc5"
  crossorigin="anonymous"
  referrerpolicy="no-referrer"
/>

<!-- External script with SRI, anonymous CORS, and no referrer -->
<script
  src="https://cdn.example.com/ui@2.4.0/bundle.min.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous"
  referrerpolicy="no-referrer"
></script>
```

When fetching external subresources with `fetch()`, pass matching `integrity`, `mode`, `credentials` and `referrerPolicy` options. A digest mismatch rejects the promise with `TypeError`.

```javascript
const response = await fetch('https://cdn.example.com/ui@2.4.0/manifest.json', {
  integrity: 'sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC',
  mode: 'cors',
  credentials: 'omit',
  referrerPolicy: 'no-referrer',
});
```

## 3. CSS images, fonts and imports: `url()` modifiers

The CSS `url()` request modifiers `cross-origin()`, `referrer-policy()` and `integrity()` set the fetch mode, the referrer and SRI verification for resources loaded from CSS, including `background-image`, `content`, `mask-image`, `border-image-source`, `filter`, `@font-face` `src` and `@import`.

| Modifier | Argument and allowed values | Purpose |
|---|---|---|
| `cross-origin(<ident>)` | Unquoted keyword: `anonymous` (default choice) or `use-credentials` | Fetches the resource with CORS and controls whether credentials are sent. Include it with `integrity()` on cross-origin resources. |
| `referrer-policy(<ident>)` | Unquoted keyword: `no-referrer` (default choice for third-party assets), `strict-origin-when-cross-origin`, `origin`, `same-origin`, `strict-origin`, `origin-when-cross-origin`, `no-referrer-when-downgrade` or `unsafe-url` | Overrides the document referrer policy for this request. |
| `integrity("<string>")` | Quoted string: `"sha384-<base64>"`, or space-separated digests `"sha384-... sha384-..."` | Checks the fetched resource against the expected digest before rendering or applying it. |

Syntax and security rules:

- The URL inside `url(...)` must be a quoted string; unquoted URLs cannot take modifiers.
- Each modifier type may appear at most once per `url()`, in any order. Repeating one (such as two `integrity()` modifiers) is invalid; put multiple hashes space-separated in a single `integrity("sha384-... sha384-...")`.
- Pair cross-origin `integrity()` with `cross-origin(anonymous)`. `@font-face` `src` and `mask-image` already fetch in anonymous `cors` mode, but `background-image`, `content`, `border-image-source` and `@import` default to `no-cors` (an opaque response that cannot be hash-verified), and an external SVG `filter` defaults to `same-origin` mode, which blocks cross-origin URLs outright. `cross-origin(anonymous)` (or `cross-origin(use-credentials)`) gives consistent CORS verification across all properties.
- In `@import` and `@font-face`, keep `cross-origin()`, `referrer-policy()` and `integrity()` inside `url("..." ...)`, and font descriptors such as `format("woff2")` and `tech(...)` outside it.

```css
@import url(
  "https://cdn.example.com/theme@1.2.0/tokens.css"
  cross-origin(anonymous)
  referrer-policy(no-referrer)
  integrity("sha384-bs0EksOYBbU/g0IAHMXbSyH1Mgw83GKn+EZlSI+VE+zVchXmSbLwhVLrPzsOWnc5")
);

@font-face {
  font-family: "BrandSans";
  src: url(
    "https://cdn.example.com/fonts@1.0.0/brand-sans.woff2"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
    integrity("sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
  ) format("woff2");
  font-display: swap;
}

.verified-graphic {
  background-image: url(
    "https://cdn.example.com/media@1.0.0/badge.svg"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
    integrity("sha384-Iw/0p59dP96nGTzHvf2XIfqcBwBW7RM6JfOij8uZxyg5azfNaOOUW8SQy6H/hU91")
  );
}
```

## Browser support and fallback

Browser support for cross-origin() for url(): Limited availability.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), and Safari 26.2 (Dec 2025).
Unsupported in: Firefox.

Browser support for referrer-policy() for url(): Limited availability.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), and Safari 26.2 (Dec 2025).
Unsupported in: Firefox.

Browser support for integrity() for url(): Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

If your Baseline target lacks the CSS `url()` modifiers, combine document-level policies with cascading CSS declarations so subresources keep working and stay protected:

1. When SRI must hold in every browser, load stylesheets with `<link rel="stylesheet" href="..." integrity="sha384-..." crossorigin="anonymous" referrerpolicy="no-referrer">` instead of `@import`. `integrity` and `referrerpolicy` on `<link rel="stylesheet">` are widely available.
2. Rely on the document-level `Referrer-Policy: strict-origin-when-cross-origin` header or `<meta name="referrer">` from section 2. In browsers without `referrer-policy()` in `url()`, it still strips the path and query from cross-origin CSS requests.
3. Cascade separate declarations for progressive enhancement. A browser that does not recognize a modifier inside `url("..." ...)` drops the whole declaration at parse time. Declare a plain `url("...")` first, then one with `cross-origin()` and `referrer-policy()` (for browsers that support those but not `integrity()`), then the full one with `integrity("sha384-...")`.
   - Never put an unverified `url()` in the same comma-separated `@font-face` `src` list. In `src: url("font.woff2" cross-origin(anonymous) integrity("sha384-...")), url("font.woff2");`, a tampered font that fails `integrity()` counts as a load failure, and the browser falls back to the second, unverified `url("font.woff2")`, bypassing SRI. With separate `src:` declarations, supporting browsers overwrite the unverified one at parse time and block tampered fonts at runtime.

```css
@font-face {
  font-family: "BrandSans";
  /* 1. Browsers without url() modifier support. */
  src: url("https://cdn.example.com/fonts@1.0.0/brand-sans.woff2") format("woff2");
  /* 2. Browsers with cross-origin() and referrer-policy() only. */
  src: url(
    "https://cdn.example.com/fonts@1.0.0/brand-sans.woff2"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
  ) format("woff2");
  /* 3. Full protection where integrity() is also supported. */
  src: url(
    "https://cdn.example.com/fonts@1.0.0/brand-sans.woff2"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
    integrity("sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC")
  ) format("woff2");
  font-display: swap;
}

.verified-graphic {
  background-image: url("https://cdn.example.com/media@1.0.0/badge.svg");
  background-image: url(
    "https://cdn.example.com/media@1.0.0/badge.svg"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
  );
  background-image: url(
    "https://cdn.example.com/media@1.0.0/badge.svg"
    cross-origin(anonymous)
    referrer-policy(no-referrer)
    integrity("sha384-Iw/0p59dP96nGTzHvf2XIfqcBwBW7RM6JfOij8uZxyg5azfNaOOUW8SQy6H/hU91")
  );
}
```

4. Feature-detect `url()` modifier support in JavaScript with `CSS.supports()`:

```javascript
export function getCssUrlModifierSupport() {
  const supportsCrossOriginAndReferrer =
    typeof CSS !== 'undefined' &&
    typeof CSS.supports === 'function' &&
    CSS.supports(
      'background-image',
      'url("https://example.com/a.svg" cross-origin(anonymous) referrer-policy(no-referrer))',
    );

  const supportsUrlIntegrity =
    typeof CSS !== 'undefined' &&
    typeof CSS.supports === 'function' &&
    CSS.supports(
      'background-image',
      'url("https://example.com/a.svg" cross-origin(anonymous) referrer-policy(no-referrer) integrity("sha384-Iw/0p59dP96nGTzHvf2XIfqcBwBW7RM6JfOij8uZxyg5azfNaOOUW8SQy6H/hU91"))',
    );

  return { supportsCrossOriginAndReferrer, supportsUrlIntegrity };
}
```
