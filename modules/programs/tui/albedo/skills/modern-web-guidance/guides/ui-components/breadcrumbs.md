# Build breadcrumbs

Breadcrumbs show where the user is in a site hierarchy and link to each ancestor page. They are not for switching between views of the same page (use tabs) or for site-wide navigation (use a navbar).

## 1. Semantics

- Wrap the trail in `<nav aria-label="Breadcrumbs">` containing an ordered list (`<ol>`) of `<li>` items, each holding an `<a>`. Order conveys the hierarchy, so use `ol`, not `ul`.
- If the page has several navigation landmarks, give each `<nav>` a unique label (here "Breadcrumbs").
- Mark the current page, the last item, as a link with `aria-current="page"`. Keep it a link rather than plain text so the trail's structure stays consistent.
- Dividers are decorative. Do not put them in the markup as text; generate them in CSS with empty alt text so they stay out of the accessibility tree:

```css
/* The empty alt text after the slash hides the divider from screen readers; li + li skips the first item. */
.breadcrumb > ol > li + li::before { content: "/" / ""; }
```

- A styled character (`/`, `›`, `>`) generated this way is the simplest divider. For an icon divider such as a chevron, render it the way the codebase renders icons and keep it decorative (see the `icons` guide).

## 2. Styling

- Lay out the `<ol>` with `display: flex; flex-wrap: wrap; align-items: center;` and a `gap`, and reset the list styles.
- Whatever the visual style, the trail must read as a path: each step visibly follows the previous one through a separator (slash or chevron) or an arrow or slant shape. Plain links with a separator are the default and safest choice.
- Keep the separator in chip-like styles. Pills, tags, or a segmented bar without one look like tabs or filters (items on the same level), not a hierarchy. Avoid plain text with no divider too, since order is then the only cue.
- Choose a visual variant:
  - Plain (slash or chevron): when the trail should stay visually quiet. Underline links at rest, or at least on hover and focus, so they never rely on color alone.
  - Bar: one bordered, segmented container with `overflow: clip`, when segments need large, clear touch targets. Keep a separator in each segment after the first.
    - For a joined pill, round the container (`border-radius: 999px`) and separate segments with a 1px `border-inline-start` and no gap. Round the container, not the individual links, so the clip handles the end caps, and give the end links the same end radius so an inset focus ring follows the rounded ends instead of being cut off.
    - Give the current page's `<li>` the same background as its link, so the chevron outside the link does not sit on the bar's background.
    - A bar must not wrap. When its segments no longer fit on one row, stack them in a column with a container query set just above the bar's natural width (measure it and round up, so it stacks only when it would not fit). In the column, use compact rows (smaller block padding) separated by a 1px `border-block-start`, turn the chevron to point down, and switch to a fixed `border-radius`, since `999px` becomes an oval once the bar grows tall.
  - Pills or tags: rounded or shaped links, when the trail is a prominent control, with a separator between them. For tags, show backgrounds only on hover.
- Style the current page distinctly (weight, color) and give non-current links a hover state.
- Custom palettes must meet WCAG AA contrast (4.5:1 for text) for links, hover, and the current page against their actual backgrounds (for example dark red on light gray). Keep a non-color cue, such as font weight, on the current page.
- Give `:focus-visible` a clear outline with at least 3:1 contrast against the background. Outlines get clipped on shaped or clipped segments, so use a negative `outline-offset` or a background or color change there.
- Lift the focused link above its neighbors (`position: relative; z-index: 1` on `a:focus-visible`). Overlapping neighbors (shaped segments) paint later and would cover an outside ring.
- Under `forced-colors: active`, backgrounds are removed, so restore borders and an underline on `[aria-current="page"]`. An icon divider drawn as a masked background also needs `forced-color-adjust: none` and a system color such as `CanvasText`, because forced colors replaces the background.

### Shaped segments

Use the simplest technique that produces the shape, and one shape per trail. The snippets below are alternatives, not meant to be combined.

