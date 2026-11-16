# Brand-Consistent Range Slider

## Use the native range input

Use a labeled `<input type="range">` rather than rebuilding a slider from `<div>` elements and custom pointer handlers. The native control keeps keyboard, pointer and touch interaction and accessibility support. Set `min`, `max`, `step` and `value` for the use case.

```html
<label for="range-slider">Volume</label>
<input type="range" id="range-slider" value="70"/>
```

If the value needs a formatted label or unit, show it in ordinary DOM content and update `aria-valuetext` when it changes. Do not use `::before` or `::after` on the slider's pseudo-elements: generated content on form controls is not interoperable. If a tooltip must follow the thumb, anchor it to the thumb with CSS anchor positioning; the `position-aware-tooltips` guide covers tooltips that stay correctly oriented when they flip.

## Choose the styling approach

For a simple color change, keep the browser's native rendering and set `accent-color` (see the `brand-consistent-forms` guide):

```css
input[type="range"] {
  accent-color: var(--brand-color);
}
```

`accent-color` is not a complete slider styling API; how it affects the thumb, track and fill depends on the browser. Use the pseudo-elements below when you need to control the track, thumb, dimensions, shape or fill.

## Style the track and thumb

Reset the default OS styling with `appearance: none`, `margin: 0` and `border: 0`. Declare the WebKit and Firefox pseudo-elements in separate rule blocks, because a browser drops a whole rule whose selector list contains a vendor pseudo-element it does not recognize; never combine them as `::-webkit-slider-thumb, ::-moz-range-thumb`. Center the WebKit thumb with `margin-block-start: calc((var(--slider-track-size) - var(--slider-thumb-size)) / 2)`; Firefox centers it automatically. Expose the themeable values as custom properties on the input so themes do not target pseudo-elements directly.

```css
input[type="range"] {
  --slider-track-size: 0.5rem;
  --slider-thumb-size: 1.25rem;
  --slider-track-radius: 999px;
  --slider-thumb-radius: 50%;
  --slider-track-color: #d9d9d9;
  --slider-fill-color: #06c;
  --slider-thumb-color: var(--slider-fill-color);
  --slider-direction: to right;

  /* reverse gradient direction for right-to-left layouts */
  &:dir(rtl) {
    --slider-direction: to left;
  }

  /* Read min and max from attributes; --control-value is synced by the script below. */
  --attr-min: attr(min type(<number>), 0);
  --attr-max: attr(max type(<number>), 100);
  --control-value: attr(value type(<number>), 50);
  --slider-progress: calc(
    progress(var(--control-value), var(--attr-min), var(--attr-max)) * 100%
  );

  appearance: none;
  inline-size: 100%;
  block-size: 2.5rem; /* Preserve a generous interaction area. */
  margin: 0;
  padding: 0;
  border: 0;
  border-radius: 0;
  background: transparent;
  cursor: pointer;
}

/* WebKit/Blink. */
input[type="range"]::-webkit-slider-runnable-track {
  block-size: var(--slider-track-size);
  border: 0;
  border-radius: var(--slider-track-radius);
  background: linear-gradient(
    var(--slider-direction),
    var(--slider-fill-color) var(--slider-progress),
    var(--slider-track-color) var(--slider-progress)
  );
}

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  inline-size: var(--slider-thumb-size);
  block-size: var(--slider-thumb-size);
  margin-block-start: calc(
    (var(--slider-track-size) - var(--slider-thumb-size)) / 2
  );
  border: 0;
  border-radius: var(--slider-thumb-radius);
  background: var(--slider-thumb-color);
}

/* Firefox. */
input[type="range"]::-moz-range-track {
  block-size: var(--slider-track-size);
  border: 0;
  border-radius: var(--slider-track-radius);
  background: var(--slider-track-color);
}

input[type="range"]::-moz-range-progress {
  block-size: var(--slider-track-size);
  border-radius: var(--slider-track-radius);
  background: var(--slider-fill-color);
}

input[type="range"]::-moz-range-thumb {
  inline-size: var(--slider-thumb-size);
  block-size: var(--slider-thumb-size);
  border: 0;
  border-radius: var(--slider-thumb-radius);
  background: var(--slider-thumb-color);
}
```

Give the track a contrast of at least 3:1 with the background.

After removing the native appearance, provide a visible keyboard focus indicator with a contrast of at least 3:1 against the background or the adjacent track, and do not rely on color alone:

```css
input[type="range"]:focus-visible {
  outline: 2px solid var(--slider-fill-color);
  outline-offset: 4px;
}
```

## Style the filled track

Firefox exposes the filled part of the track as `::-moz-range-progress`. WebKit/Blink have no equivalent pseudo-element, so the CSS above paints the fill with a gradient driven by `--control-value`. Sync the live value into it on `input` events, because the typed `attr(value)` reflects only the initial `value` attribute:

```js
const slider = document.querySelector('#range-slider');

function syncSliderValue() {
  slider.style.setProperty('--control-value', slider.value);
}

syncSliderValue();
slider.addEventListener('input', syncSliderValue);
```

## Fallback strategies

### accent-color

Browser support for `accent-color`: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021) and Safari 26.2 (Dec 2025).

`accent-color` is progressive enhancement: browsers without support ignore it and use their default UI colors.

### progress() and attr()

Baseline status for `progress()`: Newly available, Baseline since 2026-09-01.
Supported by: Chrome 138 (Jun 2025), Edge 138 (Jun 2025), Firefox 155 (Sep 2026) and Safari 26 (Sep 2025).

Where `progress()` is unsupported, compute `--slider-progress` with `calc()`:

```css
@supports not (opacity: progress(1, 0, 100)) {
  input[type="range"] {
    --slider-progress: calc(
      (var(--control-value) - var(--attr-min)) /
      (var(--attr-max) - var(--attr-min)) * 100%
    );
  }
}
```

Browser support for typed `attr()`: Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025) and Firefox 155 (Sep 2026).
Unsupported in: Safari.

Where typed `attr()` is unsupported, use this version of `syncSliderValue` instead of the one above; it also syncs `--attr-min` and `--attr-max` from the input's `min` and `max`:

```js
function syncSliderValue() {
  slider.style.setProperty('--attr-min', slider.min || 0);
  slider.style.setProperty('--attr-max', slider.max || 100);
  slider.style.setProperty('--control-value', slider.value);
}
```
