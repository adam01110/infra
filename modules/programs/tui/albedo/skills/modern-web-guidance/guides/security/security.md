# Web Security

How to add preventive web security measures safely and incrementally.

This guide covers standard web platform defenses, mostly in the browser. Applications still need thorough server-side security, authorization and input validation.

## When to apply this guide

The starting point depends on the application and on whether you can change its code directly:

- Auditing and hardening a codebase you can edit: apply the Phase 1 code hygiene, wire up Phase 2 reporting (`Reporting-Endpoints` and `report-to`), and enforce the Phase 3 headers in the same pass by updating `<script>` tags, cookies and server middleware. That means `Content-Security-Policy` with nonces or hashes, `'strict-dynamic'`, `'report-sample'`, `object-src 'none'`, `base-uri 'none'`, `frame-ancestors 'none'` (or `'self'`) and `require-trusted-types-for 'script'`, plus COOP, CORP, Fetch Metadata, HSTS, `X-Content-Type-Options`, `Referrer-Policy` and `Permissions-Policy`.
- Staged rollout on a large production site with unknown third-party dependencies: start with the Phase 1 quick wins, deploy Phase 2 report-only headers alongside the enforced companion policies while collecting violation telemetry, then promote the report-only policies to Phase 3 enforcement.
- Greenfield app, SaaS template or framework defaults: ship Phase 1 hygiene and enforced Phase 3 policies by default, with Phase 2 reporting configured so regressions show up immediately.

Phases 1 and 2 give baseline hygiene and visibility; Phase 3 core enforcement is where most of the protection comes from. Mitigating injection and XSS with an enforced CSP (3.2) and Trusted Types (3.3) addresses the largest practical threat; companion policies and isolation add defense in depth.

## Phase 1: Quick wins and obvious anti-patterns

Before deploying global policies, fix code-level problems that carry no risk of breaking the application.

### 1.1 Secure contexts

- Serve everything over HTTPS, which protects against passive and active network attackers.
- Where possible, force HTTPS with `Strict-Transport-Security`, rolled out gradually as described under "HTTP Strict Transport Security (HSTS)" in the companion policies.

### 1.2 Dangerous DOM sinks

- Use `textContent` or `innerText` rather than `innerHTML` to set text.
- To insert untrusted HTML, use `setHTML()` from the Sanitizer API where available (see the `sanitize-untrusted-html` guide) instead of `innerHTML`.
- Never pass untrusted or unsanitized input to `innerHTML` or `setHTMLUnsafe`.
- Build DOM with `DOMParser` or `document.createElement` rather than concatenating HTML strings.

Sinks to search for: `innerHTML`, `outerHTML`, `document.write`, `eval`, `setTimeout` with a string argument, `script.src`.

```javascript
// Unsafe:
element.innerHTML = `Hello, ${untrustedName}!`;

// Safe:
element.textContent = `Hello, ${untrustedName}!`;
```

Trusted Types can enforce this at runtime by blocking string assignments to dangerous sinks. Deploying it is a CSP enforcement step with real breakage risk; see 3.3.

### 1.3 Secure cookies

Configure session and application cookies securely by default, whether they are set with `Set-Cookie` headers or through framework session configuration (such as Astro or Express session middleware).

- Name first-party session cookies used by a single domain with the `__Host-` prefix (`name: '__Host-session'`). The prefix requires `Secure` (`secure: true`), `Path=/` (`path: '/'`) and no `Domain` attribute, and protects against same-site and network attackers.
- Where `__Host-` does not fit, prefer the `__Secure-` prefix. It requires `Secure` and protects against network attackers.
- Set `HttpOnly` (`httpOnly: true`) on session and authentication cookies so injected scripts cannot read them, and set `SameSite=Lax` (`sameSite: 'lax'`) explicitly on ordinary first-party cookies.
- If the application is embedded as an iframe in third-party contexts, use `SameSite=None; Secure; Partitioned`.
- Do not rely on unpartitioned `SameSite=None` cookies; browsers increasingly block them to prevent tracking.

```http
Set-Cookie: __Host-session_id=value; SameSite=Lax; HttpOnly; Secure; Path=/
Set-Cookie: third_party_var=value; SameSite=None; Secure; Partitioned
```

### 1.4 Clickjacking protection (`frame-ancestors`, `X-Frame-Options`)

Clickjacking protection is easy to deploy, very unlikely to break legitimate functionality, and immediately defends against UI redressing. Pick the tier that matches your framing needs:

