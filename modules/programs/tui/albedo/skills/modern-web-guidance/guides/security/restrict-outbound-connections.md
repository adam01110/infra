# Restrict outbound network connections with Connection Allowlists

The `Connection-Allowlist` HTTP response header limits a document or worker to an explicit list of network endpoints. Content Security Policy (CSP) needs separate per-resource directives (`connect-src`, `img-src`, `script-src`, `font-src`, `form-action`) and does not cover speculative or non-Fetch channels such as `<link rel="dns-prefetch">`, `<link rel="preconnect">` or WebRTC. `Connection-Allowlist` applies one network-layer allowlist to all outbound connections the context starts: `fetch()`, `XMLHttpRequest`, subresources, `navigator.sendBeacon()`, `<a ping>`, top-level and frame navigations, resource hints, Speculation Rules, `WebSocket`, `WebTransport` and WebRTC.

## How to implement

1. Serialize the allowlist as an RFC 9651 Inner List `(...)`. `Connection-Allowlist` (or `Connection-Allowlist-Report-Only`) is one parenthesized list of space-separated items: the unquoted token `response-origin` to allow the document's or worker's own origin, then a double-quoted `URLPattern` string for every legitimate external endpoint the context connects or navigates to (APIs, image and font CDNs, and outbound `<a href>`, `<form action>`, OAuth or payment redirect targets). When building patterns from configuration or `URL` objects, rewrite `ws:`/`wss:` to `http:`/`https:` and strip the bare trailing slash from origin-only URLs: `new URL('https://api.example.com').href` appends `/`, which restricts `URLPattern` matching to the root path only.
2. Scope by `Sec-Fetch-Dest` and cover workers. Browsers honor `Connection-Allowlist` only on document/navigation responses and worker script responses (`Sec-Fetch-Dest` of `document`, `iframe`, `worker`, `sharedworker` or `serviceworker`). When headers vary by `Sec-Fetch-Dest`, send `Vary: Sec-Fetch-Dest` so shared caches do not serve responses without the header. Serve a matching allowlist on Dedicated and Shared Worker scripts, so compromised page scripts cannot exfiltrate data through `worker.postMessage()`. A Service Worker makes its own network fetches on cache misses and navigation preloads, so its allowlist must be a superset of the allowlists of every document it controls.
3. Always configure violation reporting, and roll out in stages. Define a `Reporting-Endpoints` header and append an unquoted `; report-to=<endpoint-name>` parameter after the closing `)` of every `Connection-Allowlist` and `Connection-Allowlist-Report-Only` policy, so blocked connections are visible. You can send `Connection-Allowlist-Report-Only` alone at first, or send both on one response: `Connection-Allowlist` enforcing a baseline and `Connection-Allowlist-Report-Only` auditing a stricter candidate. Reports have `"type": "connection-allowlist"` and body `{ url, connection, allowlist, disposition }`, where `connection` is the blocked destination URL or `"webrtc"` and `disposition` is `"enforce"` or `"report"`.
4. Account for redirect and WebRTC blocking, and handle client errors. By default all `3xx` redirects are blocked (`redirects=block`), even between allowlisted or same-origin URLs, and so is all `RTCPeerConnection` traffic (`webrtc=block`). Append `; redirects=allow` only when trusted endpoints need server-side redirects (the initial request must still match the allowlist), and `; webrtc=allow` only when WebRTC is needed. On the client, wrap outbound `fetch()` calls in try/catch and handle `WebSocket` `error` events, so requests rejected with `TypeError` (`net::ERR_NETWORK_ACCESS_REVOKED`) produce a handled error state and a UI update instead of unhandled rejections.

## Example

```http
Vary: Sec-Fetch-Dest
Reporting-Endpoints: conn-reports="https://app.example.com/api/security-reports"
Connection-Allowlist: (response-origin "https://api.example.com" "https://realtime.example.com" "https://*.cdn.example.com/*"); report-to=conn-reports
Connection-Allowlist-Report-Only: (response-origin "https://api.example.com/v2/*"); report-to=conn-reports
```

