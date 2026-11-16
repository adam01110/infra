# Styling Web Components

Shadow DOM is a style boundary: page rules do not reach in and component rules do not leak out, except for inherited properties, which include custom properties. Cross the boundary deliberately through the channels below.

## `:host`, `:host()` and `:host-context()`

```css
/* The host element, styled from inside its shadow tree. */
:host { display: block; }

/* Only when the host matches a selector, such as a reflected state attribute. */
:host([disabled]) { opacity: 0.5; pointer-events: none; }

/* Based on a Light DOM ancestor. Avoid: Chromium-only. */
:host-context([theme="dark"]) { background: #111; color: #eee; }
```

Avoid `:host-context()`. It reaches outside the boundary to test ancestors, but Firefox and Safari have declined to ship it and the CSSWG is leaning toward not developing it further, so treat it as a Chromium-only dead end. Theme through an inherited custom property instead: the consumer sets the property on an ancestor and the component reads it across the boundary, which works everywhere and keeps both sides decoupled.

## Inherited and custom properties cross the boundary

Inherited properties (`color`, `font-family`, `line-height`) and CSS custom properties pass through the shadow boundary. This makes custom properties the primary theming API; expose them with sensible fallbacks:

```css
:host {
  /* Consumers override --card-bg from outside; the fallback keeps it usable. */
  background: var(--card-bg, white);
  color: var(--card-fg, black);
}
```

A custom property defined on `:host` can be overridden only by rules that target the host element itself. To let the public property inherit and be overridable from anywhere up the tree, leave it unset on `:host` and rely on the fallback in each `var()`.

To declare the fallback once instead of at every `var()`, define a private property on `:host` that reads the public one, and use the private property internally:

```css
:host {
  --_card-bg: var(--card-bg, white);
  --_card-fg: var(--card-fg, black);
}
.card { background: var(--_card-bg); color: var(--_card-fg); }
```

Consumers still override `--card-bg` from outside; the leading underscore marks the alias as internal, and the fallback lives in one place.

## `::slotted()`: styling projected Light DOM

`::slotted(selector)` targets only the top-level nodes assigned to a slot, not their descendants, and it loses to any Light DOM rule because the consumer owns their own content. Use it for light touch-ups, not control. `::slotted(...) !important` can beat consumer rules, but it overrides styling the consumer is entitled to own, so reserve it for structural fixes rather than aesthetic overrides.

```css
/* Matches a slotted <p>, not a <p> nested inside a slotted <div>. */
::slotted(p) { margin: 0; }
```

## `::part()` and `exportparts`

Mark an internal element with `part="name"` to let consumers style it with any property without learning your internal structure.

```html
<!-- inside the shadow template -->
<button part="submit">Submit</button>
```

```css
/* consumer stylesheet */
my-card::part(submit) { background: navy; color: white; }
```

Expose a few high-level parts (button, input, label), not every `<div>`; a broad part surface becomes a brittle API. To re-expose a nested component's parts through your own component, forward them with `exportparts`:

```html
<inner-widget exportparts="submit: card-submit"></inner-widget>
```

Choose the channel deliberately: custom properties for a constrained, design-system-safe set of values; parts for unrestricted styling of a specific element.

## Forwarding styles to a wrapped native element

When a custom element wraps a native control (`<my-button>` around a real `<button>`), three things commonly go wrong:

- Form controls do not inherit typography. `color` and custom properties cross the boundary, but `<button>`, `<input>` and `<select>` take `font` and related properties from the UA stylesheet, which does not inherit. The wrapped control renders in the platform font, not the page font, until you set `font: inherit` (and usually `color: inherit`) on it inside the shadow tree. This is the most common miss.
- `:host` styles do not reach the inner element. `background`, `border` or `padding` on `:host` style the host box, not the control inside, and a `:host` rule does not cascade into the wrapped element. Forward deliberately: expose the control as a `::part` for open-ended styling, or pipe a fixed set of values through custom properties.
- `display: contents` plus `all: inherit` is a real tradeoff. Collapsing the host with `display: contents` and resetting the inner control with `all: inherit` is currently the only generic way to pass arbitrary styles through to a wrapped native element without consumers learning per-component parts or custom properties, and removing the host's own box is usually the point of the pattern (composition compensating for missing built-in inheritance). `all: inherit` wipes UA defaults, so scope it to specific properties or use `revert` where you want defaults back. The concrete blocker is that `getBoundingClientRect()` and `getClientRects()` return zero for `display: contents` elements, which breaks anchor positioning against the host. Use `::part` or custom properties when those tradeoffs do not fit.

## `:state()`: styling the component's own states

A custom element can expose internal boolean states through `ElementInternals` with `this.#internals.states.add('busy')` and `.delete('busy')` (the `custom-elements` guide covers lifecycle usage). These states are a styling channel across the boundary, like `::part` and custom properties but for state rather than structure or values. Match them inside the shadow tree with `:host(:state(name))`, and from a consumer's stylesheet with `tag-name:state(name)`:

```css
/* Inside the component's shadow tree. */
:host(:state(busy)) button { opacity: 0.6; pointer-events: none; }

/* From the consumer's stylesheet: a read-only public hook. */
favorite-button:state(favorited) { filter: drop-shadow(0 0 4px crimson); }
```

Unlike a reflected attribute, a custom state is read-only from outside: consumers can style it but cannot set or forge it, so the component stays its only writer. Prefer it over a `data-*` attribute whenever the component owns the state and it only needs to be styled.

## `@layer` and container queries inside components

- Cascade layers (`@layer`) work inside a shadow root and are scoped to it; a layer name in the shadow tree is independent of a same-named layer in the page. Use them to order your own component styles (for example `@layer base, theme;`) so consumer overrides through custom properties and `::part` still win predictably.
- Container queries suit responsive components, which should respond to the space they are given rather than the viewport. Make the host or a wrapper a container and query it, so the same component adapts in a sidebar or a full-width region. Give `:host` a layout box such as `display: block` first: custom elements default to `display: inline`, and size containment does not apply to `inline` or `contents` elements.

```css
:host {
  display: block; /* size containment does not apply to the default display: inline */
  container-type: inline-size;
}

@container (min-width: 30rem) {
  .card { grid-template-columns: 1fr 2fr; }
}
```

## Fallback strategies

Baseline status for Shadow parts: Widely available. It's been Baseline since 2020-07-28.
Supported by: Chrome 73 (Mar 2019), Edge 79 (Jan 2020), Firefox 72 (Jan 2020), Safari 13.1 (Mar 2020), and Safari iOS 13.4 (Mar 2020).

Baseline status for Cascade layers: Widely available. It's been Baseline since 2022-03-14.
Supported by: Chrome 99 (Mar 2022), Edge 99 (Mar 2022), Firefox 97 (Feb 2022), and Safari 15.4 (Mar 2022).

Baseline status for Container queries (size): Widely available. It's been Baseline since 2023-02-14.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 110 (Feb 2023), and Safari 16 (Sep 2022).

Browser support for :host-context(): Limited availability.
Supported by: Chrome 54 (Oct 2016) and Edge 79 (Jan 2020).
Unsupported in: Firefox and Safari.

`::part`, cascade layers and container queries are broadly available. Theme primarily through inherited custom properties, which work even where these do not, and do not rely on `:host-context()`, which is effectively Chromium-only.