- Never framed (default): `Content-Security-Policy: frame-ancestors 'none'` with `X-Frame-Options: DENY`.
- Same-origin framing only (the app embeds its own pages): `Content-Security-Policy: frame-ancestors 'self'` with `X-Frame-Options: SAMEORIGIN`.
- Specific cross-origin embedders: `Content-Security-Policy: frame-ancestors 'self' https://trusted-partner.com`, and omit `X-Frame-Options`. It cannot express a cross-origin allowlist (`ALLOW-FROM` is obsolete and unsupported), and `DENY` or `SAMEORIGIN` would block the embed in any client that evaluates `X-Frame-Options` without `frame-ancestors`.
- Arbitrary embedding: omit both only on routes designed as publicly embeddable widgets.

```http
# Default (never framed):
Content-Security-Policy: frame-ancestors 'none';
X-Frame-Options: DENY

# Same-origin framing allowed:
Content-Security-Policy: frame-ancestors 'self';
X-Frame-Options: SAMEORIGIN

# Specific cross-origin framing allowed (omit X-Frame-Options):
Content-Security-Policy: frame-ancestors 'self' https://trusted-partner.com;
```

### 1.5 Window messaging (`postMessage`)

If the application talks to other origins through `window.postMessage`, validate both ends strictly.

- On the receiver, check `event.origin` of every incoming message with strict equality against a list of trusted origins. When comparing against URLs or elements, checking schemeful same-site relationships, or telling opaque sandboxed iframe origins apart, use the `Origin` API instead (see the `validate-origins` guide). Never trust wildcards (`*`), substring checks or unverified payloads.
- When sending sensitive data, pass a specific target origin to `postMessage`, never `*`, so only the intended origin receives it.
- Validate and sanitize incoming payload properties before acting on them or writing them to DOM sinks. Manual JSON serialization is unnecessary; `postMessage` clones objects itself.

```javascript
// Receiver: exact string check.
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://trusted-origin.com') return;
  const data = event.data;
  if (data && data.action === 'update') {
    // Validate the payload, then act on it.
  }
});

// Sender: explicit target origin.
targetWindow.postMessage({ action: 'update' }, 'https://trusted-origin.com');
```

### 1.6 WebSocket connections

Browsers do not enforce CORS on WebSocket handshakes, and they still attach eligible cookies to the upgrade request: `SameSite=Lax` and `SameSite=Strict` cookies from same-site subdomains or ports, `SameSite=None` cookies cross-site, and cookies without a `SameSite` attribute in browsers that do not default to `Lax`. Every WebSocket endpoint therefore needs explicit server-side `Origin` validation to prevent Cross-Site WebSocket Hijacking (CSWSH).

- Use `wss://` (TLS) for public WebSocket endpoints that are not local. Mixed Content blocking stops public `ws://` connections from `https://` pages, but `http://` pages and hardcoded `ws://` configurations stay exposed. Reserve `ws://` for loopback development or explicit Local Network Access exemptions (private IP literals and `.local` mDNS hostnames; see the `local-network-access` guide).
- Validate the `Origin` header against an explicit allowlist of trusted origins inside the handshake handler (for example an HTTP/1.1 `upgrade` handler or an HTTP/2 extended `CONNECT` handler). Reject missing or unexpected origins with HTTP `403` before completing the handshake.
- Do not rely on `Sec-Fetch-*` headers instead of `Origin`. Not every browser sends them on WebSocket upgrades, so rejecting requests without them breaks connections, while accepting such requests leaves those browsers unprotected. `Sec-Fetch-Site: same-site` also admits untrusted subdomains.
- Do not pass authentication tokens or secrets in the WebSocket URL query (`wss://example.com/ws?token=...`) or in the `Sec-WebSocket-Protocol` header; both leak credentials into server access logs and proxies.
- Authenticate the session by pairing strict `Origin` validation with hardened session cookies (1.3), or by requiring authentication in the first message over `wss://` and closing the socket after a short timeout if none arrives. `__Host-` cookies are host-only and are not sent to a separate WebSocket subdomain; that setup needs a `__Secure-` cookie with `Domain`, or authentication that does not use cookies.

