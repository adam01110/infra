# Loading spinner

A loading spinner (activity indicator) tells users that a process is running when its duration is unknown. Unlike a progress ring, a spinner is indeterminate and uses animation to signal activity.

This implementation:

- Uses the native `<progress>` element. Without a `value` attribute the browser treats it as an indeterminate progress bar, so assistive technologies announce it correctly.
- Draws a trailing arc with `conic-gradient()` and hollows the center into a ring with `background-clip: border-area`.
- Animates with CSS transforms and respects `prefers-reduced-motion`.

For determinate tasks with a known duration, see the `progress-ring` guide.

## Implementation

### 1. Markup

The `<progress>` element is both the semantic source of truth and the visual component. Without a `value` attribute it is indeterminate.

```html
<progress aria-label="Loading" class="loading-spinner"></progress>
```

### 2. Styles

#### Hide the native UI

Remove the browser's default indeterminate progress bar styling first.

```css
progress.loading-spinner:indeterminate::-webkit-progress-bar,
progress.loading-spinner:indeterminate::-webkit-progress-value {
  display: none;
  background: none;
}
progress.loading-spinner:indeterminate::-moz-progress-bar {
  display: none;
  background: none;
}
progress.loading-spinner:indeterminate::slider-fill {
  display: none;
  background: none;
}
```

Keep the `::-moz-progress-bar` and `::slider-fill` rules separate from the WebKit ones: a browser drops a whole selector list when it does not recognize one of its pseudo-elements.

#### Ring and trail

A `conic-gradient` draws the trail. Forced colors mode removes background gradients, so inside `@media (forced-colors: active)` opt the spinner out with `forced-color-adjust: none` and draw it in system colors; otherwise the spinner disappears.

```css
@property --arc-start {
  syntax: "<angle>";
  inherits: false;
  initial-value: 0deg;
}
@property --arc-end {
  syntax: "<angle>";
  inherits: false;
  initial-value: 0deg;
}
/* Adds the dash animation only where @property is supported. */
@property --progress-dash-animation {
  syntax: "*";
  inherits: false;
  initial-value: , progress-dash 3s ease-in-out infinite;
}

progress.loading-spinner:indeterminate {
  --_from: calc(90deg + var(--arc-start, 0deg));
  --_to: calc(90deg + var(--arc-end, 158deg));
  --size: 40px;
  --thickness: 2px;
  --spinner-color: #2563eb;
  --track-color: #e2e5e7;
  --spinner-duration: 1.5s;
  --_used-spinner-duration: var(--spinner-duration);
  --spinner-timing: linear;

  position: relative;
  width: var(--size);
  height: var(--size);
  border-radius: 50%;
  appearance: none;

  /* Trail between the animated start and end angles. */
  background: conic-gradient(
      from var(--_from),
      var(--spinner-color) calc(var(--_to) - var(--_from)),
      transparent 0
    )
    var(--track-color);

  @supports (background-clip: border-area) {
    background-clip: border-area;
    border: var(--thickness) solid transparent;
    background-origin: border-box;
  }

  /* Fallback: hollow the center with a mask. */
  @supports not (background-clip: border-area) {
    --clip-boundary: calc(100% - var(--thickness));
    mask-image: radial-gradient(
      farthest-side,
      transparent var(--clip-boundary),
      black var(--clip-boundary)
    );
    border: 0;
  }

  @media (forced-colors: active) {
    forced-color-adjust: none;
    --spinner-color: CanvasText;
    --track-color: Canvas;
  }

  animation:
    progress-spin var(--_used-spinner-duration) linear infinite
    var(--progress-dash-animation, );
}

@keyframes progress-spin {
  to {
    rotate: 1turn;
  }
}

@keyframes progress-dash {
  from {
    --arc-start: 0deg;
    --arc-end: 3deg;
  }
  50% {
    --arc-start: 100deg;
    --arc-end: 358deg;
  }
  to {
    --arc-start: 360deg;
    --arc-end: 363deg;
  }
}
```

#### Respect motion preferences

Fast spinning can disorient users with motion sensitivities, so honor `prefers-reduced-motion`. Override the internal `--_used-spinner-duration` (not the author-facing `--spinner-duration`), using the same selector as the spinner rule so the override applies, and drop the dash animation so only a slow rotation remains.

```css
@media (prefers-reduced-motion: reduce) {
  progress.loading-spinner:indeterminate {
    /* Slow down rather than stop, so users still see that the process is active. */
    --_used-spinner-duration: 6s;
    /* Without the dash animation the arc keeps a fixed length. */
    --progress-dash-animation: ;
    --arc-end: 158deg;
  }
}
```

## Fallback strategies

Baseline status for Registered custom properties: Newly available. It's been Baseline since 2024-07-09.
Supported by: Chrome 85 (Aug 2020), Edge 85 (Aug 2020), Firefox 128 (Jul 2024), and Safari 16.4 (Mar 2023).

Where `@property` is supported, the `initial-value` of `--progress-dash-animation` adds the dash animation automatically. Browsers without `@property` ignore the registration and fall back to a plain rotation. No JavaScript is needed.

Browser support for background-clip: border-area: Limited availability.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Browsers without `background-clip: border-area` use the `@supports not (background-clip: border-area)` block above, which hollows the center with a radial `mask-image`.
