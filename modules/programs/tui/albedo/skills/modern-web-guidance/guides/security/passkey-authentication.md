# Passkey Authentication

How to sign in returning users with discoverable passkey credentials, both from an explicit button and from browser autofill suggestions (conditional UI).

## Server side

### Options endpoint

Generate the WebAuthn request options with a vetted server-side WebAuthn library (listed in the `passkeys` guide).

1. RP ID: use the predefined RP ID as a constant string and return it as `rpId` in the request options, so the client can pass `publicKey.rpId` straight to Signal API calls.
2. Challenge: generate a high-entropy, cryptographically secure random buffer, store it in the user's session, and send it Base64URL-encoded.
3. Discoverable credentials: set `allowCredentials` to an empty array `[]`. The user then does not need to enter a username first; the passkey provider shows the available accounts.
4. User verification: set `userVerification: "preferred"`, or `"required"` if a compliance policy demands it. Store the requested level in the server session at the options endpoint rather than having the client send it back in a query string, so the verification endpoint can enforce it without client manipulation.

```javascript
// Discoverable flow.
const options = {
  challenge: serverGeneratedBase64UrlChallenge, // High-entropy random challenge, stored in the session.
  rpId: "example.com",
  allowCredentials: [], // Request discoverable passkeys.
  userVerification: "preferred",
};

req.session.expectedUserVerification = "preferred";
```

### Verification endpoint

1. Require the challenge in the client response to match the one stored in the session.
2. Enforce the stored user-verification level. If the session's `expectedUserVerification` is `"preferred"`, pass `requireUserVerification: false` (the SimpleWebAuthn option name; other libraries have an equivalent) to your verification library so authenticators without user verification (for example with the screen lock disabled) are accepted. If it is `"required"`, strictly require biometric or PIN verification.
3. If the credential ID from the client is not in the database, return HTTP `404` so the client can call the Signal API.

## Client side

### Form markup

Add `webauthn` to the username field's `autocomplete` tokens (space-separated, as in `autocomplete="username webauthn"`) so the browser offers passkeys in autofill (conditional UI).

Put `autofocus` on the username field only on dedicated sign-in pages and sign-in dialogs, so the autofill options appear immediately. Leave it off on pages or dialogs that are not dedicated sign-in forms, and on sign-in forms embedded in a larger page. When you do use `autofocus`, give the page a concise, descriptive title, or the dialog a concise, descriptive accessible name, and point `aria-describedby` on the autofocused element at text that gives screen reader users the context and instructions.

```html
<h1 id="signin-passkey">Sign In with Passkey</h1>
<form id="signin-form">
  <input
    type="text"
    name="username"
    aria-describedby="signin-passkey"
    autocomplete="username webauthn"
    autofocus
    data-testid="username-field"
  />
  <input type="password" name="password" autocomplete="current-password" />
  <button type="submit">Sign in</button>
</form>
```

### Button flow

Start passkey authentication when the user clicks a "Sign in with passkey" button. Abort any pending autofill (conditional get) request first, so the two prompts do not collide.

### Autofill flow (conditional mediation)

Start this on page load, so passkeys are offered when the user focuses a sign-in field:

1. Feature-detect: call `PublicKeyCredential.getClientCapabilities()` and skip passkey autofill if `conditionalGet` is unavailable.
2. Decode the fetched options with `PublicKeyCredential.parseRequestOptionsFromJSON()`.
3. Call `navigator.credentials.get()` with `mediation: "conditional"` and an `AbortController` signal. This registers the autofill suggestions without showing a passkey dialog.
4. Wrap `navigator.credentials.get()` in try/catch:
    - `NotAllowedError`: the user cancelled the prompt or it timed out.
    - `AbortError`: the request was aborted programmatically.
5. Encode the `AuthenticatorAssertionResponse` with `credential.toJSON()` before sending it to the server.
6. Wrap the verification `fetch()` in try/catch:
    - Show the user an error message that explains what went wrong (app-specific UI; the example below only logs).
    - Call `signalUnknownCredential()` only when the server answers HTTP `404` (credential not found) and the user is not signed in.
    - Pass `rpId: publicKey.rpId` from the server's request options, not `window.location.hostname`: the server's RP ID may be a registrable parent domain (such as `example.com` on `login.example.com`) or use Related Origin Requests.
    - Pass the Base64URL-encoded credential ID string (such as `encoded.id`) as `credentialId`, not the raw `ArrayBuffer` `credential.rawId`.

