# Build a Parallax Effect on Scroll

In a parallax effect, layers of content move at different speeds as the user scrolls, with foreground layers moving faster than the background. It creates an illusion of depth. Build it with CSS scroll-driven animations, which tie an animation to a container's scroll position.

## How to implement

1. Create a wrapper that groups the layers. It isn't the scroller, so clip its overflow, and give it a `height` equal to the height of one of the layers.

    ```html
    <div class="wrapper">
      …
    </div>
    ```

    ```css
    .wrapper {
      overflow: clip;
      height: 100vh; /* Height of one parallax layer. */
    }
    ```

2. Add the layers inside the wrapper.

    ```html
    <div class="wrapper">
      <div class="layer">LAYER 0</div>
      <div class="layer">LAYER 1</div>
      <div class="layer">LAYER 2</div>
      …
    </div>
    ```

3. Define an animation on `transform`, usually `translateY` to move the layers vertically.

    ```css
    @keyframes parallax {
      from {
        transform: translateY(700px);
      }
    }
    ```

4. Create a `view-timeline` on the wrapper and use it as the layers' timeline.

    ```css
    .wrapper {
      view-timeline: --wrapper;
    }

    .layer {
      animation: parallax linear both;
      animation-timeline: --wrapper;
    }
    ```

5. Stagger the layers so they move at different speeds, either in the keyframes or through `animation-range`.

   Stagger the keyframes when layers share one timeline and range but need different travel distances; it is simplest for a fixed number of layers. Stagger `animation-range` when layers should enter and exit at different scroll positions across a long container.

   Either approach can use hardcoded values, which are easiest for a few layers, or `sibling-index()`/`sibling-count()`, which suit many layers.

    - Staggering the keyframes with hardcoded values: a custom property per layer sets its offset.

        ```css
        .layer:nth-child(1) { --offset: 100px; }
        .layer:nth-child(2) { --offset: 200px; }
        .layer:nth-child(3) { --offset: 300px; }

        @keyframes parallax {
          from {
            transform: translateY(var(--offset));
          }
        }
        ```

      With `sibling-index()`, which returns an element's index among its siblings, the stagger is computed automatically:

        ```css
        @keyframes parallax {
          from {
            transform: translateY(calc(100px * sibling-index()));
          }
        }
        ```

    - Staggering `animation-range` with hardcoded values: set each layer's range explicitly.

        ```css
        .layer:nth-child(1) { animation-range: entry 25% exit 50%; }
        .layer:nth-child(2) { animation-range: entry 25% exit 75%; }
        .layer:nth-child(3) { animation-range: entry 25% exit 100%; }
        ```

      With `sibling-index()` and `sibling-count()`, the range is computed from the total number of layers:

        ```css
        .layer {
          animation-range: entry 25% exit calc(100% / sibling-count() * sibling-index());
        }
        ```

## Example

```css
@keyframes parallax {
  from {
    transform: translateY(calc(100px * sibling-index()));
  }
}

.wrapper {
  view-timeline: --wrapper;
}

.layer {
  animation: parallax linear both;
  animation-timeline: --wrapper;
}

@media (prefers-reduced-motion: reduce) {
  .layer {
    animation: none;
  }
}
```

The same effect with `animation-range`:

```css
@keyframes parallax {
  from {
    transform: translateY(700px);
  }
}

.wrapper {
  view-timeline: --wrapper;
}

.layer {
  animation: parallax linear both;
  animation-timeline: --wrapper;
  animation-range: entry 25% exit calc(100% / sibling-count() * sibling-index());
}

@media (prefers-reduced-motion: reduce) {
  .layer {
    animation: none;
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
- For `animation-range`, give every layer the same start offset (for example `entry 25%`) and a different end offset distributed with `sibling-count()` and `sibling-index()` (for example `exit calc(100% / sibling-count() * sibling-index())`).

## Browser support and fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

A fallback is therefore usually needed. Fallbacks recreate the effect with a scroll listener (for scroll timeline effects) or `IntersectionObserver` (for view timeline effects). Where scroll-driven animations are supported natively, always use the CSS version, which performs better. Not every effect can be recreated this way.

For this effect, the script below uses an `IntersectionObserver` to track whether `.wrapper` is visible and updates the layers' `transform` from the scroll position. The CSS `prefers-reduced-motion` query doesn't affect the inline styles the script sets, so the script checks the preference with `matchMedia()` and doesn't run when the user prefers reduced motion.

```js
if (!CSS.supports('(animation-timeline: view()) and (animation-range: entry)') &&
    !matchMedia('(prefers-reduced-motion: reduce)').matches) {
  const wrapper = document.querySelector('.wrapper');
  const layers = document.querySelectorAll('.layer');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        window.addEventListener('scroll', onScroll);
      } else {
        window.removeEventListener('scroll', onScroll);
      }
    });
  }, { threshold: 0 });

  observer.observe(wrapper);

  function onScroll() {
    const scrollY = window.scrollY;
    const wrapperRect = wrapper.getBoundingClientRect();
    const wrapperTop = wrapperRect.top + scrollY;
    const wrapperHeight = wrapperRect.height;
    const windowHeight = window.innerHeight;

    if (scrollY >= wrapperTop - windowHeight && scrollY <= wrapperTop + wrapperHeight) {
      const scrollPercent = (scrollY - (wrapperTop - windowHeight)) / (wrapperHeight + windowHeight);

      layers.forEach((layer, index) => {
        // Matches the first CSS example; adjust as needed.
        const initialTranslateY = 100 * (index + 1); // sibling-index() is 1-based.
        const translateY = initialTranslateY * (1 - scrollPercent);
        layer.style.transform = `translateY(${translateY}px)`;
      });
    }
  }

  // Set the initial positions.
  onScroll();
}
```
