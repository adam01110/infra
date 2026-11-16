# Size Aware Styling

## Overview

Size-aware styling lets a component change its layout or appearance based on the space available to it rather than the size of the whole screen. This suits components such as cards or navigation bars that may sit in different parts of a layout, like a narrow sidebar or a wide main area.

Prefer container queries for this: they make components modular, so you do not need to know where a component will live or write media queries for every possible layout.

## Implementation

### 1. Define the container

Container queries only work after you declare which element the browser measures.

```css
.card-container {
  /* inline-size: width-based queries. 'size' queries both width and height but requires explicit sizing. */
  container-type: inline-size;
}
```

### 2. Apply styles based on container size

Use the `@container` rule to apply styles once the container reaches a size.

```css
/* Default: stacked layout for small containers */
.card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* Side-by-side layout when the container is wider than 400px */
@container (min-width: 400px) {
  .card {
    flex-direction: row;
    align-items: center;
  }

  .card-image {
    width: 150px;
    height: 150px;
  }
}
```

### 3. Conditionally show content

Container queries can also show extra details when there is more room.

```css
.card-details {
  display: none;
}

@container (min-width: 600px) {
  .card-details {
    display: block;
  }
}
```

### Fallback strategies

Baseline status for Container queries (size): Widely available. It's been Baseline since 2023-02-14.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 110 (Feb 2023), and Safari 16 (Sep 2022).

For browsers without container queries, use a safe default layout (such as the stacked vertical layout) and progressively enhance it with media queries where the screen size allows.

```css
/* Default safe stacked layout */
.card {
  display: flex;
  flex-direction: column;
}

/* Media query fallback for older browsers */
@media (min-width: 600px) {
  .card {
    flex-direction: row;
  }
}

/* Where container queries are supported, undo the media query fallback and use them instead */
@supports (container-type: inline-size) {
  @media (min-width: 600px) {
    .card {
      flex-direction: column;
    }
  }

  @container (min-width: 400px) {
    .card {
      flex-direction: row;
    }
  }
}
```

Users on older browsers still get a usable layout, even if it does not adapt to every container width.
