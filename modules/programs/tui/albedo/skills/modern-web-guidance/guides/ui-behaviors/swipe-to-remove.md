# Swipe to remove

Swipe to remove is common in mobile apps but hard to build cleanly on the web. CSS scroll snap hooks the swipe into the browser's own scrolling, which gives high performance and physics-based momentum without a JavaScript gesture library.

The same pattern works for any single-action swipe (remove, archive, mark as read, snooze). Only the action's visuals change; the mechanics stay the same.

> If a horizontal swipe should instead snap open a set of action buttons or a side menu without committing an action, see the `swipe-to-reveal` guide.

## How to implement

The component has a list (the `<ul>`) and items. Each item is an outer `<li>`, an inner scroll track (the scroll container with the snap points) and a content element (the visible row). The action's revealed UI (trash icon, archive label and so on) sits on either side of the content. The list owns shared wiring (lazy item setup, picking up added items); each item owns its own swipe detection.

### Step 1: Markup

Swiping can't be done with a keyboard, a single tap or a screen reader, so every swipe action needs another way to run it (see Accessibility). This example gives each swipe action its own button. The button's `data-direction` names the side of the row that its swipe reveals (`right` for a left swipe, `left` for a right swipe), matching the `direction` value in Step 4, and the item name in its text tells screen reader users which row it acts on.

```html
<!-- tabindex="-1" lets focus move here when the last item is removed (Step 4). -->
<h2 id="list-heading" tabindex="-1">Inbox</h2>

<!-- Safari drops list semantics when list-style is none; role="list" restores
     the item count for screen readers. -->
<ul class="SwipeableList" role="list" aria-labelledby="list-heading">
  <li id="list-item-1" class="SwipeableList-item">
    <div class="SwipeableList-track">
      <div class="SwipeableList-content">
        <span class="SwipeableList-label">Item One</span>
        <button type="button" class="SwipeableList-action" data-direction="right">
          Remove<span class="visually-hidden"> Item One</span>
        </button>
      </div>
    </div>
  </li>
  <!-- ...more items... -->
</ul>

<!-- Screen readers only announce changes to a live region that was already in
     the page, so render it empty and fill it on removal (Step 4). -->
<p role="status" class="SwipeableList-status visually-hidden"></p>
```

### Step 2: Make the track a horizontal snap container with three snap points

The track has three full-width columns: a left spacer (`::before`), the content and a right spacer (`::after`). Snapping to a spacer means the content is fully off-screen, which is the rest position after a committed swipe.

All track styling is gated behind an `.is-initialized` class on the item. Until the JavaScript has wired up swipe detection and added the class (Step 4), the item renders as plain content with no horizontal scroller, so users can't swipe before it works.

```css
.SwipeableList {
  list-style: none;
}

.SwipeableList-item {
  /* A containing block for the absolutely positioned icons (Step 3), and
     clipping during the removal animation (Step 4). */
  contain: content;
}

.SwipeableList-item.is-initialized .SwipeableList-track {
  /* Left spacer | content | right spacer, each 100% of the track. */
  display: grid;
  grid-template-columns: 100% 100% 100%;

  /* Horizontal scrolling only; vertical overflow is clipped so the reveal
     stays inside the row. */
  overflow: scroll clip;

  /* Stops the swipe chaining into page scroll or the iOS/Android back gesture. */
  overscroll-behavior-x: none;

  /* The swipe needs no scrollbar; the action buttons are the visible alternative. */
  scrollbar-width: none;

  /* mandatory: the track always rests on a snap point, never part-scrolled. */
  scroll-snap-type: x mandatory;
}

/* The spacers are the left and right snap targets and carry the reveal color
   that slides into view behind the content during a swipe. */
.SwipeableList-item.is-initialized .SwipeableList-track::before,
.SwipeableList-item.is-initialized .SwipeableList-track::after {
  content: '';

  /* Required for a valid snap target. The value doesn't matter: each snap
     point spans the whole scroll container, so every alignment rests at the
     same position. */
  scroll-snap-align: start;

  /* Example color: red signals "delete"; use another for archive, mark as read, etc. */
  background-color: hsl(0 65% 50%);
}

.SwipeableList-content {
  /* Above the action icons (Step 3), covering them until the user swipes. */
  position: relative;
  z-index: 2;

  /* Required for a valid snap target (the rest position); value doesn't matter. */
  scroll-snap-align: start;

  /* Paints over the revealed spacer color. */
  background: Canvas;

  /* Row separator (example). */
  border-bottom: 1px solid #eee;
}

/* Gated so it only applies once the track is a scroll container. Before that,
   scroll-initial-target would walk up to the nearest scrollable ancestor
   (usually the document) and shift the page's initial scroll position to this
   row. With the gate, the initial scroll happens inside the track. */
.SwipeableList-item.is-initialized .SwipeableList-content {
  scroll-initial-target: nearest;
}

/* The track can be focusable, but its overflow is clipped, so a focus ring on
   the track itself would be invisible. Draw it on the content instead. */
.SwipeableList-track:focus-visible .SwipeableList-content {
  outline: auto;
  outline-offset: -2px;
}
```

