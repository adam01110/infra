# Forms

## 1. Semantic structure and the form element

### Guidelines

- Wrap interactive controls that collect data in a `<form>`.
- Wrap search forms and filtering controls in a `<search>` element.
- When a page has several forms, give each `<form>` an accessible name with `aria-labelledby` pointing to its heading.
- Use `method="POST"` for sensitive data and mutations, and `method="GET"` for idempotent requests such as search. `GET` exposes data in history and logs, so never use it for sensitive data.
- Set `action` to the destination URL.
- Give every form control a `name` so its data is identified on submission.
- Use semantic elements: `<button type="submit">`, `<textarea>`, `<select>` and specific `<input>` types. Do not build form controls from `<div>`, `<span>` or `<a>`.
- Set `type="button"` explicitly on secondary and helper buttons, because buttons default to `type="submit"`. Primary submit buttons keep `type="submit"`.
- Group related controls with `<fieldset>` and `<legend>`, with the `<legend>` as the first child. Do not use `<fieldset>` without a `<legend>` just for visual styling.
- Label submit buttons with actionable language, such as "Save changes".
- Do not nest `<form>` elements.
- Do not disable textarea resizing unless the layout provides an alternative.
- Do not use CSS to visually reorder controls away from their DOM and Tab order.
- Do not auto-submit when the user changes a `<select>`, radio button or checkbox; wait for an explicit submit action.

### Example

```html
<search>
  <form action="/search" method="GET">
    <label for="q">Search query</label>
    <input type="search" id="q" name="q">

    <fieldset>
      <legend>Search filters</legend>
      <input type="checkbox" id="exact" name="exact" value="true">
      <label for="exact">Exact match only</label>
      <input type="checkbox" id="archived" name="archived" value="true">
      <label for="archived">Include archived results</label>
    </fieldset>

    <button type="submit">Search</button>
  </form>
</search>
```

### Choosing a selection control

| Options | Choice type | Element | Reason |
| :--- | :--- | :--- | :--- |
| 1 | Binary toggle (yes/no) | `<input type="checkbox">` | Reversible: Space checks and unchecks it, unlike a radio button, which cannot be unchecked once checked. |
| 2–5 | Single (exclusive) | `<input type="radio">` | All choices are visible without a click, so they scan faster. |
| 6+ | Single (exclusive) | `<select>` | Saves space; use only when vertical space is scarce or the list is long. |
| 10+ or dynamic | Single (exclusive) | `<input list="id">` with `<datalist>` | Filtering by typing avoids scrolling fatigue in very large sets such as countries. |
| 2+ | Multiple | `<input type="checkbox">` | Native non-exclusive toggles. |

Rule of thumb: show 2 to 5 mutually exclusive options as visible radio buttons, and use `<select>` only when space is constrained or the list is long.

## 2. Accessible labeling and state

### Guidelines

- Associate every `<label>` with its input through `for` and `id`.
- Put labels for text inputs, `<textarea>` and `<select>` before the control in the DOM and stack them above it visually; this scans faster.
- Put labels for checkboxes and radio buttons inline, directly after the control, for consistent alignment.
- Use visible labels. Keep essential format instructions (such as "3-12 characters") in the label or in persistent helper text, not only in `placeholder`.
- Keep the space between a label and its input smaller than the space between form groups (Gestalt proximity), so each label visibly belongs to its field.
- Set `aria-invalid="true"` on controls that fail custom validation, and remove it once the problem is fixed.
- Link inputs to help text and error messages with `aria-describedby`.
- Set the `lang` attribute on `<html>` so devices translate correctly.
- Communicate state with non-color cues such as icons and text, not color alone.
- Mark required fields visibly in the label and programmatically with the `required` attribute.
- Announce dynamic errors with `aria-live`.
- Prefer a visible `<label>` over `aria-label`, and never give a control an `aria-label` that contradicts its visible text.

### Example

```html
<div class="field">
  <label for="username">Username: <span aria-hidden="true">*</span></label>
  <input type="text" id="username" name="username" aria-describedby="user-help" required>
  <span id="user-help" class="hint">3-12 characters.</span>
</div>

<style>
  .field {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
    margin-block-end: 1.5rem;
  }

  input:focus-visible {
    outline: 3px solid #0b57d0;
    outline-offset: 2px;
  }
</style>
```

