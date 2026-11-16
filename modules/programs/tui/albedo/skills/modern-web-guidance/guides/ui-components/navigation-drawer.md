# Navigation Drawer

A navigation drawer is a panel that slides in from the edge of the viewport over the page and dims everything behind it. A trigger button opens it. Users dismiss it by swiping the panel off-screen, tapping the dimmed backdrop, activating a Close button inside the panel, or pressing `Escape`.

This guide builds the drawer from:

- A top-layer element (a modal `<dialog>` or a `popover="manual"` element; see [Choose the drawer element](#choose-the-drawer-element)), so the panel and its `::backdrop` cover everything on the page regardless of stacking context.
- A horizontally scrolling container with two scroll-snap stops, one open and one closed, so the browser handles the swipe natively, with momentum, velocity, and interruption tracking and no pointer-event code.
- A scroll-driven animation that ties the backdrop's opacity to the scroll position, so the dimming follows the drag.
- An `IntersectionObserver` on the panel that detects when it has fully entered or left the viewport, and closes the drawer and updates its state at those moments.

Prefer this over JavaScript-driven `transform` animations: the user's finger drives the panel's position directly rather than a tween, which matches the interaction users know from native mobile apps.

## Choose the drawer element

First decide whether the element is only ever a drawer, or whether it also becomes a regular, always-visible sidebar under some conditions (for example on wide screens). If the request does not say, assume it is only ever a drawer.

- Only ever a drawer: use a `<dialog>` element opened with `showModal()`. The browser makes the rest of the page inert, exposes the drawer as a modal dialog to assistive technologies, handles Escape, and restores focus on close. See [Implementation with `<dialog>`](#implementation-with-dialog).
- Also a sidebar: use a regular element with `role="dialog"` and `popover="manual"`, and remove the `role` while it acts as a sidebar. A `<dialog>` element does not work here because it is always exposed as a dialog, and a sidebar is not one. A popover is not modal, so the code must handle modality itself. See [Implementation for a drawer that also acts as a sidebar](#implementation-for-a-drawer-that-also-acts-as-a-sidebar).

## Implementation with `<dialog>`

### 1. Markup

The drawer is a `<dialog>` containing a horizontal scroller, which contains the visible "sheet". The trigger button lives in the page content. The close button has `autofocus` so it receives focus when the drawer opens.

```html
<!-- Name the dialog with aria-label, or with aria-labelledby if text in the drawer can serve as its name. -->
<dialog class="Drawer" id="drawer" aria-label="Navigation drawer">
  <div class="Drawer-scroller">
    <nav class="Drawer-sheet">
      <button id="drawer-close" aria-label="Close menu" autofocus>
        <!-- close icon or blank if icon inserted via CSS -->
      </button>
      <ul>
        <li><a href="/page-1">Page 1</a></li>
        <li><a href="/page-2">Page 2</a></li>
        <!-- ... -->
      </ul>
    </nav>
  </div>
</dialog>

<main>
  <header>
    <!-- aria-controls links the trigger to the drawer; aria-expanded reflects its state. -->
    <button id="drawer-open"
            aria-label="Menu"
            aria-expanded="false"
            aria-controls="drawer">
      <!-- open icon or blank if icon inserted via CSS -->
    </button>
  </header>
  <!-- Page content. -->
</main>
```

See the `icons` guide for keeping icons accessible.

### 2. Styles

#### Reset the dialog and fill the viewport

The dialog must cover the whole viewport so the swipe surface reaches edge to edge, so reset the default dialog styles (centered, size-capped, padded, bordered).

```css
.Drawer {
  /* Caps the sheet on large screens; on a phone it leaves 20% of the page
     visible, which tells users they can tap outside to dismiss. */
  --drawer-width: min(20em, 80dvw, 100dvw - 24px);

  /* Driven by the scroll-driven animation: 0 = closed, 1 = fully open. */
  --drawer-backdrop: 0;

  inset: 0;
  width: auto;
  height: auto;
  max-width: none;
  max-height: none;
  margin: 0;
  padding: 0;
  background: transparent;
  border: 0;
  overflow: visible;
}

/* The dim overlay also signals that the rest of the page is inert. */
.Drawer::backdrop {
  background: #000;
  /* Halves the range so the content beneath stays visible. */
  opacity: calc(var(--drawer-backdrop) / 2);
}
```

#### Build the swipe surface with scroll snap

The scroller is a horizontal grid wider than the viewport. Column 1 holds the sheet (`--drawer-width` wide); column 2 is an empty pseudo-element spacer as wide as the viewport. Snapping between the two columns opens and closes the drawer.

```css
.Drawer-scroller {
  position: relative;
  display: grid;
  grid-template-columns: var(--drawer-width) 100%;

  overflow-x: scroll;
  /* Stops the swipe chaining into the page's scroll at either edge. */
  overscroll-behavior: none;
  scrollbar-width: none;
  /* `mandatory` makes the drawer settle fully open or fully closed, never half-open. */
  scroll-snap-type: x mandatory;
}

@media (prefers-reduced-motion: no-preference) {
  .Drawer-scroller {
    scroll-behavior: smooth;
  }
}

/* Empty spacer: the "closed" snap stop. */
.Drawer-scroller::after {
  content: '';
  scroll-snap-align: end;
  /* The drawer opens already scrolled to this stop (off-screen),
     so the script only scrolls to the open position to animate it in. */
  scroll-initial-target: nearest;
}

.Drawer-sheet {
  display: grid;
  grid-template-rows: auto 1fr;
  /* svh, not vh or dvh, so the height does not jump when the
     iOS Safari address bar resizes mid-swipe. */
  height: 100svh;

  background: #333;
  color: #fff;
  overflow-y: auto;
  scroll-snap-align: start;
  scrollbar-width: none;
}
```

#### Tie the backdrop opacity to the scroll position

A scroll-driven animation maps `--drawer-backdrop` from 1 (open) to 0 (closed) across the scroller's range, so the backdrop fades in step with the drag.

Wrap the whole block in `@supports`. Browsers without `animation-timeline` still parse the `@keyframes` and would apply its `0%` value (`--drawer-backdrop: 1`) permanently, leaving the backdrop fully dimmed.

```css
@supports (animation-timeline: scroll()) {
  .Drawer {
    /* Makes the scroller's (descendant's) timeline name visible to .Drawer. */
    timeline-scope: --drawer-fade;
    animation: fade-drawer-backdrop linear both;
    animation-timeline: --drawer-fade;
  }

  .Drawer-scroller {
    scroll-timeline: --drawer-fade x;
  }

  /* Required: unregistered, --drawer-backdrop is a string that cannot
     interpolate, so the backdrop would jump between 0 and 1. */
  @property --drawer-backdrop {
    syntax: '<number>';
    inherits: true;
    initial-value: 0;
  }

  @keyframes fade-drawer-backdrop {
    0% { --drawer-backdrop: 1 }   /* Scroll start: fully open. */
    100% { --drawer-backdrop: 0 } /* Scroll end: fully closed. */
  }
}
```

### 3. Open and close the drawer

Opening is two steps: show the dialog as modal, then scroll the sheet into view. Closing is one step: scroll back to the spacer; an observer (step 4) closes the dialog once the sheet is fully off-screen.

```js
const drawer = document.getElementById('drawer');
const openBtn = document.getElementById('drawer-open');
const scroller = drawer.querySelector('.Drawer-scroller');
const sheet = drawer.querySelector('.Drawer-sheet');
const closeBtn = document.getElementById('drawer-close');

function openDrawer() {
  // Enter the top layer before scrolling. scroll-initial-target on the
  // spacer starts the scroller at the closed stop, off-screen.
  drawer.showModal();

  // behavior: 'auto' defers to CSS scroll-behavior (smooth unless reduced
  // motion is requested); snapping then locks the drawer fully open.
  scroller.scrollTo({left: 0, behavior: 'auto'});
}

function closeDrawer() {
  // Do not call close() here: it would leave the top layer mid-animation
  // and hide the slide-out. The observer in step 4 closes the dialog once
  // the sheet has left the viewport.
  scroller.scrollTo({left: scroller.offsetWidth, behavior: 'auto'});
}
```

### 4. Detect open and closed state

Use an `IntersectionObserver` on the sheet, not the scroll position, as the source of truth for the drawer's state. It fires however the sheet moved (swipe, programmatic scroll, snap settle), so every dismissal path ends in the same callback.

A modal `<dialog>` already makes the rest of the page inert while open and returns focus to the trigger on close, so the callbacks only close the dialog and keep `aria-expanded` in sync.

```js
function onDrawerOpened() {
  openBtn.setAttribute('aria-expanded', 'true');
}

function onDrawerClosed() {
  // Runs after the slide-out finishes, so it stays visible.
  drawer.close();
  openBtn.setAttribute('aria-expanded', 'false');
}

// Any visible pixel counts as "not closed", so the closed callback
// fires only once the sheet is completely gone.
const visibleThreshold = 1 / window.innerWidth;

const observer = new IntersectionObserver(
  (entries) => {
    // A batch can hold several entries during programmatic scrolling;
    // only the last describes the current state.
    const entry = entries.at(-1);
    if (entry.intersectionRatio < visibleThreshold) onDrawerClosed();
    if (entry.intersectionRatio === 1) onDrawerOpened();
  },
  // With the dialog as root, the ratio is how much of the sheet is swiped on-screen.
  {root: drawer, threshold: [visibleThreshold, 1]},
);
observer.observe(sheet);
```

### 5. Wire up the trigger and dismissal handlers

```js
openBtn.addEventListener('click', openDrawer);
closeBtn.addEventListener('click', closeDrawer);

// Light dismiss: a tap inside the dialog but outside the sheet closes it.
// Do not use closedby="any": the dialog fills the viewport, so taps land on
// the dialog rather than ::backdrop, and it would close without the slide-out.
drawer.addEventListener('click', (event) => {
  if (!sheet.contains(event.target)) closeDrawer();
});

// Escape fires `cancel` on a modal dialog: prevent the instant close and
// slide out instead. Browsers may make `cancel` non-cancelable on repeated
// Escape presses without user activation in between; the dialog then closes instantly.
drawer.addEventListener('cancel', (event) => {
  if (event.cancelable) {
    event.preventDefault();
    closeDrawer();
  }
});
```

## Implementation for a drawer that also acts as a sidebar

Use this when the same element also becomes a regular, always-visible sidebar under some conditions (see [Choose the drawer element](#choose-the-drawer-element)). Toggle `role` from the same media query that switches the layout (for example with `matchMedia()`): remove it while the element is a sidebar, and restore `role="dialog"` when it becomes a drawer again. This guide does not cover the sidebar layout itself.

Follow the [`<dialog>` implementation](#implementation-with-dialog), with these changes:

- Markup: `<div class="Drawer" id="drawer" popover="manual" role="dialog" aria-label="Navigation drawer">`. It must be `popover="manual"`: the built-in light dismiss of `auto` and `hint` would also fire mid-swipe.
- Open and close: call `showPopover()` instead of `showModal()` and `hidePopover()` instead of `close()`. The rest of the CSS and JS is unchanged.
- Modality: a popover is not modal, so the code must do what a modal dialog does natively:
  - Mark the rest of the page `inert` while the drawer is open.
  - Apply `aria-modal="true"` while the drawer is open, and remove it when it closes.
  - Move focus back to the trigger button after the drawer closes.
  - Handle Escape with a `keydown` listener on `document`, since popovers do not fire `cancel`.

```js
const main = document.querySelector('main');

function openDrawer() {
  drawer.showPopover();
  // Make everything outside the drawer inert (include sibling
  // <header>/<footer> landmarks if they are outside <main>).
  main.inert = true;
  drawer.setAttribute('aria-modal', 'true');
  scroller.scrollTo({left: 0, behavior: 'auto'});
}

function onDrawerClosed() {
  // The observer also reports "closed" on page load; ignore it unless open.
  if (!drawer.hasAttribute('aria-modal')) return;
  drawer.hidePopover();
  main.inert = false;
  drawer.removeAttribute('aria-modal');
  openBtn.setAttribute('aria-expanded', 'false');
  openBtn.focus();
}

// Popovers do not fire `cancel`; listen on document because focus may be in the drawer.
document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && drawer.hasAttribute('aria-modal')) closeDrawer();
});
```

## Fallback strategies

Baseline status for Scroll snap: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 69 (Sep 2018), Edge 79 (Jan 2020), Firefox 68 (Jul 2019), and Safari 11 (Sep 2017).

Baseline status for Intersection observer: Widely available. It's been Baseline since 2019-03-25.
Supported by: Chrome 58 (Apr 2017), Edge 16 (Oct 2017), Firefox 55 (Aug 2017), Safari 12.1 (Mar 2019), and Safari iOS 12.2 (Mar 2019).

The scroll-driven backdrop fade and `scroll-initial-target` are progressive enhancements with simple fallbacks for when wide browser support is required.

### Backdrop fade without `animation-timeline`

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

Detect with `CSS.supports('animation-timeline: scroll()')` and, where unsupported, write `--drawer-backdrop` from a `scroll` listener. The `@supports` block in step 2 keeps the keyframes from applying there, so the script is the only writer.

```js
if (!CSS.supports('animation-timeline: scroll()')) {
  scroller.addEventListener('scroll', () => {
    // Same mapping as the keyframes: scroll 0 = 1 (open), sheet width = 0 (closed).
    const ratio = 1 - scroller.scrollLeft / sheet.offsetWidth;
    drawer.style.setProperty('--drawer-backdrop', ratio);
  });
}
```

### Initial scroll position without `scroll-initial-target`

Browser support for scroll-initial-target: Limited availability.
Supported by: Chrome 133 (Feb 2025) and Edge 133 (Feb 2025).
Unsupported in: Firefox and Safari.

Detect with `CSS.supports('scroll-initial-target', 'nearest')`. Where unsupported, jump-scroll to the closed position in `openDrawer()` right after showing the drawer (`showModal()`, or `showPopover()` when it [also acts as a sidebar](#implementation-for-a-drawer-that-also-acts-as-a-sidebar)). Otherwise the drawer appears instantly in the open position with no slide-in.

```js
async function openDrawer() {
  drawer.showModal(); // sidebar variant: showPopover(), main.inert = true, and aria-modal="true"

  if (!CSS.supports('scroll-initial-target', 'nearest')) {
    scroller.scrollTo({left: scroller.offsetWidth, behavior: 'instant'});
    // Wait two frames for the jump to commit; after one, the next
    // scrollTo would cancel it before the browser applies it.
    await new Promise((r) =>
      requestAnimationFrame(() => requestAnimationFrame(r))
    );
  }

  scroller.scrollTo({left: 0, behavior: 'auto'});
}
```

### Without `@property`

Baseline status for Registered custom properties: Newly available. It's been Baseline since 2024-07-09.
Supported by: Chrome 85 (Aug 2020), Edge 85 (Aug 2020), Firefox 128 (Jul 2024), and Safari 16.4 (Mar 2023).

`@property` is needed only because the scroll-driven animation interpolates `--drawer-backdrop` between keyframes; unregistered, the property is a string and jumps between 0 and 1. Every browser with scroll-driven animations also supports `@property`, and the script fallback above writes a fresh number on every scroll frame without interpolating, so no separate `@property` fallback is needed.

### Without the Popover API (sidebar variant only)

Baseline status for the api.HTMLElement.showPopover capability: Widely available. It's been Baseline since 2024-04-16.
Supported by: Chrome 114 (May 2023), Edge 114 (Jun 2023), Firefox 125 (Apr 2024), and Safari 17 (Sep 2023).

Baseline status for inert: Widely available. It's been Baseline since 2023-04-11.
Supported by: Chrome 102 (May 2022), Edge 102 (May 2022), Firefox 112 (Apr 2023), and Safari 15.5 (May 2022).

The [sidebar variant](#implementation-for-a-drawer-that-also-acts-as-a-sidebar) uses `popover="manual"` and handles dismissal entirely in JavaScript, so it does not depend on light dismiss, `popovertarget`, or top-layer `Escape` handling. Besides top-layer promotion (`showPopover()`) and `::backdrop`, it relies only on `autofocus` being processed when shown.

If wider support is needed, do not branch on feature detection; drop popover entirely. Drop the `popover="manual"` attribute, replace top-layer promotion with `position: fixed` and a high `z-index`, replace `::backdrop` with a sibling element styled identically (using the same `--drawer-backdrop` custom property), toggle visibility from a class instead of `showPopover()`/`hidePopover()`, and call `closeBtn.focus({preventScroll: true})` in `openDrawer()` after making the drawer visible (`preventScroll` avoids scrolling the container early). The rest of the component (scroll snap, the scroll-driven backdrop animation, the `IntersectionObserver`, and the dismissal handlers) is unchanged.
