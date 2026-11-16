# Stack Drill Down

A stack drill-down is a hierarchical navigation pattern, common in mobile apps, where activating a link pushes a new full-screen view on top of the previous one. The view's content is application-defined: a settings sub-page, a thread in a feed, a folder in a file browser, a detail page in a gallery. The user returns by swiping the current view off-screen to the right or by tapping a back button. Browser history stays in sync, so the OS Back gesture, deep links, and back/forward navigation all work coherently.

This guide builds the stack from:

- A horizontal scroll-snap container where each view is one snap stop. Drilling down appends a view and smooth-scrolls to it; the browser handles the swipe back natively, with momentum, velocity, and interruption tracking and no pointer-event code.
- A `scrollsnapchange` listener on the stack, used as the single source of truth for "the active view changed". Swipe, click, programmatic scroll, and `popstate` all end in one callback that updates `inert`, restores focus, prunes views the user swiped past, and reconciles browser history.
- `pushState` / `popstate`, so every drill-down adds a history entry, the OS Back gesture works, and deep links open directly into the right view.
- An optional scroll-driven `view()` animation on each view for a parallax, dim, and shadow effect tied to the swipe.

Prefer this over JavaScript-driven `transform` animations: the user's finger drives the panel's position directly rather than a tween, which matches the interaction users expect from native mobile apps.

## Implementation

### 1. Markup

The static HTML is an empty stack container. JavaScript builds views and appends them as the user navigates.

```html
<div class="Stack">
  <!-- Empty: the initial view is appended at init (step 8). -->
</div>
```

Each view is a `.Stack-view` direct child of `.Stack` (the snap target) with a `.Stack-viewContent` wrapper inside it, which holds the content and receives the parallax transform (step 2). The stack has one view per active history entry, left to right in drill-down order. Two levels in from the root, the DOM looks like this:

```html
<div class="Stack">
  <!-- Root view: the entry point of this section. No back button; nothing is behind it. -->
  <div class="Stack-view" inert>
    <!-- tabindex="-1" lets focus move to the root's content when there is no link or back button to focus (step 7). -->
    <div class="Stack-viewContent" tabindex="-1">
      <!-- Root content, including <a href> links that drill in. -->
    </div>
  </div>

  <!-- First-level view, reached from a link in the root view. -->
  <div class="Stack-view" inert>
    <div class="Stack-viewContent">
      <header>
        <!-- Every drill-down view needs a back button: the swipe is not discoverable or available
             to all users. It is named after the view it returns to (step 7). -->
        <button class="back" aria-label="Back to Inbox"></button>
        <h2>Message</h2>
      </header>
      <div class="Stack-viewBody">
        <!-- View content; may include further drill-down <a href> links. -->
      </div>
    </div>
  </div>

  <!-- Second-level view, currently visible, so not inert. -->
  <div class="Stack-view">
    <div class="Stack-viewContent">
      <header>
        <button class="back" aria-label="Back to Message"></button>
        <h2><!-- ... --></h2>
      </header>
      <div class="Stack-viewBody"><!-- ... --></div>
    </div>
  </div>
</div>
```

- Every view except the visible one has `inert`. The `scrollsnapchange` handler (step 7) sets and removes it; do not set it in your view builders.
- Views the user swipes back past are removed from the DOM (also in step 7), so the stack never has more than `currentDepth + 1` children. They are rebuilt from their cached URL paths if forward navigation returns to them.

### 2. Styles

#### The stack scroller

The stack is a horizontal grid in which each view is exactly as wide as the container, and scroll snapping enforces one view per snap. This gives the swipe back its native feel.

