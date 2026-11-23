# Show a tooltip when hovering

Users expect to see related information without losing their context. A tooltip shown when the user shows interest can define a term, explain what an icon-only button does, or give extra guidance for a form field.

## Should you use a tooltip?

A toggletip is a small button, usually an "i" or "?" icon next to a control or piece of content, whose only job is to reveal more information. Choose between tooltip, toggletip and inline content by how important and how long the information is:

- Tooltip (on the control itself): a short clarification of what the control does. Missing it costs the user little.
- Toggletip (an "i" or "?" next to the control or content): information users may well want but most don't need every time, such as why a field is required, how a total was calculated or what a policy means, or anything longer than a phrase. Inline it would add clutter, but it deserves an explicit, visible affordance so every user can find it deliberately, including on touch and with a screen reader, rather than by happening to hover. See the toggletip section below.
- Inline content: information most users need in order to act, or while acting (password rules while typing, a value they copy). A popover closes as soon as they click or focus elsewhere.

## Create the tooltip

Add `popover="hint"` to a `<div>` or another semantically appropriate element. Opening a hint popover closes other `popover="hint"` popovers but leaves `auto` and `manual` popovers open, and it handles dismissing nested tooltips. It also light-dismisses: clicking or focusing outside closes it.

The tooltip needs a unique `id`:

```html
<!-- popover="hint" light-dismisses without closing unrelated auto or manual popovers. -->
<div popover="hint" id="tooltip" class="tooltip">Tooltip content</div>
```

Users express interest by hovering or focusing an `<a>` or `<button>` whose `interestfor` attribute matches the tooltip's `id`:

```html
<button interestfor="tooltip">Tooltip trigger</button>

<!-- Links work too (the href is an example). -->
<a interestfor="tooltip" href="/docs/dom">Tooltip trigger</a>
```

Give the trigger a visual indicator that more information is available.

### Accessibility

`interestfor` is specified to wire hint popovers for assistive technology itself, based on the hint's content. A plain hint (text and images only) becomes the trigger's accessible description, or its name if it has none. A rich hint (headings, links or other interactive content) gets at least the `tooltip` role; while it is open, the trigger gets `aria-expanded` and an `aria-details` relation, and the hint comes right after the trigger in the tab order so keyboard users can reach its content.

Browsers and screen readers don't expose this consistently yet, so add explicit ARIA too:

- Hint that repeats the trigger's accessible name (for example an icon-only button with `aria-label="Bold"` and a "Bold" tooltip): add nothing. A description identical to the name would be read twice.
- Hint on a trigger with no label of its own (for example an icon-only button without `aria-label`): put `aria-labelledby` on the trigger pointing at the hint, so the hint becomes the name.
- Hint whose trigger also opens it on activation (a toggletip, or any button whose only job is the hint; give it `popovertarget` with `popovertargetaction="show"`): `role="tooltip"` on the hint and `aria-expanded` on the trigger, kept in sync through the popover's `toggle` event. A description read right after "button" suggests further actions and muddles the role; the expanded state tells the user there is content to reveal and whether it is open, and pressing the button delivers it. Place the hint right after the trigger in the DOM so reading keys reach it once open.
- Hint whose trigger does something else on activation (a link, a button with its own action): `role="tooltip"` on the hint and `aria-describedby` on the trigger, never `aria-expanded`. A trigger announced as "collapsed" suggests `Enter` will expand it, but `Enter` navigates or acts. The hint must be something the user can afford to miss: a hovercard previewing the destination, or a tooltip describing an action button's action.
- Don't attach a hint that opens on activation to a control that already uses `aria-expanded` for something else, such as a menu button. Give that hint its own trigger.
- Don't move focus into the target when interest is shown (no `autofocus`, no `focus()` in an `interest` listener). Hover or focus alone triggers interest, so moving focus would fail WCAG 3.2.1 On Focus.

Not every screen reader reads descriptions while moving through the page (NVDA skips them in browse mode by design), so a hint exposed as a description may only carry content the user can afford to miss. Link previews and tooltips on action controls qualify; anything the user needs belongs in a toggletip or inline.

Wire this with a short script rather than hand-written attributes, so the markup stays declarative and every hint follows the same rules. The script should:

