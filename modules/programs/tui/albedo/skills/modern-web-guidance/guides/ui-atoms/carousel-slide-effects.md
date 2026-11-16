# Build Carousel Slide Effects

Slide effects animate each carousel slide as it enters, centers on, and leaves the scrollport: slides can fade, rotate, or scale. Unlike separate entry and exit animations, one continuous animation controls the slide's appearance across the whole scrollport.

## How to implement

1. Create a scroller to hold the slides. This example scrolls horizontally with `overflow-x: scroll`. When the slides contain no focusable elements, give the scroller `tabindex="0"` and an accessible name, because not every browser makes a scroll container keyboard-focusable. The name needs a role that supports one: a `<ul>` already has the `list` role, but a `<div>` needs one, such as `role="region"`.

    ```html
    <!-- The slides contain no focusable elements, so the scroller takes focus itself. The label is an example. -->
    <ul class="scroller" tabindex="0" aria-label="Slides">
      <li class="entry">1</li>
      <li class="entry">2</li>
      <li class="entry">3</li>
      …
    </ul>
    ```

    ```css
    .scroller {
      overflow-x: scroll;
    }
    ```

   To make slides settle cleanly in the center when scrolling stops, optionally add `scroll-snap-type: x mandatory` to the scroller and `scroll-snap-align: center` to the slides.

2. Define a keyframe animation for the states a slide passes through as it crosses the scrollport. Keyframes can sit anywhere in the animation; a `50%` keyframe describes the slide at the center of the scrollport. Here `scale` grows slides toward the center and shrinks them away from it.

    ```css
    @keyframes animate {
      0% { scale: 0.5; }
      50% { scale: 1; }
      100% { scale: 0.5; }
    }
    ```

3. Attach the animation to the slides and link it to a view timeline that tracks each slide as it scrolls through the container.

    ```css
    .scroller > * {
      animation: animate auto linear both;
      animation-timeline: view(inline);
    }
    ```

   `view()` tracks the `block` axis by default; use `view(inline)` to track the inline axis.

## Example code

With an anonymous view timeline:

```css
/* Example values; animate compositor-friendly properties such as transform, scale, or opacity. */
@keyframes animate {
  0% { scale: 0.5; }
  50% { scale: 1; }
  100% { scale: 0.5; }
}

@media (prefers-reduced-motion: no-preference) {
  /* (animation-range: entry) excludes browsers with partial scroll-driven animation support. */
  @supports ((animation-timeline: view()) and (animation-range: entry)) {
    .scroller > * {
      animation: animate auto linear both;
      /* Tracks the item's progress through the scroller on the inline axis. */
      animation-timeline: view(inline);
    }
  }
}
```

With a named view timeline, declared on each item and driving that item's own animation:

```css
@keyframes animate {
  0% { scale: 0.5; }
  50% { scale: 1; }
  100% { scale: 0.5; }
}

@media (prefers-reduced-motion: no-preference) {
  @supports ((animation-timeline: view()) and (animation-range: entry)) {
    .scroller > * {
      animation: animate auto linear both;
      view-timeline: --item inline;
      animation-timeline: --item;
    }
  }
}
```

## Best practices

- Feature-detect with `@supports ((animation-timeline: view()) and (animation-range: entry))` and provide a fallback for browsers without support. Keep the `(animation-range: entry)` check: it filters out browsers with only partial support.
- Do not use the `scroll-timeline-polyfill` package as the fallback; it is not feature complete and has many known issues.
- If the animation is purely decorative, treat it as progressive enhancement and provide no fallback.
- Respect `prefers-reduced-motion`: disable or reduce the animation for users who prefer less motion.
- Animate compositor-friendly properties such as `transform` and `opacity` for smooth results. Animating `width`, `height` and similar properties can cause performance problems.
- Declare `animation-timeline` and `animation-range` after the `animation` shorthand, because the shorthand resets them.

Use an anonymous `view()` timeline by default when the animated element is the element being tracked, so you do not have to name every timeline. Use a named `view-timeline` when several elements share one timeline (avoiding duplicate timelines) or when reaching across the DOM, such as animating descendants or non-ancestors through `timeline-scope`, where `view()` or `scroll(nearest)` is not enough.

With `view()`:

- Optionally name the axis explicitly when it is not the default `block` axis, as in a horizontal scroller: `view(block)` or `view(inline)`.

With the `view-timeline` property:

- Name the timeline with a CSS `<dashed-ident>`, such as `view-timeline: --my-custom-name`.
- Optionally set the axis explicitly with `view-timeline-axis` when it is not the default `block` axis.
- When the element declaring the `view-timeline` is not a flat-tree ancestor of the animated element, use `timeline-scope` on a shared ancestor so the name can be found.

## Browser support and fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

A fallback is therefore typically required. Fallbacks usually use a scroll listener (for ScrollTimeline effects) or IntersectionObserver (for ViewTimeline effects). Not every effect can be recreated this way. Where scroll-driven animations are supported, always use the native CSS version, which performs better.

The fallback below uses the Web Animations API (`Element.animate()`) to create a paused animation per item, then on each `scroll` event sets each animation's `currentTime` from the item's position in the scroller. The CSS `prefers-reduced-motion` query does not affect script-created animations, so the script checks the preference with `matchMedia()` itself.

```js
if (!CSS.supports('(animation-timeline: view()) and (animation-range: entry)') &&
    matchMedia('(prefers-reduced-motion: no-preference)').matches) {
  const scroller = document.querySelector('.scroller');
  const entries = document.querySelectorAll('.entry');
  const animations = new Map();

  entries.forEach(entry => {
    const animation = entry.animate(
      { scale: ['0.5', '1', '0.5'] },
      // Duration 1 lets currentTime be set directly as a 0-1 progress value.
      { duration: 1, fill: 'both' }
    );
    animation.pause();
    animations.set(entry, animation);
  });

  const tick = () => {
    const scrollerRect = scroller.getBoundingClientRect();
    entries.forEach(entry => {
      const animation = animations.get(entry);
      if (!animation) return;
      const entryRect = entry.getBoundingClientRect();
      const progress = (entryRect.left + entryRect.width / 2 - scrollerRect.left) / scrollerRect.width;
      animation.currentTime = progress;
    });
  };

  scroller.addEventListener('scroll', tick);
  tick();
}
```
