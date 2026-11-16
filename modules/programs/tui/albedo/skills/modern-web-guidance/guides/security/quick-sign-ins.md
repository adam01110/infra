# Quick sign-ins with immediate UI mode

Sending a signed-out user to a separate sign-in page when they click "Sign in", start checkout, favorite an item or hit an article paywall loses their context and increases drop-off. Immediate UI mode (`uiMode: 'immediate'` in `navigator.credentials.get()`) enables in-place sign-in: the browser shows a unified account chooser right away when local passkeys (`publicKey`) or saved passwords (`password: true`) exist on the device.

A standard modal WebAuthn prompt always shows browser UI and falls back to cross-device QR codes or external security keys. Immediate UI mode instead fails fast with `NotAllowedError` when no eligible credentials are available locally. Returning users sign in with one tap where they are, and users without local credentials move on to your normal sign-in page, guest checkout or inline sign-in form.

## When to use it

Call immediate UI mode in a user-initiated event handler (it needs transient user activation) at a moment of clear intent, right before you would navigate away from the page. On success, complete the user's intent at once, either by updating the page in place or by going straight to the authenticated destination. On `NotAllowedError`, show a sign-in or registration flow that completes the user's intent afterwards.

Use cases:

- Header sign-in link: intercept the click on a global "Sign in" link (`event.preventDefault()`) to sign returning users in immediately; on `NotAllowedError`, continue to the sign-in page.
- Sign-in before checkout: when a shopper clicks "Proceed to checkout", sign them in with one tap and go straight to shipping and payment; on fallback, show the normal sign-in or guest checkout screen.
- Micro-actions (Favorite, Like, Bookmark, Save): when a signed-out user clicks one, sign in in place and complete the action (for example by setting `aria-pressed="true"`); on fallback, open a sign-in modal or the sign-in page with a return URL parameter.
- Soft paywalls: when a reader clicks "Continue reading with your account", sign in in place; on fallback, expand an inline sign-in or registration form.

Where not to use it:

- Not on a dedicated sign-in page. Never put `uiMode: 'immediate'` on the main "Sign in" or "Sign in with a passkey" button of the sign-in page itself. Users reach that page precisely when they have no local credentials on this device, or want to use a passkey on another device (QR code) or a hardware security key. Immediate mode hides the QR code and security key options and throws `NotAllowedError` when there are no local credentials, so the button would do nothing and leave the user stuck. On a dedicated sign-in page, use conditional UI (`mediation: 'conditional'` with `autocomplete="username webauthn"`) on the inputs plus a button that calls the standard modal `navigator.credentials.get({ publicKey })` (see the `passkey-authentication` guide).
- Not for step-up reauthentication. Never use it to re-verify a signed-in user before a sensitive operation (changing a password, updating a shipping address, editing saved payment methods, adding a passkey). Reauthentication must limit the prompt to the signed-in user's credentials with a non-empty `allowCredentials`, which immediate mode rejects with `NotAllowedError`; leaving `allowCredentials` out would let the user pick a different account from the one signed in. Follow the `passkey-reauthentication` guide instead.

## Privacy and security constraints

Browsers enforce these rules on `uiMode: 'immediate'` requests:

- Transient user activation is required, which prevents silent credential probing. Call `navigator.credentials.get({ uiMode: 'immediate' })` inside a user-initiated handler (such as a `click` listener on a `<button>` or `<a>`), never automatically on page load (`DOMContentLoaded`). The call does not consume the activation.
- No non-empty `allowCredentials`. Browsers reject any immediate-mode request with a non-empty `publicKey.allowCredentials` with `NotAllowedError`, so relying parties cannot probe for specific credential IDs to infer past visits or track users across sessions.
- No `signal`. Browsers do not allow the immediate dialog to be dismissed programmatically, so do not set an `AbortSignal` on the request. If the page also runs a background conditional UI request (`mediation: 'conditional'`), call `abort()` on that request's `AbortController` before the immediate call.
- In Incognito and private browsing windows, requests always reject with `NotAllowedError`, so a private session looks the same as one without local credentials.

## Server side

### Options endpoint

Generate discoverable WebAuthn request options for signed-out visitors:

1. Set `rpId` explicitly, matching the RP ID used at registration, so the client can pass `publicKey.rpId` straight to Signal API calls.
2. Generate a cryptographically random challenge, store it in the session, and send it Base64URL-encoded.
3. Set `userVerification: 'preferred'` and store `expectedUserVerification: 'preferred'` in the session.
4. Leave out `allowCredentials`; browsers reject a non-empty list in immediate mode with `NotAllowedError`.

