# Semantic Component Adaptation

Use style queries (`@container style()`) to trigger contextual variations without hardcoding what produces or reacts to each context. This reduces coupling in a design system and improves extensibility and component encapsulation.

For example, a `section.featured { --surface: featured }` rule can mark a context, and a landing page might also default to it with `main { --surface: featured }`. Components then opt in to reacting to `--surface: featured`: a card reveals a promotional badge, a button defaults to its filled variant, and so on.

Style queries keep both sides decoupled. The featured surfaces never name the elements that adapt to them, and the components never inspect what produced the context, so either side can grow (new components, new featured surfaces) without touching the other. Descendant selectors such as `.featured .button` do the opposite: the selector encodes both sides of the relationship and must change whenever either side does.

## Scope of this guide

This guide covers behavioral changes: a component deciding what to render, how to arrange itself, or which variant to present in response to its context, such as hiding or showing a badge, switching layout direction, or swapping a button variant.

For token-level changes (density modes, themes, or other higher-order tokens that shift values like padding and color uniformly across many components), see the `design-token-reactivity` guide.

## Choosing the right tool

Use a style query when both sides of a contextual relationship may change independently: new elements may start producing the context, or new components may start reacting to it. The indirection then pays for itself in extensibility and encapsulation, and style queries cross shadow DOM boundaries that descendant selectors cannot. When that flexibility is not needed, prefer the simpler tool:

- Descendant selectors (`.toolbar .button`): a fixed, one-off relationship that is not reusable or extensible. Do not add indirection you will not use.
- Size queries (`@container (min-width: …)`): layout and density changes driven by available space, not semantic state.
- Style queries (`@container style(…)`): semantic state, meaning what a component should render, arrange or present in a given context.

## Implementation rules

1. Define a semantic context flag as a CSS custom property on a container.
2. Style queries need no `container-type`: they query inherited custom properties on the nearest ancestor without an explicit containment context. Set one only if the element also serves size queries.
3. Apply the conditional styles to descendants with `@container style(--property: value)`. A style query cannot match the element the property is set on, only its descendants.
4. Prefer style queries over descendant selectors when the relationship must stay extensible or cross component or shadow DOM boundaries, and keep descendant selectors for fixed, one-off relationships where the indirection buys nothing.

## Example

```css
/* 1. Set the context on a layout container */
.featured {
  --surface: featured;
}

/* 2. Components react to the inherited flag */
.button {
  /* Default: outlined informational style */
  background: transparent;
  border: 1px solid currentColor;
}

.badge {
  /* Hidden except in featured surfaces */
  display: none;
}

@container style(--surface: featured) {
  .button {
    /* Filled promotional style */
    background: var(--brand-accent);
    color: white;
    border: none;
  }

  .badge {
    display: block;
  }
}
```

## Fallback strategies

Baseline status for Container style queries: Newly available. It's been Baseline since 2026-05-19.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 151 (May 2026), and Safari 18 (Sep 2024).

Until container style queries are widely available, add them as a progressive enhancement: ship a selector-based default that works everywhere and let the style query override it where supported. Wrap the context selector in `:where()` so the style query rule (same specificity, later in source order) wins.

```css
/* Defaults that work everywhere */
.button {
  background: transparent;
  border: 1px solid currentColor;
}

.badge {
  display: none;
}

/* Selector-based contextual styles with broad browser support */
:where(.featured) .button {
  background: var(--brand-accent);
  color: white;
  border: none;
}

:where(.featured) .badge {
  display: block;
}

/* Style queries override where supported */
@container style(--surface: featured) {
  .button {
    background: var(--brand-accent);
    color: white;
    border: none;
  }

  .badge {
    display: block;
  }
}
```

The selector fallback ties the contextual styling to a class name, which couples the component to its DOM placement. Remove the `:where()` rules once style queries are widely supported.
