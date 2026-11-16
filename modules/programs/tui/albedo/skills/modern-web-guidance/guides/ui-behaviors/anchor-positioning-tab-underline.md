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

Position the underline with inset properties and `anchor()` functions. Avoid `position-area` here, because it cannot be transitioned.

```css
ul::before {
  /* calc() offsets the underline slightly below the anchor. */
  inset-block-start: calc(anchor(bottom) + .1lh);
  inset-inline-start: anchor(left);
  inset-inline-end: anchor(right);
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

Browser support for Anchor positioning: Limited availability.
Supported by: Chrome 157 (Nov 2026), Edge 157 (Nov 2026), and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without anchor positioning, underline the active tab with a static `border-bottom`. It will not animate.

```css
ul li.active {
  @supports not (position-anchor: auto) {
    /* Use a color that suits the app theme. */
    border-bottom: .25lh var(--primary) solid;
  }
}
```
