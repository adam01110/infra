# Local Network Access

When a page served from a `public` origin (or an intranet `local` origin) connects to the user's private network (a LAN printer, IoT hub or router at `192.168.1.x` or `device.local`) or to a companion service on the user's own machine (`127.0.0.1`, `[::1]` or `localhost`), the browser gates the connection behind a Local Network Access (LNA) permission prompt.

LNA uses two permissions, which are also `Permissions-Policy` tokens. They follow the address-space order `public` → `local` → `loopback`, and checks apply only when a request goes from a less private space to a more private one:

- `local-network`: from a `public` origin to the `local` space: RFC 1918 private IPv4 ranges `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, link-local `169.254.0.0/16` / `fe80::/10`, IPv6 Unique Local Addresses `fc00::/7`, and `.local` mDNS hostnames.
- `loopback-network`: from a `public` or `local` origin to the `loopback` space: `127.0.0.0/8`, `::1/128` or `localhost`.

`localhost` (`127.0.0.1` and `[::1]`) is already the most private space, so an app served from `http://localhost` during development does not trigger LNA checks by default. To test prompts and permission states locally, either override the dev server's IPv4 and IPv6 address space to `public` with the Chromium flag `--ip-address-space-overrides=127.0.0.1:8080=public,[::1]:8080=public`, or switch "Local network" and "Loopback network" between Ask, Allow and Block in the browser's site settings.

Serve any app that makes local or loopback requests from a secure context (`https://`). LNA permissions are denied automatically in insecure (`http://`) top-level contexts.

Do not use the deprecated Private Network Access (PNA) preflight headers (`Access-Control-Request-Private-Network: true` / `Access-Control-Allow-Private-Network: true`). LNA works through the user permission prompts plus standard CORS headers (`Access-Control-Allow-Origin`) for reading cross-origin responses. PNA preflights were never enforced as a blocking requirement and are not needed as a fallback. Servers or device firmware that already send `Access-Control-Allow-Private-Network: true` can keep doing so harmlessly, but new code should not add PNA handling.

## Steps

### 1. Check permission state and require a user gesture

When the permission state is `'prompt'`, do not fire local or loopback requests automatically on page load (`DOMContentLoaded`). Never make the first permission-triggering request from a Service Worker or Shared Worker: they have no attached `Document`, so the request fails immediately unless permission is already `'granted'`.

Query `navigator.permissions.query()` for `'local-network'` or `'loopback-network'` first:

- `'granted'`: connect automatically.
- `'prompt'`: show UI explaining why the app needs the local device or companion app, and make the request from an explicit user gesture such as a button click.
- `'denied'`: show remediation UI telling the user how to re-enable Local network or Loopback network access in the browser's site settings.

```javascript
/**
 * Queries the granular Local Network Access permission for the target space.
 * @param {'local-network' | 'loopback-network'} permissionName
 */
export async function checkNetworkPermission(permissionName) {
  const status = await navigator.permissions.query({ name: permissionName });

  // Keep UI synchronized if the user changes permission in browser site settings
  status.addEventListener('change', () => {
    updatePermissionUI(permissionName, status.state);
  });

  updatePermissionUI(permissionName, status.state);
  return status.state;
}

function updatePermissionUI(permissionName, state) {
  const statusBadge = document.querySelector(`[data-permission-status="${permissionName}"]`);
  const remediationBox = document.querySelector(`[data-remediation="${permissionName}"]`);
  if (statusBadge) {
    statusBadge.textContent = state;
  }
  if (remediationBox) {
    // Show remediation instructions whenever permission is explicitly denied
    remediationBox.hidden = state !== 'denied';
  }
}
```

### 2. Declare `targetAddressSpace` in `fetch()` and `Request`

When an `https://` page requests an `http://` endpoint on the local network or loopback interface, set `targetAddressSpace: 'local'` or `targetAddressSpace: 'loopback'` in the `fetch()` or `Request` options. This does two things:

1. Mixed-content exemption. Mixed-content checks run before DNS resolution, so the declaration tells the browser in advance that the `http://` URL (including a custom DNS hostname that resolves to a local IP) targets a local or loopback endpoint and should be exempt from mixed-content blocking once the user grants permission.
2. Address-space verification. After DNS resolution, the browser checks that the resolved IP really belongs to the declared space. If a hostname declared `'local'` resolves to a `public` IP, the request fails at once with a `TypeError` network error.

```javascript
/**
 * Connects to a local network device (e.g., LAN printer or IoT hub) over HTTP.
 * Example endpoint URL is illustrative; replace with your device's address.
 */
export async function fetchLocalDeviceStatus(deviceUrl = 'http://192.168.1.100:8080/api/status') {
  const request = new Request(deviceUrl, {
    method: 'GET',
    mode: 'cors',
    // 'local' for RFC 1918 and .local LAN addresses.
    targetAddressSpace: 'local',
  });

  const response = await fetch(request);
  if (!response.ok) {
    throw new Error(`Device responded with HTTP ${response.status}`);
  }
  return response.json();
}

/**
 * Connects to a local companion daemon running on the user's loopback interface.
 * Example loopback port is illustrative; replace with your service's port.
 */
export async function fetchLoopbackDaemon(daemonUrl = 'http://127.0.0.1:45678/health') {
  const request = new Request(daemonUrl, {
    method: 'GET',
    mode: 'cors',
    // 'loopback' for 127.0.0.1, [::1] and localhost.
    targetAddressSpace: 'loopback',
  });

  const response = await fetch(request);
  if (!response.ok) {
    throw new Error(`Companion app responded with HTTP ${response.status}`);
  }
  return response.json();
}
```

