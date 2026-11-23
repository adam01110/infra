# Anchor Positioning Tab Underline

In a tab menu, underline the active tab to show which one is selected. Anchor positioning lets the underline animate smoothly between tabs as the active tab changes. This does not work when changing the active tab loads a new page.

The same technique can draw an animated dot beside the active tab in a vertical tab bar.

Create the underline with a `::before` pseudo-element on the `<ul>` that contains the `<li>` elements. A pseudo-element is preferred because it keeps purely decorative elements out of the DOM.

```css
ul::before {
  content: '';
}
```

Make the active list item an anchor with a unique `anchor-name`, whose value starts with `--`. Only one element should carry the name at a time; if several do, the last one in tree order wins.

```css
li.active {
  anchor-name: --active;
}
```

Tether the underline to that anchor with a matching `position-anchor`, and make it `position: absolute`:

```css
ul::before {
  position: absolute;
  position-anchor: --active;
}
```

Position the underline with logical insets and `anchor(self-start)` or `anchor(self-end)`. Avoid `position-area` here, because it cannot be transitioned. Unlike `start` and `end`, the `self-*` keywords use the underline's own writing mode rather than its containing block's, so the anchor sides stay consistent with the logical insets when an RTL tab list sits inside an LTR page and no ancestor of the underline within the RTL section establishes a containing block.

```css
ul::before {
  /* A small gap between the indicator and the tab's block-end edge. */
  inset-block-start: calc(anchor(self-end) + .1lh);
  inset-inline-start: anchor(self-start);
  inset-inline-end: anchor(self-end);
}
```

Draw the underline with a border rather than a background or `box-shadow`: forced colors mode removes both of those, which would leave no indicator.

```css
ul::before {
  /* Use your project's indicator styles. */
  border-block-end: .25lh solid red;
}
```

Finally, transition the `inset` properties, inside a `prefers-reduced-motion` query so users who ask for less motion don't get the animation:

```css
ul::before {
  @media (prefers-reduced-motion: no-preference) {
    transition: inset .2s;
  }
}
```

The underline is only a visual indicator. It does not replace `aria-current="page"` or `aria-selected`; set the appropriate one so assistive technology gets the state too.

```html
<nav aria-label="Primary">
  <ul>
    <li class="active">
      <a href="/home" aria-current="page">Home</a>
    </li>
    <li>
      <a href="/about">About</a>
    </li>
  </ul>
</nav>
```

## Fallback strategies

### Anchor positioning

Baseline status for the css.types.anchor capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

Without the anchor positioning used here, hide the pseudo-element and draw a static `border-block-end` on the active tab. The border follows the tab's writing mode.

```css
@supports not (position-anchor: --active) {
  ul::before {
    content: none;
  }

  ul li.active {
    /* Use a color that suits the app theme. */
    border-block-end: .25lh solid currentColor;
  }
}
```

### Anchor positioning animations

Browser support for Anchor positioning animations and transitions: Limited availability.
Supported by: Chrome 125 (May 2024), Edge 125 (May 2024), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

Where the underline can be anchored but `anchor()` values cannot be transitioned, keep the anchored underline. It jumps straight to the new active tab when the selection changes.
