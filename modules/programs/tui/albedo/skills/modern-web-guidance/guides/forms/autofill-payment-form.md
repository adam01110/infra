# Build a payment form that follows best practice

The payment form is the most critical part of checkout, and poor payment form design is a common cause of cart abandonment. Make payment entry as easy as possible on desktop and mobile by using the browser's built-in autofill, validation and data entry constraints.

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

```html
<input type="email" id="email" name="email" autocomplete="email" required>
<input type="tel" id="phone" name="phone" autocomplete="tel">
```

Give every `<input>`, `<select>` and `<textarea>` an appropriate `autocomplete` attribute. It improves accessibility and saves users from re-entering data.

### Make buttons helpful

Use `<button>` (or `<input type="submit">`) for buttons, never a `<div>` or other element posing as one. Button elements have accessible behavior and built-in form submission, and are easy to style.

Label each submit button with what it does. At each step toward checkout, use a descriptive call to action that shows progress and makes the next step obvious: on a delivery address form, "Proceed to Payment" rather than "Continue" or "Save".

### Use a single name input where possible

Let users enter their name in one input unless you have a good reason to store given names, family names, honorifics or other name parts separately. A single input makes the form simpler, allows cut and paste, and makes autofill simpler. Use `autocomplete="name"`.

```html
<input type="text" id="fullname" name="fullname" autocomplete="name">
```

Allow international names. Validation regular expressions that match only Latin characters exclude users whose names or addresses contain other characters. Match Unicode letters instead, which modern browsers support well in regular expressions, and make sure the backend handles Unicode securely as both input and output.

### Allow for a variety of address formats

Address formats vary widely, even within one country, so make no assumptions about a "normal" address. If your data requirements allow it, use a single `<textarea>` for the address; it is the most flexible option for local and international formats.

### Use autocomplete for the billing address

Default the billing address to the delivery address. Instead of showing the billing address as a form, offer a link to edit it (or use `<details>` and `<summary>`) to reduce clutter.

Give billing address fields the same autocomplete values as shipping fields so users enter data only once. When the same field appears in different sections, prefix the token with the section name:

```html
<!-- The token is address-line1, not address-line-1. -->
<input autocomplete="shipping address-line1" ...>
...
<input autocomplete="billing address-line1" ...>
```

### Show checkout progress

At each step toward payment, use page headings and descriptive button values that make clear what to do now and which checkout step comes next.

Use `enterkeyhint` to set the label of the mobile keyboard's Enter key: `enterkeyhint="previous"` and `enterkeyhint="next"` within a multi-page form, `enterkeyhint="done"` on the form's final input, and `enterkeyhint="search"` on a search input.

### Help users avoid re-entering payment data

Add the right `autocomplete` values to payment card fields. Without autocomplete, users may keep a physical record of card details or store them insecurely.

```html
<!-- cc-number marks this as a card number, not a generic number.
     inputmode="numeric" gives a numeric keyboard without a spinner. -->
<input id="cc-number" name="cc-number" type="text" autocomplete="cc-number"
       inputmode="numeric" pattern="[\d ]{10,30}" required>

<!-- cc-name autofills the name exactly as printed on the card;
     the Unicode pattern allows international names. -->
<input id="cc-name" name="cc-name" type="text" autocomplete="cc-name"
       maxlength="50" pattern="[\p{L} \-\.]+" required>

<!-- cc-exp autofills the full expiry date as MM/YY. The hint sits above
     the input so autofill popovers and virtual keyboards do not cover it. -->
<span id="exp-hint" class="hint">Format: MM/YY</span>
<input id="cc-exp" name="cc-exp" type="text" autocomplete="cc-exp"
       aria-describedby="exp-hint" maxlength="5" required>

<!-- cc-csc autofills the security code; it stays type="text". -->
<input id="cc-csc" name="cc-csc" type="text" autocomplete="cc-csc"
       inputmode="numeric" maxlength="4" pattern="[0-9]{3,4}" required>
```

Do not use `type="number"` for card numbers: it adds increment/decrement controls and strips leading zeros.

### Show format hints above the input

When a field has a required format, such as the `MM/YY` expiry date, put the hint in a visible element above the input and link them with `aria-describedby`, as in the `cc-exp` example. Hints below an input are easily hidden by the mobile keyboard or the autofill popover exactly when the user needs them.

Do not rely on `placeholder` as the only format hint, and never use it instead of a `<label>`: placeholder text disappears as soon as the user types, so it cannot be checked while editing. A placeholder is fine as an extra cue alongside the label and the persistent hint.

### Do not mask the security code

Use `type="text"` with `inputmode="numeric"` for the card security code, not `type="password"`. Users cannot check a masked three- or four-digit code for typos, so a wrong digit is caught only when the payment is declined. Masking adds little protection, because the code is printed on the card the user is holding.

### Use a single input for card and phone numbers

Do not split payment card or phone numbers into parts. A single input is easier to fill in, simpler to validate, and lets browsers autofill. Consider the same for other numeric data such as PINs and bank codes.

### Validate carefully

Validate both in real time and before submission. One way is a `pattern` attribute on the card number input: if the user submits an invalid value, the browser shows a warning and focuses the input.

Keep the pattern flexible. Card numbers are commonly 12 to 19 digits long, and the spaces users type between groups add characters, so the example accepts 10 to 30 digits and spaces. Strip the spaces and leave exact length and checksum validation to your payment processing. Card security codes (CSC, CVC, CVV and other names) have 3 or 4 digits.

Allow spaces in a newly entered card number, since that is how numbers appear on physical cards. Users are not told they did something wrong, conversion is less likely to be interrupted, and spaces are easy to strip before processing.

### Mark mandatory fields as required

Add the `required` attribute to mandatory fields. Modern browsers prompt for missing data and focus the field.

## Fallback strategies

Baseline status for `enterkeyhint`: Widely available, Baseline since 2021-11-02.
Supported by: Chrome 77 (Sep 2019), Edge 79 (Jan 2020), Firefox 94 (Nov 2021), Safari 13.1 (Mar 2020) and Safari iOS 13.4 (Mar 2020).

Baseline status for email, telephone and URL `<input>` types: Widely available, Baseline since 2015-07-29.
Supported by: Chrome 5 (May 2010), Edge 12 (Jul 2015), Firefox 4 (Mar 2011), Safari 5 (Jun 2010) and Safari iOS 3 (Jun 2009).

Baseline status for `inputmode`: Widely available, Baseline since 2021-12-07.
Supported by: Chrome 66 (Apr 2018), Edge 79 (Jan 2020), Firefox 95 (Dec 2021), Safari 12.1 (Mar 2019) and Safari iOS 12.2 (Mar 2019).

Autofill is progressive enhancement. Where it is unsupported, users type their payment details manually, and the semantic HTML constraints (`type`, `inputmode`, `pattern`, `required`) still validate input and provide the right virtual keyboards.
