# Passkey Conditional Create (Post-Login Promotion)

How to create a passkey automatically and silently right after a successful password sign-in, which raises passkey adoption without adding friction.

## When to trigger it

Trigger conditional create (silent post-login promotion) only immediately after a successful, complete sign-in that used a password.

- Skip it for passwordless flows such as magic links, SMS OTP or identity federation.
- With multi-factor authentication, wait until every factor has succeeded.
- Make sure an authenticated user session exists before calling the creation endpoints.

## Steps

### 1. Abort pending autofill

If the sign-in page uses passkey autofill (conditional get), call `abort()` on the `AbortController` of the pending `navigator.credentials.get()` request before calling `navigator.credentials.create()`. Leaving it pending conflicts with the create call.

### 2. Feature-detect

Check `conditionalCreate` from `PublicKeyCredential.getClientCapabilities()`:

```javascript
const capabilities = await PublicKeyCredential.getClientCapabilities();
if (capabilities.conditionalCreate) {
  // Conditional create is available.
}
```

### 3. Create the passkey

- Have the server's registration options include the predefined RP ID in `rp.id`. Without it, `publicKey.rp.id` is undefined on the client and the `signalUnknownCredential()` call in step 6 has no RP ID.
- Fill `excludeCredentials` with the user's existing passkey credential IDs so no duplicate is registered.
- Pass `mediation: 'conditional'` in the `navigator.credentials.create()` options. The browser then handles creation in the background or contextually, without a modal dialog.

### 4. Fail silently

Wrap `navigator.credentials.create()` in try/catch and silently ignore `InvalidStateError`, `NotAllowedError` and `AbortError`, showing no error UI. The user did not ask for a passkey here, so a failure should not interrupt them.

### 5. Relax user presence on the server for this flow only

The verification endpoint sets `requireUserPresence: false` (the SimpleWebAuthn option name; other libraries have an equivalent) only when verifying credentials from a conditional-create request. Keep strict user-presence verification for explicit passkey creation.

### 6. Clean up after failed server verification

If `navigator.credentials.create()` succeeds but server verification fails (for example the signature check fails, or the request errors), call `PublicKeyCredential.signalUnknownCredential({ rpId: publicKey.rp.id, credentialId: encodedResponse.id })` so the orphaned credential does not linger in the passkey provider. Take `rpId` from `publicKey.rp.id` in the server's creation options, not from `window.location.hostname`, which can mismatch a parent-domain or related-origin RP ID.

## Example

```javascript
// optionsFetch and registerVerifyFetch are app-defined server requests.
import { optionsFetch, registerVerifyFetch } from './api.js';

async function triggerConditionalCreate(loginAbortController) {
  const capabilities = await PublicKeyCredential.getClientCapabilities();
  if (capabilities.conditionalCreate !== true) {
    return; // Not supported on this platform.
  }

  // 1. Abort the pending autofill (conditional get) request.
  loginAbortController.abort();

  // 2. Ask the backend for conditional creation options (must include rp.id).
  const creationOptionsJSON = await optionsFetch({ conditional: true });
  const publicKey = PublicKeyCredential.parseCreationOptionsFromJSON(creationOptionsJSON);

  let credential;
  try {
    // 3. Silent creation.
    credential = await navigator.credentials.create({
      publicKey,
      mediation: 'conditional'
    });
  } catch (e) {
    // 4. Ignore the expected WebAuthn exceptions silently.
    if (!['InvalidStateError', 'NotAllowedError', 'AbortError'].includes(e.name)) {
      console.error('Unexpected conditional create error:', e);
    }
    return;
  }

  // 5. Server verification, in its own try/catch.
  const encodedResponse = credential.toJSON();
  const signalOrphan = async () => {
    if (PublicKeyCredential.signalUnknownCredential) {
      await PublicKeyCredential.signalUnknownCredential({
        rpId: publicKey.rp.id, // Server-provided, not window.location.hostname.
        credentialId: encodedResponse.id
      });
    }
  };
  try {
    const response = await registerVerifyFetch(encodedResponse);
    if (!response.ok) {
      await signalOrphan();
    }
  } catch (serverErr) {
    console.error('Verification network failure:', serverErr);
    await signalOrphan();
  }
}
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

Baseline status for the api.PublicKeyCredential.parseCreationOptionsFromJSON_static capability: Newly available. It's been Baseline since 2025-03-31.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 119 (Oct 2023), and Safari 18.4 (Mar 2025).

Load `webauthn-polyfills` so `PublicKeyCredential.parseCreationOptionsFromJSON()` and `PublicKeyCredential.prototype.toJSON()` are available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.
