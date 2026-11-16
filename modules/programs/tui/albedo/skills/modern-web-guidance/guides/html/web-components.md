# Web Components Orientation

Web Components are Custom Elements, Shadow DOM and HTML Templates: the platform primitives for reusable, framework-agnostic components whose markup and styles are encapsulated from the document. Use them for design systems, embeddable widgets and self-contained UI.

The rules here are cross-cutting. For the task at hand, retrieve the specific guide from the matrix at the end; each one restates the context it needs and covers its own APIs and pitfalls.

## Decide whether you need a custom element

Use a custom element only when you need encapsulated behavior, a lifecycle, or a reusable JavaScript-backed API on a tag. Do not build one when:

- A plain HTML element with CSS would do. A styled `<button>` or `<details>` is more accessible and cheaper than a re-implementation.
- The thing is purely presentational with no behavior. A class on a native element performs better and can be scoped with `@layer` or `@scope`.
- You only need style scoping on the server with no interactivity. A scoped stylesheet or Declarative Shadow DOM without an upgrade may be enough.

The most common misuse is rebuilding native semantics, such as a `<my-button>` that re-creates focus, activation and ARIA: the platform's accessibility comes for free only if you reuse the native element. When a `<my-button>`-style wrapper is warranted, usually for shared styling hooks, extra markup or behavior a native element cannot express, wrap the real `<button>` rather than re-implementing it. The `styling-web-components` guide covers forwarding styles to an internal native element.

The test is whether you need encapsulated state, a scriptable API, or behavior the native element cannot express, not merely a different look. A like/favorite toggle qualifies: it carries latched domain state, exposes that state as a styling hook for the surrounding page, and dispatches its own `change` event, none of which a styled `<button>` provides. A button that only changes color when pressed does not qualify; use `<button>` and CSS. When you do build one, model its state with a custom state or an attribute as appropriate (see the `custom-elements` guide).

## Match the tool to the codebase

Whether something should be a custom element depends on what the project already uses. Agents tend to over-abstract and create new elements too eagerly. When in doubt, the lighter option (native element, CSS, a server template) is usually right, and you can promote it to a custom element later if reuse or behavior demands it. Heuristics, in rough priority order:

- The codebase already has a component model (React, Vue, Svelte, …). Default to that framework's components for in-app UI. Use a custom element only when the thing must escape or outlive the framework: a design-system primitive shared across apps or frameworks, a widget dropped into markup the framework does not control, or output that must work as plain HTML (email, CMS, SSR fragments). Do not stand up a parallel component system for ordinary in-app views.
- No tooling, mostly static markup. Prefer plain HTML and CSS, or a server template or partial. A custom element earns its keep only where you need behavior, a lifecycle or a JavaScript-backed API on the tag, not merely to share markup, which a server include or `<template>` does without shipping JavaScript.
- Static site generator with islands of interactivity. Render the markup statically and reserve the custom element for the interactive part. For a lot of markup with a little interactivity, keep the markup in Light DOM (or Declarative Shadow DOM) and let a small custom element progressively enhance it, rather than re-rendering everything from JavaScript.
- A built-in element could be pushed further. Taking a native element as far as it goes (CSS, a few listeners, the occasional pseudo-element) is usually better than a custom element, because you keep the platform's accessibility and behavior. Switch to a custom element when the workarounds stop being maintainable: when you would be fighting the element's built-in behavior, or the authoring experience becomes worse than a clean component API. Needing a little JavaScript on a built-in element is not by itself a reason to replace it.

## Cross-cutting rules

These apply to every web component guide:

- The tag name must be kebab-case with at least one hyphen (`my-element`). The hyphen is what distinguishes custom elements from current and future built-in elements.
- Call `super()` first in the constructor. Calling it after any statement that reads or writes `this` throws.
- Use semantic elements (`<button>`, `<nav>`, `<ul>`) inside shadow templates. Most accessibility failures in shadow trees come from non-semantic markup, and a slot does not change the role of what it projects.
- ARIA `id` references (`aria-labelledby`, `aria-describedby`, `aria-controls`) cannot cross a shadow boundary; the referencing element and the `id` it points to must be in the same tree. Reflected element-reference properties such as `ariaLabelledByElements` can reach outward across it; see the `accessible-web-components` guide.
- Attach shadow roots with `attachShadow({ mode: 'open' })`, or `shadowrootmode="open"` for Declarative Shadow DOM. `mode: 'closed'` hides `element.shadowRoot` from page scripts, test harnesses, and automated accessibility checkers that walk shadow trees.
- Avoid customized built-in elements (`extends HTMLButtonElement` with `is="…"`); Safari has permanently declined to ship them.

## Guide matrix

| If you need to… | Guide |
| :--- | :--- |
| Define a new semantic tag with behavior and lifecycle | `custom-elements` |
| Scope styles and markup to a component, and project consumer content into it | `shadow-dom` |
| Render a component's shadow tree on the server (SSR) without a flash of unstyled content | `prerendering-custom-elements` |
| Style across the shadow boundary (theming, `::part`, custom properties) | `styling-web-components` |
| Submit a custom control's value to a surrounding `<form>` | `form-associated-custom-elements` |
| Make a custom element accessible (roles, focus, ARIA across shadow roots) | `accessible-web-components` |
