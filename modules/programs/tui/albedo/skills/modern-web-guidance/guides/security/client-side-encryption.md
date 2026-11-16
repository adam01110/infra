# Encrypt data client-side with WebCrypto

Use the Web Cryptography API (`crypto.subtle`) to establish shared secrets over untrusted networks, with post-quantum Key Encapsulation Mechanisms (KEMs) or classical key agreement, and to encrypt data in the browser with Authenticated Encryption with Associated Data (AEAD). For signing and verifying messages or artifacts without encrypting them, see the `digital-signatures` guide.

An end-to-end envelope encryption flow has two phases:

- One-time recipient setup (steps 1–2): the recipient generates a key pair, stores the `CryptoKeyPair` in IndexedDB for later sessions, and exports the public key (`'raw-public'`) for senders.
- Per-message encryption (steps 3–4): for each payload the sender imports the recipient's public key, calls `encapsulateKey()` to get a fresh one-time shared key and ciphertext capsule, encrypts the payload with a fresh 12-byte IV, and sends `{ capsule, iv, ciphertext }` to the recipient.

## 1. Choose a KEM and generate the recipient key pair

In Diffie-Hellman key agreement (`deriveKey()`) both parties combine their keys. A KEM instead uses the recipient's public key to produce both a random shared secret and a ciphertext capsule in one `encapsulateKey()` call; the recipient recovers the same shared key from the capsule with `decapsulateKey()`.

Use `'MLKEM768-X25519'` by default. It combines post-quantum ML-KEM (NIST FIPS 203) with classical `'X25519'`, so the shared secret stays secure as long as either algorithm holds. Choose standalone `'ML-KEM-768'` when a policy requires pure FIPS 203 output with no hybrid component, or `'ML-KEM-1024'` when a policy requires NIST Category 5 (CNSA 2.0).

| Algorithm name | Security level and use | Public key (`'raw-public'`) | Private seed (`'raw-seed'`) | Ciphertext size |
|---|---|---|---|---|
| `'MLKEM768-X25519'` | Hybrid post-quantum (`'ML-KEM-768'`) + classical (`'X25519'`); recommended default | 1216 bytes | 32 bytes | 1120 bytes |
| `'ML-KEM-768'` | NIST Category 3 (~192-bit); standalone post-quantum KEM | 1184 bytes | 64 bytes | 1088 bytes |
| `'ML-KEM-1024'` | NIST Category 5 (~256-bit); highest security margin | 1568 bytes | 64 bytes | 1568 bytes |

- The algorithm name is `'MLKEM768-X25519'`, `'ML-KEM-768'` or `'ML-KEM-1024'`. Aliases such as `'X-Wing'` or `'X25519MLKEM768'`, and `'ML-KEM-512'`, throw `NotSupportedError`.
- Generate KEM key pairs with `extractable: false` and usages `['encapsulateKey', 'decapsulateKey']` (or `['encapsulateBits', 'decapsulateBits']`). Non-extractable `CryptoKey` and `CryptoKeyPair` objects can be stored in IndexedDB directly through structured cloning (`objectStore.put(recipientKeyPair, 'recipient-kem-key')`), so the private key bytes are never exported:

```javascript
const recipientKeyPair = await crypto.subtle.generateKey(
  'MLKEM768-X25519',
  false,
  ['encapsulateKey', 'decapsulateKey'],
);
```

## 2. Export and import keys

`'MLKEM768-X25519'`, `'ML-KEM-768'`, `'ML-KEM-1024'` and `'ChaCha20-Poly1305'` reject the legacy `'raw'` format in `importKey()` and `exportKey()` with `NotSupportedError`. Use an explicit format:

- `'raw-public'`: public key bytes (1216, 1184 or 1568 bytes). Import KEM public keys with `['encapsulateKey']` (or `['encapsulateBits']`).
- `'raw-seed'`: private key seed bytes (32 for `'MLKEM768-X25519'`, 64 for `'ML-KEM-768'` and `'ML-KEM-1024'`). Import KEM private keys with `['decapsulateKey']` (or `['decapsulateBits']`); passing `['encapsulateKey', 'decapsulateKey']` to `importKey()` or `getPublicKey()` throws `SyntaxError`. `'raw'` and `'raw-private'` both throw `NotSupportedError` on KEM private keys. `'MLKEM768-X25519'` supports only `'raw-public'`, `'raw-seed'` and `'jwk'`, not `'spki'` or `'pkcs8'`.
- `'raw-secret'`: symmetric secret key bytes (`'ChaCha20-Poly1305'`; also accepted for `'AES-GCM'` and `'HKDF'`).