```javascript
// optionsFetch and loginVerifyFetch are app-defined HTTP requests.
import { optionsFetch, loginVerifyFetch } from "./api.js";

let autofillAbortController = new AbortController();

async function signalIfUnknown(response, publicKey, encoded) {
  // This runs before sign-in, so the "user not signed in" condition holds.
  if (response.status === 404 && PublicKeyCredential.signalUnknownCredential) {
    await PublicKeyCredential.signalUnknownCredential({
      rpId: publicKey.rpId, // Server-provided, not window.location.hostname.
      credentialId: encoded.id, // Base64URL-encoded credential ID.
    });
  }
}

async function initializeConditionalAutofill() {
  const capabilities = await PublicKeyCredential.getClientCapabilities();
  if (capabilities.conditionalGet !== true) {
    return;
  }
  const loginOptionsJSON = await optionsFetch();
  const publicKey =
    PublicKeyCredential.parseRequestOptionsFromJSON(loginOptionsJSON);

  try {
    const credential = await navigator.credentials.get({
      publicKey,
      signal: autofillAbortController.signal,
      mediation: "conditional",
    });

    const encoded = credential.toJSON();
    const response = await loginVerifyFetch(encoded);
    await signalIfUnknown(response, publicKey, encoded);
  } catch (err) {
    // Expected WebAuthn exceptions are ignored silently.
    if (["NotAllowedError", "AbortError"].includes(err.name)) {
      return;
    }
    console.error("Unexpected conditional get error:", err);
  }
}

async function triggerButtonAuthentication() {
  // Abort the pending conditional get so the prompts do not collide.
  autofillAbortController.abort();
  autofillAbortController = new AbortController();

  const loginOptionsJSON = await optionsFetch();
  const publicKey =
    PublicKeyCredential.parseRequestOptionsFromJSON(loginOptionsJSON);

  let credential;
  try {
    credential = await navigator.credentials.get({
      publicKey,
      signal: autofillAbortController.signal,
    });
  } catch (err) {
    if (err.name === "NotAllowedError") {
      console.log("User cancelled passkey login.");
    } else if (err.name === "AbortError") {
      console.log("The authentication operation was aborted.");
    }
    // Re-arm autofill suggestions after the button prompt is dismissed.
    initializeConditionalAutofill();
    return;
  }

  const encoded = credential.toJSON();
  try {
    const response = await loginVerifyFetch(encoded);
    await signalIfUnknown(response, publicKey, encoded);
  } catch (serverErr) {
    console.error("Verification request error:", serverErr);
  }
}

window.addEventListener("DOMContentLoaded", initializeConditionalAutofill);
```

## Browser support and fallbacks

### Passkey feature detection

Baseline status for the api.PublicKeyCredential.getClientCapabilities_static capability: Newly available. It's been Baseline since 2025-02-06.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), Firefox 135 (Feb 2025), and Safari 17.4 (Mar 2024).

Load `webauthn-polyfills` so `PublicKeyCredential.getClientCapabilities()` is available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.

### Signal API

Browser support for Web authentication signal methods: Limited availability.
Supported by: Chrome 132 (Jan 2025), Edge 132 (Jan 2025), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

The WebAuthn Signal API (`webauthn-signals`) keeps password managers in sync with the server's credential state and is a progressive enhancement. Gate calls behind `if (PublicKeyCredential.signalUnknownCredential)`; where it is unsupported, the sync is skipped without throwing.

### JSON serialization

Baseline status for the api.PublicKeyCredential.parseRequestOptionsFromJSON_static capability: Newly available. It's been Baseline since 2025-03-31.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 119 (Oct 2023), and Safari 18.4 (Mar 2025).

Load `webauthn-polyfills` so `PublicKeyCredential.parseRequestOptionsFromJSON()` and `PublicKeyCredential.prototype.toJSON()` are available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.
