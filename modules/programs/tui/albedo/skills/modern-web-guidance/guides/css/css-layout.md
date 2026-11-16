# CSS Layouts and Responsive Design

## 1 Fundamentals

Let the browser's layout engine do the work where possible; it performs better. Use intrinsic sizing, logical properties and `aspect-ratio` before hardcoded dimensions or complicated media queries.

### 1.1 Which layout mode to use

Walk this list top to bottom and stop at the first match. Layouts can nest, and each decision is about the use case of that one container.

1. A simple row or column of items: flexbox. One-dimensional and content-first; content distributes along a single axis.
2. A nested element that must line up with its grandparent grid's tracks: subgrid. Two-dimensional and relationship-first; it inherits the parent's tracks so grandchildren align across siblings.
3. A complex page or component structure with rows and columns: grid. Two-dimensional and layout-first; you define the skeleton and content fills it.
4. A long flow of prose that should split into balanced columns: multi-column. One-dimensional, newspaper-style flow.
5. Items of varied heights that must pack tightly: grid with `grid-auto-flow: dense` today. Use native masonry ("grid lanes") only once it ships in your Baseline target (see section 8).
6. An element that floats above the page and stays tethered to a trigger, even across DOM boundaries or stacking contexts: anchor positioning, with `anchor-name` on the trigger and `position-anchor` on the overlay (see section 5).

### 1.2 Working principles

- Use logical properties (`inline-size`, `block-size`, `margin-inline`, `padding-block`, `inset-inline-start`) for layout dimensions and spacing. The `css` guide covers them fully.
- Content-first versus layout-first: flexbox when the items dictate the flow, grid when you define the skeleton first.
- Use the `place-*` shorthands (`place-content`, `place-items`, `place-self`) to align on both axes in one declaration.
- Prefer intrinsic sizing (`min-content`, `max-content`, `fit-content()`) and flexible tracks (`fr`, `minmax()`) over fixed `width`/`height`. They need fewer media queries and make layouts more resilient.
- Do not use `overflow: hidden` to mask layout problems; fix them at the source. For example, replaced elements such as `<canvas>`, `<img>`, `<svg>`, `<video>` and `<iframe>` are `display: inline` by default, which can add a gap in some layouts. Remove the gap with a block-level display value (`display: block`, `grid`, `flex` and so on) instead of clipping it.
- Use `aspect-ratio` to reserve space for media and prevent layout shift before assets load.

```css
.sidebar       { inline-size: max-content; }    /* Size to longest unbreakable token. */
.main-content  { inline-size: fit-content; }    /* Grow to available space, no further. */
.media         { aspect-ratio: 16 / 9; inline-size: 100%; block-size: auto; }
body.centered  { display: grid; place-content: center; min-block-size: 100dvb; }
```

For `calc-size()` and constraint-aware intrinsic sizing, see the `calculate-with-intrinsic-sizes` guide.

## 2 Flexbox

Browser support for flex-wrap: balance: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

One-dimensional layout: items flow along a single main axis and align on the cross axis. Use it for navbars, toolbars, rows of items and any single row or column distribution.

Practices:

- Create a context with `display: flex` and set the main axis with `flex-direction` (`row` by default).
- Use `flex-wrap: wrap` whenever overflow is possible. `nowrap` without `overflow: auto/hidden` spills out on narrow viewports.
- On wrapped rows of compact items (tag clouds, filter pills, button groups, navigation links), declare `flex-wrap: balance` after `flex-wrap: wrap` to spread items evenly across lines and avoid a single orphan on the last row. Browsers without support fall back to `wrap`.
- Use the `flex` shorthand `<grow> <shrink> <basis>` (such as `flex: 1 1 250px`) on items rather than setting `flex-grow`, `flex-shrink` and `flex-basis` separately.
- Use `gap` (or `row-gap`/`column-gap`) for spacing between items instead of child margins.
- Prefix positional alignment with `safe` (such as `align-items: safe center`) so focusable content is not clipped when the container is narrower than its content.
- Push a single item to the far end of the main axis with `margin-inline-start: auto` (or `margin-block-start: auto`).
- Override cross-axis alignment per item with `align-self`.
- Use `align-items` to center all items on the cross axis, `margin: auto` on a single item to center it on both axes independently, and `align-content` only when the container wraps and has extra space across rows.
- Set `min-inline-size: 0` (or `min-width: 0`) on flex items containing long unbreakable content (URLs, code, long strings). Flex items do not shrink below their content size by default, which causes overflow.

