# Compare and validate web origins and sites

Comparing `event.origin` with a fixed, port-normalized string literal (such as `event.origin === 'https://app.example.com'`) works for a simple allowlist. String comparisons and regular expressions fail when you validate arbitrary URLs, link elements, cross-subdomain redirects or sandboxed messages:

- Prefix and substring spoofing: `url.startsWith('https://app.example.com')` accepts `'https://app.example.com.attacker.example'`.
- Unnormalized URLs: full URLs with paths, query strings or explicit default ports (`'https://app.example.com:443/path'`) do not string-equal `'https://app.example.com'` unless parsed and normalized first.
- Public Suffix List mistakes: splitting hostnames on `.` to decide same-site fails on multi-label public suffixes (such as `.co.uk`) and shared hosting domains (such as `.github.io`), and ignores scheme mismatches (`http:` vs `https:`).
- Opaque `"null"` collisions: sandboxed iframes (`<iframe sandbox="allow-scripts">`) and `data:` URLs serialize `event.origin` as the string `"null"`, so `originA === originB` on two serialized runtime origins treats two unrelated opaque contexts as equal.

The `Origin` API (`Origin.from()`, `isSameOrigin()`, `isSameSite()` and `opaque`) gives spec-compliant origin and schemeful same-site comparisons backed by the browser's URL parser and Public Suffix List.

## Choosing a comparison

- `isSameOrigin()` for strict privilege boundaries. Require an exact (scheme, host, port) match when handling cross-window `postMessage` commands (such as from an embedded checkout or auth popup) or deciding whether to attach credentials. A different subdomain (`https://blog.example.com` vs `https://app.example.com`) is a different origin and must be rejected, so a vulnerability on one subdomain cannot control another.
- `isSameSite()` for cross-subdomain navigation and link classification. Accept any subdomain or port with the same scheme and registrable domain when validating post-login redirect URLs (`?returnTo=https://billing.example.co.uk/orders`) or classifying links as internal or external. It rejects `http:` downgrades and sibling tenants on shared public suffixes (`.co.uk`, `.github.io`).
- `origin.opaque` and `Origin.from(event)` for opaque or sandboxed contexts. Reject `data:` URLs as redirect targets (`origin.opaque === true`), or pin the opaque `Origin` from `Origin.from(event)` when talking to a specific `<iframe sandbox="allow-scripts">` widget whose `event.origin` is `"null"`.

## 1. Exact origins for privileged actions: `Origin.from()` and `isSameOrigin()`

Get an `Origin` with `Origin.from()` and compare it with a trusted `Origin` using `isSameOrigin()`.

- Both sides must be `Origin` objects: `isSameOrigin(other)` and `isSameSite(other)` throw `TypeError` when given a string.
- `Origin.from()` accepts:
  - Serialized URL strings (such as `'https://app.example.com:443/path'`). Invalid URL strings, such as `'example'` or the `'null'` that `event.origin` gives for opaque origins, throw `TypeError`.
  - Platform objects that define origin-extraction steps in the HTML specification: `Origin`, `URL`, `HTMLAnchorElement` (`<a>`), `HTMLAreaElement` (`<area>`), a same-origin `Window` or `WorkerGlobalScope` (`Origin.from(self)`), and browser-dispatched `MessageEvent` objects (`Origin.from(event)`).
  - Not `Location`, `WorkerLocation`, `Document`, `Request` or `Response`: these have no origin-extraction steps and throw `TypeError`. Pass `self` (for the current context) or `request.url` / `response.url` instead.
- Browser-dispatched `postMessage` events carry an internal origin that `Origin.from(event)` reads. Synthetic `new MessageEvent('message', { origin })` events (for example in unit tests) only set the `event.origin` string, so `Origin.from(event)` throws on them. Falling back to `Origin.from(event.origin)` inside try/catch handles both, and still rejects invalid or `"null"` strings.

