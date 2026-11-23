# Build an application menu bar

An application menu bar (File, Edit, View, Help) is a row of menus that behaves as one widget: one `Tab` stop, `ArrowLeft` and `ArrowRight` move between menus, focusing a menu title shows its menu, and once one menu is open, pointing at another title switches to it. Use it for an application command bar.

Do not use it for site navigation (a short list of links users `Tab` through) or for a few unrelated menu buttons in a toolbar or page header. Those are standalone menus: each trigger is its own `Tab` stop, looks like a separate button, and has none of the bar behavior below.

Each menu in the bar is a complete popup menu: invoker-triggered popover, nested focusgroup, submenus, separators, checkable items, positioning, pointer handling, and fallbacks. Build them as described in the `menu` guide; this guide covers only what the bar adds on top of each menu.

## Structure

* Put `role="menubar"` with an `aria-label` on the container of the top-level triggers, never on a popover. Each top-level trigger is a direct child of the menubar, immediately followed by its popover.
* Give each top-level trigger `role="menuitem"` and an accessible name that describes its purpose.
* Style the bar as one continuous strip with no gaps or borders between triggers. Visually separate buttons signal one `Tab` stop each; a continuous bar signals one widget.
* Give the trigger with `aria-expanded="true"` a visible active style so users can tell which menu is open or previewed.

```html
<div role="menubar" aria-label="Document commands">
  <!-- Only the active trigger is tabbable; the script moves tabindex with ArrowLeft and ArrowRight. -->
  <button id="file-trigger" type="button" aria-haspopup="menu" aria-expanded="false"
    commandfor="file-menu" command="toggle-popover" role="menuitem">File</button>
  <div id="file-menu" popover="auto">
    <div focusgroup="menu nomemory" aria-labelledby="file-trigger">
      <!-- Items and submenus as in the `menu` guide -->
    </div>
  </div>

  <button id="edit-trigger" type="button" aria-haspopup="menu" aria-expanded="false"
    commandfor="edit-menu" command="toggle-popover" role="menuitem" tabindex="-1">Edit</button>
  <div id="edit-menu" popover="auto">
    <div focusgroup="menu nomemory" aria-labelledby="edit-trigger">
      <!-- … -->
    </div>
  </div>
</div>
```

## Keyboard and focus

The `menu` guide's keyboard model applies inside every menu. The bar adds, on top of it:

* One tab stop. `Tab` enters at the first top-level trigger. `ArrowLeft` and `ArrowRight` move between top-level triggers and wrap at either end. `Home` and `End` on a trigger enter its menu at the first or last item.
  * Which trigger `Tab` returns to: the APG allows either the first trigger or the last one used. This guide enters at the first, but because `ArrowLeft` and `ArrowRight` move the tab stop, `Shift`+`Tab` after keyboard navigation returns to the last trigger reached. Pointer use does not move the tab stop, so the same sequence can land on a different trigger. Either behavior is acceptable; pick one and keep it consistent.
* Preview. Focusing a top-level trigger shows its menu and sets `aria-expanded="true"`. Focus stays on the trigger, and no item is focused. Blurring the trigger closes a preview-only menu.
* `Enter` and `Space` on a preview. They close the preview and keep focus on the trigger. The native `toggle-popover` action handles this, so the script must not intercept these keys.
* `ArrowDown` on a preview. Converts it to an open menu and focuses the first item.
* `ArrowLeft` or `ArrowRight` in an open top-level menu. Closes it and previews the adjacent menu with focus on its trigger, wrapping at either end. `ArrowDown` then enters it. Left and Right never land inside a menu.
* `ArrowRight` on a submenu item without a child submenu. Closes the hierarchy and previews the next top-level menu while focus stays on its trigger. `ArrowDown` then enters it.
* Pointer over another top-level trigger while a menu is open. Closes it and previews the hovered one, focusing its trigger without a focus ring. With nothing open, hover does nothing.
* `Tab`. Leaves the bar from a trigger or from inside any menu, closing every open menu.

## Implementing the bar

1. Roving tabindex. Set `tabindex="0"` on the first top-level trigger and `-1` on the rest. When `ArrowLeft` or `ArrowRight` moves to another trigger, move the `0` with it. Do not put the triggers in a focusgroup: the bar needs preview on focus and menu switching, which focusgroup does not provide.
2. Preview on focus. A top-level trigger's `focus` handler calls `menu.showPopover({ source: trigger })` so the menu anchors to it. Ignore focus returning from inside the trigger's own menu, or from another window (set a flag on window `blur` and clear it a tick after window `focus`; otherwise switching apps reopens the last menu). Hide a previewed menu on `blur` unless focus moved into it.
3. Moving between menus. One function closes every open top-level menu, moves the tabindex, and focuses the target trigger; preview on focus does the rest. Call it from `ArrowLeft`/`ArrowRight` on a trigger, from the same keys inside an open top-level menu, and from `ArrowRight` on a submenu item with no child submenu.

