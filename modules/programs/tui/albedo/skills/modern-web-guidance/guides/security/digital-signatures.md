# Sign and verify data with WebCrypto

Use the Web Cryptography API (`crypto.subtle`) to sign and verify messages, tokens or artifacts in the browser with post-quantum (ML-DSA) or classical (`'Ed25519'`, `'ECDSA'`) asymmetric keys. Signatures prove data integrity and signer authenticity without a shared secret key. For establishing shared secrets and encrypting confidential payloads, see the `client-side-encryption` guide.

## 1. Choose an algorithm and generate a key pair

ML-DSA (Module-Lattice-Based Digital Signature Algorithm, NIST FIPS 204) gives lattice-based signatures that resist attacks from both classical and quantum computers.

Use `'ML-DSA-65'` by default for general-purpose signing. Choose `'ML-DSA-44'` for smaller public keys and signatures on bandwidth-constrained channels when 128-bit security is enough, or `'ML-DSA-87'` when a security policy requires NIST Category 5 (CNSA 2.0).

| Algorithm name | Security level and use | Public key (`'raw-public'`) | Signature size |
|---|---|---|---|
| `'ML-DSA-44'` | NIST Category 2 (~128-bit); smallest keys and signatures | 1312 bytes | 2420 bytes |
| `'ML-DSA-65'` | NIST Category 3 (~192-bit); recommended default | 1952 bytes | 3309 bytes |
| `'ML-DSA-87'` | NIST Category 5 (~256-bit); highest security margin | 2592 bytes | 4627 bytes |

- The algorithm name is `'ML-DSA-44'`, `'ML-DSA-65'` or `'ML-DSA-87'`. Pre-standardization names such as `'Dilithium'` or `'CRYSTALS-Dilithium'` throw `NotSupportedError`.
- Neither ML-DSA nor `'Ed25519'` takes a `hash` parameter.
- Generate the key pair with usages `['sign', 'verify']`:

```javascript
const signerKeyPair = await crypto.subtle.generateKey(
  'ML-DSA-65',
  false,
  ['sign', 'verify'],
);
```

## 2. Export and import keys

The ML-DSA algorithms reject the legacy `'raw'` format in `importKey()` and `exportKey()` with `NotSupportedError`. Use an explicit format:

- `'raw-public'`: the public key bytes (1312, 1952 or 2592 bytes). Import public keys with usage `['verify']`.
- `'raw-seed'`: the 32-byte private key seed, for all three ML-DSA algorithms. `'raw'` and `'raw-private'` both throw `NotSupportedError` on ML-DSA, so store or transmit private keys as `'raw-seed'`, `'pkcs8'` (54 bytes) or `'jwk'` (`kty: 'AKP'`). Import private keys with usage `['sign']`; passing `['sign', 'verify']` to `importKey()` throws `SyntaxError`.
- `'spki'`, `'pkcs8'` and `'jwk'`: supported for all three ML-DSA algorithms.

Export the verification key with `'raw-public'` to serialize it or share it with verifiers:

```javascript
// Signer: export the public key bytes.
const publicKeyBytes = await crypto.subtle.exportKey(
  'raw-public',
  signerKeyPair.publicKey,
);

// Verifier: import them; the usage must be ['verify'] only.
const verifierPublicKey = await crypto.subtle.importKey(
  'raw-public',
  publicKeyBytes,
  'ML-DSA-65',
  true,
  ['verify'],
);
```

If you hold only the private signing `CryptoKey` (even with `extractable: false`), derive its public `CryptoKey` with `crypto.subtle.getPublicKey()` and `['verify']`:

```javascript
const publicKey = await crypto.subtle.getPublicKey(
  signerKeyPair.privateKey,
  ['verify'],
);
```

## 3. Sign and verify

Sign with the private key through `crypto.subtle.sign()`, and check with the public key through `crypto.subtle.verify()`:

```javascript
const payloadBytes = new TextEncoder().encode(
  '{"artifact":"release-v2.4.0.tar.gz","sha256":"9f86d08..."}',
);

const signatureBuffer = await crypto.subtle.sign(
  'ML-DSA-65',
  signerKeyPair.privateKey,
  payloadBytes,
);

const isValid = await crypto.subtle.verify(
  'ML-DSA-65',
  verifierPublicKey,
  signatureBuffer,
  payloadBytes,
);
```

### Domain separation with `ContextParams`

When one key pair serves several purposes, bind each signature to a domain-separation `context` so a signature made for one purpose cannot be replayed in another part of the application or protocol. Pass a `ContextParams` dictionary (`{ name, context }`) to `sign()` and `verify()` instead of the bare algorithm name; `context` is a `BufferSource` (`Uint8Array` or `ArrayBuffer`):

```javascript
const contextBytes = new TextEncoder().encode('release-manifest-v1');

const signatureBuffer = await crypto.subtle.sign(
  { name: 'ML-DSA-65', context: contextBytes },
  signerKeyPair.privateKey,
  payloadBytes,
);

const isValid = await crypto.subtle.verify(
  { name: 'ML-DSA-65', context: contextBytes },
  verifierPublicKey,
  signatureBuffer,
  payloadBytes,
);
```

- `context` takes 0 to 255 bytes; omitting it equals passing `new Uint8Array(0)`. More than 255 bytes rejects with `OperationError`.
- `verify()` returns `true` only if the verifier passes exactly the same `context` bytes used for `sign()`.

## Browser support and fallback