```javascript
router.post('/api/login/options', (req, res) => {
  const options = {
    challenge: serverGeneratedBase64UrlChallenge, // High-entropy random challenge stored in session
    rpId: 'example.com',
    userVerification: 'preferred',
  };

  req.session.challenge = options.challenge;
  req.session.expectedUserVerification = 'preferred';
  return res.json(options);
});
```

### Verification endpoints for both credential types

`navigator.credentials.get({ password: true, publicKey, uiMode: 'immediate' })` can resolve with a passkey (`PublicKeyCredential`) or a saved password (`PasswordCredential`), so verify both:

1. WebAuthn assertion (`/api/login/verify`): verify against the session challenge and the stored public key. If the credential ID is not in the database, return HTTP `404` so the client can tell the password manager through `PublicKeyCredential.signalUnknownCredential()`.
2. Password (`/api/login/password`): check `username` (`cred.id`) and `password` (`cred.password`) against the user database and start an authenticated session.

## Client side

1. Decode the server options with `PublicKeyCredential.parseRequestOptionsFromJSON()` and, inside a user-initiated click handler, call `navigator.credentials.get()` with `password: true`, `publicKey` and `uiMode: 'immediate'`, without `signal`.
2. Branch on `cred.type`:
    - `'public-key'`: serialize with `cred.toJSON()` and POST it to the WebAuthn verification endpoint. On HTTP `404`, call `PublicKeyCredential.signalUnknownCredential({ rpId: publicKey.rpId, credentialId: encoded.id })`. Take `rpId` from the server's options; never derive it from or fall back to `window.location.hostname`, because the server's RP ID may be a registrable parent domain (such as `example.com` on `shop.example.com`) or use Related Origin Requests.
    - `'password'`: POST `{ username: cred.id, password: cred.password }` to the password verification endpoint.
3. Catch `NotAllowedError` (thrown at once when the device has no local passkeys or saved passwords, or when the user dismisses the chooser) and switch to your standard sign-in flow, such as an inline sign-in dialog or `/signin` with a return URL. When you reveal an inline sign-in form or dialog, move focus to its first interactive control and announce the change in a polite live region (`role="status"`).
4. When in-place sign-in (or the fallback form) hides the sign-in trigger or inline form, move focus back to the control that started the action, or to a surviving signed-in control in the header, so keyboard focus does not fall to `document.body`. Announce the signed-in state in a `role="status"` live region.

```javascript
let isAuthenticating = false;

async function authenticateWithImmediateUi() {
  // Defined under "Browser support and fallbacks": throws NotAllowedError if immediateGet is unsupported.
  await ensureImmediateUiSupported();

  const optionsResponse = await fetch('/api/login/options', { method: 'POST' });
  if (!optionsResponse.ok) {
    throw new Error('Failed to fetch authentication options');
  }
  const optionsJSON = await optionsResponse.json();
  const publicKey = PublicKeyCredential.parseRequestOptionsFromJSON(optionsJSON);

  // Passwords and passkeys, uiMode: 'immediate', and no signal.
  const cred = await navigator.credentials.get({
    password: true,
    publicKey,
    uiMode: 'immediate',
  });

  if (!cred) {
    throw new DOMException('No credential returned', 'NotAllowedError');
  }

  if (cred.type === 'public-key') {
    const encoded = cred.toJSON();
    const verifyResponse = await fetch('/api/login/verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(encoded),
    });

    if (verifyResponse.status === 404) {
      if (PublicKeyCredential.signalUnknownCredential) {
        await PublicKeyCredential.signalUnknownCredential({
          rpId: publicKey.rpId, // Server-provided, not window.location.hostname.
          credentialId: encoded.id, // Base64URL-encoded credential ID string
        });
      }
      throw new Error('Passkey credential is no longer recognized by the server');
    }

    if (!verifyResponse.ok) {
      throw new Error('Passkey verification failed');
    }
    return await verifyResponse.json();
  }

  if (cred.type === 'password') {
    const verifyResponse = await fetch('/api/login/password', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: cred.id,
        password: cred.password,
      }),
    });

    if (!verifyResponse.ok) {
      throw new Error('Password verification failed');
    }
    return await verifyResponse.json();
  }

  throw new Error(`Unsupported credential type: ${cred.type}`);
}

// Example: intercepting a micro-action (Favorite button); a header sign-in link works the same way.
const favoriteButton = document.getElementById('favorite-btn');

favoriteButton.addEventListener('click', async (event) => {
  event.preventDefault();
  if (isAuthenticating) return;

  // If already signed in, toggle the micro-action state immediately
  if (document.body.dataset.signedIn === 'true') {
    const nextPressed = favoriteButton.getAttribute('aria-pressed') !== 'true';
    favoriteButton.setAttribute('aria-pressed', String(nextPressed));
    return;
  }

  isAuthenticating = true;
  try {
    const user = await authenticateWithImmediateUi();
    // Complete the user's intended action immediately, restore focus so hiding
    // sign-in UI does not drop focus to document.body, and announce status
    document.body.dataset.signedIn = 'true';
    favoriteButton.setAttribute('aria-pressed', 'true');
    updateHeaderUserState(user);
    favoriteButton.focus();
  } catch (err) {
    if (err.name === 'NotAllowedError') {
      // No local credentials available or user dismissed dialog:
      // reveal fallback sign-in UI (moving focus to its first input) or redirect with return URL
      showFallbackSignInUi({ returnAction: 'favorite', returnFocusEl: favoriteButton });
      return;
    }
    console.error('Authentication error:', err);
  } finally {
    isAuthenticating = false;
  }
});
```

