# Defer rendering heavy content

Pages with a lot of content, such as infinite scrolls, complex dashboards or dense articles, can render slowly at first and respond sluggishly afterwards. You can defer rendering work for content that is not visible yet, without breaking accessibility or user expectations, using the CSS `content-visibility` property and the HTML `hidden="until-found"` attribute. Each fits a different case.

## When to use which

| Scenario | Feature | Benefit |
| :--- | :--- | :--- |
| Below the fold (speed up initial load) | `content-visibility: auto` | The browser skips layout and paint for the container until it scrolls near the viewport, without slowing normal page load. |
| Toggled views (fast view switching) | `content-visibility: hidden` | Skips layout for hidden content but keeps its rendering state, so toggling is instant and causes no structural shifts. Better than `display: none` for this. |
| Searchable, deferred content (collapsible disclosures) | `hidden="until-found"` | Combines deferred rendering with find-in-page search; see the `search-hidden-content` guide. |

## `content-visibility: auto`

### Choosing elements

Choose the elements carefully:

- Target large, self-contained blocks that are entirely below the initial fold, such as cards in an infinite feed, trailing comments, or sections near the bottom of the page.
- Prefer elements with deep or complex internal DOM, where the savings are largest.
- Leave elements in the initial, above-the-fold viewport alone. There the browser must evaluate visibility before rendering them, which delays critical rendering instead of speeding it up.

### Steps

1. Identify heavy sections that are confirmed off-screen on initial load.
2. Apply `content-visibility: auto` to each.
3. Give each an estimated size with `contain-intrinsic-size`.

### `contain-intrinsic-size`

Always pair `content-visibility: auto` with `contain-intrinsic-size`. Without it, an off-screen element collapses to 0px height, which causes large layout shifts and scrollbar jumps as the user scrolls.

`contain-intrinsic-size` is a shorthand that sets a placeholder size. With the `auto` keyword the browser remembers the element's real size once it has rendered, and uses that instead of the placeholder if the element goes off-screen again.

```css
/* Apply only to elements outside the initial viewport. */
.heavy-section-deferred {
  content-visibility: auto;

  /* - 'auto' (optional) remembers the rendered size; it needs a <length>
       to use for the first render.
     - 'none' applies no intrinsic size on that axis (width here); it can be
       used for either width or height.
     - '150px' is the estimated height; any CSS <length> works. */
  contain-intrinsic-size: auto none auto 150px;
}
```

## `content-visibility: hidden`

1. Find heavy blocks that start hidden, such as extra rows in a large data table.
2. Apply `content-visibility: hidden`.
3. To reveal the element, change `content-visibility` to `visible` or `auto`.

```css
/* Hidden, but its rendering state is cached. */
.cached-view {
  content-visibility: hidden;
}

.cached-view.is-active {
  content-visibility: visible;
}
```

`content-visibility: hidden` removes the element and its children from the accessibility tree and from find-in-page search, so do not use it for content that must stay discoverable while hidden. For hidden content that native find-in-page should still reach, use `hidden="until-found"` as described in the `search-hidden-content` guide.

## Guidelines

- Use `contain-intrinsic-size` with `content-visibility: auto`. Without it, heights are recalculated during scroll, so the viewport jumps and glitches.
- Do not apply `content-visibility: auto` inside the initial viewport; it delays critical rendering.
- After applying `content-visibility: auto`, verify that keyboard users can reach everything in sequence. In some assistive technology setups, off-screen nodes with `content-visibility: auto` may be left out of the accessibility tree or the sequential navigation order until focus is moved inside them. Test linear navigation across off-screen boundaries with the keyboard alone.

## Browser support and fallback

Baseline status for content-visibility: Newly available. It's been Baseline since 2025-09-15.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 130 (Sep 2024), and Safari 26 (Sep 2025).

Browsers that do not support `content-visibility` ignore it. `content-visibility: auto` usually needs no fallback; unsupported browsers just miss the performance gain. But `content-visibility: hidden` elements would be fully visible there, so feature-detect and fall back to `display: none`:

```css
.inactive {
  display: none;
}

@supports (content-visibility: hidden) {
  .inactive {
    display: block;
    content-visibility: hidden;
  }
}
```