The helpers used here and in the fallbacks (`menuFor`, `isOpen`, `enterOnOpen`, `pointerTrigger`) are the ones defined in the `menu` guide.

```js
// Direct children only: submenu triggers live inside the bar's nested popovers.
const rootTriggers = [...document.querySelectorAll('[role="menubar"] > [commandfor]')];

// Left/Right always land on the adjacent trigger as a preview, never inside its menu, as in
// native menubars. ArrowDown then enters.
function moveToRootTrigger(from, direction) {
  const next = rootTriggers[(rootTriggers.indexOf(from) + direction + rootTriggers.length) % rootTriggers.length];
  rootTriggers.forEach(trigger => { trigger.tabIndex = trigger === next ? 0 : -1; });
  rootTriggers.map(menuFor).filter(isOpen).forEach(menu => menu.hidePopover());
  next.focus({ preventScroll: true }); // Focusing the trigger previews its menu.
}
```

4. Hover switches open menus. On `pointerenter` of a top-level trigger while another top-level menu is open, hide that menu and focus the hovered trigger without a focus ring (`focus({ focusVisible: false })`); preview on focus then shows its menu. With nothing open, do nothing. Keep `:hover` styles on top-level triggers: with nothing open they are plain button feedback, and with a menu open the hover switches menus and focus follows.
5. Entering from a trigger. `ArrowDown` on a previewed trigger focuses the first item; on a closed trigger it marks the menu to be entered and calls `trigger.click()`, so the invoker stays the only open path. `Home` and `End` preview the menu if needed, then focus its first or last enabled item.
6. Outside focus. The `document` `focusin` listener that closes every menu must treat the menubar as inside the menu system, or `Tab` landing on a trigger closes the menu it just previewed.
7. Instant switching. Native menubars switch between open menus without animation. If menus animate, disable the transition while another menu in the bar is already open:

```css
@media (prefers-reduced-motion: no-preference) {
  /* Switching between open menubar menus is instant, as in native menubars. */
  [role="menubar"]:has(> [popover]:popover-open) > [popover] {
    transition: none;
  }
}
```

## Verify before finishing

Test the result in a browser with a real keyboard and mouse, and fix and re-test anything that fails. Check the menus themselves against the `menu` guide's list.

* One tab stop: `Tab` lands on the first trigger once and previews its menu; `Shift`+`Tab` from the page content returns to the bar once, not to every trigger.
* Arrow keys: `ArrowRight` and `ArrowLeft` on a trigger preview the adjacent menu, wrapping, without focusing an item; `ArrowDown` enters; inside an open menu, `ArrowRight` and `ArrowLeft` switch to the adjacent menu as a preview.
* Hover: With File open, pointing at Edit switches to it instantly; with nothing open, pointing at a trigger does nothing.
* Window focus: Switching to another window and back does not reopen the last menu.
* Leaving: `Tab` from a trigger or from inside a menu closes everything and leaves the bar.

## Fallback strategies

The bar itself is roving tabindex, focus handling, and `showPopover()`, all widely supported script. Beyond the menus, the bar only adds the `[role="menubar"]:has(> [popover]:popover-open)` rule that disables the transition while switching; without `:has()`, switching animates like a plain open.

The menus in the bar use focusgroup, popovers, invoker commands, anchor positioning, and `:has()`. Their fallbacks follow.

### focusgroup

Browser support for focusgroup: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Keep `focusgroup="menu nomemory"` in the markup. If `'focusGroup' in HTMLElement.prototype` is false, handle `ArrowUp`, `ArrowDown`, `Home`, and `End` in script, set `role="menu"` on each menu container, and `role="menuitem"` on buttons with no role; leave checkable items, `<hr>`, and `role="group"` alone. Never install this fallback when native focusgroup is present. Submenu preview, open, and close are author script either way.