```css
.Stack {
  /* dvh tracks the dynamic viewport on mobile as the address bar shows and hides;
     svh would clip during the address bar animation, and vh extends under it. */
  height: 100dvh;

  /* Views side by side, each full width, so horizontal scrolling moves one at a time. */
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: 100%;
  grid-template-rows: 100%;
  overflow-x: auto;

  /* "mandatory": the stack always settles on a view, never between two. */
  scroll-snap-type: x mandatory;
  /* Positioned, so views' offsetLeft (used by the parallax fallback) is relative to the stack. */
  position: relative;
  /* Keeps the swipe from chaining into the browser's own history-back gesture
     (iOS, some Android) or the page's scroll. */
  overscroll-behavior-x: none;
}

/* The snap and the parallax are the affordances; a horizontal scrollbar would look out of place. */
.Stack {
  scrollbar-width: none;
}
.Stack::-webkit-scrollbar {
  display: none;
}

/* Scripts scroll with behavior: 'auto', which defers to this rule, so the
   reduced-motion preference turns scrolling instant without per-call branching. */
@media (prefers-reduced-motion: no-preference) {
  .Stack {
    scroll-behavior: smooth;
  }
}

.Stack-view {
  scroll-snap-align: start;
  /* "always" stops a fling from skipping views, so depth changes one step at a time. */
  scroll-snap-stop: always;
}

/* The parallax transform must go on this inner element. A transform on the snap
   target (.Stack-view) feeds back into the snap geometry and the scroller jumps mid-gesture. */
.Stack-viewContent {
  width: 100%;
  height: 100%;
  /* Set text and background color together so they keep their contrast in a dark color scheme. */
  background-color: Canvas;
  color: CanvasText;
  /* Each view scrolls its own content vertically. */
  overflow-y: auto;
}
```

#### The stack effect (parallax, dim, shadow)

A scroll-driven `view(inline)` animation tracks each view's progress through the stack scroller. It slides and dims the view being covered, and gives incoming drill-down views a shadow so they read as cards stacking over the previous view.

Wrap the block in `@supports`. Browsers without scroll-driven animations still parse the `@keyframes` and would apply the `to` state as a static style, leaving every view permanently transformed.

```css
@supports (animation-timeline: view()) {
  .Stack-viewContent {
    /* Progress through the nearest scroll container on the inline axis. */
    animation: parallax linear both;
    animation-timeline: view(inline);
    /* Exit phase only (while a deeper view covers this one); the view stays
       at rest and fully bright during its own entry. */
    animation-range: exit 0% exit 100%;
  }

  /* Drill-down views (all but the root) also get an edge shadow during transitions. */
  .Stack-view:not(:first-child) .Stack-viewContent {
    animation: parallax linear both, shadow-fade linear both;
    animation-timeline: view(inline), view(inline);
    /* parallax: exit only. shadow-fade: entry through exit, so it shows only mid-transition. */
    animation-range: exit 0% exit 100%, entry 0% exit 100%;
  }

  @keyframes parallax {
    /* Example values; adjust to taste. */
    to {
      transform: translateX(75%);
      filter: brightness(0.8);
    }
  }

  @keyframes shadow-fade {
    /* Ramps in during entry, holds, ramps out during exit; invisible at rest. */
    0%, 100% { box-shadow: 0 0 1.5rem #0000; }
    25%, 75% { box-shadow: 0 0 1.5rem #0004; }
  }
}
```

This effect is common in native stack navigation and is a good starting point; adapt it to match existing transition styles.

### 3. Module state

The stack keeps four pieces of state in module scope:

```js
const stack = document.querySelector('.Stack');

// The root view element. Null until the root view is created: at init when the URL
// is '/', or later by synthesizeRootEntry() after landing on a deep link. Other code
// compares against it by identity.
let rootView = null;

// Element to refocus when the user returns to a view. Keyed by view, so entries
// are garbage-collected when the view is pruned.
const returnFocus = new WeakMap();

// History depth -> {urlPath, view}. Needed because the History API exposes state
// only for the current entry, so a pruned view's URL must be remembered here in
// case forward navigation returns to it.
const entriesByDepth = new Map();

// popstate's state gives the destination depth but not the origin; both are needed
// to compute direction and distance.
let currentDepth = 0;
```

Three application-specific helpers are where your routing and rendering plug in:

