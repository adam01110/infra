# Rearrange Items with Drag and Drop

Add reordering to an existing vertical list or horizontal row. Reorder the real children in the DOM, not with CSS `order` or `flex-direction: *-reverse`, so visual, keyboard and reading order stay aligned. For free-form 2D repositioning of a floating element such as a dialog or toolbar, see the `drag` guide. This guide covers one axis at a time; it doesn't cover reordering a grid or wrapped layout, or moving items between lists.

When items contain interactive controls or selectable text, give them a dedicated drag handle instead of making the whole item draggable. Then set up the pointer drag:

- Start pointer drags only for the primary button, and record the initial pointer offset.
- Put `cursor: grab`/`grabbing`, `touch-action: none` and `user-select: none` on the handle, so item text stays selectable and the page scrolls outside the handle. Keep `touch-action: none` on the handle only: it disables touch scrolling over the element, which is fine for a small dedicated handle (the rest of the item and the page still scroll) but traps scrolling on a whole item or list.
- The pointer leaves the handle as soon as the drag moves, so `:active` on the handle can't keep the grabbing cursor. Toggle a class on the root element for the length of the drag (removed in the drag-end cleanup) and set `cursor: grabbing` on it and its descendants.

## Keep the drag active and find the destination

- Capture the pointer. Call `handle.setPointerCapture(event.pointerId)` on `pointerdown` so the drag continues after the pointer leaves the handle, and clean up on `lostpointercapture` unless capture was deliberately re-established after a `before()` move (see the `moveBefore()` fallback).
- Follow one pointer. Remember the `pointerId` that started the drag and ignore `pointerdown`, `pointermove`, `pointerup` and `pointercancel` from any other pointer, so an accidental second touch (such as the thumb holding a phone) can't start a competing drag or end the current one.
- Let `Escape` cancel. Record the item's current rect, clear its drag `translate` without moving it in the DOM, scroll its slot back into view if the container scrolled, animate it back from the recorded rect, and announce the cancellation.
- Find the destination from layout, not `event.target`, which pointer capture redirects to the handle. Clamp the pointer to the container's bounds on the list's axis and compare it with each sibling's layout midpoint.
  - Vertical list: use `offsetTop + offsetHeight / 2`, with `position: relative` on the container and its `clientTop` and `scrollTop` accounted for. The drop spot is before the first sibling whose midpoint is below the pointer, or at the end if there is none.
  - Horizontal row: use `offsetLeft + offsetWidth / 2` with `clientLeft` and `scrollLeft`. `offsetLeft` and `scrollLeft` share one coordinate space in both reading directions (`scrollLeft` is negative once a right-to-left row is scrolled), so the same sum works for both. In a right-to-left row the DOM order runs right to left, so insert before the first sibling whose midpoint the pointer has already passed, rather than the first it hasn't reached.
- Layout midpoints ignore in-flight `translate` animations and padding gaps, so a pointer past either edge reliably resolves to the first or last place. `document.elementFromPoint()` hit-tests painted positions and can miss items while siblings animate. Use `document.elementFromPoint(event.clientX, event.clientY)` only when the destination is one of several containers (such as board columns).

While an item is dragged, show where it will land: reserve space, show a drop marker, or show a clone at the target. With a drop marker, consider collapsing the source slot so the marker alone signals the destination; a marker plus a leftover gap suggests two drop targets.

Don't reorder while the pointer moves; shifting siblings feel jittery. The default for a single-axis list is to keep the source item in its slot and show a drop marker:

- Draw a marker, don't shift items. Set `data-drop` on the list during a drag and draw the marker with its `::before` (ring) and `::after` (line), both `position: fixed; pointer-events: none`. Don't append an element to `<body>`.
- Place it in the gap. On every drop-spot update and scroll step, set `--drop-x`, `--drop-y`, `--drop-w` and `--drop-h` from the neighbours' `getBoundingClientRect()`, centering the line in the gap between the previous and next item (on the inline axis for rows, flipped in right-to-left). Don't use CSS anchor positioning, which drifts during autoscroll, and keep `transform`, `filter` and `contain` off the list and its ancestors.
- Skip no-op drops: show no marker when the drop spot is the item's own slot. Remove `data-drop` and the custom properties when the drag ends.
- Make it themeable. Drive color, line size, ring size, gap, lifted-item opacity and shadow from custom properties (such as `--drop-marker-color`) with defaults that suit the host design system, and use `Highlight` under `forced-colors: active`.
- Move once, on release. On `pointerup`, if the drop spot differs from the item's current next sibling, move the existing node atomically with `container.moveBefore(item, referenceNode)` instead of recreating it. This preserves internal state (focused controls, input values, scroll position, media, custom element instances) and active pointer capture. Keyboard moves make the same call on each step.

