# Passkey Reauthentication

How to re-verify a signed-in user with a passkey (step-up authentication) before a sensitive action such as changing a password or making a financial transfer. This guide covers only what differs from regular passkey sign-in.

## How it differs

Reauthentication limits the passkey prompt to the signed-in user's own registered credentials. This prevents account mixing and passkey spoofing during an active session.

## Server side

### Options endpoint

Fill `allowCredentials` with a `PublicKeyCredentialDescriptor` for every credential ID registered to the signed-in user. Leaving it empty or omitting it falls back to discoverable credentials, which lets any account's passkey answer and breaks session safety.

```javascript
// Node.js step-up options endpoint.
router.post("/api/reauth/options", enforceActiveSession, async (req, res) => {
  const userPasskeys = await db.findCredentialsByUserId(req.user.id);

  const options = {
    challenge: serverGeneratedBase64UrlChallenge, // Random challenge stored in the user's session.
    rpId: "example.com",
    // Only the signed-in user's credentials.
    allowCredentials: userPasskeys.map((cred) => ({
      type: "public-key",
      id: cred.id,
      transports: cred.transports, // Speeds up resolution by indicating platform transports.
    })),
  };
  return res.json(options);
});
```

### Verification endpoint

Verify the returned assertion, and check that the credential ID resolves to a stored credential whose user ID equals the signed-in user's (`storedCredential.passkeyUserId === req.user.passkeyUserId`). If a valid passkey belonging to a different user comes back, reject the reauthentication immediately.

## Client side

The reauthentication interface depends on the transaction UI. The button flow (no input fields) is shown here.

### Button flow

Start reauthentication when the user presses a button such as "Verify identity" or "Proceed with transaction". When the server answers HTTP `404` and you signal an unknown credential, pass `rpId: publicKey.rpId` from the server's request options; `window.location.hostname` does not match a parent-domain or related-origin RP ID.

```html
<button id="reauth-btn" data-testid="reauth-button">Confirm Transaction</button>
```

```javascript
let reauthAbortController = new AbortController();

async function triggerButtonReauth() {
  // Abort any background suggestion flow so passkey prompts do not collide.
  reauthAbortController.abort();
  reauthAbortController = new AbortController();

  const optionsResponse = await fetch("/api/reauth/options", {
    method: "POST",
  });
  const optionsJSON = await optionsResponse.json();
  const publicKey =
    PublicKeyCredential.parseRequestOptionsFromJSON(optionsJSON);

  try {
    const credential = await navigator.credentials.get({
      publicKey,
      signal: reauthAbortController.signal,
    });

    if (credential) {
      const encodedCredential = credential.toJSON();
      const verifyResponse = await fetch("/api/reauth/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(encodedCredential),
      });

      if (verifyResponse.ok) {
        showTransactionSuccessUI();
      } else if (verifyResponse.status === 404 && PublicKeyCredential.signalUnknownCredential) {
        await PublicKeyCredential.signalUnknownCredential({
          rpId: publicKey.rpId, // Server-provided rpId, not window.location.hostname.
          credentialId: encodedCredential.id
        });
      }
    }
  } catch (err) {
    if (err.name === "NotAllowedError") {
      console.log("User cancelled reauthentication.");
    }
  }
}

document
  .getElementById("reauth-btn")
  .addEventListener("click", triggerButtonReauth);
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
