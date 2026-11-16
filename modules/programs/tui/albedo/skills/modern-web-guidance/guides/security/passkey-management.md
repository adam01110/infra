# Passkey Management

How to let users view, rename and delete their passkeys, and keep saved credentials and account details in sync between the server and the user's password managers with the Signal API.

## Server side

The backend supports CRUD on registered credentials plus updates to the user's profile, through endpoints that:

1. List the user's credentials: return every `StoredPasskeyCredential` for the signed-in user, together with the server's configured `rpId` and the user's `passkeyUserId`, so the client never has to guess `rpId` from `window.location.hostname`. Store and return every credential `id` and `passkeyUserId` as a valid unpadded Base64URL string (`[A-Za-z0-9_-]`, no `=` padding, `length % 4 !== 1`). This includes prototype seed data and mock backends: use values such as `Buffer.from('cred-1').toString('base64url')` or `'dGVzdC1jcmVkLTE'`, never human-readable placeholders such as `'passkey-1'` or `'cred_yubikey_01'`.
2. Rename a credential: store a new nickname for a given credential ID.
3. Delete a credential by ID.
4. Update the account: accept new `name` (username) and `displayName` values for the signed-in user and return the updated profile with the server's `rpId` and the Base64URL `passkeyUserId`, so the client can sync them to the passkey provider.

```javascript
// Node.js routes for credential CRUD and account rename.
const RP_ID = 'example.com'; // Predefined server RP ID (example value; must match registration rp.id)

router.get('/api/credentials', checkUserAuthenticated, async (req, res) => {
  const credentials = await db.findCredentialsByUserId(req.user.id);
  return res.json({
    rpId: RP_ID,
    userId: req.user.passkeyUserId, // Valid unpadded Base64URL string
    credentials,
  });
});

router.put('/api/credential/:id', checkUserAuthenticated, async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;
  const cred = await db.findCredentialById(id);
  if (!cred || cred.passkeyUserId !== req.user.passkeyUserId) {
    return res.status(404).json({ error: 'Credential not found.' });
  }
  cred.name = name;
  await db.saveCredential(cred);
  return res.json(cred);
});

router.delete('/api/credential/:id', checkUserAuthenticated, async (req, res) => {
  const { id } = req.params;
  const cred = await db.findCredentialById(id);
  if (!cred || cred.passkeyUserId !== req.user.passkeyUserId) {
    return res.status(404).json({ error: 'Credential not found.' });
  }
  await db.deleteCredential(id);
  return res.json({ success: true });
});

router.put('/api/user', checkUserAuthenticated, async (req, res) => {
  const { name, displayName } = req.body;
  const updatedUser = await db.updateUser(req.user.id, { name, displayName });
  return res.json({
    ...updatedUser,
    rpId: RP_ID,
    userId: updatedUser.passkeyUserId,
  });
});
```

## Client-side management UI

Provide a settings panel where users can review and manage their sign-in methods and account details.

1. Fetch the list and render one row per credential. If it is empty, show an empty state such as "No passkeys found".
2. Look up each passkey's `aaguid` in your local registry to show its provider (see "Determine the passkey provider from AAGUID" below).
3. Each row shows:
    - Provider icon: the AAGUID-derived image or data URI.
    - Name: the AAGUID-derived provider name or the user's custom name.
    - Registration date: the stored epoch timestamp `registeredAt`, formatted as a readable date.
    - Last used date: the stored epoch timestamp `lastUsedAt`, formatted as a readable date, if present.
    - Rename button: updates the credential's nickname on the server (`PUT /api/credential/:id`). This is a server-side label only and does not call `signalCurrentUserDetails()`.
    - Delete button: deletes the credential (`DELETE /api/credential/:id`) and then syncs the remaining credential IDs with `signalAllAcceptedCredentials()`.
4. Account rename: a control to change the username (`name`) or `displayName` (`PUT /api/user`), followed immediately by `PublicKeyCredential.signalCurrentUserDetails()` to update the password manager.
5. "Create passkey" button: offer one prominently on the management page. Before rendering it, check with `PublicKeyCredential.getClientCapabilities()` that a platform authenticator is supported; if not, hide the button and encourage other MFA enrollment instead. To allow registering a security key, omit `authenticatorSelection.authenticatorAttachment` in the `navigator.credentials.create()` call.

## Signal API synchronization

The Signal API tells password managers about credential state, keeping the user's synced vault consistent with your database.