```javascript
import { WebSocketServer } from 'ws';

// Replace with your application's trusted origin(s).
const ALLOWED_ORIGINS = new Set(['https://app.example.com']);
// noServer stops `ws` from registering a competing `upgrade` listener that bypasses the check.
const wss = new WebSocketServer({ noServer: true });

server.on('upgrade', (req, socket, head) => {
  // Node drops its default socket error handler on `upgrade`; this prevents unhandled ECONNRESET crashes.
  socket.on('error', () => {});

  const origin = req.headers.origin;
  if (!origin || !ALLOWED_ORIGINS.has(origin)) {
    socket.end('HTTP/1.1 403 Forbidden\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
    return;
  }

  // Verify the hardened session cookie (1.3), or enforce first-message auth with a short timeout.
  wss.handleUpgrade(req, socket, head, (ws) => {
    wss.emit('connection', ws, req);
  });
});
```

## Phase 2: Discovery and data collection

Do not apply strict policies blindly to an existing application. Collect data first to learn its constraints.

### 2.1 Inspect the application

Before enabling anything, gather these facts:

- Existing security headers, in server config, middleware, CDN/edge config and `<meta>` tags: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Frame-Options`, `X-Content-Type-Options`, `Permissions-Policy`, `Cross-Origin-*`, `Access-Control-*`, `Timing-Allow-Origin`, `Reporting-Endpoints`.
- Inline scripts and styles in server-rendered templates and static HTML; they will need nonces, hashes or refactoring.
- Third-party script origins (analytics, ads, tag managers, CDNs); they decide what `script-src` must allow and whether `'strict-dynamic'` is viable.
- Popup-dependent flows such as OAuth, payment gateways and SSO; they constrain the COOP choice.
- Cross-origin embeds and embedders (iframes the app loads, sites that embed the app); they constrain COEP, CORP and `frame-ancestors`.
- Browser features used by the app or embedded third-party widgets (camera, geolocation, microphone, fullscreen), for `Permissions-Policy`.
- Whether third-party scripts are versioned or updated silently, which decides whether SRI can be used.
- Incoming webhooks, cross-site APIs and SSO redirect endpoints, so Fetch Metadata resource isolation does not break them.

### 2.2 Deploy report-only policies

Report-only headers reveal breakage before it happens.

- Dry-run policies without enforcement using the report-only headers:
  - `Content-Security-Policy-Report-Only` for CSP
  - `Cross-Origin-Opener-Policy-Report-Only` for COOP
  - `Cross-Origin-Embedder-Policy-Report-Only` for COEP
  - `Document-Policy-Report-Only` for document features
- Define a `Reporting-Endpoints` header so reports have a destination, and reference the endpoint name from `report-to`. Include an endpoint named `default`, which also receives deprecation and crash reports automatically.
- Run report-only long enough to cover real traffic patterns, typically days to weeks, not just synthetic tests.

```http
Reporting-Endpoints: default="https://reports.example/default", main-endpoint="https://reports.example/main"
Content-Security-Policy-Report-Only: script-src 'nonce-{RANDOM}' 'strict-dynamic' 'report-sample'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; require-trusted-types-for 'script'; report-to main-endpoint;
```

If you add `https:` and `'unsafe-inline'` to a `script-src` that uses `'strict-dynamic'`, they act as a backward-compatibility ladder: modern browsers honor `'strict-dynamic'` (which propagates trust from nonced scripts) and ignore the other two, older browsers fall back to `https:`, and very old browsers to `'unsafe-inline'`. The fallbacks are harmless in any browser that supports a stricter token.

Reporting endpoints receive many false-positive reports caused by client-side middleware, aggressive browser extensions, very old browsers, crawlers and antivirus scanners. Focus on high-frequency patterns from modern user agents, and filter the noise before deciding anything:

- Ignore reports from old browsers with known bugs that cause spurious violations, reports for markup known to be injected by popular extensions or client-side middleware (for example identical reports seen across many unrelated applications), and reports without enough information to debug.
- Once a policy is deployed, a low violation volume often indicates a false positive that can be ignored.
- Always include `'report-sample'` in `script-src`. The browser then puts the first 40 characters of the violating script or inline code in the report, which makes debugging much easier.

### 2.3 Data hygiene for reports

Keep sensitive data (PII, authentication tokens, session identifiers, query strings containing secrets) out of logs and violation reports. Mask or drop it at the edge before it reaches the reporting endpoint.

### 2.4 Discovery through browser APIs and DevTools

- Reporting API: combine `Reporting-Endpoints` with report-only headers (such as `Content-Security-Policy-Report-Only` or `Document-Policy-Report-Only`) so browsers post violations to your server automatically.
- DevTools: the Issues tab (for example in Chrome DevTools) lists blocked resources, mixed content, third-party cookie deprecation warnings and feature policy violations without manually crawling the codebase.

## Phase 3: Interpreting results and enforcing

After inspecting the application (or collecting report-only data), enforce the policies. Phase 3 has two tracks, enforced together:

- Core enforcement: the high-leverage XSS and isolation defenses (`Content-Security-Policy`, Trusted Types, COOP, CORP, Fetch Metadata).
- Companion policies: low-risk headers (`Strict-Transport-Security`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, `Clear-Site-Data`) that should always be enabled alongside core enforcement.

### Core enforcement

#### 3.1 Analyzing CSP reports

First separate the noise (see 2.2) from real application issues. For violations that look caused by your own application (the "Sample" or "Blocked URI" looks like a legitimate script or asset that could be in your markup):

- Search the codebase, server templates and static HTML for the offending script source, URL or hash.
- Open the page from the report's "Document URI" in the same browser, watch the DevTools console for CSP violations, and exercise as much functionality as possible; some violations only occur on specific interactions.

Then match the triaged reports against these common cases:

- Many inline-script violations, because the framework relies on inline scripts: implement nonces (server-rendered pages) or hashes (static pages) before enforcing.
- Violations for required third-party analytics scripts: use `'strict-dynamic'` with a per-request nonce so the analytics loader can load its dependencies. Do not add the analytics origin to a URL allowlist; domain allowlists can be bypassed through open redirects, JSONP and dependency injection on the listed origin.
- Trusted Types violations on specific sinks, because legacy code still writes strings to `innerHTML` and similar: refactor those sinks (1.2) or route them through a Trusted Types policy (3.3) before enforcing.

#### 3.2 Enforcing Content Security Policy (CSP)

Keep `Reporting-Endpoints` and `report-to` on the enforced header too, so regressions stay visible.

Required directives:

- `script-src 'nonce-{RANDOM}' 'strict-dynamic' 'report-sample'` (or SHA-256/384/512 script hashes for static HTML): the core of any CSP and the main defense against XSS.
- `object-src 'none'`: blocks plugin-based code execution (`<object>`, `<embed>`).
- `base-uri 'none'`: blocks `<base>` hijacking of relative URLs.
- `frame-ancestors 'none'` (or `'self'` when same-origin framing is needed): prevents clickjacking, together with `X-Frame-Options: DENY` (or `SAMEORIGIN`; see 1.4).
- `require-trusted-types-for 'script'`: enforces Trusted Types checks on DOM XSS sinks (3.3).
- `report-to <endpoint>`: sends violation reports to the endpoint defined in `Reporting-Endpoints`.
- Optional: `form-action 'self'` prevents form submissions to attacker-controlled origins.

```http
Reporting-Endpoints: main-endpoint="https://reports.example/main"
Content-Security-Policy: script-src 'nonce-{RANDOM}' 'strict-dynamic' 'report-sample'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; require-trusted-types-for 'script'; report-to main-endpoint;
```

HTML for a nonce-based CSP:

```html
<script nonce="{RANDOM}" src="https://example.com/script.js"></script>
```

In server-rendered or SSR middleware (such as Node.js, Express or Astro middleware), generate a fresh cryptographic nonce for every request, put it in `Content-Security-Policy`, and pass it into the template or SSR rendering context so that only trusted template `<script>` tags receive it. Express-style example:

```javascript
const bytes = new Uint8Array(16);
crypto.getRandomValues(bytes);
const nonce = btoa(String.fromCharCode(...bytes));

