# Passkey Registration

How to let users register a passkey for their account, giving them a phishing-resistant, passwordless way to sign in.

## Database

Store these fields in the credential table:

```typescript
export interface StoredPasskeyCredential {
  id: string; // Base64URL-encoded credential ID (unique lookup key)
  passkeyUserId: string; // Owning account's WebAuthn user handle (user.id), Base64URL
  credentialPublicKey: string; // Base64URL-encoded public key used to verify assertion signatures
  credentialType: "public-key";
  credentialDeviceType: "singleDevice" | "multiDevice"; // Device-bound vs cloud-synced passkey
  credentialBackedUp: boolean; // Backup state reported by the authenticator
  aaguid: string; // Authenticator Attestation GUID
  providerIcon?: string; // Provider icon from the AAGUID registry (dark or light theme URLs)
  name: string; // Provider name from the AAGUID registry
  transports: string[]; // Transport names (e.g. 'internal', 'hybrid'), needed for exclusion options
  lastUsedAt?: number; // Optional epoch timestamp of last sign-in
  registeredAt: number; // Registration epoch timestamp
  counter: number; // Authenticator signature counter, used to prevent replay attacks
}
```

## Server side

### Options endpoint

Generate the WebAuthn creation options with a vetted server-side WebAuthn library (listed in the `passkeys` guide) rather than hand-rolled cryptography.

1. RP ID: put the predefined RP ID as a constant string in `rp.id`, so the client can pass `publicKey.rp.id` straight to Signal API calls.
2. Challenge: generate a high-entropy, cryptographically secure random buffer on the server, store it in the user's session, and send it Base64URL-encoded.
3. Duplicates: list the user's existing credential IDs in `excludeCredentials`, so the authenticator does not register a second credential on the same passkey provider account.
4. Discoverable credentials: set `requireResidentKey: true` and `residentKey: "required"` in `authenticatorSelection`. Discoverable sign-in needs a discoverable credential.
5. User verification: set `userVerification` to `"preferred"` or `"required"`. Many compliance contexts (such as finance and healthcare) need `"required"` to enforce user verification at creation.
6. Attachment:
    - Promotion flow (offering a passkey right after a password sign-in or after sign-up): set `authenticatorAttachment: "platform"` to use the platform authenticator and skip external security key prompts.
    - Management flow (a settings or security page that supports external security keys as well as the platform authenticator): omit `authenticatorAttachment`.
    - One endpoint can serve both by accepting a `promotion: boolean` request flag.

```javascript
const options = {
  challenge: serverGeneratedBase64UrlChallenge, // Cryptographically random.
  rp: { id: "example.com", name: "Secure Application" },
  user: {
    id: userBase64UrlId, // Unique base64url string identifying the account.
    name: "user@example.com",
    displayName: "Jane Doe",
  },
  pubKeyCredParams: [
    { type: "public-key", alg: -7 },
    { type: "public-key", alg: -257 },
  ],
  excludeCredentials: userExistingCredentials.map((cred) => ({
    type: "public-key",
    id: cred.id,
    transports: cred.transports,
  })),
  authenticatorSelection: {
    residentKey: "required",
    requireResidentKey: true,
    userVerification: "preferred",
    ...(isPromotionFlow && { authenticatorAttachment: "platform" }),
  },
};
```

### Verification

1. Verify the challenge against the one bound to the session.
2. Check that the User Present (UP) flag in the parsed authenticator data is `true`, confirming the user was physically present at creation.
3. If the options used `userVerification: "preferred"`, configure the verification call with `requireUserVerification: false` (the SimpleWebAuthn option name; other libraries have an equivalent setting). Otherwise authenticators that register without user verification (for example with the screen lock disabled) cause spurious verification failures.

## Client side

1. Gate the UI on page load: call `PublicKeyCredential.getClientCapabilities()` and disable the "Create passkey" button if `conditionalGet` or `passkeyPlatformAuthenticator` is unavailable. This gate is for promotion entry points; a management page that also accepts security keys gates as described in the `passkey-management` guide.
2. Decode the server options with `PublicKeyCredential.parseCreationOptionsFromJSON()` and pass them to `navigator.credentials.create()`. Call `credential.toJSON()` to turn the `AuthenticatorAttestationResponse` into a JSON-serializable object before sending it to the verification endpoint.
3. Handle the WebAuthn exceptions:
    - `InvalidStateError`: a matching passkey already exists (matched through `excludeCredentials`).
    - `NotAllowedError`: the user cancelled the passkey dialog or it timed out.
    - `AbortError`: the operation was aborted.
    - `SecurityError`: not a secure origin (HTTPS) or RP ID mismatch, both configuration problems.