Pitfalls:

- `justify-self` does not work on flex items; it only applies in grid, block and absolutely positioned layouts. Use auto margins instead.
- Do not reorder interactive content with `order` or `flex-direction: *-reverse`. They change only the visual order; DOM order still drives sequential focus, so keyboard tab order stops matching what the user sees.
- `space-around` puts half-size gaps at the ends; `space-evenly` puts equal gaps before, between and after items.
- With `flex-direction: column` the axes flip: `justify-content` aligns on the block axis and `align-items` on the inline axis.
- Do not size the container and its children to fill each other; this commonly causes overflow and surprising results. Give one side a definite size.
- Do not set both `flex-basis` and `width`/`inline-size` on the same item. In a flex context `flex-basis` wins and `width` is ignored, so use `flex-basis` (or the `flex` shorthand) as the single source of truth for sizing flex items.

```css
.card-grid        { display: flex; flex-flow: row wrap; gap: 1rem; }
.card-item        { flex: 1 1 250px; }                  /* grow, shrink, basis */
.card-item-action { margin-inline-start: auto; }        /* Push to main-axis end. */
.toolbar          { display: flex; align-items: safe center; }
.tag-list         { display: flex; flex-wrap: wrap; flex-wrap: balance; gap: 0.5rem; }
```

## 3 Grid and subgrid

Baseline status for Subgrid: Widely available. It's been Baseline since 2023-09-15.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 71 (Dec 2019), and Safari 16 (Sep 2022).

Two-dimensional layout: define rows and columns explicitly, or let the engine derive them. Subgrid lets a nested grid inherit its parent's tracks so grandchildren align across siblings.

Choosing grid features:

- Do you know exactly how many columns you need?
  - Yes: use explicit tracks (`grid-template-columns: 200px 1fr`, `repeat(3, 1fr)` and so on).
    - Columns of different sizes (sidebar and main, a header spanning all columns): use `grid-template-areas` for named, readable regions.
    - Uniform columns, or items positioned purely by line number: use `repeat(N, ...)` or named lines.
  - No (responsive, unknown item count): use `repeat(auto-fit, minmax(min, 1fr))`.
    - Items on the last row should stretch to fill the remaining space: `auto-fit`.
    - Empty last-row tracks should keep their minimum size (preserving empty column slots): `auto-fill`.
- Do you need to place an item at a specific location?
  - Yes: use `grid-column: <start> / <end>` or `grid-area: <name>`.
  - No (it only spans several tracks and its flow position does not matter): use `grid-column: span <n>`.
- Do children need to inherit the parent grid's track sizes (aligning ragged edges across siblings)?
  - Yes: use subgrid on the affected axis.
    - Variable number of children per cell: subgrid one axis only, and use `grid-auto-rows`/`grid-auto-columns` for the other.
    - Fixed child count: subgrid on both axes is fine.
  - No: a standard grid without subgrid.

Practices:

- Create a context with `display: grid`.
- Use `grid-template-areas` for complex page-level layouts. Area names document themselves, and the declaration can be aligned in rows and columns for readability.
- Use `repeat(auto-fit, minmax(200px, 1fr))` for responsive card grids whose filled tracks stretch to fill the row, or `auto-fill` to keep empty repeated tracks at their minimum size.
- Use `fr` for proportional track distribution and `minmax(min, max)` for flexible but bounded tracks.
- Position items with `grid-column: span <n>` to span tracks, `grid-column: <start> / <end>` to place them at specific lines, or `grid-area: <name>` for named regions.
- Use subgrid (`grid-template-columns: subgrid` or `grid-template-rows: subgrid`) to fix ragged edges in card lists, so internal elements such as titles, metadata and calls to action line up across siblings.
- Precede a subgrid declaration with an explicit `grid-template-rows`/`-columns` declaration as a same-cascade fallback for older browsers.

Pitfalls:

- `auto-fit`/`auto-fill` track sizes come from the `repeat()` size argument, not from item content.
- Do not use `grid-auto-flow: dense` on interactive content. It packs items efficiently but reorders them visually, breaking DOM-order keyboard tab flow.
- Do not subgrid both axes when the child count varies: extra children land in the last track. Use `grid-auto-rows`/`grid-auto-columns` for the implicit axis instead.
- `justify-items`/`align-items` align item content within its track; `justify-content`/`align-content` align the tracks within the container. Using the wrong one silently has no effect.
- Do not use `repeat(auto-fit/auto-fill, ...)` without a definite `inline-size` on the container. Inside `display: inline-grid` or an unsized flex item, the container has no width to divide, so the track count is unpredictable.