## 3. Autofill and input hints

### Guidelines

- Use `autocomplete` to declare the expected data, for example `email`, `tel`, `current-password` or `new-password`.
- Use `inputmode` to pick the on-screen keyboard, for example `inputmode="numeric"` for PINs.
- Use `enterkeyhint` to set the Enter key label, for example `next` or `done`.
- Turn off text correction on fields that hold identifiers rather than prose: `autocorrect="off"`, `autocapitalize="none"` and `spellcheck="false"` on usernames, emails, URLs, codes and search inputs. Leave the defaults on for free text such as messages and comments.
- Use a single input for long numbers such as card and phone numbers; this helps autofill.
- For SMS one-time passcodes, use a single `<input type="text" inputmode="numeric" autocomplete="one-time-code">` and the WebOTP API. See the `sms-otp-form` guide.
- Do not use `type="number"` for card numbers, ZIP codes or one-time passcodes: it causes scroll-wheel problems and removes leading zeros.
- Do not split one value (a 6-digit OTP, phone number or card number) across several `<input>` boxes that auto-advance focus. Use one `type="text"` input with `inputmode="numeric"` (`type="number"` adds spinner buttons). Styling can give a similar look; for a closer match, JavaScript can set a `--value-length` CSS variable, without the usability and accessibility problems of split inputs.
- Do not block paste or disable `autocomplete` on passwords, verification codes or other authentication fields.

### Example

```html
<label for="zip">ZIP Code:</label>
<input type="text" id="zip" name="zip" autocomplete="postal-code" inputmode="numeric" pattern="\d{5}" enterkeyhint="next">

<label for="username">Username:</label>
<input type="text" id="username" name="username" autocomplete="username" autocorrect="off" autocapitalize="none" spellcheck="false" enterkeyhint="done">
```

## 4. Constraints and validation

### Guidelines

- Use native constraints: `required`, `minlength`, `maxlength`, `pattern`.
- Style errors with `:user-invalid`. Do not rely on raw `:invalid` alone, because it marks empty required fields as invalid before the user has interacted with the form.
- Use the Constraint Validation API (`setCustomValidity`, `ValidityState`) for custom messages, and write messages that explain how to fix the problem.
- When submission fails validation, move focus to the first invalid field or to an error summary.
- Keep submit buttons enabled so users can submit and see which fields need fixing. Disable the button only after a valid submission, to prevent double posts.
- Do not show validation errors or make `aria-live` announcements on every keystroke. Validate on submit or `blur`, and clear errors on `input` once fixed.

### Example

```html
<label for="code">Activation Code (4 digits):</label>
<input type="text" id="code" name="code" required pattern="\d{4}">

<script>
  const input = document.getElementById('code');
  input.addEventListener('invalid', () => {
    input.setCustomValidity('Please enter exactly 4 digits.');
  });
  input.addEventListener('input', () => {
    input.setCustomValidity('');
  });
</script>
```

### Validation timing

| Event | Phase | Action | Reason |
| :--- | :--- | :--- | :--- |
| `input` | Typing | Clear existing errors only. | Do not flag errors before the user has finished typing. |
| `blur` / `focusout` | Leaving the field | Run the check (if the field was edited) and show errors. | The user has signaled they are done with the field. |
| `submit` | Final attempt | Block submission and move focus. | Stops bad data and moves keyboard and screen reader focus to the first invalid field or an error summary. |

In short: validate on `blur` if the field was edited, clear the error on `input` as soon as the value is fixed, and on `submit` move focus to the first error or the summary.

Client-side validation is for user experience; server-side validation is for security. Never treat browser constraints as a data integrity defense.

## 5. Responsive design and typography

### Guidelines

- Use single-column layouts; they are easier to scan.
- Set `font: inherit` and `font-size: max(1rem, 1em)` on form controls so they scale with larger containers but never drop below `1rem` (16px), which prevents iOS from zooming on focus.
- Enlarge tap targets with padding tricks that do not shift layout.
- Make tap targets at least 48px.
- Use root-relative units (`rem`) and unitless `line-height`.
- Use CSS logical properties (such as `margin-inline-start`) for RTL support.

