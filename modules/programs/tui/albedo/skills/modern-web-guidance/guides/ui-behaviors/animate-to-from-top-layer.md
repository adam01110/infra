# Animate Elements To and From Top Layer

Top-layer elements (`<dialog>`, elements with the `popover` attribute, tooltips) are hard to animate because they switch between `display: none` and visible. `@starting-style`, `transition-behavior: allow-discrete` and the `overlay` property give them smooth entry and exit transitions. The examples use native CSS nesting.

## How it works

1. Discrete transitions: animating `display` requires `transition-behavior: allow-discrete`, which keeps the element visible during its exit transition. If you use the `transition` shorthand, declare `transition-behavior: allow-discrete` after it so the shorthand doesn't reset it.
2. `overlay`: an element moving into or out of the top layer must transition `overlay` too. That keeps it in the top layer for the whole animation, so it isn't clipped by other elements or the viewport too early.
3. Entry with `@starting-style`: it defines the values to transition from when the element first renders or its `display` changes from `none`. Place the `@starting-style` block inside or after the open-state selector so it cascades correctly.
4. Backdrop: animate `::backdrop` the same way, with transitions on its own properties.

Exit animations come from the transition back to the base (closed) state, not from `@starting-style`.

## Example

```css
/* 1. Visible (open) state. */
dialog[open],
[popover]:popover-open {
  opacity: 1;

  /* 2. Entry starting state; must come after the open state. */
  @starting-style {
    opacity: 0;
  }

  /* Scale only for users who haven't asked for reduced motion (see 5). */
  @media (prefers-reduced-motion: no-preference) {
    transform: scale(1);

    @starting-style {
      transform: scale(0.9);
    }
  }
}

/* 3. Base (closed/exit) state and transitions. */
dialog,
[popover] {
  opacity: 0;

  /* Top-layer elements must transition display and overlay. */
  transition-property: opacity, transform, display, overlay;
  transition-duration: 0.3s;
  transition-timing-function: ease-out;
  /* Declared separately, after transition, so a shorthand neither resets it
     nor fails in older browsers. */
  transition-behavior: allow-discrete;

  @media (prefers-reduced-motion: no-preference) {
    transform: scale(0.9);
  }
}

/* 4. Backdrop. */
dialog::backdrop,
[popover]::backdrop {
  background-color: rgba(0, 0, 0, 0);
  transition-property: background-color, display, overlay;
  transition-duration: 0.3s;
  transition-timing-function: ease-out;
  transition-behavior: allow-discrete;
}

dialog[open]::backdrop,
[popover]:popover-open::backdrop {
  background-color: rgba(0, 0, 0, 0.5);

  @starting-style {
    background-color: rgba(0, 0, 0, 0);
  }
}

/* 5. Reduced motion: the scale above only applies with no-preference,
   so this just shortens the fade. */
@media (prefers-reduced-motion: reduce) {
  dialog,
  [popover] {
    transition-duration: 0.1s;
  }
}
```

## Constraints and accessibility

- Include `overlay` in the transition list of every element that moves into or out of the top layer.
- Transitioning `display` and `overlay` requires `transition-behavior: allow-discrete`.
- Declare `allow-discrete` in a separate `transition-behavior` declaration, not inside the `transition` shorthand. Older browsers drop the whole `transition` declaration if the shorthand contains it, which is only acceptable when that is what you want.
- For reduced motion, apply transforms only inside `@media (prefers-reduced-motion: no-preference)` and shorten the duration inside `@media (prefers-reduced-motion: reduce)`, so those users get a short fade.

## Fallback strategies

Baseline status for @starting-style: Newly available. It's been Baseline since 2024-08-06.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), Firefox 129 (Aug 2024), and Safari 17.5 (May 2024).

Browser support for overlay: Limited availability.
Supported by: Chrome 117 (Sep 2023) and Edge 117 (Sep 2023).
Unsupported in: Firefox and Safari.

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

### Top-layer exit fallback

Entry animations work in pure CSS in every browser that supports `@starting-style`; no `.is-opening` class is needed, because entry doesn't depend on `overlay` or discrete `display` transitions.

Exit animations need both `overlay` and discrete `display` transitions. Where either is missing (such as in Firefox and Safari), wrap the open-state selectors in `:is()` and append `:where(:not([data-closing]))`, nesting `&::backdrop` and `@starting-style` inside. Setting `data-closing` then runs the exit transition while the element is still in the top layer. Wait for `getAnimations()` to settle before calling `.close()` or `.hidePopover()`.

```css
:is(dialog[open], [popover]:popover-open):where(:not([data-closing])) {
  opacity: 1;

  @starting-style {
    opacity: 0;
  }

  @media (prefers-reduced-motion: no-preference) {
    transform: scale(1);

    @starting-style {
      transform: scale(0.9);
    }
  }

  &::backdrop {
    background-color: rgb(0 0 0 / 0.5);

    @starting-style {
      background-color: transparent;
    }
  }
}
```

```javascript
// Evaluated lazily: canTransitionDisplay() needs document.body, so a top-level
// const would always be false if this script runs in <head>.
function supportsTopLayerExit() {
  return window.CSS?.supports?.('overlay', 'auto') && canTransitionDisplay();
}

async function closeTopLayer(element) {
  if (!supportsTopLayerExit()) {
    element.setAttribute('data-closing', '');
    const animations = element.getAnimations({ subtree: true });
    if (animations.length > 0) {
      await Promise.race([
        Promise.allSettled(animations.map((a) => a.finished)),
        new Promise((r) => setTimeout(r, 2000)),
      ]);
    }
    if (!element.hasAttribute('data-closing')) return;
    element.removeAttribute('data-closing');
  }

  element.close();
  // For a popover:
  // element.hidePopover();
}

// Route native close requests (Esc, closedby light dismiss) through the same
// helper so they animate instead of closing instantly.
for (const dialog of document.querySelectorAll('dialog')) {
  dialog.addEventListener('cancel', (event) => {
    event.preventDefault();
    closeTopLayer(dialog);
  });
}
```

Popover light dismiss and `popovertarget` toggles can't be intercepted (`beforetoggle` is only cancelable when opening), so in browsers that need this fallback those exits are instant. If the exit animation matters, provide an explicit close control that calls `closeTopLayer()`.

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