- Selectors are illustrative; use your own hook (`.breadcrumb` here) and scope to `> ol > li > a`.
- Make the slant or point size responsive with `clamp()` and container units (`cqi`).
- Hover and current-page styles must change background or text color, not border color. Keep the focus style visually distinct from hover.
- Use a negative `outline-offset` for focus, since neighbors cover outside outlines.

#### Overlapping segments

Overlapping segments convey hierarchy even without a separator. Pull each segment under the previous one with a negative inline margin, and stack them in reverse source order so each earlier segment sits above the next. `sibling-index()` and `sibling-count()` do this without per-item rules:

```css
.breadcrumb > ol > li { position: relative; z-index: calc(sibling-count() - sibling-index()); }
/* The li is the stacking context, so lift the li (not the link) of the focused segment above all others. */
.breadcrumb > ol > li:has(> a:focus-visible) { z-index: calc(sibling-count() + 1); }
```

#### Simple irregular shapes (`corner-shape`)

Prefer `corner-shape: bevel` with an irregular `border-radius` for parallelograms and arrows. It has better browser support than `border-shape` and keeps normal border flexibility (per-side widths, colors, and styles), whereas `border-shape` needs explicit inner and outer shapes or is limited to a uniform stroke. Use logical corner properties so RTL mirrors automatically without a `:dir(rtl)` rule.

- Slant (`/`): bevel the start-start and end-end corners with a horizontal radius equal to the slant and a vertical radius of 100%.
- Arrow (`>`): bevel both end corners with a horizontal radius equal to the point and a vertical radius of 50%. Overlap the next segment so each tip covers the flat start edge of the next.

```css
.breadcrumb { --slant: clamp(.4rem, 2cqi, .75rem); }
.breadcrumb > ol, .breadcrumb > ol > li { gap: 0; }
.breadcrumb > ol > li > a {
  display: block;
  corner-shape: bevel;
  /* Extra inline padding equal to the slant keeps text out of the angled corners. */
  padding: .55rem calc(var(--slant) + .8rem);
}
/* The shape shows direction, so drop the separator. */
.breadcrumb > ol > li + li::before { content: none; }

/* Slant only: leans like "/" in LTR and "\" in RTL. */
.breadcrumb > ol > li > a {
  border-start-start-radius: var(--slant) 100%;
  border-end-end-radius: var(--slant) 100%;
}
/* Overlap by the slant minus a small visible gap (.25rem here) so the angled edges run parallel. */
.breadcrumb > ol > li + li { margin-inline-start: calc(.25rem - var(--slant)); }

/* Arrow only: tip on the end side; a contrasting segment border separates the overlapped edges. */
.breadcrumb > ol > li > a {
  border-start-end-radius: var(--slant) 50%;
  border-end-end-radius: var(--slant) 50%;
}
.breadcrumb > ol > li + li { margin-inline-start: calc(var(--slant) * -1); }
```

#### Fully irregular shapes (`border-shape`)

Use `border-shape` only for shapes `corner-shape` cannot make, such as a notched arrow with a concave leading edge. Define the polygon in a custom property (`--shape`, sized by a `--point` length you set like `--slant` above) and apply it with `border-shape` so borders and focus outlines follow the shape. Polygons are physically directional and logical properties do not flip `polygon()` coordinates, so each shape needs an explicit `:dir(rtl)` mirror.

```css
.breadcrumb > ol > li > a {
  --shape: polygon(0 0, calc(100% - var(--point)) 0, 100% 50%, calc(100% - var(--point)) 100%, 0 100%, var(--point) 50%);
  padding: .55rem calc(var(--point) + .8rem);
  border-shape: var(--shape);
}
/* The first item drops the inner notch vertex so its leading edge stays flat. */
.breadcrumb > ol > li:first-child > a {
  --shape: polygon(0 0, calc(100% - var(--point)) 0, 100% 50%, calc(100% - var(--point)) 100%, 0 100%);
}
/* Overlap by slightly less than --point so notch and tip interlock. */
.breadcrumb > ol > li + li { margin-inline-start: calc(.25rem - var(--point)); }
/* RTL mirror: in each x coordinate swap 0 with 100% and calc(100% - var(--point)) with var(--point). */
.breadcrumb:dir(rtl) > ol > li > a {
  --shape: polygon(100% 0, var(--point) 0, 0 50%, var(--point) 100%, 100% 100%, calc(100% - var(--point)) 50%);
}
.breadcrumb:dir(rtl) > ol > li:first-child > a {
  --shape: polygon(100% 0, var(--point) 0, 0 50%, var(--point) 100%, 100% 100%);
}
```

