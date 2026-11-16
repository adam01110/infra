# Creating a stagger animation

In a stagger animation, ordered elements animate one after another with a short delay between each instead of all at once. It suits lists, galleries and navigation menus, where it guides the eye and gives interactions a rhythmic feel.

## Stagger with `sibling-index()`

Use `sibling-index()` in `animation-delay` so each element's delay is proportional to its position in its parent. `sibling-index()` returns a 1-based integer, so multiply it by a time value.

```css
#stagger-list > .item {
  --stagger-time: 0.1s; /* Example step delay. */
  /* `both` holds the first keyframe during each sibling's delay. */
  animation: fade-in 0.4s both;
  animation-delay: calc(sibling-index() * var(--stagger-time));
}
```

Disable the animation for users who prefer reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  #stagger-list > .item {
    animation: none;
  }
}
```

## Fallback strategies

Baseline status for sibling-count() and sibling-index(): Newly available. It's been Baseline since 2026-08-18.
Supported by: Chrome 138 (Jun 2025), Edge 138 (Jun 2025), Firefox 154 (Aug 2026), and Safari 26.2 (Dec 2025).

If your Baseline target doesn't include `sibling-index()`, feature-detect it so older browsers still get a stagger. Test with a literal time value: `@supports (animation-delay: calc(sibling-index() * 0.1s))` in CSS and `!CSS.supports('animation-delay: calc(sibling-index() * 0.1s)')` in JavaScript. Never put `var()` inside `@supports` or `CSS.supports()`: custom property references parse as valid in every browser, so the check would always return `true`.

For dynamic lists, or new implementations, set a 1-based `--sibling-index` custom property on each child with JavaScript. Wrap it in a `!CSS.supports('animation-delay: calc(sibling-index() * 0.1s)')` check so supporting browsers don't run unnecessary script. The loop runs once; re-run it when items are added (for example from a `MutationObserver`).

```js
if (!CSS.supports('animation-delay: calc(sibling-index() * 0.1s)')) {
  const staggerList = document.getElementById('stagger-list');
  [...staggerList.children].forEach((el, index) => {
    el.style.setProperty('--sibling-index', index + 1);
  });
}
```

Set the base `animation-delay` with `var(--sibling-index)`, and put the `sibling-index()` override inside `@supports (animation-delay: calc(sibling-index() * 0.1s))`. The gate is required: because `calc(sibling-index() * var(--stagger-time))` contains `var()`, the browser defers syntax validation to computed-value time. Without `@supports`, a browser that lacks `sibling-index()` accepts the second declaration at parse time, discards the fallback, and then resets `animation-delay` to `0s` as invalid at computed-value time.

```css
#stagger-list > .item {
  --stagger-time: 0.1s; /* Example step delay. */
  animation: fade-in 0.4s both;
  animation-delay: calc(var(--sibling-index) * var(--stagger-time));
}

/* Gate sibling-index() with a literal time unit. */
@supports (animation-delay: calc(sibling-index() * 0.1s)) {
  #stagger-list > .item {
    animation-delay: calc(sibling-index() * var(--stagger-time));
  }
}
```

When refactoring an existing `:nth-child()` stagger where adding client-side JavaScript is undesirable (for example static or server-rendered CSS with a small, fixed number of items), keep the `:nth-child()` delay rules inside `@supports not (animation-delay: calc(sibling-index() * 0.1s))` instead of injecting `--sibling-index` with JavaScript. The `@supports not` gate stops the higher-specificity `:nth-child()` selectors from overriding `sibling-index()` in supporting browsers.

```css
#stagger-list > .item {
  --stagger-time: 0.1s; /* Example step delay. */
  animation: fade-in 0.4s both;
}

/* A literal time in @supports avoids the always-true var() parse. */
@supports (animation-delay: calc(sibling-index() * 0.1s)) {
  #stagger-list > .item {
    animation-delay: calc(sibling-index() * var(--stagger-time));
  }
}

/* Gate :nth-child() so its higher specificity doesn't override sibling-index(). */
@supports not (animation-delay: calc(sibling-index() * 0.1s)) {
  #stagger-list > .item:nth-child(1) { animation-delay: 0.1s; }
  #stagger-list > .item:nth-child(2) { animation-delay: 0.2s; }
  #stagger-list > .item:nth-child(3) { animation-delay: 0.3s; }
}
```
