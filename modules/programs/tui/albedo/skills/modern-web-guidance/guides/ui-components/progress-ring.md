# Progress ring

A progress ring (circular progress bar) shows the status of a task. Its circular shape suits dashboards, cards, and other places where space is tight.

This implementation:

- Uses the native `<progress>` element, so the component is accessible to screen readers and keyboard users without extra work.
- Draws the ring with `conic-gradient()` and hollows it out, giving a responsive, themeable ring without SVG path manipulation.
- Registers `--value` with `@property` so the fill transitions smoothly on the GPU.

Prefer this over SVG-only rings: it uses the semantic `<progress>` element instead of ARIA and fits more easily into existing layout, design systems, and typography.

For indeterminate loading states, see the `spinner` guide.

## Implementation

### 1. Markup

A wrapper holds the ring and optional center content. The `<progress>` element stays the semantic source of truth.

```html
<div class="progress-ring-wrapper">
  <progress value="75" max="100" aria-label="Task progress" class="progress-ring"></progress>
  <!-- Optional center content; hidden because it repeats the <progress> value. -->
  <div class="progress-ring-content" aria-hidden="true">
    75%
  </div>
</div>
```

Hide the center content with `aria-hidden="true"`. The `<progress>` element already exposes its value, so screen readers would otherwise announce it twice.

If the center content shows the value in another form, such as "3 of 5 files" or a percentage, set the same text in `aria-valuetext` on the `<progress>` element on every update; otherwise screen readers get only the number.

### 2. Styles

#### Hide the native UI

Remove the browser's default progress bar styling first.

```css
progress.progress-ring::-webkit-progress-bar,
progress.progress-ring::-webkit-progress-value {
  display: none;
  background: none;
}
progress.progress-ring::-moz-progress-bar {
  display: none;
  background: none;
}
progress.progress-ring::slider-fill {
  display: none;
  background: none;
}
```

Keep the `::-moz-progress-bar` and `::slider-fill` rules separate from the WebKit ones: a browser drops a whole selector list when it does not recognize one of its pseudo-elements.

#### Container and ring

The wrapper provides the positioning context and the `<progress>` element draws the gradient. Forced colors mode removes background gradients, so inside `@media (forced-colors: active)` opt the ring out with `forced-color-adjust: none` and draw it in system colors; otherwise the ring disappears.

The ring needs `background-clip: border-area` (or the mask fallback below) to hollow its center.

```css
.progress-ring-wrapper {
  position: relative;
  display: grid;
  place-items: center;
}

progress.progress-ring {
  --size: 150px;
  --thickness: 16px;
  --track-color: #f1f5f9;
  --fill-color: #3b82f6;
  --value: attr(value type(<number>));
  width: var(--size);
  height: var(--size);
  border-radius: 50%;

  background: conic-gradient(
    var(--fill-color) calc(var(--value) * 1%),
    var(--track-color) 0
  );

  background-clip: border-area;
  border: var(--thickness) solid transparent;
  background-origin: border-box;

  /* Fallback: hollow the center with a mask. */
  @supports not (background-clip: border-area) {
    mask-image: radial-gradient(
      transparent calc(50% - var(--thickness)),
      black calc(50% - var(--thickness) + 0.5px)
    );
    border: 0;
  }

  @media (forced-colors: active) {
    forced-color-adjust: none;
    --fill-color: CanvasText;
    --track-color: Canvas;
  }
}

.progress-ring-content {
  /* Centered in the wrapper's grid. */
  position: absolute;
}
```

A `radial-gradient` can also add rounded end caps.

#### Smooth transitions with `@property`

To animate the ring when the value changes, register `--value` as a number.

The transition between values can disorient users with motion sensitivities. Use a 0s (immediate) duration by default and a longer one only under `prefers-reduced-motion: no-preference`.

```css
@property --value {
  syntax: '<number>';
  inherits: true;
  initial-value: 0;
}

progress.progress-ring {
  transition: --value 0s ease-in-out;
  @media (prefers-reduced-motion: no-preference) {
    transition-duration: 0.4s;
  }
}
```

### 3. Progress updates

On every change, update the `value` attribute of the `<progress>` element and, if it shows a percentage, the text of `.progress-ring-content`.

### 4. Optional success state

An attribute selector can change the ring's appearance when the task completes:

```css
progress.progress-ring[value="100"] {
  --fill-color: #10b981;
}
```

## Fallback strategies

Do not put fallback text inside the `<progress>` element. Assistive technology does not use it and all modern browsers ignore it.

### Animation

Baseline status for Registered custom properties: Newly available. It's been Baseline since 2024-07-09.
Supported by: Chrome 85 (Aug 2020), Edge 85 (Aug 2020), Firefox 128 (Jul 2024), and Safari 16.4 (Mar 2023).

Without `@property`, the ring jumps to the new value instead of transitioning. That is usually fine and breaks nothing. If the transition is essential, detect `@property` support and interpolate `--value` with a `requestAnimationFrame()` loop in older browsers.

### `background-clip: border-area`

Browser support for background-clip: border-area: Limited availability.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Browsers without it use the `@supports not (background-clip: border-area)` block above, which hollows the center of the `<progress>` element with a radial `mask-image`.

### `attr()`

Browser support for attr(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 155 (Sep 2026).
Unsupported in: Safari.

Where typed `attr()` is not supported for arbitrary properties, sync the `value` attribute to `--value` with a `MutationObserver`:

```js
const progress = document.querySelector("progress.progress-ring");

if (!CSS.supports("width: attr(value type(<number>))")) {
  const sync = () => progress.style.setProperty("--value", progress.getAttribute("value"));
  sync();
  new MutationObserver(sync).observe(progress, {
    attributes: true,
    attributeFilter: ["value"],
  });
}
```