Export the recipient's public key with `'raw-public'` so the bytes can be serialized (for example as Base64 with `new Uint8Array(recipientPublicKeyBytes).toBase64()`, or hex) and shared with senders:

```javascript
// Recipient: export the public key bytes.
const recipientPublicKeyBytes = await crypto.subtle.exportKey(
  'raw-public',
  recipientKeyPair.publicKey,
);

// Sender: import them; the usage must be ['encapsulateKey'].
const importedPublicKey = await crypto.subtle.importKey(
  'raw-public',
  recipientPublicKeyBytes,
  'MLKEM768-X25519',
  true,
  ['encapsulateKey'],
);
```

If you hold only the private `CryptoKey` (even with `extractable: false`), derive its public `CryptoKey` with `crypto.subtle.getPublicKey()`:

```javascript
const publicKey = await crypto.subtle.getPublicKey(
  recipientKeyPair.privateKey,
  ['encapsulateKey'],
);
```

## 3. Encapsulate and decapsulate a shared key

`encapsulateKey()` and `decapsulateKey()` import the 32-byte (256-bit) KEM shared secret into a `CryptoKey` for the algorithm named in `sharedKeyAlgorithm` (using `'raw-secret'` format). Pass `'ChaCha20-Poly1305'` or `'AES-GCM'` to get an AEAD encryption key directly:

```javascript
// Sender encapsulates a 256-bit AEAD key and produces a ciphertext capsule
const { sharedKey: senderKey, ciphertext: encapsulatedCiphertext } =
  await crypto.subtle.encapsulateKey(
    'MLKEM768-X25519',
    importedPublicKey,
    'ChaCha20-Poly1305', // Or 'AES-GCM'
    false,
    ['encrypt', 'decrypt'],
  );

// Recipient decapsulates the ciphertext capsule to recover the identical AEAD key
const recipientKey = await crypto.subtle.decapsulateKey(
  'MLKEM768-X25519',
  recipientKeyPair.privateKey,
  encapsulatedCiphertext,
  'ChaCha20-Poly1305',
  false,
  ['encrypt', 'decrypt'],
);
```

### Domain separation with `'HKDF'`

To bind the shared key to a protocol context (`info` and `salt`), or to derive several subkeys from one encapsulation, pass `'HKDF'` as `sharedKeyAlgorithm` with usage `['deriveKey']`, then call `crypto.subtle.deriveKey()`:

```javascript
const { sharedKey: hkdfBaseKey, ciphertext } = await crypto.subtle.encapsulateKey(
  'MLKEM768-X25519',
  importedPublicKey,
  'HKDF',
  false,
  ['deriveKey'],
);

const aeadKey = await crypto.subtle.deriveKey(
  {
    name: 'HKDF',
    hash: 'SHA-256',
    salt: new Uint8Array(32),
    info: new TextEncoder().encode('envelope-v1'),
  },
  hkdfBaseKey,
  { name: 'AES-GCM', length: 256 },
  false,
  ['encrypt', 'decrypt'],
);
```

## 4. Encrypt and decrypt with `'ChaCha20-Poly1305'` or `'AES-GCM'`

Encrypt every payload with a fresh, cryptographically random 12-byte (96-bit) IV, and never reuse an `(iv, key)` pair. Choose `'ChaCha20-Poly1305'` for consistent constant-time performance on devices without AES hardware acceleration, or `'AES-GCM'` to interoperate with existing WebCrypto or FIPS 140 deployments.

