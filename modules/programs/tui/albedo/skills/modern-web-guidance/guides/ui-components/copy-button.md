# Copy button

Build a button that copies the text of another element (a code block, inline value, or read-only field) or the current selection. Declare the target with Invoker Commands (`command` + `commandfor`) instead of wiring each button in JavaScript, and write with the Async Clipboard API.

## Implementation

### 1. Markup

```html
<!-- Custom commands must start with "--". commandfor is the id of the element whose text is copied. -->
<span class="copy"> <!-- positioning context for the bubble -->
  <!-- aria-label names what is copied; several bare "Copy" buttons are indistinguishable to screen readers. -->
  <button type="button" class="copy-button" command="--copy" commandfor="snippet" aria-label="Copy CSS code">
    <!-- Decorative icon, rendered however the codebase renders icons -->
    <span class="icon" aria-hidden="true"></span>
  </button>
  <!-- The confirmation bubble is the live region. Keep it empty until a copy, and outside the button:
       a button's children are presentational, so a live region inside one is not reliably announced. -->
  <span class="tip" role="status"></span>
</span>
<pre><code id="snippet">…</code></pre>
```

- Use `type="button"` so the button never submits a form.
- Make the button at least 24×24 CSS px with `min-inline-size` / `min-block-size` (not `inline-size` / `block-size`), so content can grow the target but never shrink it.
- Name an icon-only button with `aria-label`. If the button shows visible text, that text is the name; do not add an `aria-label` that differs from it.
- Render the icon the way the codebase renders icons (see the `icons` guide) and mark it decorative; the accessible name comes from `aria-label`, not the icon.

### 2. Copying logic

Put the copy logic in one function so the native and fallback paths share it.

```js
let selectedText = ''; // Set by the optional selection popover (step 3).

async function copy(button, target, command = '--copy') {
  // Form controls expose text via .value; innerText (unlike textContent) keeps rendered line breaks.
  const text = command === '--copy-selection'
    ? selectedText
    : target.matches('input, textarea') ? target.value : target.innerText.trim();
  if (!text) return;
  try {
    await navigator.clipboard.writeText(text);
    report(button, true);
  } catch {
    // Clipboard access can be denied: show the failure as well as announcing it.
    report(button, false);
  }
}

// `command` events do not bubble, so listen in the capture phase on document.
// event.source is the clicked button; event.target is the commandfor element.
document.addEventListener('command', (event) => {
  if (event.command.startsWith('--copy')) copy(event.source, event.target, event.command);
}, true);
```

Feedback:

- Use one element for sighted and screen reader users. `report()` sets `data-copied` (or `data-failed`) on the button and writes the message into the bubble, which is both the visible feedback and the live region, so both groups get the same message for both outcomes. Keep messages short ("Copied", "Copy failed").
- Show and hide the bubble with `opacity`. `display: none` and `visibility: hidden` remove it from the accessibility tree, so its text would not be announced.
- After a short timeout, remove the state attributes and clear the bubble's text, so no stale "Copied" is left for screen reader browse mode.
- Do not rely on color alone: swap the icon (copy to check) on success, and use the bubble text for both outcomes.
- On repeat clicks, clear the pending timeout and restart the animation instead of stacking timers. Do not disable the button while feedback shows: copying is idempotent, and disabling drops keyboard focus, announces a misleading unavailable state, and blocks retrying after a failure.
- Under `prefers-reduced-motion: reduce`, replace icon and bubble animations with an opacity fade.

```js
const timers = new WeakMap();

function report(button, ok) {
  const tip = button.nextElementSibling; // The role="status" bubble.
  clearTimeout(timers.get(button));
  button.removeAttribute('data-copied');
  button.removeAttribute('data-failed');
  const message = ok ? 'Copied' : 'Copy failed';
  tip.textContent = '';
  void button.offsetWidth; // Restarts the CSS animation.
  button.setAttribute(ok ? 'data-copied' : 'data-failed', '');
  requestAnimationFrame(() => (tip.textContent = message));
  timers.set(button, setTimeout(() => { // 2000 ms is an example value.
    button.removeAttribute('data-copied');
    button.removeAttribute('data-failed');
    tip.textContent = '';
  }, 2000));
}
```

