# Shrinking header on scroll

A fixed header at the top of the page shrinks smoothly as the user scrolls down, giving the main content more room while keeping navigation or branding available. CSS scroll-driven animations do this declaratively and efficiently by linking an animation to the document's scroll position.

## How to implement

1. Start with a header fixed to the top of the page with a set height.

    ```html
    <header>HEADER</header>
    ```

    ```css
    header {
      position: fixed;
      height: 200px;
      top: 0;
      left: 0;
      right: 0;
    }
    ```

2. Define an animation that changes the header's height.

    ```css
    @keyframes shrink {
      to {
        height: 50px;
      }
    }
    ```

3. Attach the animation and link it to the document's scroll position with `scroll()`.

    ```css
    header {
      animation: shrink auto linear both;
      animation-timeline: scroll(block root);
    }
    ```

4. Set `animation-range` to the scroll distance over which the animation runs. To shrink the header over the first 150 pixels of scrolling, use `animation-range: 0px 150px;`.

    ```css
    header {
      animation-range: 0px 150px;
    }
    ```

Whether the header is `position: fixed` or `position: sticky`, set `scroll-padding-top` to its height so focused controls are shown below it instead of under it. This satisfies WCAG 2.4.11 Focus Not Obscured, which requires that focused controls are not completely obscured. You can animate `scroll-padding-top` on the same scroll timeline that shrinks the header, keeping it in step with the visual change.

To keep the content after the header from being hidden under it, give `body` (or the main content container) a `padding-top` equal to the header's initial height.

To keep the page content scrolling in sync with the shrinking header, set the `animation-range-end` to the difference between the start and end sizes, so the animation finishes exactly when the header reaches its final size. Here the header shrinks from `200px` to `50px`, so the range ends at `150px`.

## Example code

```css
@keyframes shrink {
  to {
    height: 50px;
  }
}

@media (prefers-reduced-motion: no-preference) {
  /* (animation-range: 0% 100%) excludes browsers with partial support. */
  @supports ((animation-timeline: scroll()) and (animation-range: 0% 100%)) {
    header {
      animation: shrink auto linear both;
      animation-timeline: scroll(block root);
      animation-range: 0px 150px;
    }
  }
}
```

## Best practices

- Feature-detect with `@supports ((animation-timeline: scroll()) and (animation-range: 0% 100%))` and provide a fallback for browsers without support. Keep the `(animation-range: 0% 100%)` check: it filters out browsers with only partial support.
- Do not use the `scroll-timeline-polyfill` package as the fallback; it is not feature complete and has many known issues.
- If the animation is purely decorative, treat it as progressive enhancement and provide no fallback.
- Respect `prefers-reduced-motion`: disable or reduce the animation for users who prefer less motion.
- Animate compositor-friendly properties such as `transform` and `opacity` where you can. Animating `width`, `height` and similar properties can cause performance problems.
- Declare `animation-timeline` and `animation-range` after the `animation` shorthand, because the shorthand resets them.

With `scroll()`:

- Optionally name the scroller explicitly with `scroll(root)` or `scroll(self)` when it is not the nearest ancestor scroller. When `root`, `nearest` and `self` are not enough, use a named scroll timeline.
- Optionally name the axis explicitly with `scroll(block)` or `scroll(inline)` when it is not the default `block` axis, as in a horizontal scroller.

For this pattern specifically:

- When `animation-range` uses percentages, the animated element must not be `position: static` or `position: relative`. Those elements are in flow, so shrinking them while scrolling shrinks the total scroll distance and changes what, for example, `10%` of the scroll resolves to.

## Browser support and fallback strategies

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

A fallback is therefore typically required. Fallbacks usually use a scroll listener (for ScrollTimeline effects) or IntersectionObserver (for ViewTimeline effects). Not every effect can be recreated this way. Where scroll-driven animations are supported, always use the native CSS version, which performs better.

This fallback tracks the document's scroll position over `150px` with a scroll listener and sets the header's height. Like the CSS, it runs only when the user has no reduced-motion preference.

```js
if (!CSS.supports('(animation-timeline: scroll()) and (animation-range: 0% 100%)') &&
    matchMedia('(prefers-reduced-motion: no-preference)').matches) {
  const header = document.querySelector('header');

  const initialHeight = 200;
  const finalHeight = 50;
  const scrollDistance = 150;

  window.addEventListener('scroll', () => {
    const scrollPercent = Math.min(1, window.scrollY / scrollDistance);
    const newHeight = initialHeight - (initialHeight - finalHeight) * scrollPercent;
    header.style.height = `${newHeight}px`;
  });
}
```