1. Run in every browser, once the DOM is parsed and before the `interestfor` polyfill loads, and expose a function you can call again for content inserted later. Scanning up front is required: browse-mode screen reader users need the attributes before any interaction, so wiring them lazily on `focus` or `interest` is too late, and so is waiting for the polyfill, which wires its ARIA only on `load` and adds no `role="tooltip"` to plain hints.
2. For each `[interestfor]` trigger whose target has `popover="hint"`, normalize whitespace and compare the hint text with the trigger's accessible name (the `aria-labelledby` targets, else `aria-label`, else text content including image `alt`, else `title`). If they're equal, do nothing. Otherwise set `role="tooltip"` on the hint if it has no role.
3. If the trigger has no name, point its `aria-labelledby` at the hint unless it already has one. Otherwise, if the trigger also opens the hint on activation (a `popovertarget` or `commandfor` naming the hint), set `aria-expanded` to the popover's current state (`:popover-open`) unless it already has `aria-expanded`, and record that the script owns this trigger. If it doesn't open the hint, point `aria-describedby` at the hint unless it already has one.
4. Keep `aria-expanded` in sync from the popover's `toggle` event in every browser, with one capturing listener on `document` that updates every script-owned trigger whose `interestfor` matches. The `interestfor` polyfill doesn't sync `aria-expanded` for plain-text hints or when a toggletip is opened through `popovertarget`.

Easy mistakes:

- `toggle` doesn't bubble, so a bubbling listener on `document` never fires. Use the capture phase, or a listener per popover.
- Sync `aria-expanded` from `toggle`, not from `interest`/`loseinterest`. The popover is the source of truth: `Escape`, light dismiss or another invoker can close it, and several triggers can share one hint.
- A hidden popover is a valid `aria-describedby` or `aria-labelledby` target. Don't force the hint open or duplicate its text to make it "visible".
- Don't add `aria-haspopup` or a live region to any hint.
- Don't override author ARIA: an existing `aria-describedby`, `aria-labelledby` or `aria-expanded` on the trigger wins.

### WCAG 1.4.13 Content on Hover or Focus

`interestfor` handles the semantics above, but the implementation must still meet WCAG 1.4.13:

- Dismissible: users can dismiss the tooltip without moving hover or focus, for example with `Escape`. The native `popover` attribute provides this.
- Hoverable: the pointer can move onto the tooltip without it disappearing, so people using magnification can read it.
- Persistent: the tooltip stays visible until hover or focus leaves the trigger, the user dismisses it, or its content is no longer valid.

### Position the tooltip

Position the tooltip with CSS anchor positioning. When `interestfor` opens it, the trigger automatically becomes the popover's implicit anchor, so in browsers with native support you don't need `anchor-name` on the trigger or `position-anchor` on the tooltip. Position it with `position-area` and handle collisions with `position-try-fallbacks`:

```css
/* Scoped by class so toggletips switched to popover="auto" (see the hint fallback) keep it. */
.tooltip {
  /* Implicit anchor from interestfor: no anchor-name or position-anchor needed. */
  position-area: block-start;
  position-try-fallbacks: flip-block;
  /* Override the UA popover centering (inset: 0; margin: auto) so the tooltip sits next to its anchor. */
  inset: auto;
  margin: 0;
}
```

This example relies on native anchor positioning. Without the polyfill, put these rules inside `@supports`; with it, use explicit anchor names and `anchor()` insets instead, since the polyfill supports neither implicit anchors nor `position-area` with `position-try-fallbacks`. Both options are described under the anchor positioning fallback below.

## Toggletips: an "i" or "?" button

Give a toggletip two triggers: `interestfor` opens it on hover, focus and long-press; `popovertarget` opens it on click, tap and `Enter`.

```html
<label>Shipping <input name="shipping"></label>
<!-- The name says what the button reveals; "?" alone is not a name. -->
<button type="button" interestfor="shipping-help" popovertarget="shipping-help" popovertargetaction="show" aria-label="More about shipping">?</button>
<!-- Right after the trigger, so it reads in sequence. -->
<div id="shipping-help" popover="hint" class="tooltip">Free shipping applies to orders over $50. Orders placed before 2pm ship the same day.</div>
```

