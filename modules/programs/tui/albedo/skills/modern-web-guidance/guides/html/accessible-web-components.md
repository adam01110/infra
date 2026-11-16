# Accessible Web Components

A shadow boundary changes how semantics and ARIA work. The two common failures are missing semantics inside the shadow tree and ARIA references that silently break because they cannot cross shadow roots.

Start from semantic markup: use real `<button>`, `<nav>` and `<ul>` elements inside the template so most semantics come for free, and use `ElementInternals` or ARIA only for the gaps.

## Default semantics via the ElementInternals ARIA mixin

Set a custom element's role and ARIA state in JavaScript through `ElementInternals` rather than as ARIA attributes on the host. The semantics then become defaults the component owns, which keeps ARIA attributes out of the DOM and stops consumers from clobbering them by accident, while a consumer can still override them deliberately with attributes in the Light DOM. The accessibility tree sees the correct role and state either way.

```javascript
class ToggleSwitch extends HTMLElement {
  #internals;
  constructor() {
    super();
    this.#internals = this.attachInternals();
    this.#internals.role = 'switch';       // default role, no host attribute
    this.#internals.ariaChecked = 'false'; // exposed to the accessibility tree
    this.addEventListener('click', () => this.toggle());
    this.addEventListener('keydown', (e) => {
      if (e.key === ' ') { e.preventDefault(); this.toggle(); }
    });
  }
  connectedCallback() {
    // Setting tabIndex in the constructor throws on document.createElement.
    if (!this.hasAttribute('tabindex')) this.tabIndex = 0;
  }
  toggle() {
    const on = this.#internals.ariaChecked !== 'true';
    this.#internals.ariaChecked = String(on);
  }
}
customElements.define('toggle-switch', ToggleSwitch);
```

## Focus management and `delegatesFocus`

- When the host element itself is the interactive control and carries the role and state through `ElementInternals` (like `ToggleSwitch` above), put the host in the tab order in `connectedCallback` with `if (!this.hasAttribute('tabindex')) this.tabIndex = 0`. Doing this in the constructor throws on `document.createElement`. Focus then lands on the host, and assistive technology announces its role and state. Leave `tabindex` off the host of static, non-interactive components such as a callout or card.
- Attach the shadow root with `delegatesFocus: true` when the component wraps an internal focusable control that owns the semantics, or on a form-associated custom element (`static formAssociated = true`). Focusing the host, or clicking an associated `<label>` for a form-associated element, then forwards focus to the first focusable child, and `:focus` matches the host. Do not combine `delegatesFocus: true` with a role and state on the host: focus would land on the inner element and skip the host's state.
- For roving focus, or to move focus into a newly revealed region, give the target `tabindex="-1"` and call `.focus()`. Make programmatically focusable targets explicit rather than relying on tab order.

## ARIA relationships across shadow roots

- An `id` referenced by `aria-labelledby`, `aria-describedby`, `aria-controls` and similar attributes resolves only within the referencing element's own tree. An `id`-based attribute in the Light DOM cannot point at an `id` inside a shadow tree, or the reverse; the browser silently ignores the reference.
- To cross the boundary, use the reflected ARIA element properties (`ariaLabelledByElements`, `ariaDescribedByElements` and the like), which take JavaScript element references instead of ids. They resolve outward: an element inside a shadow tree can point at a target in the Light DOM or in any ancestor tree, including slotted content. This lets Light DOM content label a control inside the shadow tree, which `id` references cannot express.
- They do not resolve inward: an element cannot reference into a descendant shadow tree, so a host cannot be labelled by its own shadow content. The emerging Reference Target mechanism is the standards direction for that case, but it is not yet broadly available.
- When a relationship cannot be expressed either way, keep it within one tree (render the label in the same tree) or use `aria-label` text instead of an `id` reference.

## Fallback strategies

Baseline status for ARIA attribute reflection: Widely available. It's been Baseline since 2023-10-24.
Supported by: Chrome 103 (Jun 2022), Edge 103 (Jun 2022), Firefox 119 (Oct 2023), and Safari 16.4 (Mar 2023).

Where the `ElementInternals` ARIA mixin is unavailable, set the role and ARIA state as attributes on the host instead (`this.setAttribute('role', 'switch')`). This works everywhere, at the cost of putting attributes in the DOM that a consumer could override.

Baseline status for the api.Element.ariaLabelledByElements capability: Newly available. It's been Baseline since 2025-04-04.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 136 (Mar 2025), and Safari 16.4 (Mar 2023).

Where the reflected ARIA element properties are unavailable, use an `id`-based `aria-*` attribute for same-tree relationships. A cross-boundary label has no `id`-based equivalent, so fall back to `aria-label` text.
