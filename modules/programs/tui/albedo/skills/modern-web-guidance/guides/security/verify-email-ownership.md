# Verify email address ownership

Verifying that a user owns an email address (at sign-up, sign-in, checkout or account recovery) usually means sending a one-time passcode (OTP) or magic link out of band. The user has to leave the page, wait for delivery and copy a code, which adds friction, drop-off and phishing risk, and the email provider learns which relying party (RP) the user is visiting.

The Email Verification API (a client-side HTML extension) and the Email Verification Protocol (EVP, the backend cryptographic protocol) let a relying party verify that the user controls an address without sending an email. The browser mediates between the relying party and the user's email provider (the issuer):

1. The relying party puts a hidden `<input>` with `autocomplete="email-verification-token"` and a single-use cryptographic `nonce` in the same `<form>` as the email input.
2. When the user selects or types an address, the browser looks up the domain's `_email-verification.<domain>` DNS `TXT` record, checks that the user has an active session with that authoritative issuer, and requests an Email Verification Token (EVT) without revealing the relying party to the issuer.
3. The browser binds the EVT to the relying party's origin and the session `nonce` in a Key Binding JWT (KB-JWT) signed with an ephemeral browser key pair (`EVT + KB-JWT`), fills the hidden input, and submits the form.
4. The relying party's backend verifies the cryptographic chain and, if it is valid, skips the OTP or magic-link step.

## 1. Enable the origin trial and render the form

As the verifying site (relying party):

1. Provide the origin trial token on the page with the form, through the `Origin-Trial` response header or a `<meta http-equiv="origin-trial">` element.
   - Third-party origin trials: an embedded identity SDK can inject a third-party trial token, as long as the trial's registrant origin matches the issuer domain (same-site with the issuer, such as `https://issuer.example`).
2. Generate a cryptographically random nonce for every form render, with at least 128 bits of entropy (for example `randomBytes(32).toString('base64url')` from `node:crypto`). Store it in server-side session state keyed by an `HttpOnly`, `Secure`, `SameSite=Lax` session ID cookie, and render it into the hidden input's `nonce` attribute. Never store the expected nonce itself in a client cookie, where an attacker could replay the cookie together with a token. Serve the page with `Cache-Control: no-store` so back/forward navigation does not reuse a nonce that was already consumed.
3. Add the hidden token input (`autocomplete="email-verification-token"`) inside the same `<form>` as the email input (`autocomplete="email"`).

```html
<!-- Serve with:
     Origin-Trial: <YOUR_ORIGIN_TRIAL_TOKEN>
     Cache-Control: no-store -->
<form method="POST" action="/api/verify-email">
  <label for="email">Email address:</label>
  <input
    type="email"
    id="email"
    name="email"
    autocomplete="email"
    required
  />

  <!-- Must be in the same <form> as the email input.
       Generate the nonce on the server for every form render. -->
  <input
    type="hidden"
    name="token"
    nonce="SERVER_GENERATED_PER_FORM_NONCE"
    autocomplete="email-verification-token"
  />

  <button type="submit">Continue</button>
</form>
```

## 2. Verify the token on the server

Treat the submitted `token` field as untrusted input. On receipt, atomically read and delete the expected nonce from the server-side session store. If `token` is empty (the browser lacks EVP support, or the user is signed out of their email provider) or verification fails, fall back immediately to your normal OTP or magic-link flow:

```javascript
// Replace with your public relying-party origin
const RP_ORIGIN = 'https://rp.example.com';

export async function handleSignupSubmission(request) {
  const formData = await request.formData();
  const submittedEmail = String(formData.get('email') || '').trim();
  const rawToken = String(formData.get('token') || '').trim();
  // Atomically read and delete the single-use nonce from server-side session state
  const expectedNonce = await consumeSessionNonce(request);

  if (rawToken && expectedNonce) {
    try {
      await verifyEmailVerificationToken({
        rawToken,
        submittedEmail,
        expectedNonce,
        expectedAudience: RP_ORIGIN,
      });
      // Fast path: email ownership is cryptographically verified; skip OTP email.
      return completeAccountCreation(submittedEmail);
    } catch (err) {
      // Log token verification failures before falling back to standard email verification.
      console.error('Email verification token check failed:', err);
    }
  }

  // Fallback path: send standard OTP code or magic link email to submittedEmail.
  return sendTraditionalVerificationEmail(submittedEmail);
}
```

Implement `verifyEmailVerificationToken` with established SD-JWT and JOSE/JWT libraries for your backend, such as `@sd-jwt/core` and `jose` in Node.js, `sd-jwt-python` / `jwcrypto` in Python, or `sd-jwt-java` / Nimbus JOSE+JWT on the JVM, rather than hand-written JWT or SD-JWT parsing.