### 3.1 Example: grid and subgrid

Page shell: `<main class="page-layout">` contains `<header>`, `<aside>`, a `<section class="card-grid">` with `<div class="card">` children, and `<footer>`.

```css
/* Align grid-template-areas in rows and columns for readability. */
.page-layout {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-areas:
    "header  header  header"
    "sidebar main    main"
    "footer  footer  footer";
  gap: 1.5rem;
}

header  { grid-area: header; }
aside   { grid-area: sidebar; }
footer  { grid-area: footer; }

.card-grid {
  grid-area: main;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  grid-auto-rows: auto 1fr; /* title block, body block, repeated for every row of cards */
  gap: 1rem;
}

.card {
  grid-row: span 2;
  display: grid;
  /* Same-cascade fallback: ignored when subgrid is supported. */
  grid-template-rows: auto 1fr;
  grid-template-rows: subgrid;
}
```

## 4 Container queries

Baseline status for Container queries (size): Widely available. It's been Baseline since 2023-02-14.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 110 (Feb 2023), and Safari 16 (Sep 2022).

Container queries test the size (or computed style) of an ancestor container rather than the viewport. Use container queries for component context, and media queries for global page layout and user preferences (`prefers-color-scheme`, `prefers-reduced-motion`).

Practices:

- Create a containment context on a wrapper with `container-type: inline-size` (width-only queries) or `container-type: size` (both axes); descendants can only query it after that.
- Name containers with `container-name` (or the `container` shorthand, `container: card / inline-size`) when nested contexts could collide.
- Use container query units for fluid type and spacing: `cqi`/`cqb` (logical inline/block), `cqw`/`cqh` (physical), `cqmin`/`cqmax`.
- Give the container a definite `block-size` whenever you use `container-type: size`. Size containment makes the container ignore its content, so without one it collapses.

Pitfalls:

- `block-size` is not a valid `container-type` value. Use `size` for both axes.
- Once `container-type` is set, children's intrinsic size no longer influences the container; it is sized as if it had no children.
- Container query units in descendants without a qualifying ancestor container fall back to the small viewport units (`svw`/`svh`).

### 4.1 Example: fluid typography with container query units

```css
.card-wrapper {
  container: card / inline-size; /* shorthand for container-name / container-type */
}

@container card (inline-size > 400px) {
  .content {
    display: flex;
    gap: 2rem;
  }
}

.title {
  /* Fluid type bound to the container width, not the viewport. */
  font-size: clamp(1rem, 4cqi, 2rem);
}
```

For component-driven responsive styling patterns, see the `size-aware-styling` and `fluid-scaling` guides.

## 5 Native overlays, anchor positioning and stacking contexts

Baseline status for <dialog>: Widely available. It's been Baseline since 2022-03-14.
Supported by: Chrome 37 (Aug 2014), Edge 79 (Jan 2020), Firefox 98 (Mar 2022), and Safari 15.4 (Mar 2022).

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

Browser support for Anchor positioning: Limited availability.
Supported by: Chrome 157 (Nov 2026), Edge 157 (Nov 2026), and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Choosing an overlay primitive:

- `popover` for transient, non-modal UI (flyouts, toasts, tooltips). It renders in the top layer, so no `z-index` management is needed.
- `<dialog>` with `.showModal()` for modal interactions that need focus trapping and an inert backdrop.
- Do not combine `popover` and `.showModal()` on the same element; they are mutually exclusive runtime states.

Anchor positioning (spatial layout of overlays):

- Use `position-area` (or `anchor()` in inset properties) and `anchor-size()` to position and size an overlay relative to its trigger.
- Use `position-try-fallbacks` so the browser repositions the overlay when it overflows the viewport. `flip-block, flip-inline, flip-block flip-inline` is a reasonable default; otherwise define fallbacks for the use case.
- Do not mix physical and logical keywords in one `position-area` value; pick one coordinate system.
- Feature-detect with `@supports (anchor-name: --x)` and provide an absolute-position fallback.

For implementation details, polyfill strategies and the `popover` value reference, see the `declarative-dialog-popover-control` and `position-aware-tooltips` guides. For anchor positioning in dropdowns, flyouts and tab indicators, see the `viewport-aware-dropdowns` and `anchor-positioning-tab-underline` guides.

## 6 Overflow tracking and layout stability

