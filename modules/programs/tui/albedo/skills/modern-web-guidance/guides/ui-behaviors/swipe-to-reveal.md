# Swipe to reveal

Swipe to reveal lets users slide a foreground row or content pane sideways to expose hidden UI, such as contextual action buttons (Pin, Mute, Archive, Delete) or a secondary side menu, without activating anything. The container snaps open to show controls the user can inspect and activate, or swipe back to close.

> For a full-width swipe that commits and dismisses an item past a threshold, see the `swipe-to-remove` guide. For revealing a hidden header at the top of a vertical scroll container, see the `pull-to-reveal` guide.

## How to implement

Revealing action buttons on a list item and revealing a side menu beside a scrollable pane work the same way. Wrap the foreground content and the hidden panel in an outer horizontal scroll container with CSS scroll snap (`scroll-snap-type: x mandatory`) and `overscroll-behavior: chain`. The browser's scrolling handles momentum, snapping, focus scrolling and scroll chaining with no JavaScript gesture listeners.

### Step 1: Markup

Put the foreground content first and the revealed controls (action buttons or side menu) second inside the `.SwipeReveal` container. With the content first in DOM order, the container starts at scroll offset `0` with the panel off-screen to the right. Each action's accessible name should include the content it relates to, so people can tell the controls apart.

```html
<!-- Example A: list item with revealable action buttons -->
<div class="SwipeReveal">
  <div class="SwipeReveal-content">
    <strong>Design review notes</strong>
    <p>Updated component specs for the Q3 release.</p>
    <button type="button" data-reveal-trigger aria-label="Design review notes actions" aria-expanded="false">…</button>
  </div>
  <div class="SwipeReveal-panel" role="group" aria-label="Design review notes actions">
    <button type="button" tabindex="-1">Pin<span class="visually-hidden"> Design review notes</span></button>
    <button type="button" tabindex="-1">Archive<span class="visually-hidden"> Design review notes</span></button>
    <button type="button" tabindex="-1">Delete<span class="visually-hidden"> Design review notes</span></button>
  </div>
</div>

<!-- Example B: scrollable content pane with a revealable side menu -->
<div class="SwipeReveal" role="region" aria-label="Document preview with swipeable side menu">
  <div class="SwipeReveal-content is-scrollable" tabindex="0">
    <h2>Article Preview</h2>
    <p>Scroll vertically through this pane, or swipe left to reveal the side menu...</p>
    <button type="button" data-reveal-trigger aria-label="Article actions" aria-expanded="false">…</button>
  </div>
  <nav class="SwipeReveal-panel" aria-label="Contextual menu">
    <a href="#share" tabindex="-1">Share</a>
    <a href="#bookmark" tabindex="-1">Bookmark</a>
    <a href="#export" tabindex="-1">Export PDF</a>
  </nav>
</div>
```

### Step 2: Horizontal snap container with `overscroll-behavior: chain`

An outer scroll container added only for the swipe effect becomes an intermediate scroller inside the document (or another parent scroller).

The `overscroll-behavior` keywords independently control whether excess scroll propagates to an ancestor scroller (scroll chaining) and whether the container shows its own overscroll effect such as rubber-band stretching or edge glow (local boundary effect):

| Value | Scroll chaining to ancestor | Local boundary effect | Role in swipe to reveal |
| :--- | :--- | :--- | :--- |
| `auto` | Yes | Yes | The default. Keep it on inner content scrollers that should bounce normally; avoid it on the outer swipe wrapper, where it makes the menu bounce. |
| `chain` | Yes | No | Use on the outer `.SwipeReveal` scroller so excess scroll chains to the parent (such as the document) without the menu or action strip bouncing. |
| `contain` | No | Yes | Traps scroll in the container but still bounces locally. |
| `none` | No | No | Blocks both the local bounce and chaining. |

Make `.SwipeReveal` a two-column grid (`grid-template-columns: 100% max-content`) where `.SwipeReveal-content` snaps to `start` and `.SwipeReveal-panel` snaps to `end`:

```css
.SwipeReveal {
  /* Column 1: full-width content. Column 2: auto-sized actions or side menu. */
  display: grid;
  grid-template-columns: 100% max-content;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scrollbar-width: none;

  /* No local bounce on the wrapper or panel, but excess scroll still chains
     to the parent scroller (the document). */
  overscroll-behavior: chain;
}

@media (prefers-reduced-motion: no-preference) {
  .SwipeReveal {
    scroll-behavior: smooth;
  }
}

.SwipeReveal-content {
  scroll-snap-align: start;
  scroll-initial-target: nearest;
  background: Canvas;
}

.SwipeReveal-content:focus-visible {
  outline: auto;
  outline-offset: -2px;
}

.SwipeReveal-content.is-scrollable {
  block-size: 20rem;
  overflow: auto;
  /* Keeps the default overscroll-behavior: auto, so the pane bounces normally
     while horizontal swipes chain to .SwipeReveal. */
}

.SwipeReveal-panel {
  /* Snapping a trailing panel to end (or a leading panel to start) brings all
     its controls into view while the adjacent edge of the content stays visible. */
  scroll-snap-align: end;
  display: flex;

  &:first-child {
    scroll-snap-align: start;
  }
}
```

> To reveal controls on the left (`inline-start`) side as well, use three columns (`grid-template-columns: max-content 100% max-content`) or two (`max-content 100%`) and place the leading `.SwipeReveal-panel` before `.SwipeReveal-content`. Because `.SwipeReveal-content` has `scroll-initial-target: nearest`, the container starts on the content column rather than the leading panel.

### Step 3: Reveal the controls from the trigger button

The panel's buttons or links are off-screen at rest and out of the tab order (`tabindex="-1"`). When the trigger button is activated, scroll the panel into view, set its controls to `tabindex="0"` so people can reach them, and set `aria-expanded="true"` on the trigger. Activating the trigger again while the controls are shown reverses all three.

`behavior: 'auto'` defers to the CSS `scroll-behavior`, which is smooth only when the user has no reduced-motion preference.

Mark triggers with `data-reveal-trigger` rather than matching label text, which breaks once labels are localized. A trigger with `data-reveal-trigger="leading"` or `"trailing"` opens that side's panel. Otherwise, with a single panel, the trigger opens it; with panels on both sides, the content's first trigger opens the leading panel and any other trigger the trailing one.

```js
// Closing resets every panel; opening enables only the revealed panel's controls.
function setActionTabIndexes(reveal, openPanel = null) {
  for (const control of reveal.querySelectorAll('.SwipeReveal-panel :is(a, button)')) {
    control.tabIndex = openPanel?.contains(control) ? 0 : -1;
  }
}

for (const trigger of document.querySelectorAll('.SwipeReveal-content [data-reveal-trigger]')) {
  trigger.addEventListener('click', () => {
    const reveal = trigger.closest('.SwipeReveal');
    if (!reveal) return;

    const content = reveal.querySelector('.SwipeReveal-content');
    const triggers = content.querySelectorAll('[data-reveal-trigger]');
    const leadingPanel = reveal.firstElementChild.matches('.SwipeReveal-panel')
      ? reveal.firstElementChild
      : null;
    const isExpanded = trigger.getAttribute('aria-expanded') === 'true';

    if (isExpanded) {
      // Close: return to the content column, which follows any leading panel.
      reveal.scrollTo({ left: leadingPanel ? leadingPanel.offsetWidth : 0, behavior: 'auto' });
      for (const t of triggers) t.setAttribute('aria-expanded', 'false');
      setActionTabIndexes(reveal);
      return;
    }

    const panels = reveal.querySelectorAll('.SwipeReveal-panel');
    if (panels.length === 0) return;

    let openLeading;
    const side = trigger.dataset.revealTrigger;
    if (side === 'leading') {
      openLeading = true;
    } else if (side === 'trailing') {
      openLeading = false;
    } else if (panels.length === 1) {
      openLeading = Boolean(leadingPanel);
    } else {
      openLeading = trigger === triggers[0];
    }

    const panel = openLeading ? leadingPanel : content.nextElementSibling;
    if (!panel) return; // The requested side has no panel.

    reveal.scrollTo({ left: openLeading ? 0 : reveal.scrollWidth, behavior: 'auto' });

    for (const t of triggers) t.setAttribute('aria-expanded', t === trigger ? 'true' : 'false');
    setActionTabIndexes(reveal, panel);
  });
}
```

Users can also swipe the panel open without the button. To keep `aria-expanded` and the `tabindex` values accurate in that case, update them from scroll snap events, as described in the `scroll-snap-realtime-feedback` guide.

## Practices and pitfalls