const csp = [
  `script-src 'nonce-${nonce}' 'strict-dynamic' 'report-sample'`,
  "object-src 'none'",
  "base-uri 'none'",
  "frame-ancestors 'none'", // or "frame-ancestors 'self'" if same-origin framing is needed
  "require-trusted-types-for 'script'",
  'report-to main-endpoint',
].join('; ');

res.setHeader('Reporting-Endpoints', 'main-endpoint="https://reports.example/main"');
res.setHeader('Content-Security-Policy', csp);

// Pass the per-request nonce into your template/SSR rendering context (or replace an
// explicit placeholder token in a static template before interpolating any user data):
res.locals.nonce = nonce; // e.g., <script nonce="<%= nonce %>" src="/app.js"></script>
```

For static or cached HTML (such as SPAs) where a per-response nonce is impossible, use a hash-based CSP: compute the `sha256-` hash of each script and list the hashes in `script-src` with `'strict-dynamic' 'report-sample'`.

Avoid:

- Broad scheme or domain allowlists (such as `https:` alone, or `script-src https://cdn.example.com` without `'strict-dynamic'`) as the main `script-src` protection. Open redirects, JSONP endpoints and dependency injection on the allowed origin bypass them easily.
- Rewriting already-rendered HTML with a regular expression (such as `html.replace(/<script\b.../gi, ...)`) to add nonces to every `<script>` tag. Post-processing cannot tell developer-authored scripts from scripts injected through reflected or stored HTML injection, so it authorizes attacker scripts under `script-src 'nonce-...'`.

