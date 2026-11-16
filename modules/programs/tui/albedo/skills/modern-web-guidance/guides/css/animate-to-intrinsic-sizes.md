# Animate to Intrinsic Sizes

The `interpolate-size` property and `calc-size()` function let the browser interpolate natively between fixed lengths and intrinsic sizing keywords such as `block-size: auto` or `inline-size: max-content`. They replace JavaScript measurement and fragile `max-height` hacks.

## Implementation steps

1. Opt in to keyword interpolation: apply `interpolate-size: allow-keywords` to an ancestor (typically `:root`) to enable transitions for properties that use intrinsic keywords.
2. Define the transition: set a `transition` for the sizing property (such as `block-size` or `inline-size`) on the target element.
3. Use intrinsic keywords: change the sizing property to a supported intrinsic keyword (`auto`, `min-content`, `max-content`, `fit-content`, or `content` for `flex-basis`) on an interaction such as `:hover` or a state class.
4. Optionally calculate: use `calc-size()` for math on an intrinsic size (such as `auto + 2rem`). `calc-size()` also accepts the `any` keyword for basis-agnostic calculations.

## Example: generic expansion pattern

This pattern fits any container, such as a "Show more" section or a navigation menu, that transitions between a restricted height and its natural size.

```css
:root {
  /* Required: transitions to intrinsic keywords are disabled by default for compatibility */
  interpolate-size: allow-keywords;
}

.expandable-container {
  /* 1. Fixed initial size (or 0), overflow hidden */
  block-size: 100px;
  overflow: hidden;

  /* 2. Transition the sizing property */
  transition: block-size 0.4s ease-out;
}

.expandable-container.is-expanded {
  /* 3. Animate to the natural height */
  block-size: auto;
}
```

## Example: calculated intrinsic inline size

```css
.badge {
  inline-size: 40px;
  overflow: hidden;
  white-space: nowrap;
  transition: inline-size 0.3s ease;
}

.badge:is(:hover, :focus-visible) {
  /* calc-size(basis, calculation): 'size' is the evaluated basis, here max-content */
  inline-size: calc-size(max-content, size + 20px);
}
```

## Example: transition from intrinsic to fixed

The reverse also works: start at the natural size and collapse to a specific length, for example in dismissible components.

```css
.collapsible-alert {
  /* 1. Start at the natural content height */
  block-size: auto;
  overflow: hidden;
  transition: block-size 0.5s ease-in-out, opacity 0.5s ease;
}

.collapsible-alert.is-dismissed {
  /* 2. Collapse to zero */
  block-size: 0;
  opacity: 0;
  pointer-events: none;
}

/* Disable the sizing animations for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  .expandable-container,
  .badge,
  .collapsible-alert {
    transition: none !important;
  }
}
```

Keep assistive technology in sync: remove elements collapsed to zero size from the accessibility tree (here with `hidden` once the collapse finishes), and update `aria-expanded` on the triggers that toggle expandable content.

```javascript
const alertElement = document.querySelector('.collapsible-alert');
function dismissAlert() {
  alertElement.classList.add('is-dismissed');
  // Wait only for the transitions the class starts, ignoring other animations
  // on the element; under reduced motion there are none
  const transitions = alertElement.getAnimations().filter((animation) => animation instanceof CSSTransition);
  Promise.allSettled(transitions.map((transition) => transition.finished)).then(() => {
    if (alertElement.classList.contains('is-dismissed')) {
      alertElement.hidden = true;
    }
  });
}

// Sync aria-expanded on the trigger
const triggerBtn = document.querySelector('.accordion-trigger');
triggerBtn?.addEventListener('click', () => {
  const isExpanded = triggerBtn.getAttribute('aria-expanded') === 'true';
  triggerBtn.setAttribute('aria-expanded', !isExpanded);
});
```

## Key constraints

- No keyword-to-keyword transitions: you cannot animate directly between two different keywords (such as `min-content` to `max-content`). One end must be a fixed length or percentage (such as `0` to `auto`).
- `calc-size()` syntax: one expression cannot mix different intrinsic keywords. The first argument (the basis) defines what `size` means.
- Opt-in requirement: transitions to intrinsic keywords are disabled by default (`numeric-only`) for backward compatibility, so apply `interpolate-size: allow-keywords` to the element or an ancestor. `calc-size()` works as a per-property override and enables interpolation wherever it is used.

## Fallback strategies

Browser support for interpolate-size: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

Browser support for calc-size(): Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

`interpolate-size` and `calc-size()` are progressive enhancements. Browsers without them jump instantly to the target size.

- Graceful degradation: a simple `block-size: auto` transition just toggles the size instantly, which works but is less polished.
- Keyword fallbacks: when using `calc-size()`, declare a plain keyword fallback first, because older browsers discard the whole `calc-size()` declaration.

```css
.card {
  block-size: auto; /* Fallback for older browsers */
  block-size: calc-size(auto, size);
  transition: block-size 0.3s ease;
}
```