Steps 1–3 below form the body of `async function verifyEmailVerificationToken({ rawToken, submittedEmail, expectedNonce, expectedAudience })`, which `handleSignupSubmission` calls; it throws on any failure.

### Step 1: Parse the SD-JWT and check the email claims

After consuming the single-use `expectedNonce`, decode the SD-JWT presentation (`EVT + KB-JWT`) and check that:

- the issuer JWT (`jwt`), the Key Binding JWT (`kbJwt`) and the issuer claim (`iss`) are all present;
- `evtPayload.email_verified === true`;
- `evtPayload.email` equals the submitted email under a case-insensitive comparison (`toLowerCase()`).

```javascript
import { createHash } from 'node:crypto';
import { decodeSdJwtSync } from '@sd-jwt/core';

const hasher = (data, alg) =>
  createHash(alg === 'sha-256' ? 'sha256' : alg).update(data).digest();

const decoded = decodeSdJwtSync(rawToken, hasher);
const evtPayload = decoded.jwt.payload;
const iss = evtPayload.iss;

if (!expectedNonce || !decoded.kbJwt || !iss || evtPayload.email_verified !== true) {
  throw new Error('Missing nonce, KB-JWT, issuer, or email_verified !== true.');
}
// Compare email addresses case-insensitively.
if (evtPayload.email?.toLowerCase() !== submittedEmail.toLowerCase()) {
  throw new Error('Submitted email does not match the EVT email claim.');
}
```

### Step 2: Check DNS delegation and load the issuer JWKS

Before sending any request to `iss`, check that the email's domain delegates to exactly that issuer through a `_email-verification.<domain>` DNS `TXT` record (`iss=<issuer-host>` → `https://<issuer-host>`, with no port, path or trailing slash). Once the delegation matches `iss` byte for byte, fetch `${iss}/.well-known/email-verification` over HTTPS, confirm `metadata.issuer === iss`, and load the issuer's JSON Web Key Set (JWKS).

Some major providers (such as Gmail) omit `kid` from the EVT header. When `kid` is absent and the JWKS has several keys, `jose` throws `ERR_JWKS_MULTIPLE_MATCHING_KEYS`; the error is an `AsyncIterable` of the matching `CryptoKey`s, so iterate it with `for await (const publicKey of err)` and try each key, as in step 3.

```javascript
import dns from 'node:dns/promises';
import { createRemoteJWKSet } from 'jose';

const domain = submittedEmail.split('@')[1];
const txtRecords = (await dns.resolveTxt(`_email-verification.${domain}`)).map((r) => r.join(''));
if (!txtRecords.some((txt) => txt.startsWith('iss=') && `https://${txt.slice(4).trim()}` === iss)) {
  throw new Error(`Issuer "${iss}" is not delegated via DNS for "${domain}".`);
}

const discoveryUrl = new URL('/.well-known/email-verification', iss);
if (discoveryUrl.protocol !== 'https:') throw new Error('Issuer must use HTTPS.');
const metadata = await (await fetch(discoveryUrl)).json();
if (metadata.issuer !== iss || !metadata.jwks_uri?.startsWith('https://')) {
  throw new Error('Invalid issuer metadata or non-HTTPS jwks_uri.');
}
const issuerJwks = createRemoteJWKSet(new URL(metadata.jwks_uri));
```

### Step 3: Verify the EVT signature and the KB-JWT

Verify both signatures and the binding between the two tokens, with an explicit asymmetric algorithm allowlist (`['Ed25519', 'EdDSA', 'ES256']`):

1. EVT signature (`verifier`): verify against `issuerJwks` (catching `ERR_JWKS_MULTIPLE_MATCHING_KEYS` to try each candidate key when `kid` is missing), enforcing `iss` and a tight freshness window (`maxTokenAge: '5m'`, `clockTolerance: '1m'`).
2. Holder binding (`kbVerifier` and the `sdJwt.verify()` options): take the browser's ephemeral public key from `evtPayload.cnf.jwk`; check that `cnf.jwk.alg` and `decoded.kbJwt.header.alg` are both in `ALLOWED_ALGS` and match, treating `'Ed25519'` and `'EdDSA'` as equivalent while origin trial implementations move to the RFC 9864 name `'Ed25519'`; and verify the KB-JWT signature with `typ: 'kb+jwt'`. Pass `keyBindingNonce: expectedNonce`, `expectedKeyBindingAudience: expectedAudience` and `keyBindingMaxAgeSeconds: 300` to `sdJwt.verify()`. `@sd-jwt/core` only calls `kbVerifier` and checks `nonce`, `aud`, `iat` and `sd_hash` when `keyBindingNonce` is supplied.

```javascript
import { SDJwtInstance } from '@sd-jwt/core';
import { importJWK, jwtVerify } from 'jose';

