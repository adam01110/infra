# Custom text decorations

Style underlines, overlines and strikethroughs with the native `text-decoration` properties rather than faking them with borders, background gradients or pseudo-elements. A native decoration follows the text across wrapped lines, tracks the font's metrics, skips glyph descenders and inherits through nested elements, so none of that needs reimplementing. Use the box-based techniques near the end of this guide only when the decoration must outline or wrap the text rather than run along it.

Text decorations apply to any text, not only links. Make sure underlined text that isn't a link can't be mistaken for one. When decorating a link, use a real `<a href>` pointing at the destination (add `target="_blank" rel="noopener"` to open a new tab), not `href="javascript:void(0)"` with a script handler. A real link keeps middle-click, copy-link and screen-reader behavior.

## Style the line

Set line, style, color and thickness with the `text-decoration` shorthand, and the gap from the text with `text-underline-offset`. Wrapping the selector in `:where()` gives the defaults zero specificity, so any later override wins without custom properties.

```css
:where(.decorated) {
  /* Thickness relative to font size (0.08em is an example) keeps the line in proportion
     on small and large text; max() keeps it at least 1px so it never disappears. */
  text-decoration: underline solid currentColor max(1px, 0.08em);
  /* em makes the gap scale with font size. 0.2em clears most descenders; example value. */
  text-underline-offset: 0.2em;
}

/* Example hover state: a softer line that firms up on hover and focus.
   The 50% mix and 0.12em thickness are example values. */
:where(.decorated) {
  text-decoration-color: color-mix(in srgb, currentColor, transparent);
}

:where(.decorated:is(:hover, :focus-visible)) {
  text-decoration-color: currentColor;
  text-decoration-thickness: max(1px, 0.12em);
}

/* Other lines use a different text-decoration-line with the same properties. */
.decorated-over    { text-decoration-line: overline; }
.decorated-through { text-decoration-line: line-through; }
```

`text-decoration-style` accepts `solid`, `double`, `dotted`, `dashed` and `wavy`. `text-underline-offset` applies only to underlines.

Starting points for the design:

- Thickness: about `0.06em` to `0.1em` for body text; thicker (`0.1em` to `0.15em`) for headings and emphasized states.
- Offset: about `0.15em` to `0.25em`. Dotted and wavy lines need a little more room than solid ones, so raise the offset for them.
- Color: `currentColor` keeps the line matched to the text. A softer mix of the text color that firms up on hover keeps long runs of links calm.
- Style: `solid` for links, `dotted` for terms and abbreviations, `wavy` for annotations such as errors.

## Control where the line is skipped

### Ink skipping

By default, underlines and overlines break around glyph parts that cross them, such as descenders. `text-decoration-skip-ink` chooses the behavior:

```css
.decorated {
  /* auto: skip ink for most scripts (default). none: draw straight through.
     all: also skip ink in scripts auto doesn't, such as Japanese or Chinese. */
  text-decoration-skip-ink: all;
}
```

- For Latin text keep `auto`, and don't declare it, since it is the default.
- Use `all` when the underline sits close enough to the baseline to cross ideographic glyphs, or when mixed-script text must look consistent.
- Use `none` for a very thick or deliberately decorative line, where gaps would look like breaks.

### Skip spaces

`text-decoration-skip-spaces` controls whether the line is drawn under spaces. The default, `start end`, leaves leading and trailing spaces undecorated.

```css
.decorated {
  /* Spaces collapse by default, leaving nothing to skip. Preserve them when leading
     or trailing spaces matter, such as in padded input values. */
  white-space: pre;
  /* none: decorate every space. all: skip every space, so each word is underlined separately.
     start | end | start end: skip only leading, trailing, or both. */
  text-decoration-skip-spaces: all;
}
```

Declare `text-decoration-skip-spaces` only when the decoration should visibly cover padding (`none`) or break between every word (`all`). Ordinary inline text, such as a link's text, has no leading or trailing spaces, so the declaration does nothing there.

