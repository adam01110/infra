# Build an address form that follows best practice

Make address entry as easy as possible on desktop and mobile by using the browser's built-in autofill, validation and data entry constraints.

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

Address formats vary widely, even within one country, so make no assumptions about a "normal" address.

Use a single `<textarea>` for the street address if possible. It is the most flexible option for local and international formats that split inputs cannot accommodate.

```html
<textarea id="address" name="address" autocomplete="street-address" required></textarea>
```

If the data model needs separate address lines, use one `<input>` per line with the `address-line1`, `address-line2` (and if needed `address-line3`) `autocomplete` tokens so autofill still works. Do not split the street address across inputs that lack these tokens, and make only the first line required.

```html
<input type="text" id="address-line1" name="address-line1" autocomplete="address-line1" required>
<input type="text" id="address-line2" name="address-line2" autocomplete="address-line2">
```

### Mark mandatory fields as required

Add the `required` attribute to mandatory fields so users do not miss them.

```html
<input type="text" id="city" name="city" autocomplete="address-level2" required>
```

## Fallback strategies

Baseline status for `autocomplete` on `<input>`: Widely available, Baseline since 2015-07-29.
Supported by: Chrome 14 (Sep 2011), Edge 12 (Jul 2015), Firefox 4 (Mar 2011) and Safari 6 (Jul 2012).

Autofill is progressive enhancement. Where it is unsupported, users type their address manually, and the semantic HTML constraints (`type`, `inputmode`, `required`) still work as standard form validation.
