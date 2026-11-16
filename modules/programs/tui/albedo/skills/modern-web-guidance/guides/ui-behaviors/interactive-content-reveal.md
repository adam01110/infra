# Interactive Content Reveal

CSS masks and registered custom properties give a cheap, interactive reveal effect. A radial-gradient mask with registered stop values transitions smoothly in and out and follows the pointer with very little JavaScript.

## Implementation

### 1. Register the custom properties

Gradient stop values only interpolate if their custom properties are registered with `@property`, which tells the browser their type so it can transition between values.

```css
/* Register the spotlight's inner and outer sizes so they can interpolate. */
@property --inner-size{
  syntax: "<length-percentage>";
  inherits: true;
  initial-value: 0px;
}
@property --outer-size{
  syntax: "<length-percentage>";
  inherits: true;
  initial-value: 0px;
}
```

The pointer-position properties are never transitioned, so they don't need registering.

### 2. Define the mask layer

Apply `mask-image` to the element to reveal, using a `radial-gradient` that references the registered properties:

```css
.reveal-layer {
  /* Transition only the sizes, not the position. */
  transition: --inner-size 0.2s ease-in-out, --outer-size 0.2s ease-in-out;

  /* The opaque center of the mask reveals the layer; it fades to transparent outside. */
  mask-image: radial-gradient(
    circle at var(--mouse-x, 50%) var(--mouse-y, 50%),
    black var(--inner-size, 0%),
    transparent var(--outer-size, 0%)
  );

  /* Don't tile the mask on large elements. */
  mask-repeat: no-repeat;

  pointer-events: none;
}

/* Hovering the interactive container sets the stops, which inherit into
   .reveal-layer (the layer itself has pointer-events: none). */
.container:hover {
  --inner-size: 100px;
  --outer-size: 120px;
}
```

### 3. Track the pointer in JavaScript

Update the position properties on `pointermove`. They change instantly, so the spotlight follows the pointer directly while the sizes expand and contract smoothly.

```javascript
const container = document.querySelector('.container');

container.addEventListener('pointermove', (e) => {
  // Read the rect per event: it is viewport-relative, so a cached one goes stale on scroll.
  const rect = container.getBoundingClientRect();
  // Position as a percentage of the container.
  const x = ((e.clientX - rect.left) / rect.width) * 100;
  const y = ((e.clientY - rect.top) / rect.height) * 100;

  container.style.setProperty('--mouse-x', `${x}%`);
  container.style.setProperty('--mouse-y', `${y}%`);
});
```

### 4. Accessibility and interaction

The spotlight depends on a pointer, so treat it as a non-essential visual enhancement for pointer users. All underlying content must stay fully visible, legible and keyboard-reachable in the base layout. Never use the effect to hide or gate essential content from keyboard or assistive technology users.

- Set `pointer-events: none` on the mask layer so clicks and touches pass through to the controls underneath.
- Turn off the transition for users who prefer reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  .reveal-layer {
    transition: none !important;
  }
}
```

All underlying content must also remain reachable at high zoom. Content using this pattern must:

- scale to 200% with the browser's built-in zoom without loss of functionality;
- be visible and operable without two-dimensional scrolling at 400% zoom, starting from a 1280 by 1024 CSS pixel viewport.

Transitions must not flash more than three times in any one-second period.

## Fallback strategies

Baseline status for Registered custom properties: Newly available. It's been Baseline since 2024-07-09.
Supported by: Chrome 85 (Aug 2020), Edge 85 (Aug 2020), Firefox 128 (Jul 2024), and Safari 16.4 (Mar 2023).

### Without `@property`

Browsers that support `mask-image` but not `@property` still show the spotlight, but it jumps between on and off because they can't interpolate values inside a `radial-gradient`. They also get no initial value from the registration, so give every `var()` a fallback value. The unregistered pointer properties need one too: until the first `pointermove` they are unset, which would make the whole `mask-image` invalid and show the layer unmasked.

```css
.reveal-layer {
  mask-image: radial-gradient(
    circle at var(--mouse-x, 50%) var(--mouse-y, 50%),
    black var(--inner-size, 0%),
    transparent var(--outer-size, 0%)
  );
}
```

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

### Without masks

For browsers without CSS masking:

1. Use the prefixed `-webkit-mask-image` property for broader support.
2. Design the base UI to be fully functional and legible without the reveal. This works when the effect only adds visual flair and isn't needed to read the content.
