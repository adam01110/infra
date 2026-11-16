# Passkeys Orientation

Orientation for implementing framework-agnostic passkey authentication and credential management on the web.

## 1. Prerequisites

Passkeys use the Web Authentication API (WebAuthn), which imposes these constraints on every implementation:

- Secure context: `navigator.credentials.create()` and `navigator.credentials.get()` only work in secure contexts: `https://` in production, or `http://localhost` for local development.
- Relying Party (RP) ID: Every credential is bound to an RP ID, essentially the application's domain name. The RP ID in the server-side options must equal the current origin's domain or be a registrable domain suffix of it (`example.com` is valid on `login.example.com`), or be authorized through Related Origin Requests (`/.well-known/webauthn`). A mismatch throws `SecurityError` on the client.
- Read `rpId` from the server, not from `window.location.hostname`, wherever the client needs it, for example in WebAuthn Signal API calls. `window.location.hostname` does not match a parent-domain or related-origin RP ID configured on the server. Take it from the server-provided WebAuthn options (`publicKey.rp.id` or `publicKey.rpId`) or from a backend API response.

## 2. AAGUID is for UX only

The Authenticator Attestation Globally Unique Identifier (AAGUID) is a 128-bit identifier in the registration attestation data that names the authenticator model or provider (for example Google Password Manager, iCloud Keychain, 1Password).

- Use it only for UX hints, such as showing the provider's name and icon in a passkey management list.
- Never base cryptographic security or access decisions on it. Platform passkeys do not currently provide cryptographic attestation for their AAGUIDs, so a user agent can alter or simulate the value.

## 3. Server-side libraries

Generate WebAuthn options and verify signatures on the backend with a vetted open-source FIDO2/WebAuthn library rather than hand-rolled cryptography:

- JavaScript/TypeScript: SimpleWebAuthn (github.com/MasterKale/SimpleWebAuthn)
- Python: py_webauthn (github.com/duo-labs/py_webauthn)
- Java: Java WebAuthn Server (github.com/Yubico/java-webauthn-server), WebAuthn4J (github.com/webauthn4j/webauthn4j)
- .NET: .NET library for FIDO2 (github.com/abergs/fido2-net-lib)
- Go: WebAuthn Go Library (github.com/go-webauthn/webauthn)
- Ruby: WebAuthn Ruby (github.com/cedarcode/webauthn-ruby)
- PHP: WebAuthn Framework (github.com/web-auth/webauthn-framework)

These libraries are for the server only. On the client, call the native WebAuthn browser APIs directly instead of library wrappers such as SimpleWebAuthn's `startAuthentication` / `startRegistration`.

## 4. Use-case guides

Find the matching use case below and retrieve its guide before implementing. The key APIs for each use case (`PublicKeyCredential.parseCreationOptionsFromJSON`, `parseRequestOptionsFromJSON`, `signalAllAcceptedCredentials`, `signalCurrentUserDetails`, `signalUnknownCredential`, conditional mediation, AAGUID handling and so on) are documented only in the per-use-case guide, so this orientation is not enough to implement from.

- `passkey-registration`: offering passkey creation and promoting it.
- `passkey-conditional-create`: silently creating a passkey right after a successful password sign-in.
- `passkey-authentication`: sign-in through autofill (discoverable credentials) and through a button.
- `quick-sign-ins`: in-place, contextual sign-in with local passkeys and saved passwords, before any page navigation.
- `passkey-management`: listing, renaming and deleting passkeys, kept in sync with password managers.
- `passkey-reauthentication`: re-verifying a signed-in user before a sensitive step.
