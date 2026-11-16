# Styling siblings based on count and index

`sibling-index()` and `sibling-count()` give each element its 1-based position among its siblings and the total number of siblings, directly in CSS. They replace long `:nth-child` rule lists or JavaScript that injects inline styles, and layouts or color systems built on them adapt automatically as elements are added or removed.

## Dynamic color systems

Calculate a unique hue or lightness per child to spread a color spectrum across a group of siblings. The gradient stays consistent for any number of items.

```css
.swatch {
  /* Divide the 360deg hue circle by the sibling count, times this element's 1-based index */
  background-color: hsl(
    calc(360deg / sibling-count() * sibling-index()),
    70%,
    50%
  );
}
```

## Symmetrical layout and fan effects

For symmetrical effects such as a fan or centering items, use the total count to find the middle of the list.

```css
.card {
  /* Center index, e.g. 3 for 5 siblings */
  --center: calc((sibling-count() + 1) / 2);

  /* Negative rotation left of center, positive right of it; the center element gets 0deg */
  transform: rotate(calc(10deg * (sibling-index() - var(--center))));
}
```

## Circular and complex positioning

Combined with CSS trigonometry (`sin()`, `cos()`), these functions place elements in a circle without manual coordinates.

```css
.orb {
  /* This item's angle on the 360deg circle */
  --angle: calc(360deg / sibling-count() * sibling-index());
  --radius: 150px;

  /* Center every item before the transform */
  position: absolute;
  place-self: center;

  /* Move each element around the parent's center */
  transform: translate(
    calc(cos(var(--angle)) * var(--radius)),
    calc(sin(var(--angle)) * var(--radius))
  );
}
```

### Fallback strategies

Baseline status for sibling-count() and sibling-index(): Newly available. It's been Baseline since 2026-08-18.
Supported by: Chrome 138 (Jun 2025), Edge 138 (Jun 2025), Firefox 154 (Aug 2026), and Safari 26.2 (Dec 2025).

Where `sibling-index()` and `sibling-count()` are unsupported, inject CSS custom properties with JavaScript. Feature-detect with `CSS.supports()` so the script only runs when needed. The injected index must be 1-based to match the native function.

```js
if (!CSS.supports('top: calc(sibling-index() * 1px)')) {
  // Count per parent, across all element siblings, like the native functions
  document.querySelectorAll('.item').forEach((item) => {
    const siblings = [...item.parentElement.children];
    item.style.setProperty('--sibling-index', siblings.indexOf(item) + 1);
    item.style.setProperty('--sibling-count', siblings.length);
  });
}
```

In CSS, use these variables as the base and override them with the native functions inside an `@supports` block. The `@supports` wrapper is required: a custom property accepts any value, so without it older browsers would replace the JavaScript fallback with the unsupported function and the variables would become invalid.

```css
.item {
  /* 1. Base values from the JS fallback */
  --index: var(--sibling-index);
  --count: var(--sibling-count);

  /* 2. Your own styles, using the variables */
  background-color: hsl(calc(360deg / var(--count) * var(--index)), 70%, 50%);
}

@supports (top: calc(sibling-index() * 1px)) {
  .item {
    /* 3. Native functions, only where supported */
    --index: sibling-index();
    --count: sibling-count();
  }
}
```
