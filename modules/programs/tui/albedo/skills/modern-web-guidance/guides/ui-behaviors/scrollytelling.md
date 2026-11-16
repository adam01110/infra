# Scrollytelling

Scrollytelling animates elements as the user scrolls, guiding them through a story or narrative. CSS scroll-driven animations do this in CSS alone. The animations follow the scroll position rather than a clock, so they always stay in sync with the user's scrolling.

## How to implement

You need two sets of elements: one that tracks the scroll position and one that is animated.

Define a named `view-timeline` on each tracked element. These drive the animations.

```css
#tracked {
  section:nth-child(1){ view-timeline: --tl-1 block; }
  section:nth-child(2){ view-timeline: --tl-2 block; }
  section:nth-child(3){ view-timeline: --tl-3 block; }
  section:nth-child(4){ view-timeline: --tl-4 block; }
  section:nth-child(5){ view-timeline: --tl-5 block; }
}
```

Animate the other elements and link them to those timelines with `animation-timeline`:

```css
#animated {
  section {
    animation: animate-in auto linear both, animate-out auto linear forwards;
    animation-range: entry 25% cover 50%, exit 50% exit 75%;
  }

  section:nth-child(1){ animation-timeline: --tl-1; }
  section:nth-child(2){ animation-timeline: --tl-2; }
  section:nth-child(3){ animation-timeline: --tl-3; }
  section:nth-child(4){ animation-timeline: --tl-4; }
  section:nth-child(5){ animation-timeline: --tl-5; }
}
```

`animation-timeline` can only reference named timelines in scope. Use `timeline-scope` on a common ancestor, often the root, to make them available to every element that needs them:

```css
html {
  timeline-scope: --tl-1, --tl-2, --tl-3, --tl-4, --tl-5;
}
```

`animation-range` sets exactly which part of the timeline each animation runs in, giving fine control over when animations start and how they progress:

```css
#animated section {
  animation-range: entry 25% cover 50%, exit 50% exit 75%;
}
```

## Example

```css
@supports ((animation-timeline: scroll()) and (animation-range: 0% 100%)) {
  html {
    timeline-scope: --tl-1, --tl-2, --tl-3, --tl-4, --tl-5;
  }

  #tracked {
    section:nth-child(1){ view-timeline: --tl-1 block; }
    section:nth-child(2){ view-timeline: --tl-2 block; }
    section:nth-child(3){ view-timeline: --tl-3 block; }
    section:nth-child(4){ view-timeline: --tl-4 block; }
    section:nth-child(5){ view-timeline: --tl-5 block; }
  }

  @keyframes animate-in {
    from { scale: 0.5; opacity: 0; transform: rotateY(-180deg); }
    to { transform: rotateY(0deg); }
  }
  @keyframes animate-out {
    to { translate: 100% 0; opacity: 0; }
  }

  #animated {
    section {
      animation: animate-in auto linear both, animate-out auto linear forwards;
      animation-range: entry 25% cover 50%, exit 50% exit 75%;
      backface-visibility: hidden;
    }

    section:nth-child(1){ animation-timeline: --tl-1; }
    section:nth-child(2){ animation-timeline: --tl-2; }
    section:nth-child(3){ animation-timeline: --tl-3; }
    section:nth-child(4){ animation-timeline: --tl-4; }
    section:nth-child(5){ animation-timeline: --tl-5; }
  }
}

/* Turns the motion off for users who prefer reduced motion, even if the rules above are copied elsewhere. */
@media (prefers-reduced-motion: reduce) {
  #animated section {
    animation: none !important;
    opacity: 1 !important;
    transform: none !important;
  }
}
```

## Practices

- Feature-detect. Not every browser supports scroll-driven animations. Check with `@supports ((animation-timeline: scroll()) and (animation-range: 0% 100%))` and provide a fallback for the rest.
  - Include the `(animation-range: 0% 100%)` test; it filters out browsers with only partial support.
  - Don't use the `scroll-timeline-polyfill` package for the fallback; it is incomplete and has many known issues.
  - If the animation is purely decorative, treat it as a progressive enhancement and provide no fallback.
- Respect `prefers-reduced-motion` by disabling or reducing the animation.
- Animate compositor-friendly properties such as `transform` and `opacity`. Animating `width`, `height` and similar properties causes performance problems.
- Declare `animation-timeline` and `animation-range` after the `animation` shorthand, which would otherwise reset them.

For `view-timeline`:

- Name it with a CSS `<dashed-ident>`.
- Optionally, when tracking an axis other than the default `block` (as in a horizontal scroller), set it explicitly with `view-timeline-axis`.
- If the element declaring the `view-timeline` isn't a flat-tree ancestor of the animated element, raise the name's visibility with `timeline-scope` on a shared ancestor.

## Fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

Fallbacks recreate the effect with a scroll listener (for scroll timeline effects) or `IntersectionObserver` (for view timeline effects). Where scroll-driven animations are supported natively, always use the CSS version, which performs better. Not every effect can be recreated this way.

For this effect, the script below observes each `#tracked section` with an `IntersectionObserver` and updates the transform of the matching `#animated section`. A dense list of thresholds tracks the scroll position precisely, which makes the fallback animation smooth and close to the native one.

```js
if (!CSS.supports('(animation-timeline: scroll()) and (animation-range: 0% 100%)')) {
  const animatedSections = document.querySelectorAll('#animated section');
  // The CSS hides the sections only once this class is set, so they stay visible if the script doesn't run.
  document.querySelector('#animated').classList.add('scroll-fallback');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      const sectionIndex = Array.from(document.querySelectorAll('#tracked section')).indexOf(entry.target);
      if (sectionIndex !== -1) {
        const animatedSection = animatedSections[sectionIndex];
        // Reaches 1 once the section fills the viewport, even when it's taller than the viewport.
        const ratio = Math.min(1, entry.intersectionRect.height / Math.min(entry.boundingClientRect.height, innerHeight));

        // Animate in.
        animatedSection.style.opacity = ratio;
        animatedSection.style.transform = `scale(${0.5 + ratio * 0.5}) rotateY(${-180 + ratio * 180}deg)`;

        // Animate out.
        if (ratio < 0.5) {
          animatedSection.style.translate = `${(0.5 - ratio) * 2 * 100}% 0`;
        } else {
          animatedSection.style.translate = '0 0';
        }
      }
    });
  }, { threshold: Array.from({length: 101}, (_, i) => i / 100) });

  document.querySelectorAll('#tracked section').forEach(section => {
    observer.observe(section);
  });
}
```

The accompanying CSS:

```css
#animated.scroll-fallback section {
  opacity: 0;
  transform: scale(0.5)  rotateY(-180deg);
  backface-visibility: hidden;
}

/* Keeps content fully visible for users who prefer reduced motion; !important beats the script's inline styles. */
@media (prefers-reduced-motion: reduce) {
  #animated section {
    opacity: 1 !important;
    transform: none !important;
    translate: 0 0 !important;
  }
}
```