- `'ChaCha20-Poly1305'` has a fixed 256-bit (32-byte) key: `generateKey('ChaCha20-Poly1305', extractable, ['encrypt', 'decrypt'])` takes a string or `{ name: 'ChaCha20-Poly1305' }` with no `length` property. The `iv` must be exactly 12 bytes, and the 128-bit Poly1305 authentication tag is appended to the ciphertext.
- `'AES-GCM'`: pass `{ name: 'AES-GCM', length: 256 }` to `generateKey()` or `deriveKey()`, and a 12-byte `iv` to `encrypt()` and `decrypt()`.
- Bind unencrypted metadata (such as a record ID, recipient ID or protocol version) to the authentication tag through `additionalData` (AAD). Tampering with either the ciphertext or that metadata then makes `decrypt()` reject with `OperationError`.

```javascript
/**
 * Encrypts UTF-8 text with an AEAD CryptoKey ('ChaCha20-Poly1305' or 'AES-GCM').
 * @param {CryptoKey} key
 * @param {string} plaintext
 * @param {Uint8Array} [additionalData]
 */
export async function encryptMessage(key, plaintext, additionalData = new Uint8Array(0)) {
  // Fresh 12-byte (96-bit) IV for every message.
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encoded = new TextEncoder().encode(plaintext);

  const ciphertextBuffer = await crypto.subtle.encrypt(
    {
      name: key.algorithm.name,
      iv,
      additionalData,
    },
    key,
    encoded,
  );

  return { iv, ciphertext: new Uint8Array(ciphertextBuffer) };
}

/**
 * Decrypts and authenticates an AEAD payload. Throws OperationError if tampered.
 * @param {CryptoKey} key
 * @param {Uint8Array} iv
 * @param {Uint8Array} ciphertext
 * @param {Uint8Array} [additionalData]
 */
export async function decryptMessage(key, iv, ciphertext, additionalData = new Uint8Array(0)) {
  const plaintextBuffer = await crypto.subtle.decrypt(
    {
      name: key.algorithm.name,
      iv,
      additionalData,
    },
    key,
    ciphertext,
  );

  return new TextDecoder().decode(plaintextBuffer);
}
```

## Browser support and fallback

Baseline status for Web Cryptography: Widely available. It's been Baseline since 2017-09-19.
Supported by: Chrome 37 (Aug 2014), Edge 12 (Jul 2015), Firefox 34 (Dec 2014), and Safari 11 (Sep 2017).

Baseline status for the api.SubtleCrypto.deriveBits.x25519 capability: Newly available. It's been Baseline since 2025-02-06.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), Firefox 130 (Sep 2024), and Safari 17 (Sep 2023).

If your Baseline target may lack `SubtleCrypto.supports()`, `encapsulateKey()` or `'ChaCha20-Poly1305'`, first check that the static `SubtleCrypto.supports` exists, then probe with it; when it is missing or returns `false`, fall back to ephemeral-static Diffie-Hellman key agreement (`'X25519'` + `'HKDF'` + `'AES-GCM'`, or `'ECDH'` with `'P-256'` for browsers that predate `'X25519'` support):

- `supports()` is a synchronous static method on the `SubtleCrypto` constructor that returns a boolean: `globalThis.SubtleCrypto?.supports?.('encapsulateKey', 'MLKEM768-X25519', 'ChaCha20-Poly1305')`. `crypto.subtle.supports` is `undefined`. It validates operation-specific parameters: bare algorithm strings work for `'encapsulateKey'`, `'decapsulateKey'`, `'generateKey'`, `'importKey'`, `'exportKey'` and `'getPublicKey'`, but probing `'encrypt'` or `'decrypt'` needs an `iv`, as in `SubtleCrypto.supports('encrypt', { name: 'ChaCha20-Poly1305', iv: new Uint8Array(12) })`.
- Key format: browsers with modern WebCrypto also accept `'raw-public'` for `'X25519'` and `'ECDH'`, but use `'raw'` in fallback paths, which target older browsers.
- Classical fallback: when `SubtleCrypto.supports()` is missing or returns `false`, the sender generates an ephemeral `'X25519'` key pair, exports its public key as the capsule bytes, derives 256 bits with `deriveBits({ name: 'X25519', public: peerPublicKey }, privateKey, 256)`, and runs those bits through `'HKDF'` (`'SHA-256'`) to derive a 256-bit `'AES-GCM'` key.