- Use `popovertargetaction="show"`, not the default `toggle`. Hover has usually opened the popover already, and `toggle` would close it on the click that follows. `Escape`, light dismiss and loss of interest close it.
- Keep `popover="hint"`. Hovering across a toggletip must not close an open menu, which an `auto` popover would.
- Position it like any tooltip; the button is its implicit anchor through either attribute.

## Fallback strategies

### Interest invokers

Browser support for Interest invokers: Limited availability.
Supported by: Chrome 149 (Jun 2026) and Edge 149 (Jun 2026).
Unsupported in: Firefox and Safari.

Polyfill interest invokers conditionally with the `interestfor` package from npm. Bundle the polyfill rather than loading it from a CDN.

Feature-detect with the `interestForElement` property on `HTMLButtonElement.prototype`, and load the polyfill only when native support is missing:

```html
<script type="module">
  if (!("interestForElement" in HTMLButtonElement.prototype)) {
    // CDN URL for illustration only; prefer bundling.
    await import("https://unpkg.com/interestfor@latest");
  }
</script>
```

The polyfill cannot add native pseudo-classes or properties, so the CSS changes slightly:

- Pseudo-classes: the polyfill applies `.interest-source` and `.interest-target` classes instead of `:interest-source` and `:interest-target`. Combine both with `:is()` so native and polyfilled states match:

```css
:is(:interest-source, .interest-source) { /* ... */ }
:is(:interest-target, .interest-target) { /* ... */ }
```

- Properties: for `interest-delay`, `interest-delay-start` and `interest-delay-end`, the polyfill needs the values in CSS custom properties, because it cannot read the real properties in every browser:

```css
[interestfor] {
  --interest-delay-start: 0.2s;
  interest-delay-start: var(--interest-delay-start);
  --interest-delay-end: 0.1s;
  interest-delay-end: var(--interest-delay-end);
}
```

If an interest-triggered popover is already open and users are likely to move across several triggers in quick succession, set the start delay to `0s`:

```css
.container:has([interestfor]:is(:interest-source, .interest-source)) [interestfor] {
  --interest-delay-start: 0s;
}
```

### Popover

Baseline status for Popover: Newly available. It's been Baseline since 2025-01-27.
Supported by: Chrome 116 (Aug 2023), Edge 116 (Aug 2023), Firefox 125 (Apr 2024), Safari 17 (Sep 2023), and Safari iOS 18.3 (Jan 2025).

The Popover API is mostly a progressive enhancement, but its defining behaviours (top-layer promotion, light dismiss and `popovertarget` invocation) have no CSS-only equivalent. Older browsers need a polyfill, or a manual fallback if you'd rather not ship one.