## Trim or extend the line with an inset

`text-decoration-inset` moves the start and end of the line. A positive value pulls an end inward and a negative value pushes it outward. One value moves both ends; two values set start and end separately. Percentages refer to the inline size of the decorated box.

```css
/* Small insets soften the line's ends; larger ones read as a deliberately short line.
   Both values are examples. */
.trimmed  { text-decoration-inset: var(--deco-inset, 0.1em); }
.extended { text-decoration-inset: calc(var(--deco-inset, 0.1em) * -1); }
```

To reveal an underline on hover without a border or background gradient, trim the end by 100% and transition it back to 0:

```css
.reveal {
  text-decoration: underline; /* Always visible, including with reduced motion. */
}

/* Hide and animate the line only when the user hasn't asked for reduced motion. */
@media (prefers-reduced-motion: no-preference) {
  .reveal {
    /* Trim the end by the full inline size so the line starts at zero length. */
    text-decoration-inset: 0 100%;
    /* 150-300ms feels responsive without lag; ease-out starts quickly. Example values. */
    transition: text-decoration-inset var(--reveal-duration, 0.25s) ease-out;
  }

  /* :focus-visible gives keyboard users the same reveal as pointer users. */
  .reveal:is(:hover, :focus-visible) {
    text-decoration-inset: 0 0;
  }
}
```

## Draw a custom line with a pseudo-element

When the line must be a shape `text-decoration` can't draw, such as a squiggle, use a pseudo-element and reveal it by clipping. It needs no extra markup, so the link stays a plain `<a>`.

```html
<a class="draw" href="#">Hover to draw underline</a>
```

```css
.draw {
  position: relative;
  display: inline-block;
  color: inherit;
  text-decoration: none;
  padding-block-end: 0.4em; /* Room for the line below the text; example value. */
}

.draw::after {
  content: "";
  position: absolute;
  inset: auto 0 0 0;
  block-size: 0.4em; /* Squiggle height; example value. */
  pointer-events: none;
  border: var(--deco-thickness, max(1px, 0.08em)) solid var(--deco-color, currentColor);
  /* A single shape is stroked along its path, with the border width as the stroke. Example squiggle. */
  border-shape: shape(from 0% 50%,
    curve to 20% 50% with 5% 0% / 15% 100%,
    smooth to 40% 50% with 35% 100%,
    smooth to 60% 50% with 55% 100%,
    smooth to 80% 50% with 75% 100%,
    smooth to 100% 50% with 95% 100%);
}

/* Hide and animate the line only when the user hasn't asked for reduced motion;
   otherwise it stays fully drawn. */
@media (prefers-reduced-motion: no-preference) {
  .draw::after {
    /* Clip the line away from the right edge. Negative block insets keep the
       stroke from being cut off vertically. */
    clip-path: inset(-1em 100% -1em 0);
    /* Slightly slower than a hover reveal, so it reads as drawing; example duration. */
    transition: clip-path var(--draw-duration, 0.6s) ease-out;
  }

  .draw:is(:hover, :focus-visible)::after {
    clip-path: inset(-1em 0 -1em 0); /* Fully drawn. */
  }
}
```

## Outline text with a box instead

Two box properties decorate text by outlining it rather than running a line along it. Give the text padding so the outline doesn't touch it.

