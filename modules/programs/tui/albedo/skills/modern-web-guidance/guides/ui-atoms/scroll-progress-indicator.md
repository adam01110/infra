# Build a Scroll Progress Indicator

A scroll progress indicator shows how far the user has scrolled through a document or container, and so how much content remains.

## How to implement

You need two things:

1. An element to act as the progress bar, typically `position: fixed` or `position: absolute` so it stays in view while scrolling.
2. An animation linked to the scroll position.

Create the progress bar element and style it as you like. Define a `@keyframes` animation that scales it, commonly from `scaleX(0)` to `scaleX(1)`. Apply the animation and set `animation-timeline` to a scroll timeline, so the browser drives the animation's progress from the scroll position of the nearest ancestor scroller.

## Example code

The bar's base styles sit outside the feature and motion queries, so the script fallback below can drive the same element.

```css
#progress {
  position: fixed;
  left: 0; top: 0;
  width: 100%; height: 1em;
  background: red;
  transform-origin: 0 50%;
  transform: scaleX(0);
}
```

With an anonymous scroll timeline, created by the `scroll()` function:

```css
@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: scroll())) {
    @keyframes grow-progress {
      from { transform: scaleX(0); }
      to { transform: scaleX(1); }
    }

    #progress {
      animation: grow-progress auto linear;
      animation-timeline: scroll();
    }
  }
}
```

Given this position in the DOM, `scroll()` tracks the nearest ancestor scroller in the `block` direction, which here is the root scroller:

```html
<body>
  <div id="progress"></div>
</body>
```

With a named scroll timeline, created by the `scroll-timeline` property:

```css
@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: scroll())) {
    @keyframes grow-progress {
      from { transform: scaleX(0); }
      to { transform: scaleX(1); }
    }

    :root {
      scroll-timeline: --tl block;
    }

    #progress {
      animation: grow-progress auto linear;
      animation-timeline: --tl;
    }
  }
}
```

When the user prefers reduced motion, the bar stays at `scaleX(0)` and is not shown.

## Best practices

- Feature-detect with `@supports (animation-timeline: scroll())` and provide a fallback for browsers without support.
- Do not use the `scroll-timeline-polyfill` package as the fallback; it is not feature complete and has many known issues.
- If the animation is purely decorative, treat it as progressive enhancement and provide no fallback.
- Keep purely decorative indicators out of assistive technology. An empty element styled only with CSS needs nothing extra; if the indicator contains text or images, add `aria-hidden="true"`.
- Respect `prefers-reduced-motion`: disable or reduce the animation for users who prefer less motion.
- Animate compositor-friendly properties such as `transform` and `opacity` for smooth results. Animating `width`, `height` and similar properties can cause performance problems.
- Declare `animation-timeline` after the `animation` shorthand, because the shorthand resets it.

With `scroll()`:

- Optionally name the scroller explicitly with `scroll(root)` or `scroll(self)` when it is not the nearest ancestor scroller. When `root`, `nearest` and `self` are not enough, use a named scroll timeline.
- Optionally name the axis explicitly with `scroll(block)` or `scroll(inline)` when it is not the default `block` axis, as in a horizontal scroller.

With the `scroll-timeline` property:

- Name the timeline with a CSS `<dashed-ident>`.
- Optionally set the axis explicitly with `scroll-timeline-axis` when it is not the default `block` axis.
- When the element declaring the `scroll-timeline` is not a flat-tree ancestor of the animated element, use `timeline-scope` on a shared ancestor so the name can be found.

## Fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

Fallbacks usually use a scroll listener (for ScrollTimeline effects) or IntersectionObserver (for ViewTimeline effects). Not every effect can be recreated this way. Where scroll-driven animations are supported, always use the native CSS version, which performs better.

This fallback listens for `scroll` on the window and sets the progress bar's `transform` from the root's scroll position. It also updates on `resize` and when the page's height changes (for example as images load), because the scrollable distance changes then without a `scroll` event. Like the CSS, it runs only when the user has no reduced-motion preference.

```html
<script>
  if (!CSS.supports('animation-timeline', 'scroll()') &&
      matchMedia('(prefers-reduced-motion: no-preference)').matches) {
    const progress = document.querySelector('#progress');

    const update = () => {
      const scrollable = document.documentElement.scrollHeight - window.innerHeight;
      // A page that does not scroll counts as fully read.
      const ratio = scrollable > 0 ? window.scrollY / scrollable : 1;
      progress.style.transform = `scaleX(${ratio})`;
    };

    window.addEventListener('scroll', update);
    window.addEventListener('resize', update);
    new ResizeObserver(update).observe(document.body);
    update();
  }
</script>
```
