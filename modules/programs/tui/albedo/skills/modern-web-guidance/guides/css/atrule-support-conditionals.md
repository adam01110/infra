# Conditionally Apply CSS Based on At-Rule Support

`@supports at-rule(@<at-rule name>) {…}` applies CSS rules or declarations only when the browser supports a given at-rule. It can wrap entire rules, or be nested inside a rule to apply individual declarations conditionally.

```css
.foo {
  background: var(--accent-color);

  @supports at-rule(@property) {
    background-image: var(--rainbow-gradient);
    animation: sliding-rainbow 1s linear infinite;
  }
}
```

Do not use `@supports at-rule()` to wrap only the at-rule being detected. CSS already ignores rules the browser does not understand, so the check adds nothing:

```css
/* Unnecessary */
@supports at-rule(@starting-style) {
  @starting-style {
    /* ... */
  }
}
```

## Detecting support for at-rules when `@supports at-rule()` isn’t appropriate

When `at-rule()` is not an option, because of browser support or because deeper detection is needed, use the approaches below.

### Try properties, values or selectors first

`@supports` already detects properties, values and selectors (`@supports selector(...)`), and these often reveal support for a feature without checking the at-rule itself.

For example, detect custom functions with `@supports (color: --foo())` instead of `@supports at-rule(@function)`.

In other cases, a pseudo-class or pseudo-element that only exists alongside an at-rule can serve as the test.

### Detecting container query types

`at-rule()` detects at-rules by name only, not other syntax or descriptors. This does not work:

```css
@supports at-rule(@container style(--a: 1)) {
  /* ... */
}
```

For many container query types, test `container-type` with a matching value: `@supports (container-type: scroll-state)` for scroll-state queries, `@supports (container-type: size)` for size queries, or `@supports (container-type: anchored)` for `anchored()` queries.

Style queries have no `container-type`, so `@supports (container-type: style)` does not detect them. Use a style query that is always true instead:

```css
@container style(--a: 1) or (not (style(--a: 1))) {
  /* Applied only where style queries are supported */
}
```

This matches in every browser that supports style queries, whatever property name and value you use, as long as both halves use the same ones.

### Registered custom properties (`@property`)

If the conditional CSS reduces to a single property, a custom property registered for the purpose can carry it:

```css
/* Include the dash animation only where @property is supported */
@property --progress-dash-animation {
  syntax: "*";
  inherits: false;
  initial-value: , progress-dash 3s ease-in-out infinite;
}

.spinner {
  animation:
    progress-spin var(--_used-spinner-duration) linear infinite
    var(--progress-dash-animation, );
}
```

For a general-purpose test, register a non-inheriting property and set it to ` ` (a space) on the root element:

```css
@property --supports-atproperty {
  syntax: "*";
  inherits: false;
}

:root {
  --supports-atproperty: ;
}

body {
  /* Background applies only where @property is supported */
  background: var(--supports-atproperty, green);
}
```

Notes:

- Both techniques only work where whitespace is an acceptable alternative value. Otherwise, use JavaScript as described below.
- The general-purpose test depends on the property not inheriting, so it does not work for declarations on the root element itself.

### JavaScript as a last resort

For whole at-rules, check for their CSSOM interfaces. For example, if `globalThis.CSSFunctionRule` is defined, `@function` is supported.

To test more deeply (certain preludes, nested rules, descriptors), parse a test stylesheet and inspect the result:

```js
const sheet = new CSSStyleSheet();
sheet.replaceSync(`
  @page {
    @top-left {
      content: "test";
    }
  }
`);
const SUPPORTS_PAGE_MARGINS = Boolean(sheet.cssRules[0]?.cssRules?.[0]);
```

Caveats:

- When JavaScript detects support, do not apply the styles from JavaScript. Add a class to the root element and branch on it in CSS.
- Container queries are parsed even when their prelude is not recognized, so the CSSOM structure cannot reveal support for particular container query types.
- Do not use `CSS.registerProperty` to detect `@property` support: its support is slightly broader than `@property`'s.

## Fallback strategies

Browser support for at-rule(): Limited availability.
Supported by: Chrome 148 (May 2026), Edge 148 (May 2026), and Firefox 157 (Sep 2026).
Unsupported in: Safari.

Unless `at-rule()` is within your support target, use `@supports at-rule()` only for at-rules whose support is narrower than that of `@supports at-rule()` itself.

For at-rules that shipped before this feature, use the approaches in the section above on detecting at-rules without `@supports at-rule()`.

To detect support for `@supports at-rule()` itself, test an at-rule that every browser supporting it also has, such as `@supports at-rule(@media) { ... }`.
