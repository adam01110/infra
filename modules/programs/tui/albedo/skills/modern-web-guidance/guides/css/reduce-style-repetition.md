# Reduce Style Repetition with CSS Functions

Large stylesheets tend to repeat logic, especially around design system tokens such as gradients and responsive layout patterns. The CSS `@function` at-rule wraps that logic in reusable, parameterized functions, which keeps CSS consistent and free of duplication.

## The `@function` syntax

Define a custom function with `@function`, a dashed name and a parameter list. The `result` property sets the returned value.

```css
@function --my-function(--input1 <length>, --input2: default-value) returns <length> {
  /* Logic goes here */
  result: var(--input1);
}
```

### Key concepts

- Parameters: names start with a double dash (`--`).
- Defaults: give a default value after a colon (`:`).
- Result: the `result` property sets the returned value. The last `result` declared in the function body wins.
- Scoping: parameters and variables defined inside the function are locally scoped.
- Types: require a parameter or the return value to match a CSS type with bracket notation (such as `<color>`), and allow several types with the `type()` function (such as `type(<number> | <percentage>)`).

## Examples

### 1. Design system tokens (gradients)

Wrap gradient logic in a function to keep gradients consistent across the app. `--angle` has a typed default that callers can override.

```css
@function --fancy-gradient(--start-color <color>, --end-color <color>, --angle <angle>: 98deg) returns <image> {
  result: linear-gradient(in oklab var(--angle), var(--start-color), var(--end-color));
}

.card {
  background: --fancy-gradient(#ed73d7, #5d87e9);
}
```

### 2. Conditional layout logic

`@media` and other queries can be used inside a function to return different values for different environments. A function does not return at the first `result`: it follows the cascade and resolves to the last `result` whose query matches the screen size, container size or other condition. So put the default value first.

```css
@function --grid-template(--count <number>) {
  result: 1fr; /* Default first: stacked */
  @media (min-width: 800px) {
    result: repeat(var(--count), 1fr); /* Grid on larger screens */
  }
}

main {
  display: grid;
  grid-template-columns: --grid-template(2);
}
```

## Best practices

- Provide sensible default values to make functions robust.
- Use functions for logic that is actually repeated or complex, not for simple property-value pairs.
- Declare types for parameters and return values.
- For functions that do not depend on user input, media queries or other client-side variation, consider a CSS preprocessor instead, so the client does no unnecessary work.

### Fallback strategies

Browser support for @function: Limited availability.
Supported by: Chrome 139 (Aug 2025) and Edge 139 (Aug 2025).
Unsupported in: Firefox and Safari.

In browsers without CSS functions, a value that calls one is invalid. Declare a fallback value for the property first; browsers that support functions override it.

```css
.card {
  /* Fallback: solid color */
  background: #5d87e9;
  background: --fancy-gradient(#ed73d7, #5d87e9);
}

main {
  /* Fallback: simple stacked default */
  grid-template-columns: 1fr;
  grid-template-columns: --grid-template(2);
}
```

If you need to reduce repetition and also support other browsers, consider a CSS preprocessor with functions, such as Sass.