```js
// Return the data needed to render the drill-down view for a URL path, or null for
// paths this section does not handle (the root path '/', external links, unknown
// routes). The root view is rendered separately by createRootView().
function resolveUrl(urlPath) {
  // Replace with your routing, for example match `/view/:id` and look up the id.
}

// Build the root view. Keep the .Stack-view / .Stack-viewContent structure (the inner
// element is needed for the parallax, step 2) and do not render a back button.
function createRootView() {
  const view = document.createElement('div');
  view.className = 'Stack-view';
  view.innerHTML = `
    <!-- tabindex="-1" lets step 7 focus the root's content when there is no link to return to. -->
    <div class="Stack-viewContent" tabindex="-1">
      <!-- Root content, with <a href> links to paths resolveUrl() accepts. -->
    </div>
  `;
  return view;
}

// Build a drill-down view from route data. Customize the content freely, but keep
// the .Stack-view / .Stack-viewContent structure and include a back button.
function createDrillDownView(routeData) {
  const view = document.createElement('div');
  view.className = 'Stack-view';
  view.innerHTML = `
    <div class="Stack-viewContent">
      <header>
        <!-- Step 7 names this button after the view it returns to. -->
        <button class="back" aria-label="Back"></button>
        <h2></h2>
        <!-- Breadcrumb or other view chrome from routeData. -->
      </header>
      <div class="Stack-viewBody">
        <!-- View body from routeData, with further <a href> links to paths resolveUrl() accepts. -->
      </div>
    </div>
  `;
  // Set the title as text so it cannot inject markup. (`title` is an example field.)
  view.querySelector('h2').textContent = routeData.title;
  return view;
}

function getCurrentUrlPath() {
  return location.pathname;
}
```

### 4. Drill down

A drill-down pushes a history entry, builds the new view, appends it, and smooth-scrolls to it, in that order. The `scrollsnapchange` handler (step 7) takes over once the snap settles.

```js
function drillDown(urlPath) {
  const routeData = resolveUrl(urlPath);
  if (!routeData) return;

  const newDepth = currentDepth + 1;
  // Push before building the view, so anything observing history (analytics, etc.)
  // sees the right URL during view creation.
  history.pushState({depth: newDepth}, '', urlPath);

  // pushState truncates forward entries in browser history; mirror that here so
  // no unreachable views are kept.
  for (const d of entriesByDepth.keys()) {
    if (d >= newDepth) entriesByDepth.delete(d);
  }
  currentDepth = newDepth;

  const newView = createDrillDownView(routeData);
  stack.appendChild(newView);
  entriesByDepth.set(newDepth, {urlPath, view: newView});

  // One view to the right. 'auto' defers to CSS scroll-behavior (smooth unless
  // reduced motion is requested); scrollsnapchange fires when the snap settles.
  stack.scrollBy({left: stack.clientWidth, behavior: 'auto'});
}
```

### 5. Clicks and the back button

Turn link clicks inside the stack into drill-downs, but leave modified clicks alone so Cmd/Ctrl-click and middle-click still open the link in a new tab.

```js
stack.addEventListener('click', (e) => {
  if (e.target.closest('.back')) {
    goBack();
    return;
  }

  const link = e.target.closest('a');
  if (!link || !stack.contains(link)) return;
  // Let the browser handle modified and non-primary (middle) clicks.
  if (e.metaKey || e.ctrlKey || e.shiftKey || e.button !== 0) return;

  const urlPath = new URL(link.href).pathname;
  const parentView = link.closest('.Stack-view');
  // URLs this section does not handle navigate normally.
  if (!resolveUrl(urlPath) || !parentView) return;

  e.preventDefault();
  // Remember the link so focus returns to it when the user comes back to this view.
  returnFocus.set(parentView, link);
  drillDown(urlPath);
});
```

Going back is usually `history.back()`, with one edge case to handle: after landing directly on a deep link, there is no in-app history entry behind the current one, and `history.back()` would leave the app. Detect that case and synthesize a root entry instead, so in-app Back from a deep link lands on the root view and platform Back from there returns the user to where they came from.

