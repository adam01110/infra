# Build a toolbar

A toolbar groups related controls (formatting, alignment, view options) into one composite widget with a single tab stop. Users `Tab` into it once, move between controls with the arrow keys, and `Tab` out. Use it only for controls that act on something else (an editor, preview, or canvas). For site navigation, see the `navbar` guide; for a dropdown or context menu of commands without a persistent row of controls, see the `menu` guide.

## Structure and semantics

Put `role="toolbar"` and an `aria-label` on the container. Wrap related controls in `role="group"` with their own `aria-label`, and divide groups with `role="separator"` and `aria-orientation="vertical"`. If a wrapped separator would sit alone at a row end, hide it visually with `opacity: 0`, not `display: none` or `visibility: hidden`, which also remove it from the accessibility tree. Optionally add `aria-controls` pointing at the element the toolbar acts on; it is only worth adding when the toolbar controls one specific element.

* Use real `<button type="button">` elements.
* Icon-only buttons need an `aria-label`; tooltips do not replace it. Render decorative icons with `<svg aria-hidden="true">` and `currentColor`, or with a CSS `mask`, `background-color: currentColor`, and `forced-color-adjust: none` so forced-colors mode does not strip the fill. For a reusable CSS icon token system, see the `icons` guide.
* Toggle buttons (bold, italic) use `aria-pressed="true|false"`. Do not change their label when toggled.
* A mutually exclusive set (left/center/right) uses `aria-pressed` on each button, with script keeping exactly one `true`.
* Action buttons (copy, undo, save) run once and have no on/off state, so do not give them `aria-pressed`; use it only on buttons that stay on or off.
* Disable with `aria-disabled="true"` rather than `disabled` so the control stays focusable and reachable by arrow keys. Ignore clicks while it is set.

```html
<div role="toolbar" focusgroup="toolbar wrap" aria-label="Text formatting" aria-controls="preview">
  <div role="group" aria-label="Style">
    <button type="button" aria-pressed="false" aria-label="Bold" title="Bold"></button>
  </div>
  <span role="separator" aria-orientation="vertical"></span>
  <!-- Overflow trigger: the last item in the toolbar -->
  <button type="button" aria-label="More actions" aria-haspopup="menu" aria-expanded="false"
    popovertarget="more-menu" title="More actions"></button>
</div>
```

## Action buttons and feedback

Toggles show their result through `aria-pressed`. An action has no state to show, so a screen reader user gets no confirmation unless you provide it. When the result is not otherwise visible or announced (copy, save), write a short message to a live region outside the toolbar. If the action changes content that is already announced or focused, skip the message.

```html
<!-- Always present in the DOM so the announcement is reliable; keep it outside the toolbar -->
<p id="toolbar-status" role="status"></p>
```

```js
const statusEl = document.querySelector("#toolbar-status");

// In the copy button's click handler. Report the outcome, including failure: clipboard access can be denied.
copyButton.addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(text);
    statusEl.textContent = "Text copied";
  } catch {
    statusEl.textContent = "Copy failed";
  }
});
```

## Keyboard navigation

