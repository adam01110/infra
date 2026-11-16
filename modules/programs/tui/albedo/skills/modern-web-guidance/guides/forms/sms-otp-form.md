# SMS OTP form verification

SMS one-time passcodes (OTPs) are common for phone number verification, account recovery, step-up authentication and payment confirmation. Switching to an SMS app to memorize or copy a multi-digit code adds friction, raises drop-off, and exposes users to phishing on spoofed domains.

Semantic `<form>` markup, `<input autocomplete="one-time-code" inputmode="numeric">`, the origin-bound SMS format (`@domain #code`) and the WebOTP API (`OTPCredential`) together give a layered, progressively enhanced flow:

1. Automatic extraction and submission: browsers that support WebOTP check the origin against the `@domain #code` line in the SMS, fill the `<input>`, and start verification with a single tap.
2. Origin-bound keyboard autofill: browsers and operating systems that support `autocomplete="one-time-code"` (such as Safari on iOS, iPadOS and macOS) parse the `@domain #code` message and suggest the code in the keyboard autofill bar only when the domain matches.
3. Easy manual entry: users typing a code from another device get a numeric keypad from `inputmode="numeric"`, without the problems of `<input type="number">`.

## Security considerations

SMS OTP proves possession of a phone number and gives convenient step-up verification, but SMS and phone numbers are exposed to SIM swapping, number recycling and interception. Always pair autofill and WebOTP with the origin-bound `@domain #code` SMS format, so the browser and OS check the domain before suggesting or delivering the code. For primary, phishing-resistant authentication, prefer passkeys over SMS codes (see the `passkeys` guide).

## Form markup

Wrap the control in a `<form>` with `method="POST"` and an explicit `<button type="submit">`, and use a single `<input>` for the code.

- Use `type="text"` with `inputmode="numeric"`, never `type="number"`. An OTP is an identifier string that may have leading zeros (such as `012345`), not a quantity; `type="number"` adds spinner buttons, can strip leading zeros, and lets the scroll wheel change the value. Avoid `type="tel"` too, a legacy workaround meant for full phone numbers. `inputmode="numeric"` gives a digits-only keyboard on mobile.
- Add `autocomplete="one-time-code"` so browsers and operating systems suggest incoming SMS codes in the autofill bar when the input is focused.
- Associate a visible `<label>` through `for` and `id`, and put format instructions (linked with `aria-describedby`) above the input so autofill popovers and mobile keyboards never cover them.
- Do not split the digits across several `<input>` elements. Multi-box patterns (six `maxlength="1"` inputs) break native `one-time-code` autofill in many browsers, hinder pasting, and complicate screen reader navigation. For a segmented look, style one input with `letter-spacing` and a monospace font.

```html
<form id="otp-form" action="/verify-otp" method="POST">
  <div class="form-group">
    <label for="otp-input">Verification code</label>
    <!-- Above the input, so autofill popovers and mobile keyboards do not cover it. -->
    <p id="otp-format-hint" class="field-hint">
      Enter the 6-digit code sent to your phone.
    </p>
    <input
      type="text"
      id="otp-input"
      name="otp"
      inputmode="numeric"
      autocomplete="one-time-code"
      pattern="\d{6}"
      maxlength="6"
      aria-describedby="otp-format-hint"
      required>
  </div>
  <button type="submit">Verify code</button>
</form>
```

```css
/* Optional: space the digits of a single input visually. */
#otp-input {
  font-family: ui-monospace, monospace;
  /* At least 1rem (16px), or mobile browsers zoom on focus. */
  font-size: 1.25rem;
  letter-spacing: 0.35em;
  min-height: 48px;
  padding: 0.5rem 0.75rem;
  box-sizing: border-box;
}
```

## Origin-bound SMS format

For WebOTP and Safari's domain-bound `one-time-code` autofill to verify that the code belongs to your site, the backend must make the last line of the SMS the origin domain prefixed by `@` followed by the OTP prefixed by `#`:

```text
Your verification code is 123456.

@example.com #123456
```

Rules for the outgoing message:

- Start with a human-readable sentence containing the code, so users typing it on another device can read it.
- Put `@<domain> #<otp>` on the very last line, with `@` as its first character and no lines or signature after it.
- Use only the host: no scheme (`https://` or `http://`), port (`:8080`) or path (`/verify`) in the `@domain` token.
- Separate the tokens with exactly one space, with no whitespace inside the domain or between `#` and the code.

## Integrating the WebOTP API

WebOTP (`OTPCredential`) requires a secure context: `https://` in production, or `http://localhost` in local development. Integrate `navigator.credentials.get()` into the lifecycle and submit handler of the verification UI, rather than a detached `DOMContentLoaded` script that calls `form.submit()`:

- Tie the request to the active OTP step: start listening when the verification input is rendered and active (for example when the OTP step mounts after the user requests a code), and again each time the user clicks "Resend code".
- Pass an `AbortSignal` (`signal: ac.signal`) and call `ac.abort()` on every exit path:
  - the user submits the form manually (including a code filled by `autocomplete="one-time-code"`);
  - a new code is requested ("Resend code"): abort the previous controller before creating a new one;
  - the verification component, dialog or route unmounts.