```js
function goBack() {
  const atDeepLinkRoot = currentDepth === 0
    && entriesByDepth.get(0)?.view !== rootView;
  if (atDeepLinkRoot) {
    synthesizeRootEntry();
  } else {
    // Fires popstate, which scrolls the stack through updateFromHistoryState (step 6),
    // the same path a swipe back ends in.
    history.back();
  }
}

function synthesizeRootEntry() {
  // A new entry for the root URL. The deep-linked entry is now behind it, so
  // platform Back from the root view returns there.
  const newDepth = currentDepth + 1;
  history.pushState({depth: newDepth}, '', '/');

  // Create the root view if needed and insert it at the left end. Shift scrollLeft
  // by one view, instantly (not smooth), so the deep-linked view stays in place until the scroll below runs.
  if (!rootView) {
    rootView = createRootView();
    stack.prepend(rootView);
    stack.scrollBy({left: stack.clientWidth, behavior: 'instant'});
  }
  entriesByDepth.set(newDepth, {urlPath: '/', view: rootView});

  // Smooth-scrolls one step left to the root; scrollsnapchange fires when it settles.
  updateFromHistoryState(history.state);
}
```

### 6. Sync from history (`popstate`)

`popstate` fires when the user uses the browser or OS back or forward controls, or when script calls `history.back()` or `history.go()`. This handler is the only code that scrolls the stack in response to a history change.

```js
window.addEventListener('popstate', (event) => {
  updateFromHistoryState(event.state);
});

function updateFromHistoryState(state, behaviorOverride) {
  const newDepth = state?.depth ?? 0;
  const urlPath = getCurrentUrlPath();

  // Make sure the destination depth has an entry. If its URL changed (for example
  // forward navigation into a pruned view), clear the view so the loop below rebuilds it.
  const entry = entriesByDepth.get(newDepth) ?? {view: null};
  if (entry.urlPath !== urlPath) {
    entry.urlPath = urlPath;
    entry.view = urlPath === '/' ? rootView : null;
  }
  entriesByDepth.set(newDepth, entry);

  // Rebuild views between the root and the destination that were pruned earlier,
  // so forward navigation has an element to scroll to.
  for (let d = 0; d <= newDepth; d++) {
    const e = entriesByDepth.get(d);
    if (!e || e.view) continue;
    const routeData = resolveUrl(e.urlPath);
    if (!routeData) continue;
    const rebuilt = createDrillDownView(routeData);
    stack.appendChild(rebuilt);
    e.view = rebuilt;
  }

  currentDepth = newDepth;

  const targetView = entriesByDepth.get(newDepth)?.view;
  if (!targetView) return;

  // Already there: happens when step 7 calls history.go() to sync history after a
  // swipe back that has already finished visually.
  const toIdx = [...stack.children].indexOf(targetView);
  const fromIdx = Math.round(stack.scrollLeft / stack.clientWidth);
  if (fromIdx === toIdx) return;

  // "forward" is the spatial direction (toIdx > fromIdx), not depth: synthesizeRootEntry
  // pushes a deeper entry but scrolls left, and correctly animates like a back.
  const forward = toIdx > fromIdx;
  const multiStep = Math.abs(toIdx - fromIdx) > 1;
  const behavior = behaviorOverride ?? (forward || multiStep ? 'instant' : 'auto');
  stack.scrollTo({left: toIdx * stack.clientWidth, behavior});
}
```

The scroll behavior depends on the move:

- Multi-step jumps (such as `history.go(-3)`) are instant. Smooth scrolling would fire `scrollsnapchange` at every intermediate snap point and repeat the state-transition work for each.
- Single steps to the right (forward) are instant. Browser forward is rare on the web and often spurious (iOS Safari treats edge swipes as forward navigation even with `overscroll-behavior` set), and an instant swap is less misleading than a drill-down animation the user did not ask for. User-initiated drill-downs are unaffected: `drillDown` scrolls directly and never reaches this code.
- Single steps to the left (back) use `'auto'`, so CSS `scroll-behavior` applies (smooth unless reduced motion is requested). Back is the common case and benefits from the animation.

