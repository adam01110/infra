# Brand-Consistent Forms

The CSS `accent-color` property applies a brand color to built-in form controls with one line of CSS, keeping their accessibility and built-in browser features. Use it instead of rebuilding checkboxes and radio buttons as custom components, which takes time and easily introduces accessibility problems or missing states such as a checkbox's indeterminate state.

## How to implement

1. Pick the brand color.
2. Set `accent-color` on the element or on a container such as `body` or a specific form.
3. Recommended: declare dark mode support with `color-scheme` and adjust `accent-color` for dark mode where needed for contrast.

## Example

```css
:root {
  --brand-color: #6200ee;
}

body {
  accent-color: var(--brand-color);
}

@media (prefers-color-scheme: dark) {
  :root {
    /* A lighter shade for dark mode. */
    --brand-color: #bb86fc;
  }
}
```

```html
<form>
  <label for="subscribe">
    <input type="checkbox" id="subscribe" checked>
    Subscribe to newsletter
  </label>

  <label for="plan-monthly">
    <input type="radio" id="plan-monthly" name="plan" value="monthly">
    Monthly
  </label>
  <label for="plan-yearly">
    <input type="radio" id="plan-yearly" name="plan" value="yearly" checked>
    Yearly
  </label>

  <label for="volume">Volume:</label>
  <input type="range" id="volume" min="0" max="100" value="70">

  <label for="file">Upload Progress:</label>
  <progress id="file" max="100" value="70">70%</progress>
</form>
```

## Best practices

- Use `accent-color` to theme form controls to the brand.
- Check contrast yourself. Browsers are supposed to pick a contrasting checkmark color automatically, but known bugs in Safari (WebKit bug 244233) and Android Chrome (Chromium bug 343503163) can fail to invert it, leaving controls invisible or hard to see when the accent color lacks contrast with the background (for example a light color in light mode or a dark color in dark mode).
- Combine `accent-color` with `color-scheme: light dark` so controls look right in both themes.
- Choose a color with good base contrast, at least 3:1 against the background, even though browsers try to guarantee contrast.
- `accent-color` tints only `checkbox`, `radio`, `range` and `progress` elements, not every form control.

## Fallback strategy

Browser support for `accent-color`: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021) and Safari 26.2 (Dec 2025).

Without `accent-color` support, controls fall back to the browser's default appearance. For full brand consistency in those browsers, implement a custom fallback with the established visually-hidden-input technique, and scope it with `@supports not` so supporting browsers keep the simple `accent-color` path.

### 1. HTML structure

Wrap the label text in a `<span>` so CSS sibling selectors can reach it:

```html
<label for="subscribe-fallback">
  <input type="checkbox" id="subscribe-fallback" class="visually-hidden" checked>
  <span>Subscribe to newsletter</span>
</label>
```

### 2. CSS fallback

```css
@supports not (accent-color: var(--brand-color)) {
  /* Canonical accessible visually-hidden recipe. */
  form input[type="checkbox"].visually-hidden {
    position: absolute !important;
    clip-path: inset(50%) !important;
    overflow: hidden !important;
    width: 1px !important;
    height: 1px !important;
    margin: -1px !important;
    padding: 0 !important;
    border: 0 !important;
    white-space: nowrap !important;
  }

  label {
    position: relative;
    padding-left: 2rem;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
  }

  /* Custom checkbox box. */
  input[type="checkbox"] + span::before {
    content: "";
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 1.2rem;
    height: 1.2rem;
    border: 2px solid #ccc;
    background: white;
    border-radius: 4px;
    box-sizing: border-box;
    transition: all 0.2s ease;
  }

  /* Keep focus visible for keyboard users. */
  input[type="checkbox"]:focus-visible + span::before {
    outline: 2px solid #000;
    outline-offset: 2px;
  }

  input[type="checkbox"]:checked + span::before {
    background-color: var(--brand-color, #6200ee);
    border-color: var(--brand-color, #6200ee);
  }

  input[type="checkbox"]:checked + span::after {
    content: "✓";
    position: absolute;
    left: 0.25rem;
    top: 50%;
    transform: translateY(-50%);
    color: white;
    font-weight: bold;
    font-size: 0.9rem;
  }

  /* Range slider. */
  input[type="range"] {
    -webkit-appearance: none;
    appearance: none;
    background: transparent;
  }

  /* WebKit/Blink (Chrome, Safari, Edge). The gradient shows a static
     value (70%); see below to update it with JavaScript. */
  input[type="range"]::-webkit-slider-runnable-track {
    width: 100%;
    height: 8px;
    background: linear-gradient(to right, var(--brand-color, #6200ee) 70%, #ccc 70%);
    border-radius: 4px;
  }

  input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    height: 16px;
    width: 16px;
    border-radius: 50%;
    background: var(--brand-color, #6200ee);
    cursor: pointer;
    margin-top: -4px; /* Centers the thumb vertically. */
  }

  /* Firefox. */
  input[type="range"]::-moz-range-track {
    width: 100%;
    height: 8px;
    background: #ccc;
    border-radius: 4px;
  }

  input[type="range"]::-moz-range-thumb {
    height: 16px;
    width: 16px;
    border-radius: 50%;
    background: var(--brand-color, #6200ee);
    cursor: pointer;
  }

  /* Firefox fills the track up to the thumb natively. */
  input[type="range"]::-moz-range-progress {
    background-color: var(--brand-color, #6200ee);
    height: 8px;
    border-radius: 4px;
  }

  /* Progress bar. */
  progress {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    border: none;
    background: #ccc;
    height: 8px;
    border-radius: 4px;
  }

  progress::-webkit-progress-bar {
    background-color: #ccc;
    border-radius: 4px;
  }

  progress::-webkit-progress-value {
    background-color: var(--brand-color, #6200ee);
    border-radius: 4px;
  }

  progress::-moz-progress-bar {
    background-color: var(--brand-color, #6200ee);
    border-radius: 4px;
  }
}
```

### Dynamic range fill in the WebKit fallback

To make the fill follow the thumb in WebKit/Blink browsers without `accent-color`, drive the gradient stop with a CSS variable:

```css
input[type="range"]::-webkit-slider-runnable-track {
  background: linear-gradient(to right, var(--brand-color) var(--progress, 0%), #ccc var(--progress, 0%));
}
```

Update the variable on the `input` event. The calculation assumes `min="0"` and `max="100"`, as in the example:

```javascript
if (!CSS.supports('accent-color', 'auto')) {
  const slider = document.getElementById('volume');
  const sync = () => slider.style.setProperty('--progress', `${slider.value}%`);
  sync();
  slider.addEventListener('input', sync);
}
```
