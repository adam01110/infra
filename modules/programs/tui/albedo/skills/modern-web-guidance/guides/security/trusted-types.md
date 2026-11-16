# Prevent DOM-based XSS attacks with Trusted Types

Trusted Types prevents DOM-based cross-site scripting (DOM XSS) by requiring that values passed to dangerous browser APIs (sinks) first be converted into a typed object such as `TrustedHTML`.

Many DOM APIs, such as `innerHTML` and `document.write`, accept raw strings, so a string carrying malicious script from an untrusted source can execute. Once Trusted Types is enforced through CSP, those sinks accept only objects created by authorized policies.

## Implementation

1. Define a policy that sanitizes or transforms strings.
2. Use the policy to create Trusted Type objects from raw strings.
3. Write those objects to DOM sinks.
4. Enforce Trusted Types with a Content Security Policy (CSP).

### 1. Create a policy

Create a policy with `trustedTypes.createPolicy()`, usually delegating to a sanitizer library such as DOMPurify or to your application's HTML escaping rules:

```javascript
import DOMPurify from 'dompurify';

const myPolicy = trustedTypes.createPolicy('sanitize-html', {
  // Return a sanitized string; createPolicy() wraps it in a TrustedHTML object.
  createHTML: (input) =>
    DOMPurify.sanitize(input, { RETURN_TRUSTED_TYPE: false }),
});

// HTML escaping, for environments without a third-party sanitizer.
const escapePolicy = trustedTypes.createPolicy('escape-html', {
  createHTML: (input) =>
    String(input)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;'),
});
```

Character-level escaping (`escapePolicy`) turns all markup into plain text; it is not a context-aware HTML sanitizer. If you only need plain text, use `element.textContent`, which is not a Trusted Types sink. Never interpolate `escapePolicy.createHTML()` output into another HTML template string, such as an unquoted attribute (`<img src=${escaped}>`) or a URL attribute (`<a href="${escaped}">`, where entity escaping does not neutralize `javascript:` URLs). Whenever you accept HTML markup or attributes, use a full HTML sanitizer: DOMPurify, or `element.setHTML()` (see the `sanitize-untrusted-html` guide).

### 2. Use the policy

Call the policy's creation method instead of passing a string to the sink.

```javascript
const untrustedInput = '<p>Hello, <strong>world</strong>!</p><img src="x" onerror="alert(1)">';

// Under enforcement, this throws a TypeError:
// element.innerHTML = untrustedInput;

// Returns a TrustedHTML object with unsafe elements and attributes removed:
const cleanHTML = myPolicy.createHTML(untrustedInput);
// Result: "<p>Hello, <strong>world</strong>!</p><img src=\"x\">"
```

### 3. Migrate sinks

Convert every write to a sink so it uses a Trusted Type object. To find the writes that still pass strings, register a temporary `default` policy that logs them:

```javascript
trustedTypes.createPolicy("default", {
  createHTML(value) {
    console.warn("String passed instead of Trusted Type.");
    return DOMPurify.sanitize(value, { RETURN_TRUSTED_TYPE: false });
  },
});
```

Common sinks covered by Trusted Types:

- HTML: `element.innerHTML`, `element.outerHTML`, `document.write()`, `element.setHTMLUnsafe()`, `Document.parseHTMLUnsafe()`
- Script: `<script>` text content, `eval()`
- ScriptURL: `<script src>`, `Worker()`, `SharedWorker()`

```javascript
element.innerHTML = cleanHTML; // A TrustedHTML object.
```

The safe sanitizing methods `element.setHTML()` and `Document.parseHTML()` (see the `sanitize-untrusted-html` guide) need no Trusted Types policy, because they always remove XSS vectors natively.

### 4. Enforce with CSP

Roll out Trusted Types incrementally. Full enforcement gives the strongest protection but breaks the site if any sink write has not been migrated.

Prerequisites:

- Framework cooperation. If your framework, or any third-party library that writes to DOM sinks, does not produce `TrustedHTML` or `TrustedScript` values, enforcing Trusted Types breaks that code. Audit framework support before starting.
- Sink refactoring. Identify the dangerous sinks and refactor them to use your policies.

Rollout:

1. Report-only. Send `Content-Security-Policy-Report-Only`, which reports violations to your reporting endpoint without blocking the writes.

    ```http
    Content-Security-Policy-Report-Only: require-trusted-types-for 'script';
    ```

2. Enforcement. Once your policies are integrated and violation reports reach zero, enforce:

    ```http
    Content-Security-Policy: require-trusted-types-for 'script';
    ```

You can also restrict which policy names may be created. List your policies (such as `sanitize-html` and `escape-html`); add `dompurify` if a policy calls `DOMPurify.sanitize()`, which creates a `dompurify` policy internally; add `default` if you register a default policy during migration.

```http
Content-Security-Policy: require-trusted-types-for 'script'; trusted-types sanitize-html escape-html dompurify;
```

With this CSP, any sink write that does not use a Trusted Type throws, and so does creating a policy whose name is not listed in `trusted-types`.

The CSP can also be set with a `<meta>` element in `<head>`, though this is potentially less secure.

```html
<!-- First child of <head>: tags before it are not covered by this CSP. -->
<meta
  http-equiv="Content-Security-Policy"
  content="require-trusted-types-for 'script'; trusted-types sanitize-html escape-html dompurify;"
/>
```

## Browser support and fallback

Baseline status for Trusted types: Newly available. It's been Baseline since 2026-02-24.
Supported by: Chrome 83 (May 2020), Edge 83 (May 2020), Firefox 148 (Feb 2026), and Safari 26 (Sep 2025).

In browsers without Trusted Types, a minimal "tinyfill" keeps the code working and still runs your sanitization:

```javascript
if (!window.trustedTypes) {
  window.trustedTypes = {
    createPolicy: (name, rules) => rules,
  };
}
```

Code can then use the Trusted Types pattern everywhere. Supporting browsers enforce the types; older browsers run the sanitization logic through the mock policy, and the "TrustedHTML" values are plain strings with no enforcement at the sink.