## 3. Optional UX enhancements

Implement these only when the trail needs them; the implementation is up to you.

- Sibling menus: when ancestors have meaningful siblings (for example documentation sections), let an ancestor expose its siblings in a menu. Keep the ancestor link navigating and put the toggle in a separate button, never inside the `<a>`. For menu mechanics, see the `menu` guide.
- Long trails: on narrow containers, collapse the middle of a trail with more than 3 items instead of letting it wrap, keeping the first item and the last two. Put the hidden links in a popup opened from a "…" button, and keep the full trail when script is unavailable.
- Long labels: keep every item on one line and never truncate the current page. The `single-line-overflow` guide covers truncating ancestor labels and revealing the full label on demand without friction.

## Fallback strategy

### `corner-shape`

Browser support for corner-shape: Limited availability.
Supported by: Chrome 139 (Aug 2025) and Edge 139 (Aug 2025).
Unsupported in: Firefox and Safari.

Rounded corners are not an acceptable fallback for slants and arrows. Use plain bordered rectangular segments with a separator (`li + li::before`) as the base style, and put everything in the shape snippets that makes the shape (`corner-shape`, the radii, the padding, the overlap margins, and `content: none` on the separator) inside `@supports (corner-shape: bevel)`, so unshaped segments neither overlap nor lose their separator.

### `sibling-index()` and `sibling-count()`

Baseline status for sibling-count() and sibling-index(): Newly available. It's been Baseline since 2026-08-18.
Supported by: Chrome 138 (Jun 2025), Edge 138 (Jun 2025), Firefox 154 (Aug 2026), and Safari 26.2 (Dec 2025).

Without support, later segments paint on top. Slants are unaffected, but arrow tips are hidden. Put the stacking rules in `@supports (z-index: sibling-index())`, and gate the arrow shape on both `corner-shape` and `sibling-index()` so it stays plain with a separator otherwise:

```css
@supports (corner-shape: bevel) and (z-index: sibling-index()) {
  /* Arrow-only shape, overlap, and stacking rules from above. */
}
```

### `border-shape`

Browser support for border-shape: Limited availability.
Supported by: Chrome 147 (Apr 2026) and Edge 147 (Apr 2026).
Unsupported in: Firefox and Safari.

- Use `clip-path: var(--shape)` with the same polygon as the base style, and enhance inside `@supports (border-shape: polygon(0 0, 100% 0, 100% 100%))` by setting `clip-path: none` and applying `border-shape`.
- `clip-path` clips borders and outlines, so under the fallback show focus with a color or background change plus a negative `outline-offset` instead of an outside outline.
- `clip-path` also cuts the slanted sides off a border, and `forced-colors: active` removes the background that draws the shape, so a clipped segment loses its outline. Under forced colors, drop the clip and use plain bordered segments with a text separator so the trail still reads as a path:

```css
@media (forced-colors: active) {
  /* Only without border-shape; with it, the border follows the shape and needs no change. */
  @supports not (border-shape: polygon(0 0, 100% 0, 100% 100%)) {
    .breadcrumb > ol > li > a { clip-path: none; border: 2px solid LinkText; }
    .breadcrumb > ol > li + li { margin-inline-start: 0; } /* Undo the shape overlap. */
    .breadcrumb > ol > li + li::before { content: "›" / ""; } /* The shape no longer shows direction. */
  }
}
```

The trail stays fully functional; only borders and outlines differ.
