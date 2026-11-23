# Context Menu

A context menu gives quick access to actions for a specific item or region. In a list of items, a single button opens it. It can also be a secondary interaction, opened by right-clicking or (on some platforms) long-pressing, which keeps the primary click or touch action free for selection, navigation or drag and drop.

- Right-click plus a visible menu button (recommended): needed when the menu is the main way to reach those actions in the current view. It supports touch, keyboard and discoverability.
- Visible menu button only: use when right-click behavior is not needed.

Right-click alone is accessible only when the item can be selected first and the same actions are available elsewhere, for example in a persistent toolbar.

## Implementation

### 1. Shared foundation

Build the menu content in a popover by following the `menu` guide.

Do not reuse one context menu across several items; give each its own menu with a unique ID.

```html
<!-- The menu container -->
<div popover id="context-menu">
  <div focusgroup="menu nomemory" aria-label="Context Menu">
    <button type="button">Edit</button>
    <button type="button">Share</button>
    <button type="button">Delete</button>
  </div>
</div>
```

Use CSS anchor positioning to align the popover with its anchor and keep it from overflowing the viewport.

```css
[popover] {
  margin: 0;
  inset: auto;
  /* Align the menu relative to the anchor. */
  position-area: block-end span-inline-end;
  position-try: flip-inline, flip-block, flip-start;
}
```

### 2. Method A: right-click trigger (cursor-anchored)

To open the menu exactly at the cursor, use an invisible anchor element that script moves to the pointer on right-click. Some platforms (not iOS Safari) also fire this on a long press, but that is not universal. Put the anchor inside the element that triggers the context menu, immediately before the visible button.

```html
<span class="menu-anchor"></span>
```

```css
/* An invisible anchor that follows the cursor. */
.menu-anchor {
  position: fixed;
  inline-size: 0;
  block-size: 0;
}
```

Listen for `contextmenu` to suppress the browser's own menu, and use `pointerup` to read the coordinates and open the popover. Move focus to the first enabled button.

```js
const card = document.querySelector('.card');
const menuAnchor = card.querySelector('.menu-anchor');
const popover = card.querySelector('#context-menu');

function openContextMenu(e) {
  // Physical properties, to match clientX and clientY.
  menuAnchor.style.left = `${e.clientX}px`;
  menuAnchor.style.top = `${e.clientY}px`;

  // showPopover({ source }) establishes the implicit anchor; it is required here.
  popover.showPopover({ source: menuAnchor });
  // The popover's `toggle` listener sees the menu in `enterOnOpen` and focuses its first button.
  enterOnOpen.add(popover);
}

card.addEventListener('contextmenu', (e) => {
  // Suppress the browser's default context menu.
  e.preventDefault();
});

card.addEventListener('pointerup', (e) => {
  // Button 2 is the secondary (right) mouse button; Ctrl+click opens context menus on macOS.
  if (!(e.button === 2 || e.ctrlKey)) return;
  openContextMenu(e);
});
```

### 3. Method B: visible menu button (element-anchored)

For touch users and general discoverability, add a visible button that toggles the same popover, declared with `command` and `commandfor`. Place the popover element immediately after this `<button>`.

Size the button for WCAG 2.5.8 Target Size (Minimum): at least 24 by 24 CSS pixels when it sits directly on top of interactive content. A smaller button is allowed only when it is not on top of interactive content and a 24 CSS pixel circle centred on it overlaps no other target or the 24 pixel circle of another undersized target.

Keep the button always visible, which matters most for people who use voice control or have cognitive disabilities. Do not show it only on hover or focus.

```html
<button type="button"
  command="toggle-popover"
  commandfor="context-menu"
  aria-haspopup="menu" aria-expanded="false"
  aria-label="Actions for item 1">
  <!-- Visual trigger, such as a three-dots icon -->
</button>
```

Like `source` in `showPopover({ source })`, the `command` attribute makes the button the popover's implicit anchor, so no `anchor-name` or `position-anchor` is needed. In a list, include the item's name in the button's `aria-label` so every trigger and its menu get a distinct accessible name. Keep `aria-expanded` in sync with the popover's state.

### 4. Telling the two methods apart

To vary the menu by trigger, for instance to adjust its position, read `event.source` in the popover's `beforetoggle` event and set an attribute to style against.