Browsers validate Base64URL encoding and length in native code (`length % 4 !== 1`, only `[A-Za-z0-9_-]`, no `=` padding). Placeholder or mock IDs such as `'passkey-1'`, `'cred:01'` or `'cred_yubikey_01'` throw `TypeError: Invalid base64url string for allAcceptedCredentialIds` on page load. Encode mock and test IDs as real unpadded Base64URL strings (such as `'dGVzdC1jcmVkLTE'` or `Buffer.from('cred-1').toString('base64url')`), and validate the format before calling the Signal API.

- Use the server-provided `rpId`, matching the `rp.id` used at registration, never `window.location.hostname`. When credentials are registered to a registrable parent domain (such as `example.com` while settings live on `accounts.example.com`) or shared through Related Origin Requests (`/.well-known/webauthn`), the hostname does not match the credential's RP ID, and the sync silently targets the wrong RP ID or throws `SecurityError`.
- Feature-detect each method before calling it (`if (PublicKeyCredential.signalAllAcceptedCredentials)`, `if (PublicKeyCredential.signalCurrentUserDetails)`).
- Every `userId` and credential ID passed to `signalAllAcceptedCredentials` and `signalCurrentUserDetails` must be a valid unpadded Base64URL string. Validate `userId` and `allAcceptedCredentialIds` first, so malformed IDs are skipped instead of throwing on load.
- Call `signalAllAcceptedCredentials()` automatically when the management page loads (for example in a `DOMContentLoaded` listener, at module initialization, or in a framework component mount hook such as `useEffect`).
- Call `signalAllAcceptedCredentials()` in the delete handler right after the delete request succeeds, and `signalCurrentUserDetails()` in the account-rename handler (`name` or `displayName`) right after that request succeeds.
- Errors are non-fatal. Signal calls are passive background sync and must not break the UI. Wrap them in try/catch and log failures with `console.warn`, not `console.error`, so sync problems do not fail the Lighthouse Best Practices audit `errors-in-console` on page load.

```javascript
// Client-side management synchronization ES module
import { listFetch, renameCredentialFetch, updateUserFetch, deleteFetch } from './api.js';

// Valid unpadded Base64URL: non-empty, [A-Za-z0-9_-] only, no '=' padding, length % 4 !== 1
function isValidBase64Url(value) {
  return typeof value === 'string' &&
    value.length > 0 &&
    value.length % 4 !== 1 &&
    /^[A-Za-z0-9_-]+$/.test(value);
}

async function syncAcceptedCredentials(rpId, userId, currentCredentialsList) {
  if (!window.PublicKeyCredential || !PublicKeyCredential.signalAllAcceptedCredentials) return;
  const credentialIds = currentCredentialsList.map(c => c.id); // Array of Base64URL credential ID strings
  if (!rpId || !isValidBase64Url(userId) || !credentialIds.every(isValidBase64Url)) {
    console.warn('SignalAllAcceptedCredentials skipped: server rpId and valid unpadded Base64URL userId and credential IDs are required.');
    return;
  }

  try {
    await PublicKeyCredential.signalAllAcceptedCredentials({
      rpId, // Server-provided, not window.location.hostname.
      userId, // Base64URL-encoded user ID from the server
      allAcceptedCredentialIds: credentialIds
    });
  } catch (e) {
    // console.warn, not console.error: see "Errors are non-fatal" above.
    console.warn('SignalAllAcceptedCredentials sync warning:', e);
  }
}

async function loadManagementPanel() {
  const response = await listFetch();
  const { rpId, userId, credentials } = await response.json();
  
  renderUI(credentials);
  // Sync accepted credentials on initial load using server-provided rpId and userId
  await syncAcceptedCredentials(rpId, userId, credentials);
}

async function performDelete(credentialId) {
  const response = await deleteFetch(credentialId);
  if (response.ok) {
    const updatedResponse = await listFetch();
    const { rpId, userId, credentials } = await updatedResponse.json();
    
    renderUI(credentials);
    // Sync remaining accepted credentials after deletion
    await syncAcceptedCredentials(rpId, userId, credentials);
  }
}

// Renaming a passkey's nickname updates the server record only
async function performCredentialRename(credentialId, newCredentialName) {
  const response = await renameCredentialFetch(credentialId, { name: newCredentialName });
  if (response.ok) {
    const updatedResponse = await listFetch();
    const { credentials } = await updatedResponse.json();
    renderUI(credentials);
  }
}

// Renaming the user's account username or displayName triggers signalCurrentUserDetails
async function performUserRename(updatedName, updatedDisplayName) {
  const response = await updateUserFetch({ name: updatedName, displayName: updatedDisplayName });
  if (response.ok && window.PublicKeyCredential && PublicKeyCredential.signalCurrentUserDetails) {
    const { rpId, userId } = await response.json();
    if (!rpId || !isValidBase64Url(userId)) {
      console.warn('SignalCurrentUserDetails skipped: server rpId and valid unpadded Base64URL userId are required.');
      return;
    }
    try {
      await PublicKeyCredential.signalCurrentUserDetails({
        rpId, // Server-provided, not window.location.hostname.
        userId, // Base64URL-encoded user ID from the server
        name: updatedName, // Updated username
        displayName: updatedDisplayName // Updated display name
      });
    } catch (e) {
      console.warn('SignalCurrentUserDetails sync warning:', e);
    }
  }
}

window.addEventListener('DOMContentLoaded', loadManagementPanel);
```