#### 3.3 Trusted Types enforcement

Trusted Types enforces the 1.2 guidance at runtime: it blocks raw string assignments to DOM XSS sinks (`innerHTML`, `outerHTML`, `document.write`, `script.src`, `script.textContent`) unless they pass through a named policy.

- Enforce it with the `require-trusted-types-for 'script'` directive in `Content-Security-Policy`.
- Route HTML sink assignments through a named `trustedTypes.createPolicy(...)` policy rather than assigning raw strings, or use `element.setHTML()`, which sanitizes without needing a policy.
- Never create a pass-through policy (such as `createHTML: (s) => s`) that returns input unchanged; it cancels the protection.
- For full implementation details, including allowlisting policy names with `trusted-types` and rollout strategy, see the `trusted-types` guide.

```javascript
// Escapes all markup to plain text. To keep HTML markup, sanitize instead (see the trusted-types guide).
const htmlPolicy = window.trustedTypes?.createPolicy('app-html', {
  createHTML(input) {
    return String(input)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  },
});
```

#### 3.4 Cross-Origin Opener Policy (COOP)

The lowest-risk of the three isolation policies (COOP, CORP, cross-origin isolation). Deploy it if the app is not an OAuth provider, payment processor or anything else meant to be opened from another site's window.

- Use `Cross-Origin-Opener-Policy: same-origin-allow-popups`. It stops a malicious opener from mounting XS-Leaks attacks while still allowing OAuth and payment popups that the app itself opens.
- Move to `same-origin` only after verifying that no integration relies on cross-origin `window.opener` access.

#### 3.5 Cross-Origin Resource Policy (CORP)

Set CORP explicitly on each response according to whether other contexts should be able to embed it. It protects resources from malicious cross-origin reads and keeps them loadable when pages request stronger isolation.

- Default to `Cross-Origin-Resource-Policy: same-origin` for app-internal responses (HTML documents, internal endpoints, authenticated data, session JSON, restricted internal scripts).
- Use `same-site` for endpoints used across subdomains of the same eTLD+1.
- Use `cross-origin` only for resources meant for general embedding or widely cached delivery (static shared assets, public CDNs).

#### 3.6 Cross-origin isolation

The highest breakage risk. Deploy it only if the application needs features that depend on `SharedArrayBuffer` (such as WebAssembly multithreading or shared-memory architectures); otherwise skip it.

- Cross-browser default: serve the document with `Cross-Origin-Opener-Policy: same-origin` plus `Cross-Origin-Embedder-Policy: require-corp` (or `Cross-Origin-Embedder-Policy: credentialless` where supported). Under `require-corp`, every cross-origin subresource (images, scripts, styles, media) must opt in, either with a `Cross-Origin-Resource-Policy` header (`cross-origin` or `same-site`) or with CORS (the `crossorigin` attribute plus `Access-Control-Allow-Origin`). An embedded cross-origin `<iframe>` must both send `Cross-Origin-Resource-Policy` (`cross-origin` or `same-site`) and enforce COEP itself, or the browser blocks it.

```http
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Resource-Policy: same-origin
```

Browser support for Document-Isolation-Policy: Limited availability.
Supported by: Chrome 137 (May 2025) and Edge 137 (May 2025).
Unsupported in: Firefox and Safari.

- Alternative where supported: serve `Document-Isolation-Policy: isolate-and-credentialless` on the document that needs `SharedArrayBuffer`. It isolates that document without severing cross-origin `window.opener` references to popups or requiring embedded third-party iframes to deploy COEP, and strips cookies and credentials from non-CORS cross-origin subresource requests. Use `isolate-and-require-corp` instead to block cross-origin subresources that lack an explicit CORP or CORS opt-in.

#### 3.7 Fetch Metadata (resource isolation)

Server-side enforcement that uses the `Sec-Fetch-*` request headers to reject suspicious cross-site requests. Complete the cross-site integration inventory from 2.1 before enforcing.

