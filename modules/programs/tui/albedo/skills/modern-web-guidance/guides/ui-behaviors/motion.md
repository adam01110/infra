# Motion

- Use `clip-path` and `mask-image` for custom geometric reveals and smooth fade-outs. Both also clip the element's own focus outline, so if the clipped or masked element is focusable (for example a scroll container with `tabindex="0"`), draw its focus indicator on a parent that isn't clipped or masked.
- Use scroll-driven animations (`animation-timeline: scroll()`) for non-essential scroll-bound effects instead of JavaScript scroll listeners.
- Use view transitions to animate between complex layout states.

## Performance

- Prefer animating `opacity` and `transform`, including the individual transform properties (for example `translate` instead of `left`/`right`/`top`/`bottom`), so animations stay on the compositor thread.
- Animate discrete entry and exit states natively with `transition-behavior: allow-discrete`, `@starting-style`, and, for top-layer elements such as `<dialog>` or `[popover]`, `overlay`. See the `animate-element-entry-exit` and `animate-to-from-top-layer` guides.

```css
.popover-reveal {
  /* Transition discrete display and the top-layer overlay alongside opacity. */
  transition:
    opacity ease-out,
    display,
    overlay;
  transition-duration: 0.2s;
  /* Declared separately, after transition, so the shorthand neither resets it
     nor fails in older browsers. */
  transition-behavior: allow-discrete;
}
```

## Accessibility

- Provide a pause control. Moving, blinking or scrolling content that starts automatically, lasts more than five seconds and appears alongside other content (auto-running carousels, banners, persistent animations) needs a visible, keyboard-operable control to pause, stop or hide it, such as a `<button>` next to it (WCAG 2.2.2 Pause, Stop, Hide). `prefers-reduced-motion` doesn't replace the control, because users who haven't turned that setting on still need to stop the motion. If the button's label switches between "Pause" and "Play", don't also set `aria-pressed`, or screen readers announce a pressed "Play" button.
- Consider defaulting to static views and letting users opt in to motion.
- Never flash more than three times in any one-second period (WCAG 2.3.1 Three Flashes or Below Threshold). Rapid light-to-dark flashing can cause seizures. This holds whatever the motion preference, so don't put flashing content inside `@media (prefers-reduced-motion: no-preference)` either.
- When you turn an animation off, make sure the element still ends in its final state, so content isn't left hidden (for example at `opacity: 0`) and focus and selection indicators still appear.

### Respect reduced motion

Choose the media query by what reduced motion should do:

- Use `@media (prefers-reduced-motion: no-preference)` when reduced motion means no animation at all. Apply the animation only inside the query, rather than declaring it broadly and cancelling it with `animation: none`.
- Use `@media (prefers-reduced-motion: reduce)` when reduced motion means changed parameters, such as a slower `animation-duration`.

Don't apply `animation-duration: 0.01ms` globally; it can make some animations more jarring. Handle reduced motion case by case, nesting the `@media` query inside the rule so both versions stay together. Keep non-motion transitions such as `color` or `background-color` changes on links and buttons; only dampen or disable movement, scaling, rotation and persistent animations.

#### Opt in to motion with `no-preference`

When reduced motion should remove the animation, default to the static state and enable the animation inside `no-preference`:

```css
.spinner {
  @media (prefers-reduced-motion: no-preference) {
    animation: spin 1s linear infinite;
  }
}
```

#### Adjust parameters with `reduce`

When the animation should still run, more gently, declare it normally and override only what changes:

```css
/* Slow the animation down for reduced motion instead of cancelling it. */
progress:not([value]) {
  animation: slide 1s infinite linear;
  @media (prefers-reduced-motion: reduce) {
    animation-duration: 20s;
  }
}
```

## Animation and transition events in JavaScript

On `AnimationEvent` (`animationstart`, `animationiteration`, `animationend`, `animationcancel`) and `TransitionEvent` (`transitionrun`, `transitionstart`, `transitionend`, `transitioncancel`), `event.target` is the originating DOM element. The read-only `event.animation` property gives the exact `Animation` object (`Animation`, `CSSAnimation` or `CSSTransition`) that fired the event.

Where `event.animation` isn't available, you can usually find the animation with `event.target.getAnimations()` filtered by `event.animationName` (or `event.propertyName` for transitions). Prefer `event.animation`, because that fallback fails in several cases:

- Web Animations API animations (`element.animate()`) have no `animationName`, so they can't be matched by name.
- Matching `AnimationEvent`s by `animationName` is ambiguous when several animations with the same name run on one element. (Matching `TransitionEvent`s by transition property works, since there is only one event per transition property.)
- `event.target` is always the originating element, so it can't tell an animation on the element from one on its pseudo-element; `event.animation.effect.pseudoElement` names the pseudo-element directly.

```js
// Works for basic CSS animations, but fails for WAAPI animations,
// duplicate animation names on one element, and pseudo-elements.
document.addEventListener('animationstart', (event) => {
  const animation = event.target
    .getAnimations()
    .find((anim) => anim.animationName === event.animationName);
  console.log(animation);
});

// Preferred: the exact Animation object.
document.addEventListener('animationstart', (event) => {
  const animation = event.animation;
  console.log(animation);
});
```

Feature-detect it with `'animation' in AnimationEvent.prototype` (or `'animation' in TransitionEvent.prototype`).

When reduced motion means an animation or transition never runs (it is only applied inside `@media (prefers-reduced-motion: no-preference)`, set to `none`, or given zero duration and no delay), `animationend` and `transitionend` never fire. If code waits for those events to remove or hide an element, continue immediately when `element.getAnimations()` returns an empty array, or keep a short opacity transition instead of removing the animation.
