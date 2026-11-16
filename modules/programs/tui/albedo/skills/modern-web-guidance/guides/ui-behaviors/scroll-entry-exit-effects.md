# Add entry and exit effects to elements as they enter or exit the scrollport

Entry and exit effects are animations that run as an element enters or leaves the viewport, for example fading an element in as it scrolls into view or scaling it down as it scrolls out.

## How to implement

1. Create separate `@keyframes` for entry and exit. The entry animation runs as the element enters the viewport, the exit animation as it leaves.

    ```css
    @keyframes slide-in {
      from { transform: translateX(-100%); }
    }
    @keyframes slide-out {
      to { transform: translateX(100%); }
    }
    ```

2. Attach both animations to the element. Give the entry animation `animation-fill-mode: backwards` so its initial state applies before it starts, and the exit animation `forwards` so its final state persists after it ends.

    ```css
    .animated-element {
      animation:
        slide-in auto linear backwards,
        slide-out auto linear forwards;
    }
    ```

3. Link the animations to a view timeline, which follows the element's visibility in the viewport. Create one with `view()` in `animation-timeline`:

    ```css
    .animated-element {
      animation-timeline: view();
    }
    ```

   `view()` tracks the `block` axis by default; use `view(inline)` for the inline axis.

4. Limit each animation to its range with `animation-range`. The `entry` range runs from when the element first enters the viewport until it is fully visible; the `exit` range from when it starts to leave until it is completely hidden.

    ```css
    .animated-element {
      animation-range: entry, exit;
    }
    ```

   Alternatively, put both phases in a single `@keyframes` rule using timeline-range keyframe selectors (`entry 0%`, `entry 100%`, `exit 0%`, `exit 100%`) with `animation-fill-mode: both`. Separate keyframes suit reusable, composable animations (such as shared `fade-in` and `fade-out`); a single rule keeps an element's entry and exit logic in one place.

## Examples

With an anonymous view timeline, the scroller's direct children play `grow` as they enter the scrollport and `shrink` as they leave:

```css
@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: view()) and (animation-range: entry)) {
    @keyframes grow {
      from {
        scale: 0.5;
      }
    }
    @keyframes shrink {
      to {
        scale: 0.5;
      }
    }

    .scroller > * {
      animation:
        grow auto linear backwards,
        shrink auto linear forwards;
      animation-timeline: view(inline);
      animation-range: entry, exit;
    }
  }
}
```

The same result with a named view timeline:

```css
@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: view()) and (animation-range: entry)) {
    @keyframes grow {
      from {
        scale: 0.5;
      }
    }
    @keyframes shrink {
      to {
        scale: 0.5;
      }
    }

    .scroller > * {
      view-timeline: --tl inline;
      animation:
        grow auto linear backwards,
        shrink auto linear forwards;
      animation-timeline: --tl;
      animation-range: entry, exit;
    }
  }
}
```

The same effect in a single `@keyframes` rule with timeline-range selectors, using `both` fill mode and no `animation-range` on the element:

```css
@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: view()) and (animation-range: entry)) {
    @keyframes grow-and-shrink {
      entry 0% {
        scale: 0.5; /* Example value. */
      }
      /* Hold the resting state through the middle (contain) phase so the element
         doesn't interpolate straight from entry 0% to exit 100%. */
      entry 100%,
      exit 0% {
        scale: 1;
      }
      exit 100% {
        scale: 0.5;
      }
    }

    .scroller > * {
      animation: grow-and-shrink auto linear both;
      animation-timeline: view(inline);
    }
  }
}
```

## Practices

- Feature-detect. Not every browser supports scroll-driven animations. Check with `@supports ((animation-timeline: view()) and (animation-range: entry))` and provide a fallback for the rest.
  - Include the `(animation-range: entry)` test; it filters out browsers with only partial support.
  - Don't use the `scroll-timeline-polyfill` package for the fallback; it is incomplete and has many known issues.
  - If the animation is purely decorative, treat it as a progressive enhancement and provide no fallback.
- Respect `prefers-reduced-motion` by disabling or reducing the animation.
- Animate compositor-friendly properties such as `transform` and `opacity`. Animating `width`, `height` and similar properties causes performance problems.
- Declare `animation-timeline` and `animation-range` after the `animation` shorthand, which would otherwise reset them.

Use an anonymous `view()` timeline by default when the animated element is also the tracked element, so you don't have to name every timeline. Use a named `view-timeline` when several elements share one timeline (avoiding duplicates) or when reaching across the DOM, such as animating descendants or non-ancestors through `timeline-scope` where `view()` or `scroll(nearest)` isn't enough.

With `view()`:

- Optionally, when tracking an axis other than the default `block` (as in a horizontal scroller), state it explicitly with `view(block)` or `view(inline)`.

With `view-timeline`:

- Name it with a CSS `<dashed-ident>`.
- Optionally, when tracking an axis other than the default `block`, set it explicitly with `view-timeline-axis`.
- If the element declaring the `view-timeline` isn't a flat-tree ancestor of the animated element, raise the name's visibility with `timeline-scope` on a shared ancestor.

## Browser support and fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

A fallback is therefore usually needed. Fallbacks recreate the effect with a scroll listener (for scroll timeline effects) or `IntersectionObserver` (for view timeline effects). Where scroll-driven animations are supported natively, always use the CSS version, which performs better. Not every effect can be recreated this way.

For this effect, the script below observes each `.scroller > *` with an `IntersectionObserver` and sets its `scale` from `intersectionRatio`. The CSS `prefers-reduced-motion` query doesn't affect the inline styles the script sets, so the script checks the preference with `matchMedia()` and runs only when there is no reduced-motion preference.

```html
<script>
  if (!CSS.supports('(animation-timeline: view()) and (animation-range: entry)') &&
      matchMedia('(prefers-reduced-motion: no-preference)').matches) {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          // Matches the CSS examples; adjust as needed.
          entry.target.style.scale = 0.5 + entry.intersectionRatio * 0.5;
        }
      },
      {
        threshold: Array.from({ length: 101 }, (_, i) => i / 100),
      }
    );

    document.querySelectorAll('.scroller > *').forEach((el) => {
      observer.observe(el);
    });
  }
</script>
```
