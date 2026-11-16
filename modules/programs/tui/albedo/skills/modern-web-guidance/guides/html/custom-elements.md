# Custom Elements

A custom element is a class registered against a tag name with `customElements.define()`. Registration and the basic lifecycle are well understood; this guide covers the parts that are routinely implemented incorrectly.

A custom element has no role or keyboard behavior of its own. That is fine when its content already carries the meaning, such as a layout wrapper around headings and text. If it needs semantics or keyboard support, build it from native elements such as a `<button>` inside its template, or give it a role and ARIA state through `ElementInternals` plus focus handling, as described in the `accessible-web-components` guide. If its content is purely decorative, hide it from assistive technologies with `aria-hidden="true"`.

## Lifecycle pitfalls

- `connectedCallback` runs on every insertion, so moving the element runs it again. Make setup idempotent rather than assuming a single first run.
- When an element is relocated with `Node.moveBefore()`, `connectedMoveCallback` fires instead of the `disconnectedCallback` and `connectedCallback` pair, so state, focus, and iframe or media playback survive the move. Define it when your setup or teardown is expensive or has observable effects when re-run.
- Tear down in `disconnectedCallback`: remove global listeners, timers and observers, or they leak. The element may be re-inserted, so do not treat teardown as permanent.
- Call `super()` first in the constructor; touching `this` before it throws a `ReferenceError`. Do not depend on the full DOM being present in the constructor: attributes are usually, but not always, present, and long lists of children may not have finished parsing. Use `connectedCallback` for one-shot initialization, `slotchange` to monitor direct children, and `attributeChangedCallback` to monitor attributes. `connectedCallback` can still fire before all children are parsed, so keep handling later `slotchange` and `attributeChangedCallback` calls.
- `attributeChangedCallback` fires only for attributes listed in `observedAttributes`. Keep it cheap for attributes that do not affect output.
- `customElements.define()` reads the lifecycle hooks and `observedAttributes` once, at registration. Adding a hook or extending `observedAttributes` on the class after the call is silently ignored; in particular, `attributeChangedCallback` never fires unless `observedAttributes` existed at `define()` time.

## Upgrade timing and `:defined`

An element can be in the DOM before its class is registered, in server-rendered HTML or when the script loads late. Until then it is an inert `HTMLElement` with none of your behavior. When `customElements.define()` runs, the browser upgrades every matching element already in the document, running its constructor and `connectedCallback` at that point. Two consequences:

1. Attributes and children may already be present when the constructor or `connectedCallback` runs on upgrade. Read existing attributes in `connectedCallback` to sync the initial state, and never assume the element started empty.
2. Children may still be missing even in `connectedCallback`, because the HTML parser can yield partway through a long child list. Use the `slotchange` and `attributeChangedCallback` pattern from the lifecycle section.

Hide undefined elements to avoid a flash of unstyled content, but fail open so the content stays reachable if the script never loads. Hide with `visibility: hidden`, which also removes the content from the tab order and the accessibility tree while it cannot be seen; `opacity: 0` alone leaves focusable descendants in the tab order while invisible (WCAG 2.4.7 Focus Visible). Animate `visibility` back after a delay, so the element appears after a timeout even if it is never upgraded. `visibility` switches rather than fades; to fade the element in, optionally add `opacity: 0` and animate it alongside:

```css
my-element:not(:defined) {
  visibility: hidden;
  opacity: 0; /* Optional: fades the element in. */
  /* Reveal after 2s anyway, so a failed or slow script never hides content for good. */
  animation: defined-fallback 0.2s 2s forwards;
}
@keyframes defined-fallback { to { visibility: visible; opacity: 1; } }
```

Scope these guards to the elements that need them, or to a specific subtree with `:has(:not(:defined))`, not to the whole `body`. One slow, non-critical widget such as a share button should not delay paint for the entire page.

## Attribute and property reflection

Keep the HTML attribute and the JavaScript property in sync so the element works from both markup and script. Attribute values are always strings, so coerce them.

```javascript
class MyToggle extends HTMLElement {
  static observedAttributes = ['label', 'count', 'disabled'];

  get label() { return this.getAttribute('label') ?? ''; }
  set label(v) {
    v ? this.setAttribute('label', v) : this.removeAttribute('label');
  }

  // Numeric: coerce on read, serialize on write.
  get count() { return Number(this.getAttribute('count')) || 0; }
  set count(v) { this.setAttribute('count', String(v)); }

  // Boolean: present means true, absent means false. Never set it to "false".
  get disabled() { return this.hasAttribute('disabled'); }
  set disabled(on) { this.toggleAttribute('disabled', !!on); }

  attributeChangedCallback(name, oldVal, newVal) {
    if (oldVal !== newVal) this.render();
  }
}
```

### Where the value lives

The example keeps the DOM as the source of truth: each getter reads `getAttribute`. That is the right default for a handful of simple, string-like attributes, because the state lives in one place and cannot desync.

