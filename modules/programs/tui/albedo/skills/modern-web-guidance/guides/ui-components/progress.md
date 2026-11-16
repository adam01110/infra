# Build a Styled Progress Bar

The `<progress>` element is the semantic way to show how far a task has progressed, such as a download, an upload, or part of a multi-step process. The native element has an implicit `role="progressbar"`, so screen readers can announce its values.

This guide builds a fully styled horizontal progress bar.

## Progress bar or progress ring?

- If space is tight or a square shape fits better, use a circular progress bar; see the `progress-ring` guide.
- For most indeterminate progress, prefer a spinner (see the `spinner` guide). Use an indeterminate progress bar when that state is temporary and will soon become a determinate bar, for example while waiting for upload metadata before a percentage can be shown.

## Markup

1. Use a native `<progress>` element for built-in accessibility and platform-consistent behavior.
2. Set `max` if you need a scale other than the default 0 to 1.
3. Set `value` for a specific progress value. Omit it for an indeterminate state, such as before more concrete feedback starts.
4. Label the element with `<label for="...">`, `aria-labelledby`, or `aria-label`.

## How much customization is needed?

For limited styling, these properties are enough:

- `accent-color` to change the bar color;
- `width` / `inline-size` to change its width;
- `height` / `block-size`, which apply inconsistently, so test first;
- `writing-mode: vertical-lr` for vertical bars;
- effects applied after painting: `opacity`, `filter`, `clip-path`, masks, transforms, `box-shadow`, and so on.

If that is enough, skip the next section.

Some properties, such as `border-radius`, `background`, and `border`, silently disable the default progress bar styling. If you need more than the properties above, implement the fully custom styling below rather than adding extra properties in the hope they work.

## Fully custom styling

### 1. Basic setup

- Set `appearance: none` to enable custom styling.
- Reset the UA border with `border: 0 solid`.
- To clip the bar to the element's `border-radius`, use `overflow: clip` or give the bar the same `border-radius`. Do not use `border-radius: inherit` on the bar; it depends on the browser's shadow DOM structure.

```css
progress {
  appearance: none;
  border: 0 solid;
  /* Clips the bar to the element's border-radius. */
  overflow: clip;
}
```

### 2. Styling

- Style the track on the `progress` element itself.
- Target the bar with the browser-specific pseudo-element: `::-webkit-progress-value` for WebKit and Blink, `::-moz-progress-bar` for Firefox.
- Do not group `-webkit-` and `-moz-` pseudo-elements in one rule: each browser treats the other's pseudo-element as invalid and drops the whole rule. `:is()` and `:where()` do not help because they do not accept pseudo-elements.
- Write each browser-specific pseudo-element rule exactly once. Route state-specific changes (such as the indeterminate segment size and animation) through custom properties set on `progress`.
- Optionally transition `inline-size` on the fill so determinate value changes animate instead of jumping. Firefox sizes the fill in layout and ignores the transition, which is harmless.

```css
progress {
  --progress-bar-radius: 1e5px;
  border-radius: var(--progress-bar-radius);
  /* Track color */
  background: var(--progress-bar-track, var(--color-neutral-90));
  /* Subtle depth on the empty part of the track */
  box-shadow: inset 0 1px 2px rgb(0 0 0 / 0.1);
}

/* Let the <progress> styling show through. */
progress::-webkit-progress-bar {
  background: transparent;
}

/* WebKit, Chromium */
progress::-webkit-progress-value {
  background: var(--progress-bar-fill, var(--accent-color));
  border-radius: var(--progress-bar-radius);
  transition: inline-size 0.3s;
}

/* Firefox */
progress::-moz-progress-bar {
  background: var(--progress-bar-fill, var(--accent-color));
  border-radius: var(--progress-bar-radius);
  transition: inline-size 0.3s;
}
```

### 3. Indeterminate state

Add a custom animation that turns the fill pseudo-element into a short segment sliding along the track.

