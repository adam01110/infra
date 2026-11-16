# Prevent the Page Underneath a Modal Dialog from Scrolling

`showModal()` promotes a `<dialog>` to the top layer and makes the rest of the document inert. That blocks pointer clicks and keyboard focus on the page underneath, but not scrolling:

1. Scrolling with the pointer or a touch gesture over the `::backdrop` scrolls the page underneath.
2. Scrolling inside the `<dialog>` chains to the page once the dialog reaches its scroll boundary, or immediately if the dialog's content doesn't overflow.

Per the CSS Overscroll Behavior specification, `overscroll-behavior` applies to all scroll containers, including non-scrollable ones (elements with `overflow: hidden`, or `overflow: auto` whose content doesn't currently overflow). So CSS alone can stop the page scrolling: `overscroll-behavior: contain` on the `<dialog>`, plus `overflow: hidden` and `overscroll-behavior: contain` on `dialog::backdrop`.

## Implementation

1. Contain scroll chaining on the dialog. The user-agent stylesheet gives `<dialog>` `overflow: auto`, so it is already a scroll container. Apply `overscroll-behavior: contain` (or `none`) to `dialog:modal` (or `dialog`).
2. Make the backdrop a scroll container and contain it. `dialog::backdrop` defaults to `overflow: visible`, so it is not a scroll container and ignores `overscroll-behavior`. Set `overflow: hidden` on it to make it a non-scrollable scroll container, and add `overscroll-behavior: contain` so gestures over the backdrop don't reach the document.

```css
dialog:modal {
  /* Stops scrolling inside the modal from chaining to the page,
     even when its content doesn't overflow. */
  overscroll-behavior: contain;
}

dialog::backdrop {
  /* ::backdrop defaults to overflow: visible, which is not a scroll container.
     overflow: hidden makes it one, so overscroll-behavior applies. */
  overflow: hidden;
  overscroll-behavior: contain;
}
```

## Constraints

- Both declarations are needed. Without `overscroll-behavior: contain` on `dialog:modal` and on `dialog::backdrop`, gestures over the backdrop or inside the dialog still chain to the page.
- `dialog::backdrop` needs `overflow: hidden` (or `overflow: auto`). With the default `overflow: visible`, `overscroll-behavior` has no effect.
- Don't use `overflow: clip` or `overflow: visible` on `dialog::backdrop` or `dialog`. Neither creates a scroll container, so `overscroll-behavior` won't apply.
- Don't lock the background by setting `overflow: hidden` or `position: fixed` on `<html>` or `<body>` when the dialog opens. Changing root overflow removes the page scrollbar (a horizontal layout shift), can reset or jump the scroll position, and can break `position: sticky` elements on the page.

## Fallback strategies

Browser support for overscroll-behavior: Limited availability.
Supported by: Chrome 144 (Jan 2026), Edge 144 (Jan 2026), and Firefox 150 (Apr 2026).
Unsupported in: Safari.

This support data covers honoring `overscroll-behavior` on non-scrollable scroll containers. The property itself, on scroll containers whose content overflows, is supported by all major browsers. Honoring it on non-scrollable scroll containers is newer and cannot be feature-detected: `@supports (overscroll-behavior: contain)` and `CSS.supports('overscroll-behavior', 'contain')` return `true` in every modern browser, even those that only enforce it when content overflows. Don't use them for this.

Treat containment on non-scrollable scroll containers as a progressive enhancement:

- Where it is supported, page scrolling is fully prevented, both over `dialog::backdrop` and inside the `<dialog>` whether or not its content overflows.
- Where it isn't, `overscroll-behavior: contain` on the dialog still stops chaining whenever the dialog's own content overflows and scrolls, and `showModal()` still traps keyboard focus and makes the background inert.
- This is preferable to the legacy `overflow: hidden` or `position: fixed` on `<html>` or `<body>`, because it doesn't remove the root scrollbar, shift the layout horizontally, jump the scroll position or break `position: sticky` elements.
