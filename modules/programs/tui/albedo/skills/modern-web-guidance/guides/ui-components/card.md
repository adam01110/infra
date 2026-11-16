# Build a Card

A card groups one related piece of content or one choice. It is a visual pattern, not a fixed semantic or interaction model, so preserve the content's meaning and use the native interaction that matches its purpose.

## Guidelines

Choose the semantics of the content and of its interaction separately:

- Use `<article>` as the card root, whether or not it links anywhere.
- Use a native link for navigation. When the whole card is one destination, a single link may wrap the `<article>`, but only if the card contains no other interactive elements (`a`, `button`, `input`, `select`, `textarea`).
- Keep links and buttons for independent actions as separate native controls.
- When the card is a choice, use a radio button or checkbox with an associated `<label>`, or an `option` in a native `<select>`.

Keep media, title, supporting content, and actions in meaningful source order, and do not use CSS `order` to contradict it (see the `css-layout` guide).

## Implementation

Keep the markup minimal and let CSS selectors recognize each region; simple cards stay simple and richer cards stay possible. A card has up to four regions, in this source order, and any of them can be omitted. Regions are direct children of the card. Do not group them in wrappers such as `.card__body`, which prevent placing and styling regions by selector. A region with one element is that element itself (a lone paragraph is the `<p>`); use a wrapper only when a region holds several elements.

- Media: an `<img>`, `<picture>`, `<video>`, or `<svg>` as the first child. Add a `.media` class only to arbitrary hero content that is not one of those elements, and never wrap a plain `<img>` in a `.media` element.
- Header: a heading on its own. Use `<hgroup>` only when the heading has a subtitle or tagline, and `<header>` when the region holds more than a title, such as a byline or badge. When the card has a primary destination, put the link inside the heading.
- Content: a single `<p>`, `<ul>`, or `<dl>` stands on its own. When the content is several elements, such as multiple paragraphs or a paragraph plus a list, group them in one `<div>` so the region is a single grid item.
- Footer: a `<footer>` holding independent actions as native links and buttons. A "read more" link may share the heading link's URL, but give it a descriptive accessible name that starts with the visible text, using visually hidden text (for example `Read more<span> about poached eggs</span>`), because identical "read more" links are ambiguous in a screen reader's link list. Do not add other footer links that repeat the heading's URL.

The simplest card is an `<article>` containing a heading and a paragraph. Choose the link and action pattern that matches the card's behavior; see [Interaction models](#interaction-models).

For images or video that should fill a fixed-ratio area, set `aspect-ratio` and `object-fit: cover` on the `<img>` or `<video>` itself, so it fills the area without distortion (it may be cropped). Use a `.media` container's `aspect-ratio` only for other hero content. Otherwise keep the media's intrinsic ratio. Give informative images a suitable text alternative and decorative images `alt=""`.

### Adapt to available space

Base the layout on the card's available space, not the viewport. Make the card the size container (`container-type: inline-size`) and write `@container` rules for its children (media, text, actions). Do not size from the grid or list parent: the card's actual width depends on column count, gaps, and so on, which makes parent-based breakpoints noisy.

In a narrow container, stack the regions in source order. In a wide container, put the media in a side column beside the other regions, but only for cards that have media: scope those rules with `:has()` on the media child (for example `.card:has(> img)`) so the column definitions and `grid-column` placements never apply to a card without media. A card without media stays single-column at every width and must not reserve an empty media column.

### Align cards in a grid

When cards in a row should share region heights, use `subgrid`: make each card span four shared row tracks (media, header, content, footer) and place regions by element selector, treating everything that is not media, a heading, or a `<footer>` as content. A card that omits a region leaves its track empty, so its other regions still line up with neighboring cards. Each track holds one grid item, so when cards share tracks, wrap the content region in a `<div>` only when it has more than one element. Cards not aligned with siblings need neither the wrapper nor subgrid.

## Interaction models

### Content cards

Use an `<article>` as the card root and keep links and buttons as separate native controls.

### Single-destination cards

When the whole card is one destination with no independent actions, use one native link, which can wrap the `<article>`. Do not nest other links, buttons, or form controls inside it, and make any "read more" text a plain `<p>` or `<span>`. The link's accessible name is all of the card's text, so keep the content short. If the card has a lot of text or other actions, use the stretched-link pattern below so only the heading is the link.

```html
<a href="/recipes/poached-eggs">
  <article class="card">
    <h3>Poached eggs</h3>
    <p>Two poached eggs served on toasted sourdough.</p>
  </article>
</a>
```

### Clickable cards with independent actions

If clicking the card triggers an action rather than navigating, use a `<button>` instead of a link.

When a content card links to a primary destination, contains other interactive elements, and must be clickable as a whole:

- Put `.card-link` on exactly one link per card, the heading link. Footer and other links never get it; otherwise each would stretch its own overlay and the last one would capture the whole card.
- Link the title and stretch its pointer hit area across the card with `::after`:

  ```css
  .card:has(a.card-link) {
    position: relative;
  }

  .card a.card-link::after {
    content: "";
    position: absolute;
    inset: 0;
  }
  ```

- Lift the other interactive elements above the overlay with `position: relative; z-index: 1` so they stay operable. Select them by element type (such as `a, button`) rather than requiring an opt-in class. Do not put `z-index` on whole containers: they would then capture pointer events that trigger nothing.

  ```css
  .card:has(a.card-link) {
    /* x-button: example of a custom-element control */
    a:not(.card-link), button, input, x-button {
      position: relative;
      z-index: 1;
    }
  }
  ```

- Draw hover and focus styles on the card, not on the stretched link:

  ```css
  .card {
    a.card-link:focus-visible {
      outline: none; /* Drawn on the card instead. */
    }

    &:has(a.card-link:focus-visible) {
      /* Focus ring */
    }

    &:has(a.card-link:hover) {
      /* Hover styles */
    }
  }
  ```

### Choice cards

For cards that represent predefined choices, use `<label class="card">` with a checkbox or radio as a direct child.

Style the selected card with `:has(:checked)`. Do not change layout-affecting properties such as `border-width`, `padding`, or `font-weight` on selection, because the card and its neighbors would jump. Draw the emphasis with `outline`, `box-shadow`, or a transparent border that only changes color:

```css
.card {
  border: 2px solid transparent;

  &:has(> :checked) {
    border-color: var(--accent);
  }
}
```

A visible checkbox or radio is already a non-color indicator of selection, so a color change alone is enough. If the control is visually hidden (keep it focusable and in the accessibility tree; never use `display: none`), add a non-color indicator that does not affect layout, such as a check icon or a thicker `outline`.

When the choices belong in a dropdown picker whose options look like cards, use a native `<select>` with `appearance: base-select` and style `::picker(select)` and the `<option>` elements instead of replacing the select with `<div>` cards. See the `custom-select-picker-layouts` guide for details and fallbacks.