- Style the fill itself; do not recreate it as a background on `progress`.
- The indeterminate fill exists only through its animation. The keyframes set its length with a real `inline-size` (which beats Chromium's UA inline `inline-size`) and move it with `translate`. Do not use `scale` for the length; it distorts any pattern painted on the fill.
- `translate` percentages resolve against the fill's own width, so express positions in track units: make `progress` an inline-size container and use `cqi` in the keyframes. Include `margin-right: auto` in `from, to` so Chromium lays the fill out at the physical left in RTL too.
- Move the fill with transforms, not margins:
  - Transforms keep the animation on the compositor (unless `inline-size` is animated too).
  - Margins break in RTL for two separate reasons. Firefox positions the indeterminate fill using only its physical left margin, so `margin-inline-start` has no effect in RTL and the fill never moves. Chromium and WebKit lay the fill out as a normal block, so once a margin pushes it past the end of the track the margins add up to more than the track; standard CSS resolves that by ignoring `margin-left` in RTL, and the segment jumps to the edge instead of sliding off.
  - `translate` applies after layout, so neither problem occurs.
- To mirror the motion in RTL, as Chrome's native bar does, reverse the animation under `:dir(rtl)`:

  ```css
  progress:dir(rtl) {
    --progress-bar-indeterminate-animation: progress-bar-indeterminate var(--progress-bar-indeterminate-animation-duration) infinite linear reverse;
  }
  ```

- Define the public `--progress-bar-indeterminate-*` properties on `progress` (the name already scopes them to the state), so consumers can override them without knowing about `:indeterminate`.
- To vary the segment length (for example the leading edge races ahead and the trailing edge catches up), set `--progress-bar-indeterminate-animation` to two concurrent animations: one whose keyframes animate `translate` in `cqi` (position) and one whose keyframes animate `inline-size` (length), each with its own keyframes and easing. Do not shape both edges in one keyframe list; a per-keyframe `animation-timing-function` applies to every property in that keyframe.
- `--progress-bar-animation` applies in both states and can drive effects such as a determinate shimmer. The `revert-rule` fallback makes it override only when set, which keeps it composable.
- Never disable the indeterminate animation: `animation: none` leaves a zero-width fill in Chromium. For reduced motion, slow it down instead.

```css
progress {
  /* Lets the fill position itself in track units (cqi). */
  container-type: inline-size;
  /* Segment length relative to the track */
  --progress-bar-indeterminate-size: 30%;
  --progress-bar-indeterminate-animation-duration: 1.5s;

  @media (prefers-reduced-motion: reduce) {
    --progress-bar-indeterminate-animation-duration: 10s;
  }
}

progress:indeterminate {
  --progress-bar-animation: var(
      --progress-bar-indeterminate-animation,
      progress-bar-indeterminate var(--progress-bar-indeterminate-animation-duration) infinite linear
    );
}

/* Add to the existing pseudo-element rules. */
progress::-webkit-progress-value {
  animation: var(--progress-bar-animation, revert-rule);
}

progress::-moz-progress-bar {
  animation: var(--progress-bar-animation, revert-rule);
}

/* Physical left to right regardless of direction (reversed under :dir(rtl) to mirror). */
@keyframes progress-bar-indeterminate {
  from, to {
    inline-size: var(--progress-bar-indeterminate-size);
    /* Pins to the physical left; Chromium would otherwise lay the fill out at the inline start. */
    margin-right: auto;
  }
  from { translate: -100%; } /* Own width: fully past the left edge */
  to { translate: 100cqi; }  /* Track width: fully past the right edge */
}
```

### Additional accessibility considerations

- Announce completion without moving focus. `<progress>` is not interactive, so do not give it `tabindex` or call `.focus()` on it; moving focus there disrupts keyboard users. To announce that a background task finished, update a polite status element (`role="status"` or `aria-live="polite"`).
- Do not put fallback text inside `<progress>`. Modern browsers ignore it and assistive technologies do not use it.
- Avoid `aria-busy` plus `aria-describedby` on an unlabeled generic `<div>`. `aria-busy` has inconsistent screen reader support, and assistive technologies ignore `aria-describedby` on an unnamed `<div>` without a role. If a region's content is not ready while loading, hide it with `hidden` or `aria-hidden="true"`.
- Keep enough contrast between the bar and the track when adding custom styles.
- Consider other ways to show the indeterminate state; an indeterminate animation running beside other content can distract some users.

## Fallback strategies

### `accent-color`

Browser support for accent-color: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021), and Safari 26.2 (Dec 2025).

`accent-color` is a progressive enhancement; browsers without it ignore the property and use their default UI colors. If it is unsupported and the bar must be styled, use the fully custom styling above.

### `revert-rule`

Baseline status for revert-rule: Newly available. It's been Baseline since 2026-09-14.
Supported by: Chrome 148 (May 2026), Edge 148 (May 2026), Firefox 150 (Apr 2026), and Safari 27 (Sep 2026).

Without `revert-rule` support, `animation: var(--progress-bar-animation, revert-rule)` with `--progress-bar-animation` unset becomes `animation-name: revert-rule` with a `0s` duration, a harmless no-op as long as no `@keyframes revert-rule` exists.