### 3. `WebSocket` and `WebTransport`

LNA also governs `WebSocket` and `WebTransport` connections.

- `WebSocket`: the second argument of `new WebSocket(url, protocols)` is only a subprotocol string or array; passing a `{ targetAddressSpace }` object throws `SyntaxError`. Instead, the browser inspects the URL before DNS resolution. A `ws://` connection from an `https://` page is exempt from mixed-content blocking, and gated behind the `local-network` or `loopback-network` prompt, when the host is recognizably local or loopback from its syntax: a private or loopback IP literal (`ws://192.168.1.100:8080`, `ws://127.0.0.1:8080`, `ws://[::1]:8080`), `localhost` (`*.localhost`), or a `.local` mDNS hostname (`ws://device.local:8080`). For a local endpoint reached through a custom non-`.local` DNS hostname, connect over `wss://`.
- `WebTransport`: it always requires `https://` (HTTP/3 over QUIC, with TLS or `serverCertificateHashes` for local self-signed certificates), so it never hits mixed-content blocking and takes no `targetAddressSpace` option. The browser verifies the resolved address space itself and gates the `transport.ready` promise behind the `local-network` or `loopback-network` prompt.

```javascript
/**
 * Opens a WebSocket connection to a local network device (IP literal, .local, or localhost).
 */
export function openLocalWebSocket(wsUrl = 'ws://192.168.1.100:8080/stream') {
  // Pass only subprotocol string(s) as the second argument (never an options object).
  // Browsers exempt ws:// from Mixed Content when the host is a local/loopback IP literal,
  // .local, or localhost, and gate the connection on 'local-network' or 'loopback-network'.
  const socket = new WebSocket(wsUrl, ['v1.telemetry']);
  return socket;
}

/**
 * Opens a WebTransport session to a local network endpoint using a pinned self-signed certificate hash.
 */
export async function openLocalWebTransport(wtUrl = 'https://192.168.1.100:4433/wt', certSha256Bytes) {
  const transport = new WebTransport(wtUrl, {
    serverCertificateHashes: [
      {
        algorithm: 'sha-256',
        value: certSha256Bytes,
      },
    ],
  });

  // transport.ready resolves only after the user grants the 'local-network' permission
  // and rejects with WebTransportError if the permission is denied.
  await transport.ready;
  return transport;
}
```

### 4. Delegate access to cross-origin iframes with `Permissions-Policy`

`local-network` and `loopback-network` have a default allowlist of `'self'`, so cross-origin `<iframe>` embeds cannot make local or loopback requests. To let an embedded cross-origin iframe (such as a hardware setup widget, or an SSO frame that talks to a local agent) make them, delegate the permissions in the iframe's `allow` attribute and/or the HTTP `Permissions-Policy` header:

```html
<!-- Delegate granular local-network and loopback-network permissions to the embedded iframe -->
<iframe
  src="https://setup.partner.example.com/device-bridge"
  allow="local-network; loopback-network"
  title="Local Device Bridge">
</iframe>
```

Send the `Permissions-Policy` header on the top-level (embedding) document's response, not on the iframe's response:

```http
Permissions-Policy: local-network=(self "https://setup.partner.example.com"), loopback-network=(self "https://setup.partner.example.com")
```

## Browser support and fallback

Browser support for Local network access: Limited availability.
Supported by: Chrome 145 (Feb 2026) and Edge 145 (Feb 2026).
Unsupported in: Firefox and Safari.

If your Baseline target lacks LNA permissions and `targetAddressSpace`, feature-detect and fall back progressively:

1. Wrap `navigator.permissions.query({ name: permissionName })` in try/catch. If it throws `TypeError` because `'local-network'` or `'loopback-network'` is not a recognized `PermissionName`, treat the state as `'prompt'` and still make the request on an explicit user click; where LNA is supported, the connection attempt itself triggers the prompt.
2. Never query the legacy combined name `{ name: 'local-network-access' }`. In older Chrome versions it crashes the renderer process, which try/catch cannot prevent. Newer Chrome treats it only as a legacy alias for the two granular permissions.
3. Handle failures on `fetch()`, `WebSocket` error events and `transport.ready`: catch `TypeError` and connection errors, and show remediation steps (check that the device is powered on, on the same network, and allowed in browser permissions).

```javascript
/**
 * Cross-browser permission check for the granular LNA permissions.
 * Never falls back to querying 'local-network-access', which crashes older Chrome versions.
 * @param {'local-network' | 'loopback-network'} permissionName
 */
export async function queryLnaPermissionSafe(permissionName) {
  if (!navigator.permissions?.query) {
    return 'prompt';
  }
  try {
    const status = await navigator.permissions.query({ name: permissionName });
    return status.state;
  } catch {
    // Unrecognized permission name; proceed on user gesture
    return 'prompt';
  }
}
```