```javascript
const KEM_PUBLIC_KEY_ALGORITHMS = {
  1184: 'ML-KEM-768',
  1216: 'MLKEM768-X25519',
  1568: 'ML-KEM-1024',
};

export function supportsPostQuantumEnvelope() {
  return (
    typeof globalThis.SubtleCrypto?.supports === 'function' &&
    SubtleCrypto.supports('encapsulateKey', 'MLKEM768-X25519', 'ChaCha20-Poly1305')
  );
}

export async function generateRecipientKeys() {
  if (supportsPostQuantumEnvelope()) {
    const keyPair = await crypto.subtle.generateKey(
      'MLKEM768-X25519',
      false,
      ['encapsulateKey', 'decapsulateKey'],
    );
    const publicKeyBytes = new Uint8Array(
      await crypto.subtle.exportKey('raw-public', keyPair.publicKey),
    );
    return { suite: 'MLKEM768-X25519+ChaCha20-Poly1305', keyPair, publicKeyBytes };
  }

  // Classical fallback: X25519 key agreement + HKDF + AES-GCM
  const keyPair = await crypto.subtle.generateKey('X25519', false, ['deriveBits']);
  const publicKeyBytes = new Uint8Array(
    await crypto.subtle.exportKey('raw', keyPair.publicKey),
  );
  return { suite: 'X25519+HKDF+AES-GCM', keyPair, publicKeyBytes };
}

async function deriveFallbackAesKey(privateKey, peerPublicKey, infoBytes = new Uint8Array(0)) {
  const sharedSecret = await crypto.subtle.deriveBits(
    { name: 'X25519', public: peerPublicKey },
    privateKey,
    256,
  );
  const hkdfKey = await crypto.subtle.importKey('raw', sharedSecret, 'HKDF', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    {
      name: 'HKDF',
      hash: 'SHA-256',
      salt: new Uint8Array(32),
      info: infoBytes,
    },
    hkdfKey,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt'],
  );
}

export async function encapsulateEnvelopeKey(
  recipientPublicKeyOrBytes,
  infoBytes = new Uint8Array(0),
) {
  const pubKey =
    recipientPublicKeyOrBytes instanceof CryptoKey
      ? recipientPublicKeyOrBytes
      : await (() => {
          const bytes =
            recipientPublicKeyOrBytes instanceof Uint8Array
              ? recipientPublicKeyOrBytes
              : new Uint8Array(recipientPublicKeyOrBytes);
          const kemName = KEM_PUBLIC_KEY_ALGORITHMS[bytes.byteLength];
          return kemName
            ? crypto.subtle.importKey('raw-public', bytes, kemName, true, ['encapsulateKey'])
            : crypto.subtle.importKey('raw', bytes, 'X25519', true, []);
        })();

  if (pubKey.algorithm.name !== 'X25519') {
    const { sharedKey, ciphertext } = await crypto.subtle.encapsulateKey(
      pubKey.algorithm.name,
      pubKey,
      'ChaCha20-Poly1305',
      false,
      ['encrypt', 'decrypt'],
    );
    return { sharedKey, capsuleBytes: new Uint8Array(ciphertext) };
  }

  // Classical fallback: generate ephemeral X25519 key pair and send ephemeral public key as capsule
  const ephemeral = await crypto.subtle.generateKey('X25519', false, ['deriveBits']);
  const capsuleBytes = new Uint8Array(await crypto.subtle.exportKey('raw', ephemeral.publicKey));
  const sharedKey = await deriveFallbackAesKey(ephemeral.privateKey, pubKey, infoBytes);
  return { sharedKey, capsuleBytes };
}

export async function decapsulateEnvelopeKey(
  recipientPrivateKey,
  capsuleBytes,
  infoBytes = new Uint8Array(0),
) {
  if (recipientPrivateKey.algorithm.name !== 'X25519') {
    return crypto.subtle.decapsulateKey(
      recipientPrivateKey.algorithm.name,
      recipientPrivateKey,
      capsuleBytes,
      'ChaCha20-Poly1305',
      false,
      ['encrypt', 'decrypt'],
    );
  }

  const ephemeralPubKey = await crypto.subtle.importKey('raw', capsuleBytes, 'X25519', true, []);
  return deriveFallbackAesKey(recipientPrivateKey, ephemeralPubKey, infoBytes);
}
```