### Step 3: Add the action icons

The action color is on the spacers (Step 2); the action icon is on the list item, anchored to the row's left and right edges.

> [!NOTE]
> In this guide, "left" means the left side of the row, revealed by swiping right, and "right" means the right side, revealed by swiping left.

The placement, sizing and motion below are a starting point. Adjust icon size, insets, the threshold pop scale, transition duration, and even pseudo-elements versus real DOM nodes to suit your design. The only mechanical requirements are that the icon sits behind the content (so the content covers it before a swipe) and inside the list item (so it doesn't scroll with the spacer).

```css
/* Icons are absolutely positioned in the row (a containing block via
   contain: content) at z-index 1, under the content at z-index 2. */
.SwipeableList-item.is-initialized::before,
.SwipeableList-item.is-initialized::after {
  /* Inline SVG icon; swap in whatever fits the action. fill='white' contrasts
     with the red spacer; change it for a light background. */
  --action-icon: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='white'><path d='M9 3v1H4v2h1v13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V6h1V4h-5V3H9zm0 5h2v9H9V8zm4 0h2v9h-2V8z'/></svg>");

  content: '';
  position: absolute;
  z-index: 1;

  /* Example size; background-size: contain scales the icon with width. */
  width: 1.5em;
  aspect-ratio: 1;
  top: 50%;
  translate: 0 -50%;

  /* Animates the activate-point pop and the removal fade (0.2s is an example). */
  transition: scale 0.2s ease, opacity 0.2s ease;

  background: var(--action-icon) center / contain no-repeat;
}
/* Example insets from the row edges. */
.SwipeableList-item.is-initialized::before { left: 1.5em; }
.SwipeableList-item.is-initialized::after  { right: 1.5em; }

/* Pop the icon once the swipe passes the activate point (class set in Step 4). */
.SwipeableList-item.is-activating::before,
.SwipeableList-item.is-activating::after {
  scale: 1.333;
}

/* Fade and shrink the icons as the row collapses (class set at commit in Step 4). */
.SwipeableList-item.is-removing::before,
.SwipeableList-item.is-removing::after {
  scale: 0.5;
  opacity: 0;
}

/* Show only the icon on the leading side of the swipe (direction set in Step 4). */
.SwipeableList-item.is-activating[data-swipe-direction="left"]::after,
.SwipeableList-item.is-activating[data-swipe-direction="right"]::before {
  visibility: hidden;
}

@media (prefers-reduced-motion: reduce) {
  .SwipeableList-item.is-activating::before,
  .SwipeableList-item.is-activating::after {
    scale: 1;
  }
}

/* Forced colors replaces the action background with Canvas, hiding the white
   icon, so paint the icon shape in CanvasText instead. */
@media (forced-colors: active) {
  .SwipeableList-item.is-initialized::before,
  .SwipeableList-item.is-initialized::after {
    forced-color-adjust: none;
    background: CanvasText;
    mask: var(--action-icon) center / contain no-repeat;
  }
}
```

### Step 4: Detect the commit with `IntersectionObserver`

Observe the content with an `IntersectionObserver` rooted at the track. As the user swipes, the content's intersection ratio drops. Use two thresholds:

- `activateThreshold`, a high ratio such as 0.8: below it, the user is past the visual activate point; toggle the icon pop.
- `commitThreshold`, a low ratio such as 0.2: below it, the user has committed. Start the remove animation immediately rather than waiting for the snap to settle. The collapsing row blends into the swipe's momentum, which feels much more responsive.

The code also handles:

- Lazy per-item setup. One outer `IntersectionObserver` rooted at the viewport sets each item up the first time it scrolls into view and pauses its swipe observer when it scrolls away. This bounds the number of active observers and avoids reading layout values like `clientWidth`, which are 0 before the item renders.
- Dynamic items. Lists grow (initial render, infinite scroll, server push), so a `MutationObserver` on the `<ul>` registers added items with the outer observer.
- Action buttons. A click (or `Enter`) on an action button runs the same `commit` function as the swipe it stands in for, so both share the focus move, announcement and removal animation. The action color and icon only appear when a swipe scrolls the track, not when the button is used.

```js
// Per-item handles, created on first setup and used by the viewport observer
// to start and stop each item's inner observer.
const swipeObservers = new WeakMap();

// Sets an item up on first entry (setupItem reads layout values that are 0
// before render), starts its inner observer while visible, stops it offscreen.
const viewportObserver = new IntersectionObserver((entries) => {
  for (const entry of entries) {
    const item = entry.target;
    if (entry.isIntersecting) {
      const handle = swipeObservers.get(item) ?? setupItem(item);
      handle.observer.observe(handle.content);
    } else {
      const handle = swipeObservers.get(item);
      if (handle) handle.observer.unobserve(handle.content);
    }
  }
});

function setupItem(item) {
  const track = item.querySelector('.SwipeableList-track');
  const content = track.querySelector('.SwipeableList-content');

  // Turns on the CSS from Steps 2 and 3. Done before the inner observer is
  // attached so the snap container exists when callbacks fire.
  item.classList.add('is-initialized');

  // activateThreshold: the icon-pop point. commitThreshold: the point of no
  // return; past it the action commits even if the user releases and the track
  // snaps back. A low value (~0.2) commits before the snap settles.
  const activateThreshold = 0.8;
  const commitThreshold = 0.2;

  // Rooted at the track. Vertical scrolling of the list moves root and target
  // together, so this only fires for horizontal swipes.
  const observer = new IntersectionObserver((entries, observer) => {
    const entry = entries.at(-1);
    const ratio = entry.intersectionRatio;

    // A positive offset from the track's left edge means the content was pulled
    // right (left spacer revealed), so the leading icon is on the left.
    const direction = (entry.boundingClientRect.x - entry.rootBounds.x) > 0
      ? 'left'
      : 'right';

    if (ratio < commitThreshold) {
      // The entry's boundingClientRect is the last reliable measurement before
      // the animation; removeItem reuses it for the height and slide distance.
      commit(direction, entry);
      return;
    }

    item.classList.toggle('is-activating', ratio < activateThreshold);

    // Keep the previous direction at rest so the icon's exit animation ends on
    // the side the user swiped toward.
    if (entry.boundingClientRect.x !== entry.rootBounds.x) {
      item.dataset.swipeDirection = direction;
    }
  }, {
    root: track,
    threshold: [commitThreshold, activateThreshold],
  });

  // Swipes and action buttons both commit here. The guard stops a second swipe
  // or click from removing the row twice.
  function commit(direction, entry) {
    if (item.classList.contains('is-removing')) return;
    removeItem(item, content, direction, entry);
    viewportObserver.unobserve(item);
    observer.disconnect();
  }

  // Observation starts from the viewport observer once the item is in view.
  const handle = {observer, content, track, commit};
  swipeObservers.set(item, handle);
  return handle;
}

async function removeItem(item, content, direction, entry) {
  // Removing or inerting the row would drop focus to <body>, so first move it
  // to the next row (or the previous one, or the list heading when the list is
  // empty), skipping rows that are still collapsing. Keep focus on the same
  // kind of element: if the row's track had focus (some browsers make the track
  // a tab stop even when it contains buttons), focus the next row's track so the
  // row-sized focus indicator appears where expected; otherwise focus the next
  // row's first button.
  const list = item.parentElement;
  if (item.contains(document.activeElement)) {
    const rows = [...list.children].filter(
      (row) => row === item || !row.classList.contains('is-removing'),
    );
    const index = rows.indexOf(item);
    const next = rows[index + 1] ?? rows[index - 1];
    const listHeading = document.getElementById(list.getAttribute('aria-labelledby'));
    const firstButton = next?.querySelector('button');
    const target = document.activeElement.matches('.SwipeableList-track')
      ? next?.querySelector('.SwipeableList-track')
      : firstButton;
    (target ?? listHeading).focus();
    // Not every browser lets the track take focus; fall back to the button.
    if (target && document.activeElement !== target) (firstButton ?? listHeading).focus();
  }

  // A disappearing row isn't announced, so name it in the status region from Step 1.
  const label = item.querySelector('.SwipeableList-label').textContent;
  document.querySelector('.SwipeableList-status').textContent = `${label} removed`;

  // Sliding the row off-screen is large movement: skip it under reduced motion
  // and use a shorter collapse. 150ms and 300ms are example durations.
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const opts = { duration: reduce ? 150 : 300, easing: 'ease', fill: 'forwards' };

  const rect = entry.boundingClientRect;
  // Content offset from the track's left edge.
  const x = rect.x - entry.rootBounds.x;
  // Distance the content must travel to be fully out of view.
  const translate = direction === 'left'
    ? rect.width - x
    : -(x + rect.width);

  // CSS transitions handle the declarative styles (icons) and WAAPI the computed
  // values; wait for all of them. The content slide matters because the height
  // collapse can otherwise finish before smooth scroll snapping has moved the
  // content fully off-screen.
  item.classList.add('is-removing');
  item.animate([{ height: `${rect.height}px` }, { height: '0px' }], opts);
  if (!reduce) content.animate([{ translate: `${translate}px` }], opts);
  await Promise.allSettled(
    item.getAnimations({ subtree: true }).map((a) => a.finished),
  );

  // Safari scroll-latching bug: removing the node while the swipe's momentum is
  // still resolving makes the next item (sliding up into its place) inherit the
  // scroll and scroll itself off-screen. Detect Safari through the Safari-only
  // GestureEvent and defer removal until the gesture has settled. 5s is
  // conservative; anything longer than the momentum tail works. inert blocks
  // interaction with the row meanwhile.
  if (globalThis.GestureEvent) {
    item.inert = true;
    setTimeout(() => item.remove(), 5000);
  } else {
    item.remove();
  }
}

function setupList(list) {
  for (const item of list.children) {
    if (item.matches('.SwipeableList-item')) {
      viewportObserver.observe(item);
    }
  }

  // Pick up items added later. Removals need no handling here: commit()
  // unobserves the item before removing it.
  new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.ELEMENT_NODE &&
            node.matches('.SwipeableList-item')) {
          viewportObserver.observe(node);
        }
      }
    }
  }).observe(list, { childList: true });

  // Delegated so later items work too. Keyboard users can reach a button before
  // its row has scrolled into view, so set the item up on demand.
  list.addEventListener('click', (event) => {
    const button = event.target.closest('.SwipeableList-action');
    const item = button?.closest('.SwipeableList-item');
    if (!item) return;
    const handle = swipeObservers.get(item) ?? setupItem(item);
    // Commit with the button's revealed side, with the same measurements an
    // IntersectionObserver entry carries.
    handle.commit(button.dataset.direction, {
      boundingClientRect: handle.content.getBoundingClientRect(),
      rootBounds: handle.track.getBoundingClientRect(),
    });
  });
}

document.querySelectorAll('.SwipeableList').forEach(setupList);
```

### Step 5: Fit the action to the use case

For other actions, only the visuals and the commit handler's body change:

- Archive: green or blue background, archive icon; move the item to an archive list instead of removing it.
- Mark as read: subdued background, checkmark icon; update the item's state and re-render (or just remove an `.unread` class).
- Snooze: blue background, clock icon; hide the item until a chosen time.

The scroll, snap and observation mechanics stay the same.

#### Different actions per swipe direction

A row can also offer two actions, one per swipe direction (for example archive on a right swipe, delete on a left swipe), as many native mail apps do. Scrolling, snapping and commit detection don't change; only the commit handler does. Pick the handler from `direction` (the revealed side), and give each action its own button whose `data-direction` names the side its swipe reveals (Step 1). Define `archiveItem` with the same signature as `removeItem`:

```js
function commit(direction, entry) {
  if (item.classList.contains('is-removing')) return;
  const handler = direction === 'left' ? archiveItem : removeItem;
  handler(item, content, direction, entry);
  viewportObserver.unobserve(item);
  observer.disconnect();
}
```

`removeItem` is named for the destructive case, but what it does (collapse the row, slide the content off, drop the node) is a generic "animate this row away" routine that suits archive, mark as read or snooze too, since the row leaves this list either way. If neither handler actually deletes anything (both move the item elsewhere), rename it to something neutral such as `dismissItem`.

To make the two actions visually distinct, set a color and icon per direction on the item, then paint the track with a split gradient and the two pseudo-element icons from the same variables:

```css
.SwipeableList-item {
  /* --left-* is revealed by swiping right (e.g. archive);
     --right-* by swiping left (e.g. delete). */
  --left-action-color: hsl(140 50% 40%);
  --left-action-icon: url("…archive svg…");
  --right-action-color: hsl(0 65% 50%);
  --right-action-icon: url("…trash svg…");
}

.SwipeableList-item.is-initialized .SwipeableList-track {
  /* background-attachment: local makes the gradient's positioning area the
     scrollable area (3x the visible width), so the default size fills it and
     the 50% hard stop lines up with the middle of the resting content column.
     The color also stays continuous behind the content as it slides off, so
     the leading color shows the whole way. */
  background-image: linear-gradient(
    to right,
    var(--left-action-color) 50%,
    var(--right-action-color) 50%
  );
  background-attachment: local;
}

.SwipeableList-item.is-initialized::before { background-image: var(--left-action-icon); }
.SwipeableList-item.is-initialized::after  { background-image: var(--right-action-icon); }
```

With this variant the track's gradient provides the reveal color, so you can drop the `background-color` rule on `.SwipeableList-track::before, ::after` from Step 2.

## Practices and pitfalls

- Use `mandatory` snapping, not `proximity`, which can leave the row part-scrolled with the action background half visible.
- Set `overscroll-behavior-x: none` on the track; otherwise an over-swipe can trigger the browser's back gesture on iOS and Android.
- Commit at a threshold before the snap settles (`commitThreshold` around 0.2) rather than waiting for the content to be fully off-screen. Starting the animation during the gesture feels much more responsive.
- Drive per-item setup from an outer viewport `IntersectionObserver` rather than wiring every item at page load. This avoids reading layout values (`clientWidth` and so on) before items render and keeps the active observer count proportional to what is visible.
- Use a `MutationObserver` on the list when items are added dynamically (initial render after data loads, infinite scroll, server push); otherwise added items aren't wired up.
- Don't drive a manual transform from `pointerdown`/`pointermove`/`pointerup`. You'd lose the momentum, snap-back and keyboard scrolling that native scrolling provides.
- Confirm destructive actions where appropriate. For removal, consider an undo toast after the swipe, since the gesture is quick and easy to trigger by accident. Announce the result (for example "Item One removed") in a `role="status"` element that is already in the page, because screen readers only announce changes to live regions that existed before the change.

## Accessibility

WCAG 2.5.1 Pointer Gestures requires that functionality isn't available only through swiping. Visible buttons are an accessible alternative, particularly for people using voice control software. Make each button at least 24×24 CSS pixels (WCAG 2.5.8 Target Size (Minimum)), name it after the item it acts on, and make sure keyboard users can move focus to it and operate it. Once a row has a button, don't add `tabindex` to the track: arrow keys on a focused track commit the action with no confirmation.

Another way to meet 2.5.1 is to offer the same function elsewhere. In an email inbox where swiping left favorites a message, a "Favorite email" button after opening the email is sufficient, as long as keyboard users can reach and operate it. If the use case involves many repeated actions, this is less usable, because people with disabilities spend more time reaching the alternative. A long-press menu offering the same actions can also be sufficient, but is usually less discoverable than permanently visible buttons. If the buttons appear only on hover or focus, also show them when the item is tapped so touch users can reach them.

## Fallback strategies

Baseline status for Scroll snap: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 69 (Sep 2018), Edge 79 (Jan 2020), Firefox 68 (Jul 2019), and Safari 11 (Sep 2017).

Baseline status for Intersection observer: Widely available. It's been Baseline since 2019-03-25.
Supported by: Chrome 58 (Apr 2017), Edge 16 (Oct 2017), Firefox 55 (Aug 2017), Safari 12.1 (Mar 2019), and Safari iOS 12.2 (Mar 2019).

Baseline status for MutationObserver: Widely available. It's been Baseline since 2015-07-29.
Supported by: Chrome 26 (Mar 2013), Edge 12 (Jul 2015), Firefox 14 (Jul 2012), and Safari 7 (Oct 2013).

Baseline status for Resize observer: Widely available. It's been Baseline since 2020-07-28.
Supported by: Chrome 64 (Jan 2018), Edge 79 (Jan 2020), Firefox 69 (Sep 2019), Safari 13.1 (Mar 2020), and Safari iOS 13.4 (Mar 2020).

Baseline status for Web animations: Widely available. It's been Baseline since 2020-09-16.
Supported by: Chrome 84 (Jul 2020), Edge 84 (Jul 2020), Firefox 75 (Apr 2020), and Safari 14 (Sep 2020).

The newer features used here are either not core to the experience or have reliable fallbacks.

### `overscroll-behavior`

Browser support for overscroll-behavior: Limited availability.
Supported by: Chrome 144 (Jan 2026), Edge 144 (Jan 2026), and Firefox 150 (Apr 2026).
Unsupported in: Safari.

This data covers honoring the property on non-scrollable scroll containers; on scrollable ones it works in all major browsers. No fallback is needed. `overscroll-behavior` has an interop issue on containers without scrollable overflow, but this track always scrolls horizontally (three full-width columns in a 100%-wide container), so the property behaves consistently and reliably contains the swipe.

### `scrollbar-width`

Baseline status for scrollbar-width: Newly available. It's been Baseline since 2024-12-11.
Supported by: Chrome 121 (Jan 2024), Edge 121 (Jan 2024), Firefox 64 (Dec 2018), and Safari 18.2 (Dec 2024).

Hiding the scrollbar is cosmetic, not what makes the swipe work. Without `scrollbar-width`, the row still scrolls, snaps, detects the commit and removes correctly, but may show a horizontal scrollbar. If you must hide scrollbars in older WebKit-derived browsers, add a narrowly scoped `::-webkit-scrollbar { display: none; }` rule for the track.

### `scroll-initial-target`

Browser support for scroll-initial-target: Limited availability.
Supported by: Chrome 133 (Feb 2025) and Edge 133 (Feb 2025).
Unsupported in: Firefox and Safari.

If your Baseline target lacks `scroll-initial-target`, scroll the track to the content in `setupItem`, detecting support with `CSS.supports`:

```js
// Hoisted so the ResizeObserver below can be skipped when the property is supported.
const needsScrollWorkaround = !CSS.supports('scroll-initial-target', 'nearest');

function setupItem(item) {
  // ...existing setup from Step 4...

  if (needsScrollWorkaround) {
    track.scrollLeft = track.clientWidth;
  }

  // ...attach the inner IntersectionObserver, etc.
}
```

The order of these calls matters. The programmatic scroll must run:

1. After `.is-initialized` is added to the item. The class makes the track a scroll container; setting `scrollLeft` on a non-scrollable element does nothing.
2. Before the inner `IntersectionObserver` from Step 4 is attached. Otherwise the initial scroll past the left spacer is observed as a swipe and fires the commit handler immediately.

Driving setup from the outer viewport observer is what makes this reliable: `setupItem` runs after the item renders, so `track.clientWidth` is a real value rather than `0`.

Some browsers, notably Safari, also reset a snap container's scroll position whenever the track resizes (URL bar showing or hiding, viewport resize, container queries and so on). Re-apply the scroll from a `ResizeObserver` on each track, gated by the same check; when `scroll-initial-target` is supported, the browser restores the position on resize itself.

```js
const trackResizeObserver = needsScrollWorkaround
  ? new ResizeObserver((entries) => {
      for (const entry of entries) {
        entry.target.scrollLeft = entry.target.clientWidth;
      }
    })
  : null;

function setupItem(item) {
  // ...existing setup...

  if (needsScrollWorkaround) {
    track.scrollLeft = track.clientWidth;
    trackResizeObserver.observe(track);
  }

  // ...attach the inner IntersectionObserver, etc.
}
```

Stop observing the track before the row's height animation in `removeItem` runs, or the height change re-triggers the resize callback during removal. Add it next to `viewportObserver.unobserve(item)` in `commit` (Step 4):

```js
function commit(direction, entry) {
  if (item.classList.contains('is-removing')) return;
  removeItem(item, content, direction, entry);
  viewportObserver.unobserve(item);
  if (needsScrollWorkaround) trackResizeObserver.unobserve(track);
  observer.disconnect();
}
```
