# Interest Triggered Action Previews

Showing users a preview of an action before they commit to it can help them decide. Interest invokers, an experimental platform feature, declare an interest relationship between an interest source (a button or link) and an interest target. Once the relationship exists you can respond to interest and loss of interest in CSS and JavaScript. For previews, use the `interest` and `loseinterest` events on the target.

Use a preview only for secondary information that is also available elsewhere in the UI, or after selecting a control that does not submit anything. Not everyone can reach what a preview shows, particularly people using assistive technology, so it must never be the only way to get that information.

## How to implement

Create the relationship with the `interestfor` attribute on a button or link (the interest source). Its value is the ID of the interest target. A source can have only one target, but a target can have many sources.

```html
<button interestfor="interestingElement" data-effect="A">Some effect</button>
<button interestfor="interestingElement" data-effect="B">Some other effect</button>
<div id="interestingElement">Something interesting</div>
```

Both events are `InterestEvent`s. Their `source` property is the element with the `interestfor` attribute that triggered them.

```javascript
const interestingElement = document.getElementById("interestingElement");

interestingElement.addEventListener("interest", event => {
  // Apply the preview for event.source.
  event.target.dataset.preview = event.source.dataset.effect;
});

interestingElement.addEventListener("loseinterest", event => {
  // Remove the preview.
  delete event.target.dataset.preview;
});
```

> [!NOTE]
> Don't announce interest-driven previews through a live region. Interest fires just from moving the pointer across the page or tabbing past nearby buttons, so apply and remove announcements quickly become noise that drowns out content the user cares about. The preview itself is the affordance: users who can perceive it benefit directly, and users who can't gain nothing from a spoken "Previewing effect: A". If a specific case seems to need an announcement, test it carefully with users.

Select active sources and targets in CSS with the `:interest-source` and `:interest-target` pseudo-classes:

```css
/* Styles while the effect is previewed. */
:interest-source {}
:interest-target {}
```

Set the start and end delay on the source with `interest-delay-start` and `interest-delay-end`, or the `interest-delay` shorthand:

```css
[interestfor] {
  interest-delay-start: 0.2s;
  interest-delay-end: 0.1s;
}
```

## Fallback strategies

Browser support for Interest invokers: Limited availability.
Supported by: Chrome 149 (Jun 2026) and Edge 149 (Jun 2026).
Unsupported in: Firefox and Safari.

Polyfill interest invokers conditionally with the `interestfor` package from npm. Bundle the polyfill rather than loading it from a CDN.

Feature-detect with the `interestForElement` property on `HTMLButtonElement.prototype`, and load the polyfill only when native support is missing:

```html
<script type="module">
  if (!("interestForElement" in HTMLButtonElement.prototype)) {
    // CDN URL for illustration only; prefer bundling.
    await import("https://unpkg.com/interestfor@latest");
  }
</script>
```

### CSS caveats with the polyfill

The polyfill cannot add native pseudo-classes or properties, so the CSS changes slightly:

- Pseudo-classes: the polyfill applies `.interest-source` and `.interest-target` classes instead of `:interest-source` and `:interest-target`. Combine both with `:is()` so native and polyfilled states match:

```css
/* Styles while the effect is previewed. */
:is(:interest-source, .interest-source) { /* ... */ }
:is(:interest-target, .interest-target) { /* ... */ }
```

- Properties: for `interest-delay`, `interest-delay-start` and `interest-delay-end`, the polyfill needs the values in CSS custom properties, because it cannot read the real properties in every browser:

```css
[interestfor] {
  --interest-delay-start: 0.2s;
  interest-delay-start: var(--interest-delay-start);
  --interest-delay-end: 0.1s;
  interest-delay-end: var(--interest-delay-end);
}
```

If a preview (or another interest-triggered element) is already active and users are likely to move across several triggers in quick succession, set the start delay to `0s`:

```css
.container:has([interestfor]:is(:interest-source, .interest-source)) [interestfor] {
  --interest-delay-start: 0s;
}
```