### 3. Copy the current selection (optional)

Add this only for long prose where users want a floating button on selection. Skip it for code blocks, inline values, and fields.

- Use a `popover="manual"` element (not light-dismissed, so the selection survives) containing a button with `command="--copy-selection" commandfor="<container id>"`.
- Enable the popover only when `matchMedia('(pointer: fine)').matches`. Touch browsers already offer Copy in their native selection menu, which the popover would duplicate and collide with.
- Show it on `selectionchange` (debounced; while dragging, wait for `pointerup`), only when the selection is non-collapsed and inside the container. A triple-click ends at the start of the next element, so do not require the end node to be inside: clip the range's end to the container and accept the selection when the clipped text equals the selected text. Copy from and position against the clipped range, using its `getBoundingClientRect()`: centered on the inline axis and above the selection on the block axis, so it never covers selected text.
- When showing the popover, save the selected text in `selectedText`; `copy()` reads that saved string for `--copy-selection`, because interacting with the button can collapse the live selection.
- Call `preventDefault()` on the popover's `pointerdown` to keep the selection. This also stops the button from taking focus on click or tap, so `:focus-within` cannot tell you a press is in progress. Instead, set a flag on the popover's `pointerdown` and, while it is set, do not hide the popover even if the selection collapses (some touch browsers clear it anyway). Clear the flag and re-check when the copy feedback ends, and on `pointercancel`.
- Otherwise, hide the popover on `Escape`, and when the selection collapses unless keyboard focus is inside the popover (re-check when focus leaves it).
- Do not hide the popover when the copy feedback timeout ends. A keyboard user's focus is on its button, and hiding it drops focus to the page, so the next `Tab` starts from the top. If `Escape` hides it while focus is inside, first move focus to the container: set `tabindex="-1"` on the container just before the move and remove it on `blur`. Do not leave `tabindex` in the markup: a focusable container makes `Tab` skip the copy button in Firefox after a click in the text.

### 4. Repeated copyable elements (optional)

When a page repeats copyable elements (code blocks, list rows, token or ID cells), a visible button on each adds noise. Keep the button hidden until the element is hovered, reveal it for keyboard users too, and never make it hover-only.

```css
/* Touch devices (no hover): the button stays visible, so keep it in flow where it cannot cover content. */
.copyable { display: flex; align-items: start; gap: .5rem; }
.copyable .copy { flex: none; order: 1; }

/* Hide only where hover exists; the overlay is then revealed on demand. */
@media (hover: hover) {
  .copyable { display: block; position: relative; }
  /* .copy is the bubble's positioning context, so move it rather than the button. */
  .copyable .copy { position: absolute; inset-block-start: .5rem; inset-inline-end: .5rem; }
  .copyable .copy-button { opacity: 0; transition: opacity .15s; }
  .copyable:hover .copy-button,
  .copyable:focus-within .copy-button,
  .copyable .copy-button:focus-visible,
  .copyable .copy-button[data-copied],
  .copyable .copy-button[data-failed] { opacity: 1; }
}
```

- Hide with `opacity` only. `display: none` and `visibility: hidden` remove the button from the tab order, so keyboard users could never reach it.
- Reveal on the container's `:focus-within` as well as `:hover`, so the button shows when focus is on it or on focusable content in the block (such as a scrollable `<pre tabindex="0">`).
- Keep it visible on `(hover: none)` devices, where nothing can reveal it, and lay it out in flow beside the content there so it never covers it.
- Keep it visible while feedback shows (`data-copied` / `data-failed`), so the state does not vanish when the pointer leaves.
- Keep the 24×24 px minimum size and the accessible name; screen readers still announce a button hidden by opacity.
- Do not add `aria-hidden`, `inert`, or `hidden` to the button to hide it, and do not toggle them on hover. Screen reader users (VoiceOver included) must reach it without hovering, and focus moving onto it (including a screen reader cursor that moves focus) is what makes it visible.
- Add `padding-inline-end` to the `<pre>` so the button clears the code at rest. On a horizontally scrolling `<pre>` that padding is reached only at the end of the scroll range, so long lines can pass under the button while scrolling. Give the button a mostly opaque background and a visible border so it stays legible over code, rather than reserving a permanent margin that narrows the code area on small screens.

