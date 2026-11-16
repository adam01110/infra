# Calculate With Intrinsic Sizes

`calc-size()` performs math on intrinsic sizing keywords such as `auto`, `min-content` and `fit-content`. Use it only when an intrinsic size needs a calculation or constraint. For a plain keyword animation (such as `0` to `auto`), use `interpolate-size: allow-keywords` instead.

## Implementation steps

1. Choose the intrinsic basis: the keyword (`auto`, `min-content`, and so on) the calculation starts from.
2. Define constraints: use math functions such as `clamp()`, `min()` or `max()` in the second argument to keep the intrinsic size within design limits.
3. Provide a fallback: declare a standard sizing keyword or length immediately before the `calc-size()` declaration, so the layout still works in unsupported browsers.
4. Prefer logical properties such as `inline-size` and `block-size`, so calculations respect the writing mode.
5. Optionally enhance progressively: wrap complex layout logic or animations in `@supports (inline-size: calc-size(auto, size + 0px))` so only capable browsers get them.

## Basic syntax

```css
/* calc-size(<calc-size-basis>, <calc-sum>) */
.element {
  /* Fallback for browsers without calc-size() */
  inline-size: min-content;

  /* Modify the intrinsic basis with a calculation */
  inline-size: calc-size(min-content, size + 2rem);
}
```

### Valid basis arguments (`<calc-size-basis>`)

The first argument is the base size for the calculation.

Standard keywords:

- `auto`: the element's default sizing.
- `min-content`: the smallest size the element can take without overflowing.
- `max-content`: the size that fits all content on one line.
- `fit-content`: equivalent to `clamp(min-content, auto, max-content)`.
- `content`: valid only when `calc-size()` is used in `flex-basis`.

Special arguments:

- `any`: a generic basis for when the intrinsic type is unknown or when nesting calculations.
- A nested `calc-size()`: for multi-step or conditional calculations.
- `<calc-sum>`: a length, percentage or math expression (such as `100px` or `20%`). With a fixed basis, the `size` keyword is still available in the second argument and represents the resolved basis value.

The `size` keyword is not valid in the first argument itself. It only exists to refer back to the basis from the second argument.

### Valid calculation arguments (`<calc-sum>`)

The second argument is the math expression.

- It usually uses `size` to refer to the basis value.
- `size` is technically optional, but without it the calculation resolves to a fixed value and ignores the basis.
- It can use the operators `+`, `-`, `*` and `/`.
- It can use math functions such as `clamp()`, `min()`, `max()` and `round()`.
- Each `calc-size()` allows only one intrinsic size value (the basis). You cannot mix intrinsic keywords in one call.

## Use cases

### Animating to and from intrinsic sizes

Browsers cannot interpolate between a length (such as `0px`) and an intrinsic keyword (such as `auto`) by default. Wrapping the keyword in `calc-size()` makes it interpolatable.

#### Choosing the right tool for animations

- `interpolate-size: allow-keywords`: use this for simple animations to or from intrinsic sizes (such as `height: 0` to `height: auto`) with no math. Ideally apply it globally on `:root`.

  ```css
  :root {
    interpolate-size: allow-keywords;
  }

  .item {
    height: 0;
    visibility: hidden;
    transition: height 0.3s ease, visibility 0.3s;
  }

  .item.open {
    /* 0 to auto now interpolates without calc-size() */
    height: auto;
    visibility: visible;
  }
  ```

- `calc-size()`: use this only when a transition needs math on the intrinsic size, such as adding padding or clamping.

```css
.accordion-content {
  display: block;
  overflow: hidden;
  /* Closed state */
  block-size: 0;
  /* Removes closed content from the accessibility tree and tab order;
     transitioning visibility keeps it visible until the panel finishes closing */
  visibility: hidden;
  transition: block-size 0.3s ease-out, visibility 0.3s;
}

.accordion-content.open {
  /* Fallback for the open state */
  block-size: auto;
  /* Animates from 0 to the intrinsic size plus 2rem */
  block-size: calc-size(auto, size + 2rem);
  visibility: visible;
}
```

Collapsing to zero size (`block-size: 0` or `height: 0`) only hides content visually: screen readers still read it, and its links and controls stay in the tab order. Set `visibility: hidden` on the closed state and `visibility: visible` on the open state, and include `visibility` in the transition so the content stays visible until it has finished closing.

You cannot interpolate directly between two intrinsic keywords. One end of the transition must be a length or a percentage.

#### Respecting user motion preferences

Animations that resize large layout areas can be disruptive for users with vestibular disorders. Use the `prefers-reduced-motion` media query to simplify or minimize non-essential animations: disable the motion, shorten it, or replace layout shifts with subtle opacity transitions.

```css
.accordion-content {
  opacity: 0;
  visibility: hidden;
  transition: block-size 0.3s ease, opacity 0.3s ease, visibility 0.3s;
}

.accordion-content.open {
  opacity: 1;
  visibility: visible;
}

@media (prefers-reduced-motion: reduce) {
  .accordion-content {
    /* Replace the layout animation with a fade: the size changes instantly,
       opacity gives a clear state change without large-scale motion */
    transition: opacity 1.5s ease, visibility 1.5s;
  }

  .accordion-content.open {
    block-size: auto;
  }
}
```

### Applying constraints to intrinsic sizes

`calc-size()` works with any CSS math function, such as `min()`, `max()`, `clamp()` or `round()`, to keep an intrinsic size within design limits.

```css
.dynamic-container {
  /* Fallback for browsers without calc-size() */
  inline-size: fit-content;

  /* Content-based size, offset and then capped with math functions */
  inline-size: calc-size(fit-content, min(size + var(--extra-space), var(--max-allowed)));
}
```

## Considerations

- Percentages in `<calc-sum>` resolve against the container's size, not against `size`. `calc-size(auto, size + 10%)` adds 10% of the parent's width to the element's `auto` width, which can give unexpected results or overflow.
- Use `interpolate-size: allow-keywords`, not `calc-size()`, for simple animations such as `0` to `auto`. Reserve `calc-size()` for layouts that need math on the intrinsic basis.
- Animating box-model properties such as `inline-size` or `block-size` triggers layout recalculation, which can be expensive. Use `calc-size()` animations mainly for layout-critical elements where non-layout alternatives are not enough.

## Fallback strategies

Browser support for calc-size(): Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

Browser support for interpolate-size: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

`calc-size()` and `interpolate-size` are progressive enhancements. Unsupported browsers ignore them; the layout keeps working, but animations to intrinsic keywords jump instead of transitioning. Always declare a standard keyword or length as a fallback.

```css
.element {
  /* Fallback for browsers without calc-size() */
  inline-size: fit-content;
  inline-size: calc-size(fit-content, size + 2rem);
}
```

### Animation and transition fallbacks

Without `calc-size()` or `interpolate-size`, transitions involving intrinsic keywords do not interpolate.

- Graceful degradation: the default fallback is an instant jump between states (such as `0` to `auto`). The layout still works, which is usually acceptable.
- Enhanced experience: use `@supports` for layout logic or styling that only makes sense when smooth intrinsic animations are possible.
- Avoid JavaScript measurement: measuring elements and animating their dimensions manually is usually unnecessary and can cause layout thrashing. The native instant jump is the recommended fallback.

To detect support:

```css
@supports (inline-size: calc-size(auto, size + 0px)) {
  .element {
    /* Advanced logic only where supported */
  }
}
```

```javascript
if (CSS.supports('inline-size', 'calc-size(auto, size + 0px)')) {
  // Apply advanced sizing or animations
}
```
