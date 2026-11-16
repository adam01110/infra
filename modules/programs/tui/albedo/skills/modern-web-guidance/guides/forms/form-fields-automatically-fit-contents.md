# Form Fields Automatically Fit Contents

Form controls such as `<input>`, `<textarea>` and `<select>` have fixed dimensions by default, whatever the user enters or selects. The CSS property `field-sizing: content` lets them shrink or grow to fit their content, including placeholders.

## Auto-sizing form controls

With `field-sizing: content`, inputs, selects and textareas resize as the user types or selects. Account for inherited styles, layout defaults and size limits:

- Text inputs: set both `min-inline-size` (or `min-width`) and `max-inline-size` (or `max-width`). The minimum stops an empty input collapsing to zero width, where it cannot be clicked; the maximum stops it growing without limit and breaking the layout.
- Textareas: give them an explicit width such as `width: 100%`. Horizontal auto-sizing is jarring, for example a textarea with a long placeholder abruptly shrinks when the user types one character. A fixed width keeps the horizontal size stable while the textarea still grows vertically as content wraps.
- Selects: set a `max-inline-size` (or `max-width`) so a very long selected option cannot break the layout.

```css
input {
  field-sizing: content;
  /* Resets a width inherited from global styles. */
  width: auto;
  /* Keeps an empty input from collapsing. */
  min-inline-size: 15ch;
  max-inline-size: 50ch;
}

textarea {
  field-sizing: content;
  /* Resets a height inherited from global styles. */
  height: auto;
  /* Fixed width avoids horizontal jumps when a long placeholder is replaced;
     use 100% or 50ch depending on the layout. */
  width: 50ch;
  /* About 3 lines when empty. */
  min-block-size: 3lh;
  /* Past this height the textarea stops growing and scrolls. */
  max-block-size: 10lh;
}

select {
  /* Sizes the select to the selected option only. */
  field-sizing: content;
  max-inline-size: 50ch;
}
```

Explicit `width` and `height` override `field-sizing: content` on every form control. If global CSS sets inputs, selects or textareas to `width: 100%`, reset them to `width: auto` (or `width: fit-content`) on the elements that use `field-sizing: content`, or auto-sizing will not work. Likewise set `height: auto` on textareas if a fixed height was set globally.

Grid and Flexbox layouts often stretch their children to fill available space. If a control with `field-sizing: content` will not shrink, check its container's alignment and give the control `align-self: start` or `justify-self: start` to stop the stretching.

## Fallback strategies

Baseline status for `field-sizing`: Newly available, Baseline since 2026-06-16.
Supported by: Chrome 123 (Mar 2024), Edge 123 (Mar 2024), Firefox 152 (Jun 2026) and Safari 26.2 (Dec 2025).

Treat `field-sizing` as progressive enhancement. Without support, controls keep their default fixed size and overflowing content scrolls inside them.

If growing fields are essential in older browsers, use feature detection and a workaround. The most robust textarea fallback is a CSS Grid trick: a hidden pseudo-element mirrors the user's input in real time and forces the grid container, and the textarea in it, to grow.

```html
<!-- The container mirrors the textarea's value. -->
<div class="growable-textarea" data-replicated-value="">
  <textarea></textarea>
</div>
```

```javascript
if (!CSS.supports('field-sizing', 'content')) {
  document.querySelectorAll('.growable-textarea > textarea').forEach(textarea => {
    textarea.addEventListener('input', () => {
      textarea.parentNode.dataset.replicatedValue = textarea.value;
    });
  });
}
```

```css
@supports not (field-sizing: content) {
  .growable-textarea {
    display: grid;
  }

  /* The pseudo-element and textarea must share the same cell, font and padding. */
  .growable-textarea::after,
  .growable-textarea > textarea {
    grid-area: 1 / 1 / 2 / 2;
    font: inherit;
    padding: 0.5rem;
    border: 1px solid #999;
  }

  /* Invisible copy of the text that stretches the grid. */
  .growable-textarea::after {
    /* The trailing space makes trailing empty lines render. */
    content: attr(data-replicated-value) " ";
    white-space: pre-wrap;
    visibility: hidden;
  }

  .growable-textarea > textarea {
    resize: none;
    overflow: hidden;
  }
}
```

Duplicating styles and synchronizing state for every control is complex, so for most applications accept the default fixed-size fallback unless dynamic sizing is critical to the user experience.