```javascript
const ALLOWLIST_DESTS = new Set(['document', 'iframe', 'worker', 'sharedworker', 'serviceworker']);

// Normalize a config URL or URLPattern string for Connection-Allowlist:
// - Rewrites ws:// and wss:// to http:// and https:// (WebSocket matching rule).
// - Strips a bare trailing slash on origin-only URLs (e.g. from new URL(...).href)
//   so all subpaths on the origin are permitted instead of only "/".
export function normalizeAllowlistPattern(rawPattern) {
  const trimmed = String(rawPattern).trim().replace(/^ws(s?):\/\//i, 'http$1://');
  if (!/^https?:\/\//i.test(trimmed)) {
    throw new Error(`Pattern must include an http:// or https:// scheme: ${rawPattern}`);
  }
  if (/[\s,]/.test(trimmed)) {
    throw new Error(`Pattern must be a single URLPattern without spaces or commas: ${rawPattern}`);
  }
  if (/[()]/.test(trimmed)) {
    throw new Error(`Custom regex groups are rejected by Connection-Allowlist: ${rawPattern}`);
  }
  return trimmed.replace(/^(https?:\/\/[^/?#]+)\/$/i, '$1');
}

// Build an RFC 9651 Inner List value for Connection-Allowlist or Connection-Allowlist-Report-Only.
export function buildConnectionAllowlistHeader({
  allowSelf = true,
  patterns = [],
  reportTo,
  redirects = 'block',
  webrtc = 'block',
} = {}) {
  const items = allowSelf ? ['response-origin'] : [];
  for (const pattern of patterns) {
    const raw = String(pattern).trim();
    if (raw === 'response-origin') {
      if (!items.includes('response-origin')) items.push('response-origin');
      continue;
    }
    const normalized = normalizeAllowlistPattern(raw);
    items.push(`"${normalized.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`);
  }
  let header = `(${items.join(' ')})`;
  if (redirects === 'allow') header += '; redirects=allow';
  if (webrtc === 'allow') header += '; webrtc=allow';
  if (reportTo) {
    const endpointToken = String(reportTo).trim().replace(/^"+|"+$/g, '');
    header += `; report-to=${endpointToken}`;
  }
  return header;
}

// Server or middleware helper applying Connection-Allowlist and Reporting-Endpoints
// on document and worker responses.
export function setConnectionAllowlistHeaders(res, options = {}) {
  const {
    secFetchDest = 'document',
    patterns = ['https://api.example.com', 'https://realtime.example.com', 'https://*.cdn.example.com/*'],
    reportOnlyPatterns,
    reportEndpointName = 'conn-reports',
    reportEndpointUrl = 'https://app.example.com/api/security-reports',
    redirects = 'block',
    webrtc = 'block',
    reportOnly = false,
  } = options;

  const setHeader = (name, value) =>
    typeof res.setHeader === 'function' ? res.setHeader(name, value) : res.headers.set(name, value);

  if (typeof res.appendHeader === 'function') {
    res.appendHeader('Vary', 'Sec-Fetch-Dest');
  } else if (typeof res.headers?.append === 'function') {
    res.headers.append('Vary', 'Sec-Fetch-Dest');
  } else {
    setHeader('Vary', 'Sec-Fetch-Dest');
  }
  if (secFetchDest && !ALLOWLIST_DESTS.has(String(secFetchDest).toLowerCase())) return;

  setHeader('Reporting-Endpoints', `${reportEndpointName}="${reportEndpointUrl}"`);
  setHeader(
    reportOnly ? 'Connection-Allowlist-Report-Only' : 'Connection-Allowlist',
    buildConnectionAllowlistHeader({ allowSelf: true, patterns, reportTo: reportEndpointName, redirects, webrtc }),
  );

  if (!reportOnly && Array.isArray(reportOnlyPatterns)) {
    setHeader(
      'Connection-Allowlist-Report-Only',
      buildConnectionAllowlistHeader({
        allowSelf: true,
        patterns: reportOnlyPatterns,
        reportTo: reportEndpointName,
        redirects,
        webrtc,
      }),
    );
  }
}

// Client-side helper that catches blocked outbound requests gracefully without unhandled rejections.
export async function fetchWithPolicyHandling(url, { statusElement, ...fetchOptions } = {}) {
  try {
    const response = await fetch(url, fetchOptions);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const body = await response.text();
    if (statusElement) {
      statusElement.textContent = `Allowed: Loaded ${url} (${body.length} bytes).`;
    }
    return { ok: true, body, error: null };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (statusElement) {
      statusElement.textContent = `Blocked: Request to ${url} was rejected by the outbound connection policy (${message}).`;
    }
    return { ok: false, body: null, error };
  }
}
```

## Rules

- Format `Connection-Allowlist` as a single RFC 9651 Inner List `(...)` of space-separated items. If a non-empty header fails top-level Structured Field parsing (for example without `(...)`, or with single quotes `'...'`), the browser fails closed with an empty allowlist and blocks all outbound connections. Send `Connection-Allowlist: ()` when you deliberately want to revoke all network access after load; the local schemes `data:`, `blob:`, `about:` and `filesystem:` stay allowed.
- Write origin-wide patterns without a trailing slash (`"https://api.example.com"`) or with an explicit wildcard (`"https://api.example.com/*"`), so subpaths such as `/v1/users` match. Strip the trailing slash that `new URL(origin).href` adds before serializing.
- Allowlist `WebSocket` endpoints (`ws://` and `wss://`) with `"http://..."` and `"https://..."` patterns, because the browser normalizes WebSocket schemes to HTTP/HTTPS before matching.
- Include expected external navigation targets (`<a href>`, `<form action>`, OAuth/SSO providers, payment checkouts) in a restricted document's allowlist. The default `redirects=block` blocks even same-origin `3xx` redirects unless `; redirects=allow` is set.
- Leave `response-origin` and parameter values (`; report-to=conn-reports`, `; redirects=allow`, `; webrtc=allow`) unquoted, and do not separate items inside `(...)` with commas.
- Patterns cannot contain custom regular-expression groups such as `(\d+)` or be relative paths such as `"/api/*"`: the browser's network-service parser rejects regex groups and patterns without a scheme and hostname.
- Do not rely on the experimental `<iframe connectionAllowlist="...">` attribute or the `Allow-Connection-Allowlist-From` embedded-enforcement header in production yet; embedded enforcement is not enabled by default in shipping browsers.

## Browser support and fallback

Browser support for Connection allowlists: Limited availability.
Supported by: Chrome 152 (Aug 2026) and Edge 152 (Aug 2026).
Unsupported in: Firefox and Safari.

`Connection-Allowlist` is enforced in the browser's network layer from a response header, so it cannot be polyfilled in JavaScript. If your Baseline target includes browsers without it, pair it with a `Content-Security-Policy` header (or, when you cannot set response headers, a `<meta http-equiv="Content-Security-Policy">` element for document-level fetch and subresource restrictions):

- The two are additive defense in depth. Supporting browsers enforce both: `Connection-Allowlist` blocks the channels CSP misses (`dns-prefetch`, `preconnect`, WebRTC, redirects), while CSP restricts `fetch()`, subresources and `<form action>` navigations in browsers without `Connection-Allowlist`.
- Set `form-action` and `worker-src` explicitly. `default-src` does not apply to `<form action>` submissions, so always include `form-action`. Include `worker-src 'self'` (without `blob:`) so restricted pages cannot spawn `blob:` SharedWorkers to bypass document-level restrictions.
- Map allowed origins to per-resource CSP directives. `Connection-Allowlist` uses one endpoint list and does not govern inline markup; CSP's `default-src 'self'` restricts each resource type (`connect-src`, `img-src`, `style-src`, `font-src`, `script-src`) and blocks inline `<style>` and `<script>` unless authorized with hashes or nonces.
- The CSP below shows only the directives that stand in for `Connection-Allowlist`. Merge them into the app's main CSP rather than shipping it as is: script protection still needs a nonce- or hash-based `script-src` with `'strict-dynamic'` and `base-uri 'none'` (see the `security` guide), not the `'self'` allowlist implied here.
- List `wss://` origins in CSP `connect-src` explicitly when WebSockets are used, for cross-browser behaviour, even though `Connection-Allowlist` matches `wss://` against `"https://..."` patterns.

```http
Content-Security-Policy: default-src 'self'; connect-src 'self' https://api.example.com https://realtime.example.com wss://realtime.example.com; img-src 'self' https://*.cdn.example.com data: blob:; form-action 'self'; worker-src 'self'; object-src 'none'; base-uri 'none'; report-to conn-reports
```

```html
<!-- Document-level fallback when HTTP response headers cannot be set on static hosting -->
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self'; connect-src 'self' https://api.example.com https://realtime.example.com wss://realtime.example.com; img-src 'self' https://*.cdn.example.com data: blob:; form-action 'self'; worker-src 'self'; object-src 'none'; base-uri 'none'"
/>
```