```javascript
// Replace with your application's trusted origin(s)
const TRUSTED_ORIGIN = Origin.from('https://app.example.com');

function extractOrigin(candidate) {
  try {
    return Origin.from(candidate);
  } catch (err) {
    // Synthetic new MessageEvent('message', { origin }) objects in tests lack an
    // internal browser origin; fall back to parsing candidate.origin if it is a URL.
    if (typeof MessageEvent !== 'undefined' && candidate instanceof MessageEvent) {
      return Origin.from(candidate.origin);
    }
    throw err;
  }
}

export function isTrustedSameOrigin(candidate) {
  try {
    return extractOrigin(candidate).isSameOrigin(TRUSTED_ORIGIN);
  } catch {
    // Rejects invalid URLs, "null" strings, or unsupported objects
    return false;
  }
}

window.addEventListener('message', (event) => {
  if (!isTrustedSameOrigin(event)) return;

  // Safe to process privileged commands from the verified origin
});
```

## 2. Cross-subdomain redirects and links: `isSameSite()`

Use `isSameSite()` to validate redirect targets (such as `?returnTo=` parameters) or internal links across subdomains of one registrable domain (for example `https://app.example.co.uk` and `https://billing.example.co.uk:8443`).

- It is a schemeful same-site comparison: `https://sub.example.com` and `http://sub.example.com` are not same-site because the schemes differ.
- It uses the browser's Public Suffix List, so separate tenants on shared public suffixes (`https://tenant-a.github.io` and `https://tenant-b.github.io`, or `https://a.co.uk` and `https://b.co.uk`) compare as `false`.

```javascript
// Replace with your application's primary origin
const APP_ORIGIN = Origin.from('https://app.example.co.uk');

export function isAllowedSameSiteUrl(candidateUrlOrElement) {
  try {
    return extractOrigin(candidateUrlOrElement).isSameSite(APP_ORIGIN);
  } catch {
    return false;
  }
}

// true: same scheme (https) and same registrable domain (example.co.uk)
isAllowedSameSiteUrl('https://billing.example.co.uk:8443/checkout');

// false: scheme downgrade (http vs. https) is rejected by schemeful same-site
isAllowedSameSiteUrl('http://billing.example.co.uk/checkout');
```

## 3. Opaque origins: `origin.opaque` and `Origin.from(event)`

Sandboxed iframes (`<iframe sandbox="allow-scripts">`), `data:` URLs and `new Origin()` produce opaque origins (`origin.opaque === true`). Their serialization is always `"null"`, but `Origin.from(event)` extracts the sender's actual opaque origin from a browser-dispatched `MessageEvent`:

- Two messages from the same sandboxed iframe give `Origin` objects that are `isSameOrigin()` with each other.
- Messages from different sandboxed iframes, and separate `Origin.from('data:...')` or `new Origin()` calls, give distinct opaque origins for which `isSameOrigin()` is `false`. This blocks `"null" === "null"` spoofing between unrelated opaque contexts.
- `new Origin()` creates a fresh opaque origin that matches nothing but itself. It works as a deny-all placeholder until the expected peer origin is pinned once at initialization.

```javascript
// Initialize with a unique opaque sentinel that matches no other origin
let pinnedSandboxOrigin = new Origin();
let isSandboxPinned = false;

export function handleSandboxedWidgetMessage(event, expectedWidgetWindow) {
  try {
    const senderOrigin = Origin.from(event);

    // Pin the opaque origin only once on initialization from the expected sandboxed iframe
    if (!isSandboxPinned && event.source === expectedWidgetWindow && event.data?.type === 'init') {
      pinnedSandboxOrigin = senderOrigin;
      isSandboxPinned = true;
    }

    // Subsequent messages from the SAME sandboxed iframe match pinnedSandboxOrigin;
    // messages from any other sandboxed iframe (also event.origin === "null") return false.
    return senderOrigin.isSameOrigin(pinnedSandboxOrigin);
  } catch {
    return false;
  }
}
```

## Rules