// IETF draft-hardt-email-verification-02 (§3.3, §5.1.1) specifies RFC 9864 'Ed25519' and 'ES256'.
// Remove 'EdDSA' once live issuers (e.g. Gmail) and Chrome Origin Trial builds finish
// transitioning from 'EdDSA' (with crv: 'Ed25519') to 'Ed25519'.
const ALLOWED_ALGS = ['Ed25519', 'EdDSA', 'ES256'];
const normalizeAlg = (alg) => (alg === 'Ed25519' ? 'EdDSA' : alg);
const evtOptions = {
  typ: 'ev+sd-jwt',
  issuer: iss,
  algorithms: ALLOWED_ALGS,
  maxTokenAge: '5m',
  clockTolerance: '1m',
};

const sdJwt = new SDJwtInstance({
  hasher,
  verifier: async (data, sig) => {
    const compactEvt = `${data}.${sig}`;
    try {
      await jwtVerify(compactEvt, issuerJwks, evtOptions);
    } catch (err) {
      // When `kid` is omitted (e.g. Gmail) and multiple keys match in the JWKS,
      // jose throws JWKSMultipleMatchingKeys, which yields each matching CryptoKey.
      if (err?.code !== 'ERR_JWKS_MULTIPLE_MATCHING_KEYS') throw err;
      let matched = false;
      for await (const publicKey of err) {
        try {
          await jwtVerify(compactEvt, publicKey, evtOptions);
          matched = true;
          break;
        } catch {}
      }
      if (!matched) throw err;
    }
    return true;
  },
  kbVerifier: async (data, sig) => {
    const holderJwk = evtPayload.cnf?.jwk;
    const holderAlg = holderJwk?.alg;
    const kbAlg = decoded.kbJwt.header.alg;
    if (
      !holderAlg ||
      !kbAlg ||
      !ALLOWED_ALGS.includes(holderAlg) ||
      !ALLOWED_ALGS.includes(kbAlg) ||
      normalizeAlg(kbAlg) !== normalizeAlg(holderAlg)
    ) {
      throw new Error('Missing, disallowed, or mismatched KB-JWT algorithm.');
    }
    const holderKey = await importJWK(holderJwk, kbAlg);
    await jwtVerify(`${data}.${sig}`, holderKey, {
      typ: 'kb+jwt',
      audience: expectedAudience,
      algorithms: [kbAlg],
      maxTokenAge: '5m',
      clockTolerance: '1m',
    });
    return true;
  },
});

const verified = await sdJwt.verify(rawToken, {
  requiredClaimKeys: ['email', 'email_verified'],
  keyBindingNonce: expectedNonce,
  expectedKeyBindingAudience: expectedAudience,
  keyBindingMaxAgeSeconds: 300,
  skewSeconds: 60,
});
```

## Rules

- Verify tokens only on the server. Never validate them in client-side JavaScript or trust client-side verification state; client checks can be bypassed or forged and give the relying party no assurance.
- Parse and validate the `EVT~KB-JWT` presentation with established SD-JWT and JOSE/JWT libraries (such as `@sd-jwt/core` and `jose` in Node.js), and pass `keyBindingNonce` to `sdJwt.verify()` so key-binding verification cannot be skipped. Do not hand-roll JWT, SD-JWT or `sd_hash` parsing and signature verification.
- Generate a fresh nonce (at least 128 bits, such as `randomBytes(32).toString('base64url')`) on the server for every form render, keep it in server-side session state rather than in a client cookie, and serve the form with `Cache-Control: no-store`.
- Atomically read and delete the expected nonce as soon as the `POST` arrives, so an intercepted token cannot be replayed.
- Compare `evtPayload.email` with the submitted address case-insensitively (`email.toLowerCase()`), but keep the submitted string as entered.
- When the EVT header has no `kid`, try every key in the issuer's JWKS (providers such as Gmail omit `kid`).
- Verify DNS delegation (`_email-verification.<domain>`) before trusting any `iss` in an EVT, and confirm `metadata.issuer === iss` in the `.well-known/email-verification` response.
- Ownership is not deliverability. EVP proves the user controls the account at the authoritative provider; still send transactional welcome emails and handle bounces as usual.
- Never block account creation or sign-in because `token` is empty or verification failed; fall back to the standard OTP or magic-link flow.

## Fallback

Email verification (`autocomplete="email-verification-token"`) is a progressive enhancement over out-of-band verification (OTP codes or magic links):

- Unsupported browsers ignore the hidden input and submit an empty `token`.
- If the address's domain publishes no `_email-verification` DNS `TXT` record, or the user has no active session with their email provider in the browser, the browser submits an empty `token`.
- If the nonce has expired or was already consumed, or any step of `verifyEmailVerificationToken` in `handleSignupSubmission` fails, the server catches the error and sends a normal OTP or magic-link email without interrupting sign-up or sign-in.