- When the request resolves with `otp`, set `otpInput.value = otp.code` and call `form.requestSubmit()` (or call your verification function directly). Do not call `form.submit()`: it bypasses `submit` event listeners (`event.preventDefault()` and `fetch()` handlers) and skips native constraint validation.

```javascript
const otpForm = document.getElementById('otp-form');
const otpInput = document.getElementById('otp-input');

let otpAbortController = null;

function stopSmsOtpListener() {
  if (otpAbortController) {
    otpAbortController.abort();
    otpAbortController = null;
  }
}

async function startSmsOtpListener() {
  // Feature-detect WebOTP support
  if (!otpInput || !('OTPCredential' in window)) {
    return;
  }

  // Cancel any previous pending WebOTP request (e.g., when re-sending an SMS code)
  stopSmsOtpListener();
  const ac = new AbortController();
  otpAbortController = ac;

  try {
    const otp = await navigator.credentials.get({
      otp: { transport: ['sms'] },
      signal: ac.signal,
    });

    if (!otp) return;
    otpInput.value = otp.code;

    // Trigger standard form submission so submit event listeners and validation run
    if (otpForm) {
      otpForm.requestSubmit();
    }
  } catch (err) {
    // Expected when aborted by manual submission, resend, unmount, or user dismissal
    if (err && err.name === 'AbortError') {
      return;
    }
    console.error('WebOTP verification error:', err);
  }
}

otpForm.addEventListener('submit', async (event) => {
  // Abort any in-flight WebOTP request on submit.
  stopSmsOtpListener();

  // AJAX submission. To keep the native POST instead, omit preventDefault() and fetch().
  event.preventDefault();
  const formData = new FormData(otpForm);
  // await fetch(otpForm.action, { method: 'POST', body: formData });
});

// Start listening when the OTP verification step becomes active
startSmsOtpListener();
```

## Cross-origin iframe verification

Receiving an SMS OTP in a cross-origin `<iframe>` is blocked by default. It is mainly used for embedded payment confirmation, such as 3D Secure where `shop.example` embeds an issuer challenge from `bank.example`. It needs three coordinated settings:

1. Bind both origins on the last line of the SMS: the top-level domain first (`@shop.example`), then `#<otp>`, then a space and the iframe's domain (`@bank.example`):

```text
Your verification code is 123456.

@shop.example #123456 @bank.example
```

2. Delegate `otp-credentials` to the iframe's origin with a `Permissions-Policy` response header on the parent document:

```http
Permissions-Policy: otp-credentials=(self "https://bank.example")
```

3. Add `allow="otp-credentials"` to the `<iframe>`, with a descriptive `title` for screen readers:

```html
<iframe
  src="https://bank.example/verify"
  allow="otp-credentials"
  title="Payment verification">
</iframe>
```

Inside the iframe document served by `https://bank.example`, use the same `<form>` markup and the same `navigator.credentials.get({ otp: { transport: ['sms'] }, signal: ac.signal })` lifecycle as above.

## Fallback strategies

### WebOTP API

Browser support for WebOTP: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021) and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Do not load a third-party JavaScript polyfill for WebOTP: reading incoming SMS needs operating system integration. Guard the `navigator.credentials.get({ otp: { transport: ['sms'] } })` call with `if ('OTPCredential' in window)` and rely on the markup's progressive enhancement. Without `OTPCredential`:

1. Browsers that support `autocomplete="one-time-code"` (such as Safari on iOS 14+, iPadOS, and macOS with iCloud SMS relay) parse the `@domain #code` SMS and offer the code in the keyboard autofill bar when the input is focused.
2. All other browsers fall back to manual entry in the single `<input type="text" inputmode="numeric" pattern="\d{6}" maxlength="6" required>`, with a numeric keypad on mobile and submission through the `<button type="submit">`.

### Permissions Policy

Browser support for Permissions Policy: Limited availability.
Supported by: Chrome 108 (Nov 2022) and Edge 108 (Dec 2022).
Unsupported in: Firefox and Safari.

Where delegating `otp-credentials` through `Permissions-Policy` and `<iframe allow="otp-credentials">` is unsupported, the form in the cross-origin iframe degrades to `one-time-code` keyboard suggestions and manual numeric entry without unhandled exceptions.

### inputmode and AbortController

Baseline status for `inputmode`: Widely available, Baseline since 2021-12-07.
Supported by: Chrome 66 (Apr 2018), Edge 79 (Jan 2020), Firefox 95 (Dec 2021), Safari 12.1 (Mar 2019) and Safari iOS 12.2 (Mar 2019).

Baseline status for `AbortController` and `AbortSignal`: Widely available, Baseline since 2019-03-25.
Supported by: Chrome 66 (Apr 2018), Edge 16 (Oct 2017), Firefox 57 (Nov 2017), Safari 12.1 (Mar 2019) and Safari iOS 12.2 (Mar 2019).

Both work across modern browsers and need no polyfill or fallback code.