- Convert both sides to `Origin` objects with `Origin.from()` before calling `isSameOrigin(other)` or `isSameSite(other)`.
- Pass a browser-dispatched `MessageEvent` straight to `Origin.from(event)` when opaque-origin identity matters. Get the current context's origin with `Origin.from(self)`; `Location` and `Document` throw `TypeError`.
- Wrap `Origin.from()` on untrusted or runtime input in try/catch, so invalid URLs, `"null"` strings or unsupported objects return `false` instead of throwing an uncaught `TypeError`.
- Never compare two runtime `event.origin` or `url.origin` strings directly without first rejecting `"null"` (`origin !== 'null'`), because two unrelated opaque origins both serialize to `"null"`.
- Never validate origins or sites with `startsWith()`, `includes()`, `endsWith()` or `.split('.')` hostname slicing.

## Browser support and fallback

Browser support for Origin: Limited availability.
Supported by: Chrome 145 (Feb 2026), Edge 145 (Feb 2026), and Safari 26.5 (May 2026).
Unsupported in: Firefox.

If your Baseline target includes browsers without the `Origin` interface, feature-detect with `'Origin' in globalThis` and fall back to parsing with `new URL()`:

- Same-origin (tuple origins): get the URL string (`event.origin` for a `MessageEvent`, `candidate.href` for a link element), parse the candidate and the trusted URL with `new URL()`, reject `"null"` (`candidateUrl.origin !== 'null'`), and compare `candidateUrl.origin === trustedUrl.origin`. An opaque origin is never same-origin with a tuple origin such as `'https://app.example.com'`, so rejecting `'null'` outright matches `isSameOrigin()`.
- Same-site (caveat): `URL` does not expose the Public Suffix List. Without `Origin`, only suffix-match against an explicit, known private registrable domain you control (checking both `protocol` and an exact or dot-prefixed `hostname` match), or use a maintained Public Suffix List library.
- Opaque or sandboxed iframes: without `Origin`, `MessageEvent` exposes no distinct opaque identity (`event.origin` is always `"null"`). To accept messages from a known `<iframe sandbox="allow-scripts">`, check `event.source === expectedWidgetWindow`, or communicate over a dedicated `MessageChannel` port transferred to the iframe at initialization, instead of comparing `event.origin`.

```javascript
// Replace with your trusted reference URL and known registrable domain
const TRUSTED_URL = 'https://app.example.com';
const TRUSTED_SITE_DOMAIN = 'example.com';

function extractUrlString(candidate) {
  if (typeof candidate === 'string') return candidate;
  if (typeof MessageEvent !== 'undefined' && candidate instanceof MessageEvent) {
    return candidate.origin;
  }
  if (candidate === globalThis) {
    return globalThis.location?.href ?? '';
  }
  return candidate?.href ?? '';
}

// extractOrigin() is the helper defined in section 1.

export function checkSameOriginWithFallback(candidate) {
  try {
    if ('Origin' in globalThis) {
      return extractOrigin(candidate).isSameOrigin(Origin.from(TRUSTED_URL));
    }
    const candidateUrl = new URL(extractUrlString(candidate));
    const trustedUrl = new URL(TRUSTED_URL);
    return candidateUrl.origin !== 'null' && candidateUrl.origin === trustedUrl.origin;
  } catch {
    return false;
  }
}

export function checkSameSiteWithFallback(candidate) {
  try {
    if ('Origin' in globalThis) {
      return extractOrigin(candidate).isSameSite(Origin.from(TRUSTED_URL));
    }
    const candidateUrl = new URL(extractUrlString(candidate));
    const trustedUrl = new URL(TRUSTED_URL);
    return (
      candidateUrl.origin !== 'null' &&
      candidateUrl.protocol === trustedUrl.protocol &&
      (candidateUrl.hostname === TRUSTED_SITE_DOMAIN ||
        candidateUrl.hostname.endsWith(`.${TRUSTED_SITE_DOMAIN}`))
    );
  } catch {
    return false;
  }
}
```