Then animate:

- Animate every move, including the release and keyboard moves, so items travel rather than jump. Record each sibling's `getBoundingClientRect()` before the move, then animate `translate` from the old offset (on both axes, correcting for any scroll in between) to `0 0` (FLIP).
- Animate the release from the item's released position to its final rect (FLIP). Measure the final rect after finishing the item's in-flight animations (`item.getAnimations().forEach((animation) => animation.finish())`), otherwise it includes the animation offset. Keep the item raised until the animation ends.
- Skip these animations under `prefers-reduced-motion: reduce`.
- Lift the real item rather than a clone. Keep it in the DOM and in its slot, and make it follow the pointer with `translate` (adding the list's scroll change since the grab, so autoscroll keeps it under the pointer). Give it `position: relative`, a raised `z-index`, a slight `scale`, a shadow and `pointer-events: none`. Its empty slot shows where it was picked up. A clone duplicates IDs, loses state, breaks descendant selectors, framework bindings and IDREFs, and becomes invalid markup when appended outside the list.
- Handle a quick re-grab: don't clear the item's drag state from a finished animation's callback if a new drag of that item has already started.

## Scroll while dragging

If the items are in a scrollable container, scroll it while the pointer is near or past its start or end edge on the list's axis (top and bottom with `scrollTop`, or left and right with `scrollLeft` for a row), so off-screen items stay reachable, especially on small viewports.

- Run a `requestAnimationFrame` loop for the duration of the drag. Scale the scroll speed by how far the pointer is into an edge zone (the dragged item's size on the list axis, capped at a third of the container's size so the two zones never overlap), keep increasing past the edge up to a cap, and base it on frame time rather than a fixed step. Cancel the loop when the drag ends.
- After each scroll change, re-run drop-spot detection with the last pointer position clamped into the container, because the pointer hasn't moved.
- Don't use `scroll-behavior: smooth` on that container.
- Give the container space on every side so focus rings and elevation shadows aren't clipped. The space must cover the focus ring's outline width and offset plus the grabbed item's scale growth: about 1rem for a 3px outline, 2px offset and `scale(1.02)`. Note that `overflow-y: auto` also clips on the x axis. Put the end space (bottom, or inline end for a row) on the last item's margin rather than the container's padding, because some engines leave a grid or flex container's end padding out of its scrollable overflow.

## Keyboard reordering

Provide a keyboard alternative to pointer reordering. Pick the interaction by how often users reorder and how discoverable it must be:

- Visible move controls or an actions menu: the best default for discoverability and screen reader compatibility, because standard buttons work in screen reader browse modes without intercepting arrow keys. Use an actions menu when persistent inline buttons add too much clutter.
- Arrow keys (or a modifier plus arrows, such as `Alt` + arrow) on a focusable handle or item: suits frequent reordering with minimal UI. Give the handle an accessible name that identifies both the item and the reorder action. Screen reader browse modes may intercept bare arrow keys on a `<button>` handle unless you pair it with explicit move controls or modifier keys.
- Grab, move, drop (`Space` or `Enter` to pick up, arrow keys along the list's axis to move, `Space` or `Enter` to drop, `Escape` to cancel): arrow keys do nothing until the item is grabbed, so they don't conflict with screen reader navigation. Toggle `aria-pressed` on the handle, announce the grabbed state and the available keys on pickup, restore the original DOM position on `Escape`, and drop when the handle itself loses focus (not only when focus leaves the list, since the next tab stop is often another control in the same item), ignoring any blur caused by the move itself.

Keys follow the list's axis: `ArrowUp`/`ArrowDown` for a vertical list, `ArrowLeft`/`ArrowRight` for a row. Arrows follow the visual direction, so in a right-to-left row `ArrowLeft` moves the item later in the DOM and `ArrowRight` earlier. Ignore the other axis's keys, match direction labels and icons on move buttons, and name the direction in announcements.

Whatever the approach, announce the item and its new position in a polite live region. Clear its text and delay the update briefly (see the `moveBefore()` fallback below) so moves that refocus the handle are still announced. Announce only real position changes (not a click or a drop in place), but always announce a cancellation.

Show focus and the grabbed state on the item being moved, not just on the handle:

- Keep the item in view. After each keyboard move (including `Escape` restoring the original position) and each pointer drop, call `item.scrollIntoView({ block: 'nearest', inline: 'nearest' })` after the move but before the animation starts, because an in-flight `translate` skews the scroll target. Then restore focus with `focus({ preventScroll: true })` so the browser doesn't scroll again, and give items a `scroll-margin` matching the space around them in the container.
- Reveal the whole item on keyboard focus. Otherwise the browser scrolls only the focused handle into view, leaving the rest of the item and its focus ring clipped. When keyboard focus enters an item (for example with `Tab`), scroll the item the same way (`block` and `inline` both `'nearest'`) from a `focusin` handler that checks `:focus-visible` and skips items with running animations.
- Draw the focus ring on the item with `.item:has(.handle:focus-visible)`.
- For grab-move-drop handles, show a visible key hint on the focused item: an `aria-hidden="true"` element reading "Space to reorder" that switches to "Arrows to move · Space to drop · Esc to cancel" while grabbed. Keep this text in the DOM rather than CSS `content` so it can be translated. Fade the handle slightly at rest so reordering reads as available.
- Apply the handle's hover style on `:focus-visible` too (`.handle:is(:hover, :focus-visible)`) so sighted keyboard users see it is activatable. Use a fill rather than an outline so it doesn't look like a second focus ring, and give the grabbed (`aria-pressed`) state its own pressed look.
- Elevate the grabbed item with full opacity, a slight `scale()` and `box-shadow`. Avoid rotation, especially for single-axis movement.
- Keep the layout shrinkable: make each row's flexible column shrinkable (`minmax(0, 1fr)`, with form controls at `width: 100%`) so the move controls stay visible on narrow viewports without horizontal scrolling.

### Align reading order with the visual layout

Keep DOM and focus order understandable relative to the visual layout. With separate move controls, make the item's context available before or alongside them. A focusable drag handle needs an accessible name that identifies the item and its reordering function. Place controls to suit the layout and writing direction without making the reading or focus order confusing.

For complex layouts where visual and DOM order can't naturally match, use the `reading-flow` property on grid or flex containers so tab order follows the visual layout instead of source order:

```css
.task {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) auto; /* minmax(0, ...) lets the middle column shrink when narrow. */
  reading-flow: grid-rows; /* Tab order follows the visual rows. */
}
```

### Boundaries and focus

Allow moves only to valid destinations. If items can move between containers, make those destinations available to keyboard users too. At a container's edge, block further movement only when there is no valid destination in that direction.

After a move, keep focus on the item's handle. With separate move buttons, keep focus on the activated button, or move it to the other move control on the same item when the activated one becomes disabled.

## Decide on fallback behaviour

When reordering is supplementary, keep the collection readable and usable in its default DOM order without JavaScript. When the order is user-controlled data or affects behaviour (task priority, playlist order, workflow sequence), reordering is essential: provide the pointer and keyboard interactions rather than presenting the static order as equivalent.

## Browser support and fallback strategies

### `moveBefore()`

Browser support for moveBefore(): Limited availability.
Supported by: Chrome 133 (Feb 2025), Edge 133 (Feb 2025), and Firefox 144 (Oct 2025).
Unsupported in: Safari.

If your Baseline target lacks `moveBefore()`, feature-detect with `'moveBefore' in Element.prototype` and fall back to `referenceNode.before(item)` (or `container.append(item)` when there is no reference node) with the existing node. `before()` removes and reinserts the node, which has two side effects:

- It drops active pointer capture. Keep the `pointermove`, `pointerup` and `pointercancel` listeners on `document`, where captured events still bubble. After the move, call `handle.setPointerCapture(event.pointerId)` again when `hasPointerCapture()` is false, and end the drag on `lostpointercapture` only if capture isn't re-established.
- It blurs focused descendants. Call `.focus()` on the active handle or move button after the move. Also delay the live-region update by about 500 ms (debounced, clearing the previous message first); otherwise the focus re-announcement swallows the position announcement in screen readers such as VoiceOver in Safari.

### `reading-flow`

Browser support for reading-flow: Limited availability.
Supported by: Chrome 137 (May 2025) and Edge 137 (May 2025).
Unsupported in: Firefox and Safari.

Without `reading-flow`, sequential focus navigation follows DOM order. Order each item's DOM so its controls form a logical reading and tab sequence without relying on CSS visual reordering.

### `user-select`

Browser support for user-select: Limited availability.
Supported by: Chrome 54 (Oct 2016), Edge 79 (Jan 2020), and Firefox 69 (Sep 2019).
Unsupported in: Safari.

Declare `-webkit-user-select: none` before `user-select: none` on the drag handle so text selection stays suppressed during drags in Safari.
