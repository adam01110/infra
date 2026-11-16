# Selector & @-rule Combinations

## The problem

Styles often depend on a combination of conditions of different types: selectors with media queries, media queries with container queries, and so on.

For example, to apply styles in light or dark mode regardless of how the color scheme was set, you combine `(prefers-color-scheme: dark)` with a selector that targets color scheme overrides, such as `:root:has(> head > meta[name="color-scheme"][content="dark"])` or `:root.dark`.

Writing this directly duplicates code:

```css
/* Light mode styles */
.card.featured {
  font-weight: 400;
}

#logo-dark {
  display: none;
}

@media (prefers-color-scheme: dark) {
  /* Dark mode styles */
  :root:not(.light) {
    .card.featured {
      font-weight: 300;
    }

    #logo-dark {
      display: inline;
    }

    #logo {
      display: none;
    }
  }
}

/* Dark mode styles, again */
:root.dark {
  .card.featured {
    font-weight: 300;
  }

  #logo-dark {
    display: inline;
  }

  #logo {
    display: none;
  }
}
```

## Better approach

Store the result of the combined condition in a custom property, then use container style queries to apply rules based on that property.

This only works when the custom property is set on an ancestor of every element the rules must match, because container queries query an ancestor.

### 1. Decouple the selection logic from the applied rules

```css
:root {
  --color-scheme: light;

  @media (prefers-color-scheme: dark) {
    --color-scheme: dark;
  }

  &:has(> head > meta[name="color-scheme"][content="dark"]) {
    --color-scheme: dark;
  }

  &:has(> head > meta[name="color-scheme"][content="light"]) {
    --color-scheme: light;
  }
}
```

### 2. Key the applied rules on the custom property

```css
@container not style(--color-scheme: dark) {
  .card.featured {
    font-weight: 400;
  }

  #logo-dark {
    display: none;
  }
}

@container style(--color-scheme: dark) {
  .card.featured {
    font-weight: 300;
  }

  #logo {
    display: none;
  }
}
```

### 3. Optional: utility classes for toggling visibility

Toggling visibility on whether the condition matches is a common case. Utility classes must win over arbitrary component styles (hence `!important`), and the `display` value they should show is unknown, so they cannot work as overrides. Gate them with `not style(...)` instead:

```css
@container not style(--color-scheme: dark) {
  .if-dark {
    display: none !important;
  }
}

@container not style(--color-scheme: light) {
  .if-light {
    display: none !important;
  }
}
```

## Fallbacks

Baseline status for Container style queries: Newly available. It's been Baseline since 2026-05-19.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 151 (May 2026), and Safari 18 (Sep 2024).

The fallback depends on how critical the branching is and what an acceptable fallback looks like.

1. Critical branching, where every state must work even without style query support: style queries cannot be used. Duplicate the rules for each state as in the first example. Utility classes still work if they are defined the same way.
2. Non-critical branching, where a default state is acceptable: define the base styles outside any `@container` rule and use style queries only as overrides. This keeps most of the approach's benefit; its main downside is the coupling between values that overrides introduce.

```css
#logo-dark {
  display: none;
}

@container style(--color-scheme: dark) {
  #logo-dark {
    display: inline; /* override */
  }

  #logo {
    display: none;
  }
}
```