## Browser support and fallbacks

### Immediate UI mode

Treat `uiMode: 'immediate'` as a progressive enhancement. Do not infer support from browser name or version; the only reliable signal is `capabilities.immediateGet` from `PublicKeyCredential.getClientCapabilities()`. Always check it before calling `navigator.credentials.get({ uiMode: 'immediate' })`: browsers that do not know `uiMode` ignore the unknown key and open a blocking modal passkey and QR code dialog. When `immediateGet` is falsy, or the call rejects with `NotAllowedError`, fall back to your standard sign-in experience (an inline sign-in modal, or the sign-in page with a return URL parameter), so users of unsupported browsers see the existing flow unchanged:

```javascript
async function isImmediateUiSupported() {
  if (!window.PublicKeyCredential || !PublicKeyCredential.getClientCapabilities) {
    return false;
  }
  try {
    const capabilities = await PublicKeyCredential.getClientCapabilities();
    return Boolean(capabilities?.immediateGet);
  } catch {
    return false;
  }
}

// Call this first in authenticateWithImmediateUi() (see the example above).
async function ensureImmediateUiSupported() {
  // Unsupported browsers would open a modal passkey and QR code dialog instead.
  if (!(await isImmediateUiSupported())) {
    // NotAllowedError lets the caller's catch treat "unsupported" like "no local credentials".
    throw new DOMException('Immediate UI mode is not supported', 'NotAllowedError');
  }
}
```

### Client capabilities detection

Baseline status for the api.PublicKeyCredential.getClientCapabilities_static capability: Newly available. It's been Baseline since 2025-02-06.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), Firefox 135 (Feb 2025), and Safari 17.4 (Mar 2024).

Load `webauthn-polyfills` so `PublicKeyCredential.getClientCapabilities()` is available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.

### Password credentials

Browser support for Password credentials: Limited availability.
Supported by: Chrome 60 (Jul 2017) and Edge 79 (Jan 2020).
Unsupported in: Firefox and Safari.

With `password: true` alongside `publicKey`, supporting browsers include saved passwords from their password manager in the unified immediate account chooser. Browsers without `PasswordCredential` ignore `password: true`, or fail the `capabilities.immediateGet` check and fall back to the standard sign-in form, where `<input autocomplete="username webauthn">` and `<input type="password" autocomplete="current-password">` provide native password autofill.

### JSON serialization

Baseline status for the api.PublicKeyCredential.parseRequestOptionsFromJSON_static capability: Newly available. It's been Baseline since 2025-03-31.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 119 (Oct 2023), and Safari 18.4 (Mar 2025).

Load `webauthn-polyfills` so `PublicKeyCredential.parseRequestOptionsFromJSON()` and `PublicKeyCredential.prototype.toJSON()` are available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.

### Signal API

Browser support for Web authentication signal methods: Limited availability.
Supported by: Chrome 132 (Jan 2025), Edge 132 (Jan 2025), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

The WebAuthn Signal API (`webauthn-signals`) is a progressive enhancement that removes stale passkeys from the user's password manager when the server answers HTTP `404`. Gate calls behind `if (PublicKeyCredential.signalUnknownCredential)`. Where it is unsupported, skip the call and show a clear message suggesting the user sign in another way.