Only one item may be in the tab order at a time. Put `focusgroup="toolbar wrap"` on the `role="toolbar"` container: the browser provides the roving tab stop, arrow-key movement across all groups (wrapping at the ends, reversed in RTL), `Home`/`End`, and focus restoration after a click. Do not add a second roving-tabindex system alongside it. Where `focusgroup` is unsupported, install the [fallback](#focusgroup) below.

## Vertical toolbar

Choose a vertical toolbar when controls stack along a side edge (a tool palette or zoom controls beside a canvas); otherwise use a horizontal one. Everything above applies except:

* Set `aria-orientation="vertical"` on the toolbar and use `focusgroup="toolbar wrap block"` so `ArrowDown`/`ArrowUp` move between items.
* Lay items out in a column (`flex-direction: column`, no wrapping).
* A separator between stacked items is horizontal: use `aria-orientation="horizontal"` (the separator default) there, not `vertical`.
* Tooltips open beside the button (`position-area: inline-end`), not below it; see [Tooltips](#tooltips-for-icon-only-buttons).

## Visible states

* Make each button at least 24×24 CSS px with `min-inline-size` / `min-block-size` (not `inline-size` / `block-size`), so content can grow the target but never shrink it. Enlarge it under `@media (pointer: coarse)` (for example from `2.5rem` to `3rem`).
* Keep a clear `:focus-visible` outline with an offset; never remove it.
* Style toggled state from the ARIA attribute (`[aria-pressed="true"]`), not a separate class, so visual and accessible state cannot diverge.
* Show the toggled state by changing the button background. If that background contrasts less than 3:1 with the adjacent background in any supported color scheme, add another cue that meets 3:1, such as an outline or inset shadow around it (see the `color` guide).
* Under `forced-colors: active`, use system colors (`ButtonText`, `Highlight`).
* Draw separators and tooltip boxes with a border (a `transparent` one is fine), not `background` alone, which forced colors replaces with the page color.
* Wrap hover styles in `@media (hover: hover)` and transitions in `@media (prefers-reduced-motion: no-preference)`.

## Tooltips for icon-only buttons

Give each icon-only button a `title` as the baseline tooltip. Only where both interest invokers and anchor positioning are supported, upgrade it to an interest invoker with `popover="hint"`, which shows the tooltip without closing an open menu popover. Elsewhere the native `title` tooltip stays.

Position the hint on the axis the toolbar does not stack along: `position-area: block-end` (fallback `flip-block`) for a horizontal toolbar, `position-area: inline-end` (fallback `flip-inline`) for a vertical one. A hint placed along the stacking axis covers the next control and swallows its click, because the hint stays open while the pointer is over it.

```html
<button type="button" aria-label="Bold" title="Bold">…</button>
```

```js
// Upgrade title tooltips only when interest invokers and anchor positioning both work
if ("interestForElement" in HTMLButtonElement.prototype && CSS.supports("position-area", "block-end")) {
  document.querySelectorAll('[role="toolbar"] button[title]').forEach((b, i) => {
    const tip = Object.assign(document.createElement("div"), { id: `tip-${i}`, textContent: b.title });
    tip.setAttribute("popover", "hint");
    b.setAttribute("interestfor", tip.id);
    b.removeAttribute("title"); // Avoids a second, native tooltip.
    document.body.append(tip); // Keeps open hints out of role="group" / role="toolbar".
  });
}
```

The `interestfor` specification wires hint popovers (`popover="hint"`) to assistive technology itself, based on what the target contains. A plain hint (text and images only) becomes the trigger's accessible description, or its name if the trigger has none. A rich hint (headings, links, or other interactive content) gets a minimum role of `tooltip`, the trigger gets `aria-expanded` and an `aria-details` relation while the hint is open, and the open hint comes right after the trigger in the tab order so keyboard users can reach its content.

Browsers and screen readers do not yet expose this consistently, so add explicit ARIA as well:

* Hint that repeats the trigger's accessible name (for example an icon-only button with `aria-label="Bold"` and a "Bold" tooltip): add nothing. A description identical to the name would be read twice.
* Hint on a trigger with no visible label of its own (for example an icon-only button without `aria-label`): put `aria-labelledby` on the trigger pointing at the hint, so the hint becomes the name.
* Hint whose trigger also opens it on activation (a toggletip, or any button whose only job is the hint; give it `popovertarget` with `popovertargetaction="show"`): put `role="tooltip"` on the hint and `aria-expanded` on the trigger, kept in sync with the popover's `toggle` event. A description read right after "button" suggests further actions and muddles the role; the expanded state tells the user there is content to reveal and whether it is open, and pressing the button delivers it. Place the hint right after the trigger in the DOM so reading keys reach its content once it is open.
* Hint whose trigger does something else on activation (a link, a button with its own action): put `role="tooltip"` on the hint and `aria-describedby` on the trigger, never `aria-expanded`. A trigger announced as "collapsed" suggests `Enter` would expand it, but `Enter` navigates or acts. The hint must be something the user can afford to miss: a hovercard previews the destination, a tooltip on an action button describes the action.
* Do not attach a hint that opens on activation to a control that already uses `aria-expanded` for something else (for example, a menu button). Give that hint its own trigger instead.
* Do not move focus into the target when interest is shown (no `autofocus`, no `focus()` in an `interest` listener). Interest is triggered by hover or focus alone, so moving focus would fail WCAG 3.2.1 (On Focus).

Not every screen reader reads descriptions when moving through the page (NVDA skips them in browse mode by design), so a hint exposed as a description must only carry content the user can afford to miss. Link previews and tooltips on action controls qualify; anything the user needs belongs in a toggletip or inline.

Wire this with a short script instead of hand-authoring the attributes, so the markup stays declarative and the same rules apply to every hint. The script should:

1. Run in every browser, once the DOM is parsed and before loading the `interestfor` polyfill, and expose a function that can be called again for content inserted later. Scan upfront: a browse-mode screen reader user needs the attributes in place before any interaction, so wiring them lazily on `focus` or `interest` is too late, and so is waiting for the polyfill, which wires its ARIA only on `load` and adds no `role="tooltip"` to plain hints.
2. For every `[interestfor]` trigger whose target has `popover="hint"`, normalize whitespace and compare the hint text with the trigger's accessible name (`aria-labelledby` targets, else `aria-label`, else text content including image `alt`, else `title`). Equal: do nothing. Otherwise set `role="tooltip"` on the hint if it has no role.
3. When the trigger has no name, point `aria-labelledby` at the hint unless it already has one. Otherwise, if the trigger also opens the hint on activation (a `popovertarget` or `commandfor` naming the hint), set `aria-expanded` to the popover's current state (`:popover-open`) unless it already has `aria-expanded`, and remember which triggers the script owns; if not, point `aria-describedby` at the hint unless it already has one.
4. Keep `aria-expanded` in sync from the popover's `toggle` event in every browser with a single capturing listener on `document`, updating every trigger with a matching `interestfor` that the script owns (the `interestfor` polyfill does not sync `aria-expanded` on plain-text hints or when a toggletip is opened via `popovertarget`).

Things that are easy to get wrong:

* `toggle` does not bubble. A bubbling listener on `document` never fires; use the capture phase (or a listener per popover).
* Sync `aria-expanded` from `toggle`, not from `interest`/`loseinterest`. The popover is the source of truth: it can be closed by `Escape`, light dismiss, or another invoker, and several triggers can share one hint.
* A hidden popover is a valid `aria-describedby` or `aria-labelledby` target. Do not force the hint open or duplicate its text to make it "visible".
* Do not add `aria-haspopup` or a live region to any hint.
* Do not override author ARIA: an existing `aria-describedby`, `aria-labelledby`, or `aria-expanded` on the trigger wins.

By default, interest is shown and lost after a half-second delay for keyboard and mouse users. This keeps the popover from opening while the user tabs through the page or moves the mouse around, and from closing while the mouse travels from the trigger to the popover. Adjust the timing with the `interest-delay` property.

```css
[interestfor]{
  /* Shorthand for interest-delay-start and interest-delay-end */
  interest-delay: 0.2s 0.1s;
}
```

If users are likely to move through several triggers in quick succession, set the start delay to `0s` while an interest-triggered popover is already open. To avoid `:has()` performance problems, anchor it on a nearby container with few child nodes and target the triggers as directly as possible.

```css
[role="toolbar"]:has(button:interest-source) [interestfor] {
  interest-delay-start: 0s;
}
```

```css
[popover="hint"] {
  inset: auto;
  /* Anchor to the invoker; flip to the other side if there is no room */
  position-area: block-end;
  position-try-fallbacks: flip-block;
}
```

## Overflow menu for secondary actions (optional)

Two patterns fit a toolbar into a narrow space: an overflow menu, better on desktop, or a horizontally scrollable toolbar with no scrollbar and scroll hints, better on mobile. For the scrollable pattern use `overflow-x: auto; scrollbar-width: none; scroll-snap-type: x proximity`, and hint at hidden controls with edge fades (`mask-image`) or a partly visible last item. Choose by input type (`@media (pointer: coarse)`) or container width.

Add a trailing "More actions" menu when the toolbar has secondary actions or must fit narrow containers; skip it if every control is common and fits. If items must move into the menu dynamically as space runs out, build that overflow behavior yourself.

* Make the trigger the last toolbar item (`aria-label="More actions"`, `aria-haspopup="menu"`, `aria-expanded="false"`, and `popovertarget` pointing at the menu popover; `commandfor` with `command="toggle-popover"`, as in the `menu` guide, works the same way) with the conventional three-vertical-dots icon (`⋮`). Open it only on activation, never as a preview when focus arrows across the toolbar.
* Anchor the `popover` container to its trigger (`inset: auto; position-area: block-end span-inline-start; position-try-fallbacks: flip-block, flip-inline`) and nest `<div focusgroup="menu nomemory" aria-label="More actions">` inside it, adding `role="menu"`, `role="menuitem"`, `tabindex="-1"`, and `ArrowDown`/`ArrowUp`/`Home`/`End` only when `'focusGroup' in HTMLElement.prototype` is false. Sync `aria-expanded` and focus the first item on `toggle`, close the popover on `Tab` without trapping focus, and let `Space` on `role="menuitemcheckbox"` toggle `aria-checked` without closing. For nested submenus or radio groups, see the `menu` guide.
* Announce the result of every menu activation in the toolbar's live region, such as `"Strikethrough on"` or `"Formatting cleared"`. When closing the menu returns focus to the trigger, delay the live-region write slightly (for example 500 ms) so the focus-change announcement does not preempt it.

## Fallback strategies

### `focusgroup`

Browser support for focusgroup: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

Keep `focusgroup` in the markup. Only if `'focusGroup' in HTMLElement.prototype` is false, load a roving-tabindex fallback; never install it when native focusgroup is present. The fallback implements what focusgroup does natively:

* The active item has `tabindex="0"`; all others have `tabindex="-1"`. Initially the first item is active.
* On `focusin`, move `tabindex="0"` to the focused item so returning to the toolbar (including after a click) restores position.
* In a horizontal toolbar, `ArrowRight`/`ArrowLeft` move to the next/previous item across all groups and wrap at the ends. In RTL, reverse the directions. Do not wire `ArrowUp`/`ArrowDown`.
* In a vertical toolbar, `ArrowDown`/`ArrowUp` move to the next/previous item instead, and `ArrowLeft`/`ArrowRight` do nothing.
* `Home`/`End` move to the first/last item.
* Call `preventDefault()` only for keys the toolbar handles so `Tab` keeps working.

```js
if (!('focusGroup' in HTMLElement.prototype)) {
  // items = every toolbar control across all groups, in DOM order
  items.forEach((b, i) => (b.tabIndex = i ? -1 : 0));
  bar.addEventListener("focusin", ({ target }) => {
    if (items.includes(target)) items.forEach((b) => (b.tabIndex = b === target ? 0 : -1));
  });
  // Call at keydown time so runtime changes to direction or orientation are honored.
  const steps = () => {
    const vertical = bar.getAttribute("aria-orientation") === "vertical";
    // Only horizontal toolbars flip with direction; RTL does not flip Up/Down.
    const rtl = getComputedStyle(bar).direction === "rtl";
    return vertical
      ? { ArrowDown: 1, ArrowUp: -1 }
      : { ArrowRight: rtl ? -1 : 1, ArrowLeft: rtl ? 1 : -1 };
  };
  // keydown: look up steps()[key] (or Home/End), move focus, preventDefault only for handled keys.
}
```

### Interest invokers

Browser support for Interest invokers: Limited availability.
Supported by: Chrome 149 (Jun 2026) and Edge 149 (Jun 2026).
Unsupported in: Firefox and Safari.

Do not load an `interestfor` polyfill here: when native interest invokers or anchor positioning are missing, the upgrade script is skipped and buttons keep their baseline `title` tooltip.

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

### `popover="hint"`

Browser support for popover="hint": Limited availability.
Supported by: Chrome 151 (Jul 2026), Edge 151 (Jul 2026), and Firefox 153 (Jul 2026).
Unsupported in: Safari.

The popover polyfill does not add `popover="hint"`. Where `popover` exists without `hint`, two tooltips can stay open at once (for example one opened by focus and one by hover). Treat this as graceful degradation: the upgrade only runs where interest invokers are supported, and other browsers keep the native `title` tooltip.

### Clipboard API

Baseline status for the api.Clipboard.writeText capability: Widely available. It's been Baseline since 2020-03-24.
Supported by: Chrome 66 (Apr 2018), Edge 79 (Jan 2020), Firefox 63 (Oct 2018), Safari 13.1 (Mar 2020), and Safari iOS 13.4 (Mar 2020).

Where the Clipboard API is unavailable, `navigator.clipboard` is undefined and the call throws, so the `catch` branch in the feedback snippet reports the failure.

### Anchor positioning

Baseline status for the css.properties.position-area capability: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), Firefox 147 (Jan 2026), and Safari 26 (Sep 2025).

Without anchor positioning, a popover is placed by the UA at the center of the viewport. Tooltips need no fallback: the `title` upgrade above is skipped without anchor positioning. For the overflow menu, position it from script so it stays attached to its trigger. Keep the CSS inside `@supports not (position-area: block-end)` so supporting browsers are unaffected.

```css
@supports not (position-area: block-end) {
  #more-menu {
    /* Viewport coordinates are set from script when the menu opens */
    position: fixed;
    inset: auto;
    margin: 0;
  }
}
```

```js
// Without anchor positioning: below the trigger, flipped above when it would overflow.
menu.addEventListener("toggle", ({ newState }) => {
  if (newState !== "open" || CSS.supports("position-area", "block-end")) return;
  const t = more.getBoundingClientRect();
  const m = menu.getBoundingClientRect();
  const below = t.bottom + m.height <= innerHeight;
  menu.style.top = `${below ? t.bottom : t.top - m.height}px`;
  // Right-aligned with the trigger, clamped to the viewport.
  menu.style.left = `${Math.max(0, Math.min(t.right - m.width, innerWidth - m.width))}px`;
});
```