To support `popover` in older browsers, load [`@oddbird/popover-polyfill`](https://github.com/oddbird/popover-polyfill) conditionally. Feature-detect the `popover` property on `HTMLElement.prototype` and load the polyfill only when native support is missing.

With a bundler or import map:

```js
if (!Object.hasOwn(HTMLElement.prototype, "popover")) {
  import("@oddbird/popover-polyfill");
}
```

Without a package manager, import it from a CDN, for example `"https://unpkg.com/@oddbird/popover-polyfill@latest/dist/popover.min.js"`.

Polyfill caveats:

- Don't use the `popover` IDL property in code that may run before the polyfill has loaded. The value isn't mirrored to the attribute, the polyfill won't pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill can't define the real `:popover-open` pseudo-class, so it applies a `.\:popover-open` class instead. Combine the two with `:is()` or `:where()`; otherwise browsers without `:popover-open` discard the whole rule.

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

`@oddbird/popover-polyfill` doesn't polyfill `popover="hint"` in browsers that already support native `auto` and `manual` popovers. There the unrecognized `"hint"` value falls back to `manual` (the HTML invalid-value default), so a tooltip opened by keyboard focus can stay open when a second one opens on hover, unless the invoker dismisses it on loss of interest.

A toggletip can also open on click, with no interest to lose, so a `manual` fallback would never close. Where `hint` is unsupported, switch toggletips to `popover="auto"` as they open. This has to happen in `beforetoggle`: the browser reads the popover type after that event, and changing the type of an already open popover closes it. `beforetoggle` doesn't bubble, so delegate with a capturing listener:

```js
// The popover property reports the type the browser actually uses: "manual" when hint is unsupported.
const probe = document.createElement("div");
probe.popover = "hint";
if (probe.popover !== "hint") {
  document.addEventListener("beforetoggle", ({ target, newState }) => {
    const toggletip = target.getAttribute("popover") === "hint"
      && document.querySelector(`[popovertarget="${CSS.escape(target.id)}"]`);
    if (newState === "open" && toggletip) {
      target.popover = "auto";
    }
  }, true);
}
```

### Anchor positioning

Browser support for Anchor positioning: Limited availability.
Supported by: Chrome 157 (Nov 2026), Edge 157 (Nov 2026), and Safari 27 (Sep 2026).
Unsupported in: Firefox.

Without anchor positioning, tethered elements such as `[popover]` overlays fall back to their default UA placement, centered in the viewport for popovers. Depending on whether the tooltip must stay tethered, load the polyfill conditionally or gate the positioning rules with `@supports`.

#### Option 1: polyfill (`@oddbird/css-anchor-positioning`)

When the element must stay tethered to its trigger in unsupported browsers, load `@oddbird/css-anchor-positioning` conditionally. Feature-detect with `CSS.supports("anchor-name: --a")` (or `"anchorName" in CSSStyleDeclaration.prototype`) and load it only when native support is missing.

With a bundler or import map:

```js
if (!CSS.supports("anchor-name: --a")) {
  import("@oddbird/css-anchor-positioning");
}
```

Without a bundler, import it from a CDN in a `<script type="module">`:

```html
<script type="module">
  if (!CSS.supports("anchor-name: --a")) {
    import("https://unpkg.com/@oddbird/css-anchor-positioning");
  }
</script>
```

Polyfill caveats:

- It doesn't support implicit anchors (from `popovertarget`, `commandfor`, `interestfor` or `showPopover({ source })`). Set a unique explicit `anchor-name` on each trigger and a matching `position-anchor` on its positioned element.
- It doesn't support `position-area` together with `position-try-fallbacks`. For elements that need fallbacks, position with `anchor()` on the inset properties (`top`, `left`, `right`, `bottom`) and `inset: auto` instead of `position-area`.
- Don't wrap polyfilled rules in `@supports`. Browsers without native support evaluate `@supports (position-area: ...)` and `@supports (anchor-name: --a)` as false and discard the block before the polyfill can read it.

```css
.trigger {
  /* Each trigger and positioned element pair shares a unique anchor name. */
  anchor-name: --my-trigger;
}

[popover].anchored-overlay {
  position-anchor: --my-trigger;
  /* anchor() on inset properties instead of position-area, for the polyfill. */
  inset: auto;
  top: anchor(bottom);
  left: anchor(left);
  margin: 0;
}
```

#### Option 2: progressive enhancement with `@supports` (no polyfill)

Without the polyfill, don't set `inset: auto` or `margin: 0` unconditionally on a `[popover]` that relies on `position-area` or `anchor()`. In browsers without anchor positioning, `inset: auto` overrides the UA centering (`inset: 0; margin: auto`) while `position-area` is ignored, which strands the popover at `(0, 0)` or on top of its trigger.

Gate `inset: auto` and `margin: 0` in `@supports` for the specific feature you use (for example `@supports (position-area: block-end)` or `@supports (top: anchor(bottom))`) so unsupported browsers keep the default centered placement, or add a matching `@supports not (...)` layout such as a fixed bottom sheet:

```css
@supports (position-area: block-end) {
  [popover].anchored-overlay {
    inset: auto;
    margin: 0;
    position-area: block-end span-inline-end;
    position-try-fallbacks: flip-block, flip-inline, flip-block flip-inline;
  }
}

@supports not (position-area: block-end) {
  /* Optional: replace the default centering with a fixed bottom bar. */
  [popover].anchored-overlay {
    position: fixed;
    inset: auto 0 0 0;
    width: auto;
    margin: 0;
  }
}
```
