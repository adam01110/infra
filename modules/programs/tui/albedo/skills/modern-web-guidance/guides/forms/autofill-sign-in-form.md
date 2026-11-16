# Build a sign-in form that follows best practice

Use cross-platform browser features to build sign-in forms that are secure, accessible and easy to use. Sign-in design matters most for people on poor connections, on mobile, in a hurry or under stress. Poorly designed sign-in forms have high bounce rates, and each bounce can mean a lost customer and a frustrated user, not just a missed sign-in.

## How to implement

### Use meaningful, valid HTML

Use the elements and attributes built for forms:

- `<form>`, `<input>`, `<label>` and `<button>`
- `type`, `autocomplete` and `inputmode`

They enable built-in browser features, improve accessibility and add meaning to the markup.

### Label every field with `<label>`

Label each `<input>`, `<select>` and `<textarea>` with a `<label>`. Associate them by giving the label's `for` attribute the same value as the input's `id`.

### Use the right input types and autocomplete values

Choose the `<input>` `type` that gives mobile users the right keyboard and enables the browser's basic validation. Use `type="email"` for email addresses and `type="tel"` for phone numbers.

Give every `<input>`, `<select>` and `<textarea>` an appropriate `autocomplete` attribute. It improves accessibility and saves users from re-entering data.

Username and email inputs hold identifiers, not prose. Add `spellcheck="false"` so the browser does not rewrite them into something the account does not match. Browsers always disable `autocorrect` and `autocapitalize` on `type="email"`, but a non-email username input needs them turned off explicitly (`autocorrect="off" autocapitalize="none"`).

### Make buttons helpful

Use `<button>` (or `<input type="submit">`) for buttons, never a `<div>` or other element posing as one. Button elements have accessible behavior and built-in form submission, and are easy to style.

Give the submit button a clear, recognizable label that says what it does: "Sign In" rather than "Continue" or "Submit".

### Use a single name input where possible

If the form asks for a name (a sign-in form usually does not), let users enter it in one input unless you have a good reason to store given names, family names, honorifics or other name parts separately. A single input makes the form simpler, allows cut and paste, and makes autofill simpler. Use `autocomplete="name"`.

```html
<input type="text" id="fullname" name="fullname" autocomplete="name">
```

Allow international names. Validation regular expressions that match only Latin characters exclude users whose names or addresses contain other characters. Match Unicode letters instead, which modern browsers support well in regular expressions, and make sure the backend handles Unicode securely as both input and output.

### Show sign-in progress

At each step toward sign-in, use page headings and descriptive button values that make clear what to do now and what comes next.

Use `enterkeyhint` to set the label of the mobile keyboard's Enter key: `enterkeyhint="previous"` and `enterkeyhint="next"` within a multi-page form, `enterkeyhint="done"` on the form's final input, and `enterkeyhint="search"` on a search input.

### Validate carefully

Validate both in real time and before submission. With `type="email"` the browser checks the email format itself. Add `required` to mandatory fields to prevent empty submissions.

### Put sign-in in its own `<form>` element

Collect user data in a `<form>` rather than wrapping inputs in a `<div>` and submitting purely with JavaScript. A form is accessible to screen readers and other assistive technology, enables built-in browser features, makes basic sign-in simpler to support in older browsers, and can still work if JavaScript fails.

### Ask for each value once

Do not make users enter their email or password twice. It may prevent errors for a few users, but it adds work for everyone and raises abandonment, and it makes no sense when browsers autofill email addresses or suggest strong passwords. Instead, let users confirm their email address (you need to do that anyway) and make password reset easy.

### Keep passwords private, but let users see them

Give password inputs `type="password"` to hide the text and tell the browser the input holds a password. (Browsers use a variety of techniques to understand input roles and decide whether to offer to save passwords.)

Add a "Show password" toggle so users can check what they typed, and add a "Forgot password" link.

### Give mobile users the right keyboard

`<input type="email">` gives mobile users a suitable keyboard and basic built-in email validation without JavaScript.

If you use a telephone number instead of an email address, `<input type="tel">` shows a telephone keypad on mobile. Use `inputmode` where needed: `inputmode="numeric"` suits PINs.

### Keep the mobile keyboard from covering the Sign in button

Mobile keyboards can cover the form or partly hide the Sign in button, and users may give up before they notice. Where possible, show only the email (or phone) input, the password input and the Sign in button at the top of the sign-in page, with other content below.

### Help browsers store and autofill credentials

Autofill saves users from remembering and typing email and password values, and lets browsers store sign-in details securely. Without `autocomplete`, users are more likely to keep a physical record of their sign-in details or store them insecurely on their device. This matters most on mobile, and especially for email inputs, which have high abandonment rates. It has two parts:

1. The `autocomplete`, `name`, `id` and `type` attributes tell browsers each input's role so they can store data for later autofill. To store data, modern browsers also require a stable `name` or `id` (not randomly generated on each page load or deployment), and the inputs must be in a `<form>` with a submit button.
2. The `autocomplete` attribute lets browsers fill inputs correctly from stored data.

Give the email input `autocomplete="username"`, because password managers in modern browsers recognize `username`, while still using `type="email"` (and, if you like, `id="email"` and `name="email"`). Give password inputs the value that tells new and current passwords apart: `autocomplete="new-password"` or `autocomplete="current-password"`.

### Use `autocomplete="current-password"` for an existing password

Give the sign-in form's password input `autocomplete="current-password"` so the browser fills in the password it has stored for the site:

```html
<input type="password" autocomplete="current-password" id="current-password" …>
```

### Let the browser suggest a strong password

Modern browsers use heuristics to decide when to show the password manager UI and suggest a strong password. Built-in generators mean neither users nor developers need to define a "strong password", and because browsers store and autofill passwords securely, users need not remember or type them. Users who accept a generated password are more likely to have a unique, strong password on your site and less likely to reuse one that could be compromised elsewhere.

### Require both credentials

Add `required` to both the email and password fields. Modern browsers prompt for missing data and focus the field.

```html
<input type="email" id="email" name="email" autocomplete="username" required>
<input type="password" id="password" name="password" autocomplete="current-password" required>
```

### Allow password pasting

Do not block pasting into password inputs. Blocking it annoys users, encourages memorable (and so easier to compromise) passwords, and according to organizations such as the UK National Cyber Security Centre may reduce security. Users find out pasting is blocked only after they try to paste, so blocking it does not avoid clipboard vulnerabilities.

## Fallback strategies

Baseline status for email, telephone and URL `<input>` types: Widely available, Baseline since 2015-07-29.
Supported by: Chrome 5 (May 2010), Edge 12 (Jul 2015), Firefox 4 (Mar 2011), Safari 5 (Jun 2010) and Safari iOS 3 (Jun 2009).

Baseline status for `inputmode`: Widely available, Baseline since 2021-12-07.
Supported by: Chrome 66 (Apr 2018), Edge 79 (Jan 2020), Firefox 95 (Dec 2021), Safari 12.1 (Mar 2019) and Safari iOS 12.2 (Mar 2019).

Baseline status for `autocorrect`: Newly available, Baseline since 2026-09-11.
Supported by: Chrome 153 (Sep 2026), Edge 153 (Sep 2026), Firefox 136 (Mar 2025), Safari 14.1 (Apr 2021) and Safari iOS 14.5 (Apr 2021).

Autofill is progressive enhancement. Where it is unsupported, users type their credentials manually, and the semantic HTML constraints (`type`, `inputmode`, `required`) still validate input and provide the right virtual keyboards.