- Check the `Sec-Fetch-*` headers on the server and reject `cross-site` requests to non-navigational endpoints.
- Reject before authentication or authorization checks, so the response leaks no timing information about whether a resource or session exists.
- Send `Vary: Sec-Fetch-Dest, Sec-Fetch-Mode, Sec-Fetch-Site` so intermediate caches (CDNs) do not serve cached responses to attackers.
- `same-site` trusts every subdomain of your eTLD+1. If any subdomain hosts user-generated content, a legacy app or other untrusted code, drop `same-site` from the allowlist and accept only `same-origin` and `none`.
- Misconfigured checks block legitimate requests from cross-site integrations, SSO handlers and webhooks. Log and test the constraints first.
- Fetch Metadata middleware does not cover WebSocket handshakes; validate `Origin` in the handshake handler instead (1.6).

Express example:

```javascript
app.use((req, res, next) => {
  res.setHeader('Vary', 'Sec-Fetch-Dest, Sec-Fetch-Mode, Sec-Fetch-Site');

  const site = req.get('Sec-Fetch-Site');
  const mode = req.get('Sec-Fetch-Mode');
  const dest = req.get('Sec-Fetch-Dest');

  if (!site) return next(); // Legacy browsers send no Sec-Fetch-* headers.

  if (['same-origin', 'same-site', 'none'].includes(site)) return next();

  // Allow standard navigate GET requests (link clicks)
  if (site === 'cross-site' && mode === 'navigate' && req.method === 'GET' && !['object', 'embed'].includes(dest)) {
    return next();
  }

  res.status(403).send('Forbidden');
});
```

### Companion policies

These carry much lower breakage risk than core enforcement and can be deployed alongside, or before, the CSP and isolation rollouts.

#### HTTP Strict Transport Security (HSTS)

- Send `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload` to force HTTPS.
- In a production rollout, start with a short `max-age` (such as 300 seconds) and raise it step by step to one year. A misconfigured HSTS policy with a long `max-age` can make the site unreachable until the cached policy expires in every browser that saw it.

#### `X-Content-Type-Options`

- Send `X-Content-Type-Options: nosniff` to block MIME-type sniffing.
- Serve correct `Content-Type` headers for every resource (`application/javascript` for scripts, `application/json` for APIs, `text/html` for documents and so on), so the browser can enforce `nosniff` strictly.

#### Referrer Policy

- Use `Referrer-Policy: strict-origin-when-cross-origin` as a safe default.

#### Permissions Policy

- Disable unused browser features (camera, geolocation, microphone) for the page and its iframes, using Structured Fields syntax.
- When delegating a feature to an iframe, use the HTML `allow` attribute in addition to the header.
- Blocking a feature that a third-party widget (an embedded video player, a payment gateway) needs makes it fail silently. Audit third-party dependencies before blocking.

```http
Permissions-Policy: camera=(), geolocation=(), microphone=()
```

```html
<iframe src="https://trusted-video.com/player" allow="fullscreen"></iframe>
```

#### Subresource Integrity (SRI)

- Load third-party scripts and stylesheets with an `integrity` hash (`sha384`, `sha512` or `sha256`) and `crossorigin="anonymous"`. The `secure-external-subresources` guide covers SRI, CORS and Referrer Policy for HTML and CSS subresources in depth.
- Make sure the server or CDN sends a suitable `Access-Control-Allow-Origin` header, so the browser can compute the hash.
- Use SRI only for immutable, versioned assets. On dynamic or unversioned assets, a silent update makes the script fail to execute.

```html
<script src="https://cdn.example.com/lib@1.0.0.js" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
```

#### Cross-Origin Resource Sharing (CORS)

CORS is a permission grant, not a defense: it tells the browser which cross-origin reads to allow. The risk is making it too permissive.

- Validate the `Origin` request header on the server and set `Access-Control-Allow-Origin` dynamically to specific origins rather than `*`.
- `*` cannot be combined with `Access-Control-Allow-Credentials: true`; the browser rejects such a response.
- Answer preflight (`OPTIONS`) requests with the appropriate headers before processing any data.

```http
Access-Control-Allow-Origin: https://trusted-app.com
Access-Control-Allow-Credentials: true
```

#### `Clear-Site-Data` (logout)

Send `Clear-Site-Data: "cookies", "storage", "cache"` from logout endpoints to end the session completely. Omitting any of the three leaves session cookies, Web Storage state or cached authenticated pages behind.

```http
Clear-Site-Data: "cookies", "storage", "cache"
```
