# Shadow DOM, Templates & Slots

A shadow root is an encapsulated DOM subtree attached to a host element: its styles do not leak out, and page styles do not leak in, except for inherited properties. Templates build the tree efficiently; slots project Light DOM content into it.

## Attaching a shadow root

```javascript
this.attachShadow({ mode: 'open', delegatesFocus: true });
```

`delegatesFocus: true` moves focus from the host to the first focusable element inside the shadow tree, makes `:focus` match the host, and on form-associated custom elements (`static formAssociated = true`) forwards `<label>` clicks to the inner control. Set it whenever the component wraps focusable controls.

Use `mode: 'open'` in almost all cases, so dev tools, page scripts and server hydration can reach `element.shadowRoot` (see the `web-components` guide).

## Templates

Define a `<template>` once, at module scope or in a static field, and deep-clone its content per instance. Cloning a parsed fragment is far faster than re-parsing an `innerHTML` string on every construction.

```javascript
const template = document.createElement('template');
template.innerHTML = `
  <div class="card">
    <slot name="header"></slot>
    <div class="body"><slot></slot></div>
    <slot name="footer"></slot>
  </div>
`;

class MyCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    // Deep clone, so each instance gets its own nodes.
    this.shadowRoot.append(template.content.cloneNode(true));
  }
}
customElements.define('my-card', MyCard);
```

Keep templates lean. Deeply nested `<div>` wrappers and many levels of nested shadow roots both add measurable style-resolution and layout cost, which becomes a major performance hit at scale. Prefer a flat structure and semantic elements.

## Slot behaviors that surprise

Default and named slots work as documented. These behaviors cause bugs:

- Whitespace counts. Text nodes between elements, including whitespace-only ones, are assigned to the default slot, so a default slot is rarely truly empty.
- Projected nodes keep their Light DOM order for `:first-child` and `:last-child`, regardless of which slot they fill. `::slotted(*:first-child)` matches the first DOM child, not the first child of that slot, so it often does not match what you expect.
- `slotchange` is the upgrade-timing signal. It fires when the assigned nodes change, including the initial assignment, and it is the reliable way to learn that Light DOM children have arrived after an upgrade, when they may not have existed during `connectedCallback`.

```javascript
this.shadowRoot.querySelector('slot[name="header"]')
  .addEventListener('slotchange', (e) => {
    const nodes = e.target.assignedElements();
    this.toggleAttribute('has-header', nodes.length > 0);
  });
```

## Loading stylesheets into a shadow root

| Method | Pros | Cons |
| :--- | :--- | :--- |
| `<style>` in the template | Simple, fully encapsulated, works without JS. | Duplicated per instance; bloats the DOM at scale. |
| `<link rel="stylesheet">` | Cacheable external file. | Extra request; risks a flash of unstyled content. |
| `adoptedStyleSheets` | One shared `CSSStyleSheet` across all instances; fastest at scale. | Requires JS; constructed sheets don't support `@import`. |

For many instances of one component, share one constructed stylesheet, so no instance parses its own copy:

```javascript
const sheet = new CSSStyleSheet();
sheet.replaceSync(`:host { display: block; }`);

class MyCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.adoptedStyleSheets = [sheet];
  }
}
```