```js
popover.addEventListener('beforetoggle', (event) => {
  if (event.newState === 'open') {
    popover.setAttribute('source', event.source?.tagName ?? '');
  }
});
```

```css
[popover][source="button" i] {
  position-area: block-end span-inline-start;
}
```

## Fallbacks

### Popover

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

Popover is mostly progressive enhancement, but its defining behaviors (top-layer promotion, light dismiss, and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you prefer not to ship one.

To polyfill, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) only when native support is missing, detected by the `popover` property on `HTMLElement.prototype`. With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, for example `https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js`.

Polyfill caveats:

- Do not use the `popover` IDL property in code that may run before the polyfill has loaded. The value is not mirrored to the attribute, the polyfill does not pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill cannot define the real `:popover-open` pseudo-class, so it adds a `.\:popover-open` class. Combine the two with `:is()` or `:where()`; in a plain selector list, browsers without `:popover-open` discard the whole rule.

```css
[popover]:is(:popover-open, .\:popover-open) {
  display: block;
}
```

Until the polyfill loads, unsupported browsers render popovers as ordinary visible content. Hide them with CSS in the meantime:

```css
@supports not selector(:popover-open) {
  [popover]:not(.\:popover-open) {
    display: none;
  }
}
```

### Invoker commands

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

If your Baseline target lacks invoker commands, use `popovertarget`:

```html
<button type="button"
  popovertarget="context-menu"
  aria-haspopup="menu" aria-expanded="false"
  aria-label="Actions for item 1">
  <!-- Visual trigger, such as a three-dots icon -->
</button>
```

### Anchor positioning and `ToggleEvent.source`

Baseline status for the css.properties.position-area capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

If your Baseline target lacks CSS anchor positioning, compute the popover's insets in script: at the click position for a right-click, and at the button's block-end edge for a button click. This also lets placement differ by trigger, but it does not handle overflow.

```js
const supportsAnchors = CSS.supports('anchor-name: --a');

function openContextMenu(event) {
  const x = event.clientX;
  const y = event.clientY;
  if (supportsAnchors) {
    menuAnchor.style.left = `${x}px`;
    menuAnchor.style.top = `${y}px`;
  } else {
    popover.style.removeProperty('right');
    popover.style.left = `${x}px`;
    popover.style.top = `${y}px`;
  }

  enterOnOpen.add(popover);
  popover.showPopover({ source: menuAnchor });
}

buttonTrigger.addEventListener('click', (event) => {
  const menu = menuFor(buttonTrigger);
  if (!menu || supportsAnchors) return;
  // Without anchor positioning, place the menu under the button's inline-end edge.
  const { right, bottom } = buttonTrigger.getBoundingClientRect();
  menu.style.removeProperty('left');
  menu.style.right = `${document.documentElement.clientWidth - right}px`;
  menu.style.top = `${bottom}px`;
});
```

Baseline status for ToggleEvent source: Newly available. It's been Baseline since 2026-05-11.
Supported by: Chrome 140 (Sep 2025), Edge 140 (Sep 2025), Firefox 145 (Nov 2025), and Safari 26.5 (May 2026).

Where anchor positioning works but `ToggleEvent.source` does not, the `beforetoggle` attribute above cannot be set. Set `position-area` from each trigger instead:

```js
const supportsToggleSource = 'source' in ToggleEvent.prototype;

function openContextMenu(event) {
  if (supportsAnchors && !supportsToggleSource) {
    popover.style.setProperty('position-area', 'block-end span-inline-end');
  }
  // ...
}

buttonTrigger.addEventListener('click', () => {
  const menu = menuFor(buttonTrigger);
  if (!menu) return;
  if (supportsAnchors && !supportsToggleSource) {
    menu.style.setProperty('position-area', 'block-end span-inline-start');
  }
  // ...
});
```

### focusgroup

Browser support for focusgroup: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Load `@microsoft/focusgroup-polyfill` only when native support is missing:

```js
if (!Object.hasOwn(HTMLElement.prototype, 'focusGroup')) {
  const { polyfill } = await import('@microsoft/focusgroup-polyfill');
  polyfill();
}
```

- Use the `focusgroup` and `focusgroupstart` attributes, not the `focusGroup` property, which the polyfill does not add.
- The polyfill does not notice items hidden or shown later: add `focusgroup="none"` to an item while it is hidden.
