# Animate Element Entry and Exit

CSS transitions don't run when an element is first added to the DOM or when its `display` changes from `none`. `@starting-style` and `transition-behavior: allow-discrete` make entry and exit animations declarative.

## Implementation

### 1. Animate `display: none` toggles

To animate an element shown and hidden through an attribute such as `hidden` (`display: none`):

1. Set the final visible values (for example `opacity: 1`) on the base rule.
2. Use `@starting-style` for the values to transition from when the element becomes visible.
3. Include `display` in `transition` and set `transition-behavior: allow-discrete`.
4. Set the exit values on the `[hidden]` rule.

```css
.card {
  display: block;
  opacity: 1;
  translate: 0;
  transition:
    display,
    opacity ease-out,
    translate ease-out;
  transition-duration: 0.4s;
  /* Declared separately, after transition, so the shorthand neither resets it
     nor fails in older browsers. */
  transition-behavior: allow-discrete;
}

/* Entry: transition from these values when first rendered. */
@starting-style {
  .card {
    opacity: 0;
    translate: 0 -20px;
  }
}

/* Exit: transition to these values when hidden. */
.card[hidden] {
  display: none;
  opacity: 0;
  translate: 0 -20px;
}

@media (prefers-reduced-motion: reduce) {
  .card {
    /* No movement; a short, simple fade. */
    translate: none;
    transition-duration: 0.1s;
  }

  @starting-style {
    .card {
      translate: none;
    }
  }

  .card[hidden] {
    translate: none;
  }
}
```

### 2. Animate DOM insertion and removal

For elements added with `appendChild()` or removed with `remove()`:

- Entry: use `@starting-style` as above. The browser sees the change from no styles to the element's initial styles and transitions from the `@starting-style` values.
- Removal: `element.remove()` is instant and runs no transition, so trigger the exit transition first and wait for it to finish before removing the node.

```javascript
// 1. Start the exit transition.
element.hidden = true;

// 2. Wait for running transitions and animations, with a failsafe timeout
//    for animations that never end (such as looping ones).
const animations = element.getAnimations();
if (animations.length > 0) {
  await Promise.race([
    // allSettled keeps waiting even if some animations are cancelled.
    Promise.allSettled(animations.map(a => a.finished)),
    new Promise(r => setTimeout(r, 2000))
  ]);
}

// 3. Remove the node.
element.remove();
```

## Constraints and accessibility

- Transitioning `display` requires `transition-behavior: allow-discrete`; without it the element disappears instantly on exit.
- Declare `allow-discrete` with a separate `transition-behavior` declaration, not inside the `transition` shorthand. Older browsers drop the whole `transition` declaration if the shorthand contains it, which is only acceptable when that is what you want.
- Entry animations need `@starting-style`. Browsers skip transitions on an element's first style update (initial render or a change from `display: none`) unless it is provided.
- When animating top-layer elements such as `<dialog>` or a popover, include `overlay` in the `transition` list so they stay in the top layer during the exit animation.
- Respect `prefers-reduced-motion`.
- `@starting-style` only sets the starting point of an entry transition. Exit animations come from the transition to the hidden state.

## Fallback strategies

Baseline status for @starting-style: Newly available. It's been Baseline since 2024-08-06.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 129 (Aug 2024), and Safari 17.5 (May 2024).

### transition-behavior

Baseline status for transition-behavior: Newly available. It's been Baseline since 2024-08-06.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 129 (Aug 2024), and Safari 17.4 (Mar 2024).

Browser support for the css.properties.transition-behavior.transitionable_display capability: Limited availability.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), and Safari 18 (Sep 2024).
Unsupported in: Firefox.

Firefox 129+ parses `transition-behavior: allow-discrete` (`CSS.supports('transition-behavior', 'allow-discrete')` returns `true`) but doesn't actually transition `display` (Firefox bug 1882408), so elements vanish immediately on exit.

To detect discrete `display` transitions reliably, don't rely on `CSS.supports('transition-behavior', 'allow-discrete')` alone. Probe whether a temporary element's computed `display` stays visible while transitioning to `none`:

```javascript
let supportsDisplayTransition;
function canTransitionDisplay() {
  if (supportsDisplayTransition !== undefined) return supportsDisplayTransition;
  if (!window.CSS?.supports?.('transition-behavior', 'allow-discrete') || !document.body) {
    return false;
  }
  const probe = document.createElement('div');
  // The shorthand is deliberate: browsers that don't parse allow-discrete drop the
  // whole declaration, display: none applies instantly, and the probe correctly
  // returns false. !important guards against global reduced-motion resets such as
  // `* { transition: none !important }`.
  probe.style.cssText = 'transition: display 1s allow-discrete !important; display: block;';
  document.body.appendChild(probe);
  getComputedStyle(probe).display;
  probe.style.display = 'none';
  supportsDisplayTransition = getComputedStyle(probe).display === 'block';
  probe.remove();
  return supportsDisplayTransition;
}
```

### Exit fallback without discrete `display` transitions

`@starting-style` entry animations work in all modern browsers without JavaScript. Where discrete `display` transitions are unsupported (`!canTransitionDisplay()`), setting `hidden` applies `display: none` immediately and skips the exit animation, both when hiding and before `element.remove()`. Separate the visual exit state (`[data-closing]`) from `display: none` (`[hidden]`) so `opacity` and `translate` finish animating before the element is hidden or removed. Replace the `.card[hidden]` rules from step 1, including the `prefers-reduced-motion` override, with:

```css
.card:where([hidden], [data-closing]) {
  opacity: 0;
  translate: 0 -20px;
}

.card[hidden] {
  display: none;
}

@media (prefers-reduced-motion: reduce) {
  .card:where([hidden], [data-closing]) {
    translate: none;
  }
}
```

```javascript
async function hideElement(el) {
  if (canTransitionDisplay()) {
    el.hidden = true;
  } else {
    el.setAttribute('data-closing', '');
  }

  const animations = el.getAnimations();
  if (animations.length > 0) {
    await Promise.race([
      Promise.allSettled(animations.map((a) => a.finished)),
      new Promise((r) => setTimeout(r, 2000)),
    ]);
  }

  // Skipped if showElement() cancelled the close mid-animation.
  if (el.hasAttribute('data-closing')) {
    el.removeAttribute('data-closing');
    el.hidden = true;
  }
}

function showElement(el) {
  el.removeAttribute('data-closing');
  el.hidden = false;
}

async function removeElement(el) {
  await hideElement(el);
  el.remove();
}
```