- Use `scroll-snap-type: x mandatory`, not `proximity`. With `proximity`, a light swipe can leave the actions or side menu partly exposed at rest.
- Set `overscroll-behavior: chain` on the outer `.SwipeReveal` scroller so scroll can chain to the parent without the revealed menu or action strip bouncing.
- Leave `overscroll-behavior: auto` (the default) on inner scrollable panes (`.SwipeReveal-content.is-scrollable`) that should bounce normally while horizontal swipes still chain to the outer scroller.
- Make revealed actions and menu items real focusable controls (`<button>`, `<a>`). When `.SwipeReveal-content` is focusable or contains focusable controls, add a `focusin` listener that checks `event.target.matches(':focus-visible')` and calls `scrollIntoView({ block: 'nearest', inline: 'start' })`, so tabbing back into the content closes the side panel without affecting pointer interaction.
- Don't intercept `wheel`, `touchmove` or `pointermove` in JavaScript to translate the content or emulate scroll chaining. Main-thread gesture handling blocks compositor scrolling, breaks native momentum and hurts responsiveness.

## Accessibility

WCAG 2.5.1 Pointer Gestures requires that functionality isn't available only through swiping. Visible buttons are an accessible alternative, particularly for people using voice control software. Make each button at least 24×24 CSS pixels (WCAG 2.5.8 Target Size (Minimum)) and make sure keyboard users can move focus to it and operate it.

Another way to meet 2.5.1 is to offer the same function elsewhere. In an email inbox where swiping left favourites a message, a "Favourite email" button after opening the email is sufficient. If the use case involves many repeated actions, this is less usable, because people with disabilities spend more time reaching the alternative. Operating system or browser features (such as long press on iOS) can also be sufficient alternatives, but are usually less discoverable than permanently visible buttons.

## Fallback

Browser support for scroll-initial-target: Limited availability.
Supported by: Chrome 133 (Feb 2025) and Edge 133 (Feb 2025).
Unsupported in: Firefox and Safari.

When a `.SwipeReveal` has a leading `.SwipeReveal-panel` before `.SwipeReveal-content`, browsers without `scroll-initial-target: nearest` start at scroll offset `0` with the leading panel exposed.

If your Baseline target lacks `scroll-initial-target`, detect it with `CSS.supports('scroll-initial-target', 'nearest')` and, on `load`, call `scrollTo()` with `behavior: 'instant'` so containers with a leading panel jump straight to `.SwipeReveal-content`. Scrolling the container this way doesn't scroll the page.

```js
if (!CSS.supports('scroll-initial-target', 'nearest')) {
  window.addEventListener('load', () => {
    for (const reveal of document.querySelectorAll('.SwipeReveal')) {
      const leadingPanel = reveal.firstElementChild;
      if (leadingPanel?.matches('.SwipeReveal-panel')) {
        reveal.scrollTo({ left: leadingPanel.offsetWidth, behavior: 'instant' });
      }
    }
  }, { once: true });
}
```

## Progressive enhancement

Browser support for overscroll-behavior: Limited availability.
Supported by: Chrome 144 (Jan 2026), Edge 144 (Jan 2026), and Firefox 150 (Apr 2026).
Unsupported in: Safari.

Baseline status for Scroll snap: Widely available. It's been Baseline since 2020-01-15.
Supported by: Chrome 69 (Sep 2018), Edge 79 (Jan 2020), Firefox 68 (Jul 2019), and Safari 11 (Sep 2017).

Baseline status for scrollbar-width: Newly available. It's been Baseline since 2024-12-11.
Supported by: Chrome 121 (Jan 2024), Edge 121 (Jan 2024), Firefox 64 (Dec 2018), and Safari 18.2 (Dec 2024).

The overscroll-behavior data above covers honoring the property on non-scrollable scroll containers; on scrollable ones it works in all major browsers. Treat `overscroll-behavior: chain` and `scrollbar-width: none` as progressive enhancements with no JavaScript fallback:

- The initial value of `overscroll-behavior` is `auto`. Browsers that don't recognize `chain` drop the declaration at parse time and keep `auto`, which already chains to ancestor scrollers. The swipe and the chaining work everywhere; supporting browsers just suppress the unwanted bounce on the outer wrapper.
- If a base stylesheet or utility class sets `overscroll-behavior: contain` or `none`, declare `overscroll-behavior: auto` immediately before `overscroll-behavior: chain`, so browsers without `chain` still chain scrolling to the parent instead of trapping it.
- Hiding the scrollbar is purely cosmetic. An engine that ignores `scrollbar-width: none` shows a standard scrollbar and the container still works.
