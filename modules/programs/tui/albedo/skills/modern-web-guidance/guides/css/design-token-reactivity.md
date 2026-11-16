# Design Token Reactivity

## Overview

Components often need contextual design changes. With selectors alone, ordinary design tokens can live in custom properties, but higher-order tokens can only be encoded as a selector pattern (a class name or attribute convention) or as props or context in a JavaScript framework.

Container style queries style elements based on the computed custom property value of an ancestor. Higher-order design tokens can then be meaningful values in the stylesheet instead of depending on markup or JavaScript for presentation.

## How to implement

1. Set the higher-order design token as a custom property on a container. It does not need to be a registered custom property.
2. Query the value of that property with `@container style()`.
3. Apply the styles to descendants of the container.

Points to keep in mind:

- The container queried by a style query needs no `container-type` or `container-name`, though a `container-name` allows more specific querying.
- A container style query cannot style the container itself.

Basic example:

```html
<div class="features">
  <div class="card"></div>
  <div class="card"></div>
</div>
<div class="bugs">
  <div class="card"></div>
  <div class="card"></div>
  <div class="card"></div>
  <div class="card"></div>
</div>
```

```css
.features {
  --density: spacious;
}

.bugs {
  --density: compact;
}

@container style(--density: compact) {
  .card {
    padding: 8px;
  }
}

@container style(--density: spacious) {
  .card {
    padding: 24px;
  }
}
```

## Fallback strategies

Baseline status for Container style queries: Newly available. It's been Baseline since 2026-05-19.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 151 (May 2026), and Safari 18 (Sep 2024).

Until container style queries are widely available (or within your support target), avoid them for core features that must work in every browser: a fallback is hard to build without either giving up their benefits or adding limitations of its own. Features that are not core can use them without a fallback; for example, if a UI density user preference does not need to be available in every experience, implement it with style queries alone.

### Using selectors instead

For core features, use selectors. This example encodes the density token in the markup as a `data-density` attribute instead of a custom property:

```html
<div class="features" data-density="spacious">
  <div class="card"></div>
  <div class="card"></div>
</div>
<div class="bugs" data-density="compact">
  <div class="card"></div>
  <div class="card"></div>
  <div class="card"></div>
  <div class="card"></div>
</div>
```

```css
/* :where() avoids increasing specificity */
:where([data-density="compact"]) .card {
  padding: var(--card-padding-compact);
}

:where([data-density="spacious"]) .card {
  padding: var(--card-padding-spacious);
}
```

The main limitation of this approach is that it does not support nested elements with `data-density`. Both selectors have the same specificity, so order of appearance decides: `[data-density="spacious"]` always wins over `[data-density="compact"]`.

### Using style queries as a progressive enhancement

This is not recommended for core features. If you still want style queries as a progressive enhancement for one, avoid duplication by defining custom properties for the values and placing the style queries after the fallback. Select the containers with `:where()` in the fallback so its specificity does not increase.

```css
.card {
  --card-padding-compact: 8px;
  --card-padding-spacious: 24px;
}

:where([data-density="compact"]) .card {
  padding: var(--card-padding-compact);
}

:where([data-density="spacious"]) .card {
  padding: var(--card-padding-spacious);
}

/* Progressive enhancement: same specificity, so order of appearance decides */

@container style(--density: compact) {
  .card {
    padding: var(--card-padding-compact);
  }
}

@container style(--density: spacious) {
  .card {
    padding: var(--card-padding-spacious);
  }
}
```

### Feature detection in CSS

To show UI only where container style queries work, detect them with a style query:

```css
:root {
  --style-queries-supported: check;
}

.density-toggle {
  display: none;
}

@container style(--style-queries-supported) {
  .density-toggle {
    display: revert;
  }
}
```

### Feature detection in JavaScript

The `CSSContainerRule` interface existed before container style queries were added, so its presence is not a reliable test. Instead, check the computed value of a property that a style query sets. A custom property works well because it has no visual effect:

```css
:root {
  --style-queries-supported: check;
}

@container style(--style-queries-supported: check) {
  body {
    --style-queries-supported: yes;
  }
}
```

```js
if (getComputedStyle(document.body).getPropertyValue("--style-queries-supported") === "yes") {
  // Use container style queries
} else {
  // Use fallback strategy
}
```