4. Put the verification `fetch()` in its own try/catch. When verification fails (`response.ok` is false, or the request throws), call `PublicKeyCredential.signalUnknownCredential({ rpId: publicKey.rp.id, credentialId: encodedResponse.id })`, gated on `if (PublicKeyCredential.signalUnknownCredential)`. Do not signal on the standard WebAuthn cancel errors above.
5. Take `rpId` from `publicKey.rp.id` in the server's creation options, not from `window.location.hostname`: the server's RP ID may be a registrable parent domain (such as `example.com` on `accounts.example.com`) or use Related Origin Requests.

```javascript
// optionsFetch and registerVerifyFetch are app-defined HTTP requests.
import { optionsFetch, registerVerifyFetch } from "./api.js";

async function registerPasskey(isPromotion = false) {
  const capabilities = await PublicKeyCredential.getClientCapabilities();
  if (
    !capabilities.passkeyPlatformAuthenticator ||
    !capabilities.conditionalGet
  ) {
    // Hide "Create passkey" buttons and fall back to password flows.
    showStandardPasswordFallbackUI();
    return;
  }

  const creationOptionsJSON = await optionsFetch({ promotion: isPromotion });
  const publicKey =
    PublicKeyCredential.parseCreationOptionsFromJSON(creationOptionsJSON);

  let credential;
  try {
    credential = await navigator.credentials.create({ publicKey });
  } catch (err) {
    if (err.name === "InvalidStateError") {
      console.log("A passkey already exists for this account.");
      alert("A passkey already exists for this account.");
    } else if (err.name === "SecurityError") {
      console.error("Configuration RP ID or Secure Context error.");
      alert("Configuration RP ID or Secure Context error.");
    } else if (err.name === "NotAllowedError") {
      console.log("User cancelled the passkey dialog.");
    } else if (err.name === "AbortError") {
      console.log("The creation operation has been aborted.");
    }
    return; // Do not signal an unknown credential for these errors.
  }

  const encodedResponse = credential.toJSON();
  const signalOrphan = async () => {
    if (PublicKeyCredential.signalUnknownCredential) {
      await PublicKeyCredential.signalUnknownCredential({
        rpId: publicKey.rp.id, // Server-provided, not window.location.hostname.
        credentialId: encodedResponse.id, // Base64URL-encoded credential ID.
      });
    }
  };
  try {
    const response = await registerVerifyFetch(encodedResponse);
    if (!response.ok) {
      await signalOrphan(); // The server rejected the credential, leaving it orphaned.
    }
  } catch (serverErr) {
    console.error("Server verification network failure:", serverErr);
    await signalOrphan();
  }
}
```

## Browser support and fallbacks

### Signal API

Browser support for Web authentication signal methods: Limited availability.
Supported by: Chrome 132 (Jan 2025), Edge 132 (Jan 2025), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

The WebAuthn Signal API (`webauthn-signals`) keeps password managers in sync with the server's credential state and is a progressive enhancement. Gate the call with `if (PublicKeyCredential.signalUnknownCredential)` so it is skipped where unsupported; the server then just logs the verification failure, and the password manager is not updated.

### JSON serialization

Baseline status for the api.PublicKeyCredential.parseCreationOptionsFromJSON_static capability: Newly available. It's been Baseline since 2025-03-31.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 119 (Oct 2023), and Safari 18.4 (Mar 2025).

Load `webauthn-polyfills` so `PublicKeyCredential.parseCreationOptionsFromJSON()` and `PublicKeyCredential.prototype.toJSON()` are available wherever `PublicKeyCredential` is supported:

```js
// With a bundler (`npm install webauthn-polyfills`):
import 'webauthn-polyfills';
```

Without a bundler, serve the package from your own origin or import it from a CDN such as `https://esm.sh/webauthn-polyfills@0.1.7` (pin the exact version). Give third-party URLs Subresource Integrity: the `integrity` attribute on the `<script>` element, or the import map's `integrity` field for `import` statements.
