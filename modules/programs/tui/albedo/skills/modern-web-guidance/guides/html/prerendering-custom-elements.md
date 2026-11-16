# Pre-rendering custom elements

Pre-rendering ships a custom element's markup, including its shadow tree, from the server, so the component is structured and styled before any JavaScript runs. The platform primitive for this is Declarative Shadow DOM (DSD): the parser attaches the shadow root from HTML alone, and the element is later upgraded ("hydrated") by its class if one is registered. Use it for server-side rendering, streaming, and avoiding a flash of unstyled content (FOUC).

## Authoring a declarative shadow root

Nest a `<template shadowrootmode>` as the first child of the host. The parser attaches its content as a shadow root and removes the template, without any script.

```html
<my-card>
  <template shadowrootmode="open">
    <style>
      .card { border: 1px solid; border-radius: 8px; padding: 1rem; }
    </style>
    <div class="card">
      <slot name="header"></slot>
      <div class="body"><slot></slot></div>
    </div>
  </template>

  <!-- Light DOM children are projected into the slots above. -->
  <h2 slot="header">Server-rendered title</h2>
  <p>Visible and styled before JS loads.</p>
</my-card>
```

## Hydration timing

When the matching class is registered, the browser upgrades the host. The shadow root already exists at that point, so the constructor must not blindly create a second one:

```javascript
class MyCard extends HTMLElement {
  constructor() {
    super();
    // Reuse the server-rendered shadow root; create one only if absent.
    if (!this.shadowRoot) {
      this.attachShadow({ mode: 'open' });
      this.shadowRoot.append(template.content.cloneNode(true));
    }
    // Attach listeners once to the existing markup and do not re-render.
    this.shadowRoot.getElementById('toggle')
      ?.addEventListener('click', () => this.toggleAttribute('open'));
  }
}
```

Attach listeners once against the existing markup, as above, rather than unguarded in `connectedCallback`, which re-runs whenever the element moves in the DOM. Re-rendering would discard the server's DOM and cause a flash.

Use `shadowrootmode="open"` rather than `closed` in almost all cases, so scripts and tools can reach `this.shadowRoot` to hydrate. To serialize an existing shadow root back to HTML on the server or in tests, attach the root with `serializable: true` and call `getHTML({ serializableShadowRoots: true })`.

## Avoiding FOUC

DSD renders correctly on first paint only if the styles ship inside the declarative template:

- Put component CSS inside the `<template shadowrootmode>`, as a `<style>` or `<link>`, not in a sheet that script loads later.
- Use `my-card:not(:defined) { … }` only for styles that must wait for JavaScript, typically page-level guard rules such as a fade-out for client-rendered instances that missed the SSR pass. These rules belong in the page (Light DOM) stylesheet, because the shadow root does not exist yet for those instances and `:host` selectors do not apply from outside. Structural styles inside the DSD template need no such guard.
- Do not re-render the shadow tree on hydration. Treat the server markup as authoritative and attach behavior to it.

## Fallback strategies

Baseline status for Declarative shadow DOM: Widely available. It's been Baseline since 2024-02-20.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 123 (Feb 2024), and Safari 16.4 (Mar 2023).

In engines that do not parse `shadowrootmode`, the template stays inert and its content is not attached as a shadow root. Detect this with `Object.hasOwn(HTMLTemplateElement.prototype, 'shadowRootMode')`; if it is absent, attach the shadow root imperatively from the same markup during upgrade so the component still renders.