### Example

```css
.form-group {
  margin-block-end: 1.5rem;
}

/* Larger tap area without layout shift. */
label {
  display: inline-block;
  padding: 10px 0;
  margin: -10px 0;
}

input {
  font: inherit;
  font-size: max(1rem, 1em);
  padding: 0.75rem;
  min-height: 48px;
  box-sizing: border-box;
}

@media (pointer: coarse) {
  input {
    min-height: 52px;
  }
}
```

## 6. Styling form controls

### Guidelines

- Use `accent-color` to brand native radio buttons and checkboxes quickly.
- Use `appearance: none` for custom drop-down arrows; it keeps the native semantics.
- Make inputs clearly visible with enough border contrast, for example `#767676` or darker on white.
- Keep a visible `:focus-visible` indicator on every control. Remove the outline (`outline: none`) only if you provide a high-contrast alternative.
- To hide an input visually, use the canonical `.visually-hidden` recipe (`clip-path: inset(50%)` with 1px dimensions), not `display: none`, which removes it from the accessibility tree.

### Example

```html
<div class="checkbox-container">
  <input type="checkbox" id="sub" name="sub" class="visually-hidden">
  <label for="sub" class="checkbox-label">Subscribe</label>
</div>

<style>
  .visually-hidden {
    position: absolute;
    clip-path: inset(50%);
    overflow: hidden;
    width: 1px;
    height: 1px;
    margin: -1px;
    padding: 0;
    border: 0;
    white-space: nowrap;
  }
  .checkbox-label::before {
    content: "";
    display: inline-block;
    width: 1.25rem;
    height: 1.25rem;
    border: 2px solid #767676;
  }
  input:checked + .checkbox-label::before {
    background: #0b57d0;
    border-color: #0b57d0;
  }
  input:focus-visible + .checkbox-label::before {
    outline: 2px solid #0b57d0;
  }
</style>
```

## 7. JavaScript and AJAX

### Guidelines

- Before treating Enter as submit in chat or text inputs, check `KeyboardEvent.isComposing` so IME text composition is not interrupted. See the `ime-safe-enter-submit` guide.
- For AJAX submission, prevent the default navigation with `e.preventDefault()` in the `submit` handler.
- Use `ValidityState` for real-time validation checks.
- Announce AJAX submission results with `role="status"` or `aria-live`.
- Use `aria-expanded` and `aria-controls` for UI that is revealed dynamically.
- Keep a server-side submission path so the form still works if JavaScript fails.

### Example

```js
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const data = new FormData(form);
  // fetch('/submit', { method: 'POST', body: data });
});
```

## 8. Identity, payments and security

### Guidelines

- Use `autocomplete="new-password"` for sign-up and `autocomplete="current-password"` for sign-in.
- Allow pasting into password fields.
- Provide an accessible `<button type="button">` with `aria-pressed` that lets users unmask the password.
- Show the exact amount on pay buttons, for example "Pay $100".
- Use `autocomplete="cc-number"`, `cc-exp` and `cc-csc` on card fields.
- Serve every page over HTTPS.
- Protect mutating actions (POST/PUT/DELETE) with cryptographically secure anti-CSRF tokens, and never use HTTP `GET` for endpoints that change state.
- Sanitize user input (for example with DOMPurify) before inserting it into the DOM, to prevent XSS.
- Protect open forms from spam with accessible CAPTCHAs (such as invisible reCAPTCHA) or honeypot fields hidden from assistive technology (`tabindex="-1"` and `aria-hidden="true"`).
- Attach event handlers from script rather than inline attributes such as `onclick="..."`, so the form works under a strict Content Security Policy.

### Example

