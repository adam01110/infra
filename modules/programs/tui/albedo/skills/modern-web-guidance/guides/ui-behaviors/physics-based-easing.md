# Physics Based Easing

Easing keywords such as `ease-in` and `cubic-bezier()` describe simple curves, so they cannot express physics effects like bounces or springs. The `linear()` timing function takes a series of stops that approximate any curve. The browser interpolates in straight lines between stops, but with enough stops the result looks smooth.

## Implementation steps

1. Generate the stops. Plotting dozens of points by hand is impractical, so take a timing function from an external library, or use a tool that converts a JavaScript easing function or an SVG path into `linear()` syntax. Optionally store the results in CSS custom properties for reuse across the site.
2. Apply the stops through `transition-timing-function` or `animation-timing-function`, or the `transition` or `animation` shorthand.
3. Set a duration and tune it. JavaScript physics engines derive duration from physical properties such as mass and stiffness, but CSS needs a fixed duration, and `linear()` does not compute one for you. Adjust it until the effect looks right.

## Example: spring

A `linear()` curve that overshoots the target before settling:

```css
.spring {
  --spring-easing: linear(0, 0.016 0.5%, 0.06 1%, 0.226 2%, 1.116 5.4%, 1.375 6.6%, 1.527 7.7%, 1.565 8.2%, 1.585 8.8%, 1.581 9.3%, 1.559 9.8%, 1.458 10.9%, 0.937 14.3%, 0.784 15.5%, 0.693 16.6%, 0.67 17.1%, 0.657 17.7%, 0.671 18.7%, 0.729 19.8%, 1.042 23.3%, 1.13 24.5%, 1.182 25.6%, 1.201 26.7%, 1.192 27.7%, 1.156 28.8%, 0.977 32.2%, 0.925 33.4%, 0.894 34.5%, 0.882 35.6%, 0.887 36.6%, 0.907 37.7%, 1.045 42.4%, 1.069 44.5%, 1.059 46.3%, 0.979 50.9%, 0.96 53.4%, 0.966 55.3%, 1.013 59.9%, 1.024 62.3%, 0.986 71.2%, 1.008 79.9%, 0.995 88.9%, 1);

  /* linear() has no duration of its own; choose one that fits the spring. */
  transition: scale 0.8s var(--spring-easing);
}

.spring:hover {
  scale: 1.2;
}
```

## Example: bounce

```css
.bounce {
  --bounce-easing: linear(0, 0.214 14.7%, 0.386 23.7%, 0.598 31.9%, 0.999 44.7%, 0.807 52.6%, 0.762 56%, 0.747 59.4%, 0.758 62.4%, 0.793 65.6%, 0.999 77.4%, 0.961 81.2%, 0.949 84.8%, 0.956 88%, 0.993 95.5%, 1);

  /* linear() has no duration of its own; choose one that fits the bounce. */
  transition: scale 0.4s var(--bounce-easing);
}

.bounce:hover {
  scale: 1.2;
}
```

## Considerations

- Performance: for the smoothest result, apply `linear()` to properties that animate off the main thread, such as `transform` and `opacity`.
- Precision and payload: more stops give a smoother curve but a larger stylesheet. Most generators can simplify the curve to balance smoothness and size.
- Bounces on `opacity`: avoid them. If the value overshoots below 0 or above 1 it causes jarring flicker.
- Accessibility: complex physics animations can distract or cause discomfort for people sensitive to motion. Reduce or disable them for users who prefer reduced motion.

```css
@media (prefers-reduced-motion: reduce) {
  .element {
    transition: none;
  }
}
```

## Fallback strategies

Baseline status for linear() easing: Widely available. It's been Baseline since 2023-12-11.
Supported by: Chrome 113 (May 2023), Edge 113 (May 2023), Firefox 112 (Apr 2023), and Safari 17.2 (Dec 2023).

### CSS fallback

Declare a standard easing first. Browsers that don't recognize `linear()` ignore that declaration and keep the earlier valid one.

```css
.element {
  /* Fallback for older browsers. */
  transition: transform 0.8s ease-out;

  /* Supporting browsers override it with the physics-based easing. */
  transition-timing-function: linear(0, 1.1, 0.95, 1.02, 1);
}
```

### JavaScript library fallback (Motion or GSAP)

Optional: if a high-fidelity physics animation matters even in older browsers, use a library such as Motion (motion.dev) or GSAP (greensock.com) when `linear()` is unsupported. Detect support with `CSS.supports()`, and only then load and apply the library's spring or bounce.

```javascript
const supportsLinearEasing = window.CSS && CSS.supports('animation-timing-function', 'linear(0, 1)');

if (!supportsLinearEasing) {
  // Spring fallback with Motion (current API), loaded only when native support is missing.
  // Pin a version in production instead of @latest.
  import("https://cdn.jsdelivr.net/npm/motion@latest/+esm").then(({ animate }) => {
    const el = document.querySelector(".element");
    const spring = { type: "spring", stiffness: 100, damping: 10 };
    el.addEventListener("pointerenter", () => animate(el, { scale: 1.2 }, spring));
    el.addEventListener("pointerleave", () => animate(el, { scale: 1 }, spring));
  });
}
```

In CSS, `@supports` detects it explicitly:

```css
@supports not (animation-timing-function: linear(0, 1)) {
  .element {
    /* Alternative for unsupported browsers. */
    transition-duration: 0.4s;
    transition-timing-function: cubic-bezier(0.34, 1.56, 0.64, 1);
  }
}
```