## Determine the passkey provider from AAGUID

An AAGUID (Authenticator Attestation Globally Unique Identifier) is a 128-bit identifier for an authenticator model, not a specific device. It is part of the authenticator data at registration and identifies which passkey provider (such as Google Password Manager, iCloud Keychain or 1Password) created the credential.

Use the AAGUID only to help users manage passkeys. It can be altered unless cryptographically attested, and platform passkeys currently do not support that attestation.

### 1. AAGUID registry

A community-maintained JSON map of AAGUIDs to provider names and icons:

```text
https://raw.githubusercontent.com/passkeydeveloper/passkey-authenticator-aaguids/refs/heads/main/combined_aaguid.json
```

Each entry has this shape:

```json
{
  "<aaguid-uuid>": {
    "name": "Provider Name",
    "icon_light": "data:image/png;base64,...",
    "icon_dark": "data:image/png;base64,..."
  }
}
```

### 2. Using the AAGUID after registration

After verifying a registration response, read `aaguid` from the result (`registrationInfo` in SimpleWebAuthn; other libraries expose it similarly) and look it up in the registry to fill the credential's `name` and `providerIcon`.

If the AAGUID is `'00000000-0000-0000-0000-000000000000'`, skip the lookup: set `name` to a fallback (such as a device name derived from the user agent, or "Unknown passkey provider") and `providerIcon` to `undefined`.

```javascript
import aaguids from './aaguids.json' with { type: 'json' };

const { aaguid } = registrationInfo;
if (aaguid === '00000000-0000-0000-0000-000000000000') {
  // use the device name as the passkey provider based on
  // the information derived from the user agent string,
  // or just say "Unknown passkey provider"
} else {
  const provider = aaguids[aaguid];
  const credential = {
    // ...other fields
    aaguid,
    name: provider?.name || 'Unknown passkey provider',
    providerIcon: provider?.icon_light,
  };
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

Before rendering the "Create passkey" button, check platform authenticator support with `PublicKeyCredential.getClientCapabilities()`, and hide the button if it is unsupported:

```javascript
async function isPasskeySupported() {
  if (!window.PublicKeyCredential || !PublicKeyCredential.getClientCapabilities) {
    return false;
  }
  try {
    const capabilities = await PublicKeyCredential.getClientCapabilities();
    return Boolean(capabilities.passkeyPlatformAuthenticator);
  } catch {
    return false;
  }
}

const createButton = document.getElementById('create-passkey');
if (!(await isPasskeySupported())) {
  createButton.hidden = true;
}
```

### Signal API

Browser support for Web authentication signal methods: Limited availability.
Supported by: Chrome 132 (Jan 2025), Edge 132 (Jan 2025), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

The WebAuthn Signal API (`webauthn-signals`) is a progressive enhancement that syncs server-side credential deletions and account profile changes to the user's password manager. It talks directly to the browser or OS passkey provider, so no polyfill is available where `webauthn-signals` is unsupported. Gate each call on static feature detection on `PublicKeyCredential`, so unsupported browsers skip the sync without throwing while listing, renaming, deleting and profile updates keep working on the server:

```javascript
if (window.PublicKeyCredential && PublicKeyCredential.signalAllAcceptedCredentials) {
  try {
    await PublicKeyCredential.signalAllAcceptedCredentials({
      rpId, // Server-provided RP ID (never window.location.hostname)
      userId, // Valid unpadded Base64URL user ID
      allAcceptedCredentialIds: credentialIds, // Valid unpadded Base64URL credential IDs
    });
  } catch (e) {
    console.warn('SignalAllAcceptedCredentials sync warning:', e);
  }
}

if (window.PublicKeyCredential && PublicKeyCredential.signalCurrentUserDetails) {
  try {
    await PublicKeyCredential.signalCurrentUserDetails({
      rpId, // Server-provided RP ID (never window.location.hostname)
      userId, // Valid unpadded Base64URL user ID
      name: updatedName,
      displayName: updatedDisplayName,
    });
  } catch (e) {
    console.warn('SignalCurrentUserDetails sync warning:', e);
  }
}
```