Baseline status for Web Cryptography: Widely available. It's been Baseline since 2017-09-19.
Supported by: Chrome 37 (Aug 2014), Edge 12 (Jul 2015), Firefox 34 (Dec 2014), and Safari 11 (Sep 2017).

Baseline status for the api.SubtleCrypto.sign.ed25519 capability: Newly available. It's been Baseline since 2025-05-29.
Supported by: Chrome 137 (May 2025), Edge 137 (May 2025), Firefox 129 (Aug 2024), and Safari 17 (Sep 2023).

If your Baseline target may lack `SubtleCrypto.supports()` or ML-DSA, first check that the static `SubtleCrypto.supports` exists, then probe with it; when it is missing or returns `false`, fall back to `'Ed25519'` (or to `'ECDSA'` with `'P-256'` and `'SHA-256'` for browsers that predate `'Ed25519'` support):

- `supports()` is a synchronous static method on the `SubtleCrypto` constructor that returns a boolean: `globalThis.SubtleCrypto?.supports?.('sign', 'ML-DSA-65')`. `crypto.subtle.supports` is `undefined`. You can probe `'sign'`, `'verify'`, `'generateKey'`, `'importKey'`, `'exportKey'` or `'getPublicKey'`, or pass a `ContextParams` dictionary, as in `SubtleCrypto.supports('sign', { name: 'ML-DSA-65', context })`.
- Key format: browsers with modern WebCrypto also accept `'raw-public'` for `'Ed25519'` and `'ECDSA'`, but use `'raw'` in fallback paths, which target older browsers.
- Domain separation: `'Ed25519'` and `'ECDSA'` ignore a `context` property in the algorithm dictionary (WebIDL silently drops unknown members of `Algorithm` and `EcdsaParams`). In the fallback, prepend a length-prefixed `context` header to the payload so domain separation behaves the same in both suites.

```javascript
const ML_DSA_PUBLIC_KEY_ALGORITHMS = {
  1312: 'ML-DSA-44',
  1952: 'ML-DSA-65',
  2592: 'ML-DSA-87',
};

export function supportsPostQuantumSignatures() {
  return (
    typeof globalThis.SubtleCrypto?.supports === 'function' &&
    SubtleCrypto.supports('sign', 'ML-DSA-65')
  );
}

export async function generateSigningKeyPair() {
  if (supportsPostQuantumSignatures()) {
    const keyPair = await crypto.subtle.generateKey('ML-DSA-65', false, ['sign', 'verify']);
    const publicKeyBytes = new Uint8Array(
      await crypto.subtle.exportKey('raw-public', keyPair.publicKey),
    );
    return {
      suite: 'ML-DSA-65',
      keyFormat: 'raw-public',
      keyPair,
      publicKeyBytes,
    };
  }

  // Classical fallback: Ed25519
  const keyPair = await crypto.subtle.generateKey('Ed25519', false, ['sign', 'verify']);
  const publicKeyBytes = new Uint8Array(await crypto.subtle.exportKey('raw', keyPair.publicKey));
  return {
    suite: 'Ed25519',
    keyFormat: 'raw',
    keyPair,
    publicKeyBytes,
  };
}

function frameFallbackInput(payloadBytes, contextBytes) {
  if (contextBytes.byteLength > 255) {
    throw new DOMException('Context must not exceed 255 bytes', 'OperationError');
  }
  const framed = new Uint8Array(1 + contextBytes.byteLength + payloadBytes.byteLength);
  framed[0] = contextBytes.byteLength;
  framed.set(contextBytes, 1);
  framed.set(payloadBytes, 1 + contextBytes.byteLength);
  return framed;
}

export async function signPayload(
  privateKey,
  payloadBytes,
  contextBytes = new Uint8Array(0),
) {
  if (privateKey.algorithm.name.startsWith('ML-DSA')) {
    const sig = await crypto.subtle.sign(
      { name: privateKey.algorithm.name, context: contextBytes },
      privateKey,
      payloadBytes,
    );
    return new Uint8Array(sig);
  }

  const framed = frameFallbackInput(payloadBytes, contextBytes);
  const sig = await crypto.subtle.sign('Ed25519', privateKey, framed);
  return new Uint8Array(sig);
}

export async function verifyPayload(
  publicKeyOrBytes,
  signatureBytes,
  payloadBytes,
  contextBytes = new Uint8Array(0),
) {
  const publicKey =
    publicKeyOrBytes instanceof CryptoKey
      ? publicKeyOrBytes
      : await (() => {
          const bytes =
            publicKeyOrBytes instanceof Uint8Array
              ? publicKeyOrBytes
              : new Uint8Array(publicKeyOrBytes);
          const mlDsaName = ML_DSA_PUBLIC_KEY_ALGORITHMS[bytes.byteLength];
          return mlDsaName
            ? crypto.subtle.importKey('raw-public', bytes, mlDsaName, true, ['verify'])
            : crypto.subtle.importKey('raw', bytes, 'Ed25519', true, ['verify']);
        })();

  if (publicKey.algorithm.name.startsWith('ML-DSA')) {
    return crypto.subtle.verify(
      { name: publicKey.algorithm.name, context: contextBytes },
      publicKey,
      signatureBytes,
      payloadBytes,
    );
  }

  const framed = frameFallbackInput(payloadBytes, contextBytes);
  return crypto.subtle.verify('Ed25519', publicKey, signatureBytes, framed);
}
```
