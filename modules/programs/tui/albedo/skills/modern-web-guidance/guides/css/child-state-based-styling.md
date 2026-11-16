# Child State Based Styling

The `:has()` pseudo-class lets a selector style a container based on the presence or state of its descendants, not only the other way around.

Combined with state pseudo-classes such as `:checked`, `:focus`, `:valid`, `:invalid` or `:not()`, it lets you build interactive components entirely in CSS, without JavaScript toggling modifier classes such as `.is-active` or `.has-error` on parent elements. Examples: a local theme toggle reacting to a checkbox (`:checked`), a form group highlighting an error (`:invalid`), or a card elevating when a child link is focused (`:focus-within`).

## Implementing state-based container styling

Put `:has()` on the container element and use it to detect the state (such as `:checked`, `:focus`, `:invalid`) of its interactive child.

1. Define the default styling: set CSS variables on the container for its base state.
2. Apply state-based overrides: target the container with `:has([child-selector]:[state])` and redefine the variables for the active or alternate state.

Example: a component that changes theme based on a child toggle.

```css
/* 1. Default state on the container; custom properties keep state switching clean */
.theme-card {
  --card-bg: #ffffff;
  --card-text: #333333;
  --card-border: #cccccc;

  background-color: var(--card-bg);
  color: var(--card-text);
  border: 1px solid var(--card-border);

  transition: background-color 0.3s, color 0.3s;
}

/* 2. Override when the child is in the given state */
.theme-card:has(.theme-toggle:checked) {
  --card-bg: #222222;
  --card-text: #f0f0f0;
  --card-border: #555555;
}

/* Combine :has() and :not() for negative states: a card whose toggle is NOT checked */
.theme-card:not(:has(.theme-toggle:checked)) {
  /* Optional explicit styles for the unchecked state */
}
```

```html
<!-- The container that receives the styling -->
<div class="theme-card">
  <!-- The child whose state controls the container -->
  <label>
    <input type="checkbox" class="theme-toggle">
    Enable Dark Mode
  </label>

  <h2>Card Title</h2>
  <p>The style of this entire card is controlled by the checkbox above.</p>
</div>
```

Performance: scope `:has()` to the most specific container possible (such as `.theme-card`). Avoid anchoring it to high-level elements like `body:has(...)` when the styling change is local, because broad `:has()` queries can trigger more layout recalculation.

## Fallback strategies

Baseline status for :has(): Widely available. It's been Baseline since 2023-12-19.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 121 (Dec 2023), and Safari 15.4 (Mar 2022).

If the state-based styling is critical to the user experience or page layout, provide a fallback for browsers without `:has()`. Purely decorative effects can use `:has()` as a progressive enhancement with no fallback.

For a critical feature, define a traditional class-based fallback inside `@supports not selector(:has(*))`. If the state change comes from user interaction, also add a small inline script, gated by `CSS.supports()`, that toggles that class on the equivalent JavaScript event (such as `change`, `focus` or `blur`).

```css
/* Fallback for browsers without :has() */
@supports not selector(:has(*)) {
  /* Modifier class with the same overrides */
  .theme-card.is-active {
    --card-bg: #222222;
    --card-text: #f0f0f0;
    --card-border: #555555;
  }
}
```

```javascript
// Only runs where :has() is unsupported
if (!CSS.supports('selector(:has(*))')) {
  const toggle = document.querySelector('.theme-toggle');
  const card = document.querySelector('.theme-card');

  if (toggle && card) {
    toggle.addEventListener('change', (e) => {
      card.classList.toggle('is-active', e.target.checked);
    });
  }
}
```