### 7. `scrollsnapchange`: the single source of truth

After every snap commit, whether from a swipe, a click, or a programmatic scroll, the browser fires `scrollsnapchange` on the scroll container with the newly snapped element in `event.snapTargetInline` (for horizontal snapping). Keeping every state transition in this one handler keeps the swipe, click, and `popstate` paths coherent.

The handler lives in a standalone `onActiveViewChanged` function so the [fallback](#scroll-snap-events) can reuse it.

```js
function onActiveViewChanged(currentView) {
  // Record this before views become inert or are removed, so the focus fallback
  // below only moves focus that would otherwise be lost, and never on page load.
  const focusWasInStack = stack.contains(document.activeElement);

  // Views up to currentView stay; all but currentView become inert, so focus, pointer
  // events, and assistive technology cannot reach content hidden behind the parallax.
  // Views after currentView were swiped past and are removed; their urlPath stays in
  // entriesByDepth so forward navigation can rebuild them.
  let seenCurrent = false;
  for (const view of [...stack.children]) {
    if (seenCurrent) {
      for (const e of entriesByDepth.values()) {
        if (e.view === view) e.view = null;
      }
      view.remove();
    } else {
      view.toggleAttribute('inert', view !== currentView);
      if (view === currentView) seenCurrent = true;
    }
  }

  // A depth mismatch means the user swiped rather than clicked: sync history so the
  // browser back/forward buttons match the screen.
  let currentViewDepth;
  for (const [d, e] of entriesByDepth) {
    if (e.view === currentView) currentViewDepth = d;
  }
  if (currentViewDepth !== undefined && currentViewDepth !== currentDepth) {
    // Fires popstate; updateFromHistoryState then finds fromIdx === toIdx and does not scroll.
    history.go(currentViewDepth - currentDepth);
  }

  // Name the active view in the title (the app name alone for the root). The history
  // list, the tab, and screen readers use it to tell entries apart. ('Mail' is an example.)
  const viewTitle = currentView.querySelector('h2')?.textContent;
  document.title = viewTitle ? `${viewTitle} | Mail` : 'Mail';

  // Name the back button after the view it returns to (the previous view, or the root
  // after a deep link). Focus lands on it after a drill-down, and "Back" alone tells
  // screen reader users nothing. ('Inbox' is the example root title.)
  const back = currentView.querySelector('.back');
  if (back) {
    const parentTitle =
      currentView.previousElementSibling?.querySelector('h2')?.textContent ?? 'Inbox';
    back.setAttribute('aria-label', `Back to ${parentTitle}`);
  }

  // Restore focus with preventScroll: plain focus() scrolls the snap container toward
  // the element, fights the snap, and can leave the stack mid-snap.
  const stored = returnFocus.get(currentView);
  if (stored?.isConnected) {
    // Back to the link the user drilled out of this view from.
    stored.focus({preventScroll: true});
    returnFocus.delete(currentView);
  } else if (currentView !== rootView) {
    // A new drill-down view: the back button is the obvious next action.
    currentView.querySelector('.back')?.focus({preventScroll: true});
  } else if (focusWasInStack && !currentView.contains(document.activeElement)) {
    // The root has no back button, and after a deep link or a pruned view there is no
    // stored link. Without this, focus stays in a removed or inert view and falls to
    // <body>, sending keyboard and screen reader users back to the top of the page.
    currentView.querySelector('.Stack-viewContent')?.focus({preventScroll: true});
  }
}

stack.addEventListener('scrollsnapchange', (event) => {
  // The element snapped to on the inline axis: the new active view.
  onActiveViewChanged(event.snapTargetInline);
});
```

### 8. Initialization and deep links

On load, the URL may already point at a deep view (a shared link, a bookmark, a refresh). Build the one initial view that matches the URL (root or deep-linked, never both), append it to the empty stack, seed the depth-0 history entry, and run an initial pass with `behavior: 'instant'` so nothing animates on first paint.

```js
const initialUrlPath = getCurrentUrlPath();
const initialRouteData = resolveUrl(initialUrlPath);

// The other view type is created later if needed, by synthesizeRootEntry (step 5)
// or drillDown (step 4).
let initialView;
if (initialRouteData) {
  initialView = createDrillDownView(initialRouteData);
} else {
  rootView = createRootView();
  initialView = rootView;
}
stack.appendChild(initialView);

entriesByDepth.set(0, {urlPath: initialUrlPath, view: initialView});
// Gives the landing entry a depth for later pushState / popstate to count from.
history.replaceState({depth: 0}, '');

updateFromHistoryState(history.state, 'instant');
```

### Best practices

- Use `scrollsnapchange` (with the `IntersectionObserver` fallback below) as the source of truth for "the active view changed", not scroll coordinates. A snap commit is the one event that fires consistently across swipe, click, programmatic scroll, and `popstate`.
- Apply transforms to a child of the snap target, never the snap target itself, which feeds back into the snap geometry and makes the scroller glitch mid-gesture.
- Make every view except the visible one `inert`. Otherwise focus and screen reader navigation reach views hidden behind the parallax, a severe accessibility failure that sighted users never see.
- Push a history entry on every drill-down and handle `popstate`, so the OS Back gesture and the browser back/forward buttons work. This is what makes the pattern feel like a native app.
- When a swipe back lands on a view whose depth does not match `currentDepth`, reconcile history in the active-view handler. Otherwise the next OS Back goes somewhere unexpected because the browser's history position no longer matches the screen.
- Prune views the user swiped past. A long session could otherwise accumulate dozens of detached subtrees; the cached URL path in `entriesByDepth` is enough to rebuild any of them.
- Make sure focus ends up inside the active view after every change, including Back from a deep link and jumps to the root. With no stored link and no back button, focus the view's `.Stack-viewContent` (which has `tabindex="-1"`). Focus left in a removed or `inert` view falls to `<body>`.
- Update `document.title` to name the active view on every change. Each drill-down adds a history entry, and the title is how the history list, the tab, and screen readers tell entries apart.
- Restore focus inside the stack with `.focus({preventScroll: true})`. The default scrolls the target into view, which fights the snap container and can leave it mid-snap.
- Keep Cmd/Ctrl-click and middle-click working on internal links, so URLs stay shareable and can open in a new tab.
- Use `behavior: 'instant'` for multi-step history jumps and for spatially forward `popstate` moves (`toIdx > fromIdx`). Multi-step smooth scrolls fire `scrollsnapchange` at every intermediate snap and repeat the inert, focus, and history work each time. Forward `popstate` is often spurious (iOS Safari treats edge swipes as browser forward even with `overscroll-behavior-x: none`), and an instant swap is less misleading than animating a drill-down the user did not start. `drillDown` is unaffected because it scrolls directly, not through `popstate`.
- Respect `prefers-reduced-motion`: declare `scroll-behavior: smooth` only inside `@media (prefers-reduced-motion: no-preference)` and call `scrollTo` / `scrollBy` with `behavior: 'auto'`, not `'smooth'`, which would bypass the user's setting.
- Use real `<a href>` elements as drill-down triggers, not `<button onclick>` or `<div>`. Anchors come with URL preview on hover, shareability, middle-click, the link role for screen readers, and SEO.
- Include a visible back button in every drill-down view. The swipe is not discoverable or available to everyone; keyboard, pointer, and desktop users need a visible control. (Horizontal arrow keys and trackpad swipes can also scroll the stack.)
- Never call `history.pushState` from the `popstate` handler; it adds entries while the user is going back and breaks the back button.
- Do not drive the parallax from a `scroll` listener where scroll-driven animations are available. The CSS animation runs on the compositor; a scroll listener runs on the main thread and visibly drops frames during the gesture.
- Do not touch views after pruning them. `entriesByDepth` is the canonical record: a pruned entry has `view: null` and is rebuilt on demand in `updateFromHistoryState`.

## Fallback strategies

Baseline status for Scroll snap: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 69 (Sep 2018), Edge 79 (Jan 2020), Firefox 68 (Jul 2019), and Safari 11 (Sep 2017).

Baseline status for Intersection observer: Widely available. It's been Baseline since 2019-03-25.
Supported by: Chrome 58 (Apr 2017), Edge 16 (Oct 2017), Firefox 55 (Aug 2017), Safari 12.1 (Mar 2019), and Safari iOS 12.2 (Mar 2019).

Baseline status for inert: Widely available. It's been Baseline since 2023-04-11.
Supported by: Chrome 102 (May 2022), Edge 102 (May 2022), Firefox 112 (Apr 2023), and Safari 15.5 (May 2022).

The features that may need fallbacks are scroll snap events and scroll-driven animations. Both have reliable fallback or progressive enhancement paths and are safe to use here.

### Scroll snap events

Browser support for Scroll snap events: Limited availability.
Supported by: Chrome 129 (Sep 2024) and Edge 129 (Sep 2024).
Unsupported in: Firefox and Safari.

`scrollsnapchange` fires exactly once per snap commit, which makes it the cleanest signal. Where it is missing, an `IntersectionObserver` watching each view for full visibility inside the stack does the same job. Required whenever you support browsers without scroll snap events. The fallback calls the same `onActiveViewChanged` as the primary path, so the state logic stays in one place.

```js
// Detect on HTMLElement.prototype (not window or document): the event handler
// IDL attribute exists there whenever the feature is supported.
if (!('onscrollsnapchange' in HTMLElement.prototype)) {
  const viewObserver = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      // threshold: 1 also reports views dropping below full visibility;
      // only the fully visible (entering) view marks the snap commit.
      if (entry.intersectionRatio === 1) {
        onActiveViewChanged(entry.target);
      }
    }
  }, {root: stack, threshold: 1});

  // Observe views as they are added and stop when they are removed, so the primary
  // code (drillDown, updateFromHistoryState, synthesizeRootEntry, init) needs no fallback wiring.
  new MutationObserver((mutations) => {
    for (const m of mutations) {
      for (const node of m.addedNodes) {
        if (node.classList?.contains('Stack-view')) viewObserver.observe(node);
      }
      for (const node of m.removedNodes) {
        if (node.classList?.contains('Stack-view')) viewObserver.unobserve(node);
      }
    }
  }).observe(stack, {childList: true});

  // Views already in the stack (typically the initial view from step 8).
  for (const view of stack.children) viewObserver.observe(view);
}
```

### Scroll-driven animations

Baseline status for Scroll-driven animations: Newly available. It's been Baseline since 2026-10-27.
Supported by: Chrome 115 (Jul 2023), Edge 115 (Jul 2023), Firefox 159 (Oct 2026), and Safari 26 (Sep 2025).

The parallax, dim, and shadow effect is a progressive enhancement. The `@supports (animation-timeline: view())` gate in step 2 limits it to supporting browsers; elsewhere views simply cut between snap stops. Snapping, history sync, focus management, and `inert` all work without it.

If older targets need the parallax, compute each view's progress in a `scroll` listener on the stack and drive `transform` and `filter` from it:

```js
if (!CSS.supports('animation-timeline: view()')) {
  stack.addEventListener('scroll', () => {
    const viewWidth = stack.clientWidth;
    for (const view of stack.children) {
      // 0 when the view is in place, 1 when it has fully exited left; matches the keyframes.
      const offsetLeft = view.offsetLeft - stack.scrollLeft;
      const progress = Math.min(1, Math.max(0, -offsetLeft / viewWidth));
      const content = view.querySelector('.Stack-viewContent');
      content.style.transform = `translateX(${progress * 75}%)`;
      content.style.filter = `brightness(${1 - progress * 0.2})`;
    }
  });
}
```