For richer components, keep the source of truth in a JavaScript field and reflect outward to an attribute only when something else must see it, such as CSS targeting or a consumer reading it. Reading a field is far cheaper than parsing and coercing an attribute on every access, and non-string values never round-trip through serialization. Libraries such as Lit hold state in JavaScript for this reason and reflect only what the outside world must observe, not every property.

Pitfalls:

- List in `observedAttributes` only the attributes whose change must re-render or trigger a side effect. Observing everything adds a callback to every mutation for no benefit.
- A setter that writes an attribute re-enters `attributeChangedCallback`. Guard against loops with an `oldVal !== newVal` check, as above.
- Derive the state exposed to assistive technologies (ARIA state through `ElementInternals`, or attributes on the native control inside) from the same source of truth as the visible state, and update it on every path that changes it: attributes read on upgrade, `attributeChangedCallback`, property setters and user interaction. Otherwise state set from markup or by a consumer's script changes what is shown but not what is announced (WCAG 4.1.2 Name, Role, Value).
- When re-rendering, update only the nodes that change instead of rebuilding the shadow tree with `innerHTML`. Replacing a focused element moves focus to `<body>`, and keyboard and screen reader users lose their place (WCAG 2.4.3 Focus Order).
- For internal state that exists only to drive styling (loading, active, expanded), prefer custom states (below) over reflecting a synthetic attribute. Reflect to an attribute only when consumers must be able to set the state from markup.

## Custom states

Custom states are boolean flags an element exposes about itself for CSS, set through `ElementInternals` and matched with the `:state()` pseudo-class. Use them for internal runtime UI state such as `busy`, `expanded` or `invalid` instead of a synthetic attribute: they cannot collide with a consumer's attributes, never appear in the DOM, and are read-only from outside (a consumer can style `:state()` but cannot forge it).

```javascript
class AsyncButton extends HTMLElement {
  #internals;
  #action = async () => {};

  constructor() {
    super();
    this.#internals = this.attachInternals();
  }

  set action(fn) { this.#action = fn; } // the host supplies the work to run

  async run() {
    if (this.#internals.states.has('busy')) return; // guard against re-entry
    this.#internals.states.add('busy');
    this.#internals.ariaBusy = 'true'; // assistive technologies don't see custom states
    this.#internals.states.delete('success');
    this.#internals.states.delete('error');
    try {
      await this.#action();
      this.#internals.states.add('success');
    } catch {
      this.#internals.states.add('error');
    } finally {
      this.#internals.states.delete('busy');
      this.#internals.ariaBusy = 'false';
    }
  }
}
```

`CustomStateSet` is a set, so independent states compose (`busy` plus `error`) without a combined `data-status` enum.

Custom states reach only CSS. When a state tells the user something (busy, success, error, invalid, expanded), also expose it to assistive technologies as ARIA state through `ElementInternals` (as with `ariaBusy` above) or on the native control inside the component, show it in text rather than color alone, and announce the outcome of an action, such as a save succeeding or failing, as a status message (WCAG 4.1.2 Name, Role, Value; 1.4.1 Use of Color; 4.1.3 Status Messages).

Custom state is runtime-only. It is not serialized to the DOM, so it does not survive a reload, re-creation of the element, or server rendering. State that must be set declaratively in markup or persist across loads belongs in an attribute (see "Where the value lives"); restore it in `connectedCallback` from your source of truth. As a rule: custom state for what the component derives and owns at runtime and only needs to style; an attribute for what must be set from markup or serialized.

For styling these states, inside the component and from a consumer's stylesheet, see the `styling-web-components` guide.

## Naming conventions

- For private state, use native `#` fields (`#count`) for hard encapsulation, and a `_` prefix only when subclasses must reach it. `#` fields are not inherited: a subclass cannot see a base class's private fields.
- Symbol-keyed properties are a middle ground: hidden from ordinary enumeration, but reachable by any code holding the symbol (export it, or expose it as a `static` field on the class). Each symbol is unique, so two symbols with the same description never collide. Use them when a subclass or sibling needs controlled access that `#` fields cannot provide.
- Do not shadow global attributes (`style`, `class`, `id`, `slot`, `part`, `title`, `lang`, `dir` and others) with your own properties, such as a `role` or `ariaLabel` class field. Doing so breaks their built-in behavior: a consumer setting the property no longer changes the attribute or what assistive technologies receive.
- `disabled` is global only on form controls. On other elements you must implement its effect yourself, including ignoring activation and exposing the state to assistive technologies (for example `this.#internals.ariaDisabled = 'true'`).
- If the component's styles set `display` on `:host`, also add `:host([hidden]) { display: none; }`. Otherwise the `hidden` attribute stops hiding the element, and its content stays visible, focusable and in the accessibility tree.

For new API surface, follow the platform's conventions: lowercase kebab-case tag names with at least one hyphen (`my-toggle`), `lowerCamelCase` properties and methods, and lowercase attribute names kept in sync with their corresponding properties.