```css
/* Gradient outline with a see-through middle. */
.ring {
  padding: 0.2em 0.75em; /* Example values: enough room that the outline doesn't touch the text. */
  /* The border width is the outline thickness: relative to font size, with a 2px
     minimum so it stays visible on small text. Example value. */
  border: var(--ring-width, max(2px, 0.12em)) solid transparent;
  background: linear-gradient(135deg, var(--ring-start, #2563eb), var(--ring-end, #db2777)) border-box;
  /* Paint the background only under the border, so the inside stays transparent. */
  background-clip: border-area;
}

/* A border following a shape border-radius can't draw, such as a tag with a pointed end. */
.tag {
  padding: 0.2em 1.5em 0.2em 0.9em; /* Example values: extra room at the point so text isn't clipped. */
  border: var(--shape-stroke, max(2px, 0.08em)) solid var(--shape-color, currentColor); /* Example stroke width. */
  /* One shape is stroked along its path; two shapes fill the area between them.
     This polygon is an example; use shape() for curves. */
  border-shape: polygon(0 0, 85% 0, 100% 50%, 85% 100%, 0 100%);
}
```

`border-shape` replaces only the border. The background is still the rectangular box, so don't rely on it to fill a shape.

When only the corners need a different shape (a beveled, scooped or notched label), use `corner-shape` with `border-radius` instead. The background and border both follow the corners, and unsupported browsers fall back to ordinary rounded corners.

```css
.label {
  padding: 0.2em 0.9em; /* Example values. */
  border: var(--shape-stroke, max(2px, 0.08em)) solid var(--shape-color, currentColor);
  border-radius: 0.6em; /* Corner size; example value. */
  corner-shape: bevel; /* round (default) | scoop | bevel | notch | square | squircle */
}
```

## Choose a technique

- `text-decoration` (line, ink skipping, spaces, inset): the default choice, for a line that runs along the text, wraps with it and follows its font metrics.
- Pseudo-element with `border-shape` and `clip-path`: for a custom-shaped line or a draw-on animation. Use it only when `text-decoration-style` can't produce the look, because it needs extra positioning.
- `background-clip: border-area`: for a gradient outline. Use plain `border-color` when a solid outline is enough.
- `corner-shape`: when only the corners need a different shape, such as beveled, scooped or notched. Pair it with `border-radius`, which sets the corner size.
- `border-shape`: when the outline needs a shape `border-radius` can't draw, such as a tag or arrow. Use `border-radius` when rounded corners are enough.
- Inset hover reveal: worth adding when a link needs a hover affordance beyond a color change. Skip it for non-interactive text.

## Fallback strategies

Each fallback keeps the text readable and the core decoration intact. Decide by the user's Baseline target: if it includes browsers without a property, apply the matching fallback.

### Ink skipping `all`

Baseline status for text-decoration-skip-ink: all: Newly available. It's been Baseline since 2026-05-07.
Supported by: Chrome 148 (May 2026), Edge 148 (May 2026), Firefox 75 (Apr 2020), and Safari 15.4 (Mar 2022).

Where `text-decoration-skip-ink: all` is unsupported, the declaration is ignored and the browser keeps `auto`. Latin descenders are still skipped; only scripts that `auto` doesn't cover, such as Japanese, lose ink skipping. This degrades gracefully and needs no extra code.

### Skip spaces

Where `text-decoration-skip-spaces` is unsupported, the browser uses its default handling of spaces, and the line is drawn under any spaces it doesn't skip. This degrades gracefully.

### Inset

Where `text-decoration-inset` is unsupported, the declaration is ignored: the link keeps its normal, fully visible underline and the transition has nothing to animate. Only the hover reveal is lost, so no `@supports` check is needed.

### Border area

Browser support for background-clip: border-area: Limited availability.
Supported by: Chrome 150 (Jun 2026), Edge 150 (Jul 2026), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Where `background-clip: border-area` is unsupported, the declaration is ignored and the background paints under the whole border box, filling the text area instead of only the outline. When the gradient is part of the design, reproduce it rather than settling for a plain solid border, and apply `background-clip: border-area` only inside `@supports`.

If the element's background is a known flat color, use an opaque layer: paint the surface color over the padding box and the gradient under the border box, so the gradient shows only through the transparent border.