```js
if (!('focusGroup' in HTMLElement.prototype)) {
  document.querySelectorAll('[focusgroup~="menu"]').forEach(group => {
    group.setAttribute('role', 'menu');
    group.querySelectorAll('button:not([role])').forEach(item => {
      item.setAttribute('role', 'menuitem');
    });
    group.addEventListener('keydown', event => {
      if (!['ArrowDown', 'ArrowUp', 'Home', 'End'].includes(event.key)) return;
      // Own items only: a nested submenu has its own focusgroup, a role="group" wrapper does not.
      const items = [...group.querySelectorAll('button')]
        .filter(item => item.closest('[focusgroup]') === group)
        .filter(item => !item.disabled && item.getAttribute('aria-disabled') !== 'true');
      const current = items.indexOf(document.activeElement);
      if (current < 0) return;
      const next = event.key === 'Home' ? 0 : event.key === 'End' ? items.length - 1 :
        (current + (event.key === 'ArrowUp' ? -1 : 1) + items.length) % items.length;
      event.preventDefault();
      event.stopImmediatePropagation();
      items[next].focus({ preventScroll: true });
    }, true);
  });
}
```

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

* Do not use the `popover` IDL property in code that may run before the polyfill has loaded. The value is not mirrored to the attribute, the polyfill does not pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
* The polyfill cannot define the real `:popover-open` pseudo-class, so it adds a `.\:popover-open` class. Combine the two with `:is()` or `:where()`; in a plain selector list, browsers without `:popover-open` discard the whole rule.

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

The polyfill cannot fully emulate the top layer, so a menu must not become the containing block for its submenus, which an opening `translate` transition would make it. Wrap any property that creates a containing block (`filter`, `translate`, `scale`, `transform` and so on) in `@supports selector(:popover-open)`:

```css
[popover]:has(> [focusgroup~="menu"]) {
  @supports selector(:popover-open) {
    translate: 0 -.25rem;
  }
}
```

### Anchor positioning

Baseline status for the css.properties.position-area capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

Without anchor positioning, a popover falls back to the UA's centered viewport placement. Do not ship that for a menu: it detaches the menu from its trigger, and a centered submenu covers its parent. Gate the anchored rules behind `@supports (position-area: block-end)` and position the menu from script when it fails:

* Place the menu below its trigger (top level) or beside it (submenu), flipping to the other side and clamping to the viewport when it would overflow.
* Run it in the `toggle` handler when the menu opens, and apply the result as `left` and `top` on the menu. Use `position: fixed` with `inset: auto` and `margin: 0` so the coordinates are viewport-relative.
* Keep these overrides inside `@supports not (position-area: block-end)`, so browsers with anchor positioning are unaffected.

Baseline status for ToggleEvent source: Newly available. It's been Baseline since 2026-05-11.
Supported by: Chrome 140 (Sep 2025), Edge 140 (Sep 2025), Firefox 145 (Nov 2025), and Safari 26.5 (May 2026).

If targeting earlier implementations where `showPopover({ source })` does not establish an implicit anchor (no `source` on `ToggleEvent.prototype`), give each trigger a unique `anchor-name` and each menu a matching `position-anchor` from script, instead of writing per-menu CSS rules.

### Invoker commands

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

Without invokers, `command="toggle-popover"` does nothing. Use `popovertarget` instead: it has longer support, and the popover polyfill supports it.

* Mark the menu in `enterOnOpen` unless the click came from the pressed trigger (`pointerTrigger`), so only keyboard opens enter the menu.
* `Enter` and `Space` still work because they generate a click on buttons.

### `:has()`

Baseline status for :has(): Widely available. It's been Baseline since 2023-12-19.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 121 (Dec 2023), and Safari 15.4 (Mar 2022).

If targeting browsers without `:has()`, add a class to each menu popover instead of selecting `[popover]:has(> [focusgroup~="menu"])`.

### `sign()`

Baseline status for abs() and sign(): Newly available. It's been Baseline since 2025-06-26.
Supported by: Chrome 138 (Jun 2025), Edge 138 (Jun 2025), Firefox 118 (Sep 2023), and Safari 15.4 (Mar 2022).

If your Baseline target lacks `sign()`, skip `--bridge-side` (part of the `menu` guide's pointer bridge) and pick the edge and the apex nudge with `clamp()`: a large multiplier pushes `--pointer-x` past either bound, so the result is one end or the other.

```css
@supports not (width: calc(sign(1px) * 1px)) {
  [data-bridge]::before {
    --bridge-edge: clamp(100vw, 50% + var(--pointer-x) * 1e6, 100% - 100vw);
    --bridge-apex: calc(100vw + var(--pointer-x) + clamp(-1 * var(--bridge-slack), var(--pointer-x) * 1e6, var(--bridge-slack)));
  }
}
```