```html
<form method="post">
  <input type="hidden" name="csrf_token" value="secure_token_abc123">

  <h1>Sign up</h1>

  <div class="form-group">
    <label for="name">Full name</label>
    <input id="name" name="name" autocomplete="name" required pattern="[\p{L}\.\- ]+">
  </div>

  <div class="form-group">
    <label for="email">Email</label>
    <input id="email" name="email" type="email" autocomplete="username" required>
  </div>

  <div class="form-group">
    <label for="password">Password</label>
    <button id="toggle-password" type="button" aria-pressed="false" aria-label="Show password" aria-describedby="toggle-warning">
      <img class="icon-eye" src="/icons/eye.svg" alt="" width="20" height="20">
      <img class="icon-eye-off" src="/icons/eye-off.svg" alt="" width="20" height="20">
    </button>
    <span id="toggle-warning" class="visually-hidden">Warning: this will display your password on the screen.</span>
    <input id="password" name="password" type="password" autocomplete="new-password" minlength="8" aria-describedby="password-constraints" required>
    <div id="password-constraints">Eight or more characters.</div>
  </div>

  <button id="sign-up" type="submit">Sign up</button>
</form>
```

## 9. Address collection

### Guidelines

- Use a single field for names. Splitting names into rigid "First" and "Last" fields fails global audiences.
- Do not restrict names or usernames to Latin characters.
- Use `autocomplete="street-address"`.
- If the site has users in several countries, use a `<textarea>` for the address so it fits each region's format. If the form uses separate inputs for address parts (such as street and city), use the `autocomplete` values `address-line1`, `address-line2` and so on.
- Make postal codes optional.
- When collecting both shipping and billing addresses, provide a "Same as shipping address" checkbox, and scope `autocomplete` values with `shipping` or `billing` inside a `<fieldset>`.

### Example

```html
<form action="/save-address" method="POST">
  <div class="form-group">
    <label for="full-name">Full name</label>
    <input type="text" id="full-name" name="full_name" maxlength="100" required autocomplete="name">
  </div>

  <div class="form-group">
    <label for="address">Address</label>
    <textarea id="address" name="address" required autocomplete="street-address" maxlength="300"></textarea>
  </div>

  <button type="submit">Save Address</button>
</form>
```

## 10. Usability testing and analytics

### Guidelines

- Test forms on several devices, browsers and screen sizes.
- Test keyboard-only navigation (Tab, Shift+Tab, Space, Enter and the arrow keys) and check that focus is visible.
- Emulate visual and motor impairments with browser tools.
- Monitor completion rates and drop-off points with analytics.
- Track discrete events such as field focus and clicks to find small points of friction.
- Automated tools such as Lighthouse are not enough for usability; test with real users.
- Keep sensitive personal data out of event labels.

### Example

```html
<form action="/submit" method="POST" id="track-form">
  <label for="postal-code">ZIP or postal code</label>
  <input type="text" id="postal-code" name="postal-code" autocomplete="postal-code" maxlength="20" required>
  <button type="submit" id="submit-btn">Submit</button>
</form>

<script>
  const trackBtn = document.getElementById('submit-btn');

  trackBtn.addEventListener('click', () => {
    console.log('Analytics Event: Submit clicked');
  });
</script>
```

## 11. Multi-page forms

### Guidelines

- Show progress clearly, with clear labels and accessible progress indicators such as `aria-current="step"` or `<progress>`.
- Let users move back and forward between pages without losing what they entered.
- When switching steps without a full page load, move focus to the new step's heading (with `tabindex="-1"`) or to its first input.
- Use context-specific `enterkeyhint` values on inputs, such as `"previous"` and `"next"`, to guide navigation from on-screen keyboards.
- Lay out steps so the mobile keyboard does not cover inputs or buttons, for example by placing them in the upper half of the viewport when focused or by using CSS `scroll-padding`.
- Remove inactive steps from the Tab order and the accessibility tree with `hidden`, `display: none` or `inert`.

### Example

```html
<nav aria-label="Progress">
  <ol class="progress-tracker">
    <li class="step-done">Step 1: Account (completed)</li>
    <li class="step-active" aria-current="step">Step 2: Shipping</li>
    <li class="step-todo">Step 3: Payment</li>
  </ol>
</nav>

<form action="/checkout/shipping" method="POST">
  <label for="postcode">Postcode</label>
  <input id="postcode" name="postcode" autocomplete="postal-code" enterkeyhint="next">

  <!-- Both buttons submit, so the server keeps what was entered on this step.
       Next comes first because Enter submits with the form's first submit button.
       formnovalidate lets the user go back with incomplete fields. -->
  <button type="submit" name="nav" value="next">Next</button>
  <button type="submit" name="nav" value="previous" formnovalidate>Previous</button>
</form>
```