## Fallbacks and browser support

### Invoker Commands

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

If your Baseline target does not include Invoker Commands, keep the same markup and add a click listener that calls the same `copy()` function:

```js
// Detect on the interface, not an instance.
if (!('CommandEvent' in window)) {
  // Resolve the target from commandfor, as the browser does for command events.
  document.addEventListener('click', (event) => {
    // Respect handlers that already canceled the button's activation.
    if (event.defaultPrevented) return;
    const button = event.target.closest('button[command^="--copy"]');
    if (!button) return;
    const target = document.getElementById(button.getAttribute('commandfor'));
    // A missing target would throw inside copy().
    if (target) copy(button, target, button.getAttribute('command'));
  });
}
```

Register only one of the two paths so a click never copies twice.

### Async Clipboard

Baseline status for the api.Clipboard.writeText capability: Widely available. It's been Baseline since 2020-03-24.
Supported by: Chrome 66 (Apr 2018), Edge 79 (Jan 2020), Firefox 63 (Oct 2018), Safari 13.1 (Mar 2020), and Safari iOS 13.4 (Mar 2020).

`navigator.clipboard` exists only in secure contexts (`https:` or `localhost`), and the write is rejected when permission is denied. `copy()` already handles both: a missing `navigator.clipboard` throws inside the `try`, so the failure message is shown and announced. The real fix is to serve the page over HTTPS.

Only as a last resort, when you cannot control the host page's protocol (for example a component embedded on third-party sites), fall back to the deprecated `document.execCommand('copy')` so copying still works. It needs the click's transient user activation, so use it only when `navigator.clipboard` is missing or the write rejects. A missing `navigator.clipboard` throws before the first `await`, so the fallback still runs in the same task as the click; after a rejected write, some browsers may no longer count the activation and the fallback can fail, which reaches the normal failure path:

```js
function legacyCopy(text) {
  const previousFocus = document.activeElement;
  const field = Object.assign(document.createElement('textarea'), { value: text });
  field.setAttribute('readonly', '');
  field.style.cssText = 'position:fixed;inset-block-start:0;opacity:0';
  document.body.append(field);
  field.select();
  try {
    return document.execCommand('copy');
  } finally {
    field.remove();
    // Selecting the temporary field can move focus; restore it even if copying fails.
    previousFocus?.focus({ preventScroll: true });
  }
}

// In copy(), replace the plain write with:
try {
  await navigator.clipboard.writeText(text);
} catch {
  if (!legacyCopy(text)) throw new Error('Copy failed'); // Reaches the existing failure path.
}
```

### Popover

Only the optional selection button (step 3) uses Popover.

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

- Do not use the `popover` IDL property in code that may run before the polyfill has loaded. The value is not mirrored to the attribute, the polyfill does not pick up the popover, and the own property permanently shadows the accessor the polyfill adds. Use `setAttribute()` and `removeAttribute()` instead.
- The polyfill cannot define the real `:popover-open` pseudo-class, so it adds a `.\:popover-open` class. Combine the two with `:is()` or `:where()`; in a plain selector list, browsers without `:popover-open` discard the whole rule.

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

### Repeated announcements (VoiceOver)

VoiceOver skips a message identical to the previous one from the same region, even if the region was emptied in between. Track the last message in a variable (not by reading the bubble, which is cleared) and, when a message repeats, append a no-break space (`\u00A0`) so it differs; the space is not read aloud. One page-wide variable is simplest. A message from another button's bubble then gets the space too, which is harmless. Do not use `ariaNotify()` for this.

```js
let lastMessage = '';

// In report(), change `const message` to `let message`, then:
if (message === lastMessage) message += '\u00A0'; // Differs from the last one, so it is announced.
lastMessage = message;
```