Baseline status for scrollbar-gutter: Newly available. It's been Baseline since 2024-12-11.
Supported by: Chrome 94 (Sep 2021), Edge 94 (Sep 2021), Firefox 97 (Feb 2022), and Safari 18.2 (Dec 2024).

line-clamp is not natively supported by any major browser yet.

Manage layout shifts, scrollbars and clipping predictably.

Practices:

- Use `overflow: auto` so scrollbars appear only when content actually overflows.
- Use `overflow: clip` to clip content without creating a scroll container, and allow controlled spillover with `overflow-clip-margin`.
- Use `scrollbar-gutter: stable` to reserve scrollbar space and prevent layout shift when content grows.
- On nested scroll regions (sidebars, modals, lists), use `overscroll-behavior: contain` (or `none`) to stop scroll chaining into the page. On intermediate scroll wrappers (such as swipe-to-reveal tracks), use `overscroll-behavior: chain` when excess scroll should pass to an ancestor scroller without a local rubber-band bounce.
- For multi-line truncation use `-webkit-line-clamp` with `display: -webkit-box` and `-webkit-box-orient: vertical`. Despite the prefix, this pattern is fully specified and not deprecated. Declare the unprefixed `line-clamp` shorthand alongside it; browsers that do not support it ignore it harmlessly.
- For text that must stay on one line (labels, table cells, file names), the `single-line-overflow` guide covers truncating it and revealing the full text on demand without UX friction.

Pitfalls:

- Do not use `overflow: scroll` where `auto` will do: `scroll` shows scrollbars even when there is nothing to scroll.
- Do not use `overflow: hidden` when you only want to clip: `hidden` creates a scroll container that can still be scrolled programmatically.

```css
.scrollable-list {
  max-block-size: 400px;
  overflow-y: auto;
  scrollbar-gutter: stable;       /* Reserve scrollbar space. */
  overscroll-behavior: contain;   /* No scroll chaining into the page. */
}

.snippet {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  line-clamp: 3;                  /* Ignored where unsupported. */
  overflow: clip;
}
```

For `overflow: clip` and `overflow-clip-margin` in depth, see the `overflow-clipping-control` guide. For nested scroll handoff with `overscroll-behavior: chain` in swipe-to-reveal UI, see the `swipe-to-reveal` guide. For scrollbar color, sizing and theming, see the `customize-scrollbar-color-and-thickness`, `dark-mode` and `adapt-scrollbar-to-contrast-preferences` guides.

## 7 Viewport mechanics and track distribution

Baseline status for Small, large, and dynamic viewport units: Widely available. It's been Baseline since 2022-12-05.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 101 (May 2022), and Safari 15.4 (Mar 2022).

- Use `dvh`/`dvw` for mobile layout containers that must account for browser UI moving (the URL bar collapsing and expanding).
- Do not use `100vw` for full-width layout: it includes the width of a classic vertical scrollbar, so it overflows horizontally. `100dvw` and `100svw` do the same. Use `100%` instead.

For the responsive design entry point (dynamic viewport units, reserving space for media, fluid typography), see the `responsive-design` guide.

## 8 Grid lanes (masonry)

Browser support for Grid lanes: Limited availability.
Supported by: Safari 27.2.
Unsupported in: Chrome, Edge, and Firefox.

The specification is being developed as "grid lanes" (such as `display: grid-lanes`); earlier experimental prototypes used `grid-template-rows: masonry`.

- For tight packing today, use grid with `grid-auto-flow: dense`, accepting that DOM order may not match visual order.
- For content-heavy masonry-like flow where items are document fragments rather than equal-weight cards, use multi-column (`columns: 3; column-gap: 1rem`).
- Treat native masonry only as a progressive enhancement behind an `@supports` check, and do not ship it as a hard requirement until your Baseline target supports it. Test the current syntax (`display: grid-lanes`) and, if you need the older prototypes, `grid-template-rows: masonry`.

```css
.gallery       { columns: 3 200px; column-gap: 1rem; }
.gallery > *   { break-inside: avoid; margin-block-end: 1rem; }

@supports (grid-template-rows: masonry) {
  .gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    grid-template-rows: masonry;
    gap: 1rem;
    columns: unset;
  }
  .gallery > * { margin-block-end: 0; }
}

@supports (display: grid-lanes) {
  .gallery {
    display: grid-lanes;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 1rem;
    columns: unset;
  }
  .gallery > * { margin-block-end: 0; }
}
```
