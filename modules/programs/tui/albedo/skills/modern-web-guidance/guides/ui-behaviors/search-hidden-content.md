# Search hidden content

Interfaces often hide content to save space, simplify the view or improve performance. `display: none` and `visibility: hidden` hide content visually but also make it unreachable for screen readers and browser features such as find-in-page.

To hide content visually while keeping it findable by search, and linkable through URL fragments and scroll-to-text-fragment links, use the HTML `<details>` element or the `hidden="until-found"` attribute. Prefer `<details>`, which is simpler to build and maintain. Use `hidden="until-found"` only where `<details>` isn't enough, for example when:

- you want full control over the styling of the show/hide mechanism;
- the controls that show and hide the content are elsewhere in the DOM;
- you don't want to support hiding the content again after it is shown.

## How to implement

`<details>` content is searchable and accessible by default and needs nothing extra.

For `hidden="until-found"`:

1. Add `hidden="until-found"` to the elements whose content should be hidden.
2. If other UI depends on the content's visibility (ARIA attributes, open/close classes, rotating accordion icons), keep it in sync with a `beforematch` listener. Register it on the element with `hidden="until-found"`, or, because the event bubbles, register one delegated listener on a parent (such as a tab container) for several hidden sections. In the listener, update the related UI, for example closing other open tabs or changing a toggle button's state.

## Examples

Each example keeps content invisible until the user searches for a word inside it.

### `<details>`

```html
<details>
  <summary>Click to expand</summary>
  <p>This content is visually hidden.</p>
</details>
```

For mutually exclusive regions such as an exclusive accordion, give the `<details>` elements a shared `name`:

```html
<div class="accordion-group">
  <!-- The shared name makes the disclosures mutually exclusive. -->
  <details class="disclosure" name="my-accordion">
    <summary>Section 1</summary>
    <p>Section 1 content</p>
  </details>

  <details class="disclosure" name="my-accordion" open>
    <summary>Section 2</summary>
    <p>Section 2 content</p>
  </details>

  <details class="disclosure" name="my-accordion">
    <summary>Section 3</summary>
    <p>Section 3 content</p>
  </details>
</div>
```

### `hidden="until-found"`

```html
<!-- The browser removes hidden="until-found" when a search matches inside. -->
<div class="hidden-container" hidden="until-found">
  <p>This content is visually hidden.</p>
</div>
```

For custom mutually exclusive regions controlled by external buttons, make sure only the matched panel stays visible, and update the related ARIA state in the `beforematch` handler, such as `aria-expanded="true"` on the controlling button.

```html
<div class="custom-accordion">
  <div class="controls">
    <button aria-expanded="true" aria-controls="panel-1" id="btn-1">Section 1</button>
    <button aria-expanded="false" aria-controls="panel-2" id="btn-2">Section 2</button>
  </div>

  <div id="panel-1" class="panel">
    <p>Section 1 content (visible)</p>
  </div>

  <div id="panel-2" class="panel" hidden="until-found">
    <p>Section 2 content (hidden)</p>
  </div>
</div>
```

```javascript
const accordion = document.querySelector('.custom-accordion');

accordion.addEventListener('beforematch', (e) => {
  // Hide the other panels and sync button states before the browser reveals the match.
  accordion.querySelectorAll('.panel').forEach((panel) => {
    if (panel !== e.target) {
      panel.hidden = 'until-found';
    }
  });
  accordion.querySelectorAll('button').forEach((btn) => {
    const controls = btn.getAttribute('aria-controls');
    btn.setAttribute('aria-expanded', controls === e.target.id ? 'true' : 'false');
  });
});
```

## Rules for `hidden="until-found"`

- Put borders, padding and backgrounds on a nested child wrapper, not on the element with `hidden="until-found"`, to avoid layout shifts or visual remnants while it is hidden.
- Don't apply `display: none`, `visibility: hidden` or any other `display` or `visibility` value to elements with `hidden="until-found"`. That breaks the feature and keeps the content out of search for good.
- Don't use it for sensitive information, internal data tokens, or irrelevant data that shouldn't be exposed to search.
- Don't use it as a replacement for screen-reader-only (`.sr-only`) text.

## Browser support and fallback strategies

Baseline status for <details>: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 12 (Jun 2011), Edge 79 (Jan 2020), Firefox 49 (Sep 2016), and Safari 6 (Jul 2012).

Browser support for hidden="until-found": Limited availability.
Supported by: Chrome 102 (May 2022), Edge 102 (May 2022), and Firefox 148 (Feb 2026).
Unsupported in: Safari.

Don't avoid `hidden="until-found"` because of limited support; its accessibility benefits far outweigh the cost of a fallback.

For ordinary UI such as accordions or "Read more" sections, feature-detect it and show all content when it's unsupported:

```javascript
if (!('onbeforematch' in HTMLElement.prototype)) {
  // Expand all hidden content in unsupported browsers.
  document.querySelectorAll('[hidden="until-found"]').forEach((el) => {
    el.removeAttribute('hidden');
    // Also update any ARIA that refers to this element, such as aria-expanded on controls whose aria-controls points here.
  });
}
```

For mutually exclusive UI, such as custom panels that share one visual region, the fallback should lay out all the content linearly below the main interactive area and use URL fragment anchors so users can jump to each section.
