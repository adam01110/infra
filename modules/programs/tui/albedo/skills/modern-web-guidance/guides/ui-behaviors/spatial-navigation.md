# Spatial Navigation (Directional Keypad Focus)

Directional focus navigation (arrow keys or a D-pad) lets keyboard-only and alternative-input users move between interactive items according to their visual 2D layout. It helps in spatial interfaces such as media rails, dashboard panels and nested catalogs, but a careless implementation breaks native behaviour such as viewport scrolling.

This guide covers performant, accessible 2D directional navigation inside composite widgets.

## Core principles

1. Limit it to composite widgets. Don't override arrow keys in normal document flow or in simple vertical lists where sequential Tab navigation is expected. Use it only when a composite role matches the interaction. The `accessibility` guide covers general document flow.
2. Preserve native scrolling at the edges. When there is no focusable element in the pressed direction, don't prevent the default action; let the event through so the browser scrolls the viewport. Overriding arrow keys unconditionally breaks accessibility (WCAG 1.4.10).
3. Keep focus visible. After moving focus, scroll the new element into view, for example with `scrollIntoView({ block: 'nearest', inline: 'nearest' })`, so it is fully visible.
4. Follow the actual layout. Work out candidate positions from live geometry (`getBoundingClientRect()`) on each keypress. Don't assume DOM order or a fixed grid matches the visual layout. The `css-layout` guide covers modern layout.

## Accessible focus management

The widget exposes a single tab stop to sequential Tab navigation. Inside it, manage focus with a roving tabindex:

- The active item has `tabindex="0"`.
- All other items have `tabindex="-1"`.
- To navigate, move `tabindex="0"` to the new item and call `focus()` on it.

Roving tabindex only works with screen readers when the container and items have matching composite-widget roles and states (for example grid/gridcell or listbox/option); tabindex alone is not enough. Choose semantics by what the navigation does:

- Rows of interactive elements: `grid`.
- Controls that, when selected, update content related to the selected control: `tablist`.
- Suggested items that, when selected, fill a related input: `combobox`.
- A list where one or more options can be selected: `listbox`.
- A collection of interactive items with a clear hierarchy: `tree`.
- A grid-like pattern with expandable items and a clear hierarchy: `treegrid`.

## Visual candidate selection

Index-based mapping fails in asymmetric, wrapped or grid layouts. Derive candidates from live geometry on each keypress:

- Candidates: the widget's focusable descendants that pass `checkVisibility()`. Hidden elements can report a zero-sized rect at `(0, 0)` and would otherwise become accidental `up` or `left` targets.
- Geometry: read `getBoundingClientRect()` for the focused element and every candidate while handling the key. Don't cache rects globally; layout changes for many reasons, and a few geometry reads per user-paced key event are cheap.
- Direction filter: a candidate is in the pressed direction only if its near edge is at or beyond the current element's far edge on that axis, with a small tolerance for sub-pixel rounding. For `right`, `candidate.left >= current.right - tolerance`. Don't compare centres for this test.
- Aligned candidates first: among candidates that pass the filter, prefer those whose extent on the perpendicular axis overlaps the current element's. Pick the smallest gap on the navigation axis, breaking ties by the smallest perpendicular centre offset. This keeps navigation in the adjacent visual row or column even when an item is unusually wide.
- Fallback scoring: if no candidate overlaps on the perpendicular axis, score the rest as `gap + w * perpendicularCentreOffset` and take the minimum. Start with `w >= 2` and tune it for the layout; a larger weight favours better-aligned candidates.
- No candidate: return nothing. The handler then doesn't call `preventDefault()`, and the browser scrolls natively.

Implementations can vary, but the direction test must be edge-based and the overlap preference must apply before the weighted fallback; that is the core of the algorithm. Any caching policy and the weight are tunable, not universally correct values.

## Key handling and scrolling

Prevent the default viewport scroll only when a spatial focus move actually happens:

- Don't intercept the event when a modifier key is held, when `e.defaultPrevented` is already true, or when the innermost target uses arrow keys itself. Use `e.composedPath()[0]` rather than just `e.target`, which can be retargeted to a shadow host. A practical check for editable elements and controls is `target.matches(':read-write, select, input[type="range"], [role="slider"]')`; closed shadow roots can't be inspected.
- Attach the listener to the widget container so several spatial widgets can coexist on a page.
- Act only when the focused element is itself a candidate. If items contain their own focusable controls, either make those controls candidates too or leave them alone; don't resolve a parent with `closest()`.
- When a candidate is found, call `preventDefault()`, update the roving `tabindex`, call `focus()`, and call `scrollIntoView({ block: 'nearest', inline: 'nearest' })`.
- When none is found, return without `preventDefault()` so native scrolling continues.

Don't add single-character shortcuts such as `h`/`j`/`k`/`l` or `W`/`A`/`S`/`D` for spatial navigation. They conflict with screen reader and speech-input commands (WCAG 2.1.4 Character Key Shortcuts). Arrow keys are not character keys, and keeping native scrolling when no candidate exists avoids blocking viewport movement unnecessarily.