```css
.ring {
  border: var(--ring-width, max(2px, 0.12em)) solid transparent; /* Example width. */
  /* Fallback: an opaque surface layer hides the gradient inside the border. */
  background:
    linear-gradient(var(--surface, canvas) 0 100%) padding-box,
    linear-gradient(135deg, var(--ring-start, #2563eb), var(--ring-end, #db2777)) border-box;
}

@supports (background-clip: border-area) {
  .ring {
    background: linear-gradient(135deg, var(--ring-start, #2563eb), var(--ring-end, #db2777)) border-box;
    background-clip: border-area; /* The inside stays transparent. */
  }
}
```

If the inside must stay transparent, use a masked pseudo-element: it carries the gradient, and a mask cuts away everything except its padding ring.

```css
@supports not (background-clip: border-area) {
  .ring {
    position: relative;
    border-color: transparent;
    background: none; /* Drop the base gradient, which would fill the whole box here. */
  }

  .ring::before {
    content: "";
    position: absolute;
    inset: calc(var(--ring-width, max(2px, 0.12em)) * -1); /* Cover the border box. */
    padding: var(--ring-width, max(2px, 0.12em)); /* Ring thickness. */
    border-radius: inherit;
    background: linear-gradient(135deg, var(--ring-start, #2563eb), var(--ring-end, #db2777));
    /* Keep only the area between the content box and the border box. */
    mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
    mask-composite: exclude;
    pointer-events: none;
  }
}
```

### Border shape

Browser support for border-shape: Limited availability.
Supported by: Chrome 147 (Apr 2026) and Edge 147 (Apr 2026).
Unsupported in: Firefox and Safari.

Where `border-shape` is unsupported, the declaration is ignored and the element keeps its rectangular border. A rounded rectangle is an acceptable fallback only when the shape is purely decorative. When the shape carries meaning, such as a tag, arrow or callout, reproduce it as closely as possible and apply `border-shape` only inside `@supports`.

Draw the outline with a clipped pseudo-element. Keep a transparent border so the box has the same size as in the supported case, fill the pseudo-element with the outline color, and cut it into a ring with an `evenodd` `clip-path`: the outer shape, then the same shape inset by the stroke width.

```css
.tag {
  --stroke: max(2px, 0.08em); /* Example stroke width. */
  position: relative;
  padding: 0.2em 1.5em 0.2em 0.9em; /* Example values. */
  border: var(--stroke) solid transparent;
}

@supports not (border-shape: circle(50%)) {
  .tag::before {
    content: "";
    position: absolute;
    inset: calc(var(--stroke) * -1); /* Cover the border box. */
    background: var(--shape-color, currentColor);
    pointer-events: none;
    /* Outer shape, then the inner shape inset by the stroke. The inner points are
       approximate on diagonal edges, so the stroke looks slightly thinner there. */
    clip-path: polygon(evenodd,
      0 0, 85% 0, 100% 50%, 85% 100%, 0 100%,
      var(--stroke) var(--stroke),
      calc(85% - var(--stroke)) var(--stroke),
      calc(100% - var(--stroke) * 2) 50%,
      calc(85% - var(--stroke)) calc(100% - var(--stroke)),
      var(--stroke) calc(100% - var(--stroke)));
  }
}

@supports (border-shape: circle(50%)) {
  .tag {
    border-color: var(--shape-color, currentColor);
    border-shape: polygon(0 0, 85% 0, 100% 50%, 85% 100%, 0 100%);
  }
}
```

For a filled shape rather than an outline, put `clip-path: polygon(...)` with the same points directly on the element.

For the pseudo-element underline, draw a straight line with `border-block-end` on `.draw::after`, and apply the `block-size`, `border` and `border-shape` squiggle only inside `@supports (border-shape: circle(50%))`. The line is straight but still draws on, because the `clip-path` animation doesn't depend on the shape.

`clip-path` also clips focus rings and `box-shadow`. Don't rely on an outline on the clipped element to show focus; style `:focus-visible` with a color or background change instead.
