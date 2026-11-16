# Triggering Effects After Programmatic Scrolling Completes

When you scroll programmatically to a section or element, especially with `behavior: 'smooth'`, a follow-up action fired immediately (flashing a highlight, starting an entry animation, moving focus) runs while the target is still off-screen or mid-scroll.

The old workarounds were unreliable. A `setTimeout()` guess fires too early on long scrolls and too late on short ones. A hand-rolled `Promise` around `scrollend` needs a fallback timer, because `scrollend` doesn't fire when the target is already in view and nothing scrolls.

The scroll methods on `Element` (`scrollIntoView()`, `scroll()`, `scrollTo()`, `scrollBy()`) and `Window` (`scroll()`, `scrollTo()`, `scrollBy()`) now return a `Promise` that resolves when the scroll completes. If no scrolling is needed because the target is already at the requested position, the promise resolves immediately rather than hanging.

## Implementation

1. Make the handler that triggers the scroll an `async` function.
2. Await the scroll method directly: `await element.scrollIntoView({ behavior: 'smooth', ... })`, or `await element.scrollTo(...)`, `await window.scrollTo(...)` and so on. Execution resumes once the scroll animation finishes and the position settles.
3. Apply the effect after the `await`: toggle the highlight class, start the animation or move focus.

## Interrupted scrolls and focus

If a new scroll starts on the same container before a smooth scroll finishes, the browser aborts the running scroll and resolves (does not reject) every pending scroll promise on that container. To skip the effect for superseded scrolls when users click rapidly, keep an incrementing operation ID and return early after `await` if a newer scroll has started:

```javascript
let currentScrollId = 0;
const sections = document.querySelectorAll('section');

async function scrollToAndHighlight(targetElement) {
  const scrollId = ++currentScrollId;
  sections.forEach((sec) => sec.classList.remove('highlight'));

  await targetElement.scrollIntoView({ behavior: 'smooth', block: 'center' });

  // Skip the effect if another scroll started while waiting.
  if (scrollId !== currentScrollId) return;

  targetElement.classList.add('highlight');
}
```

When moving keyboard focus to the target (or to a heading inside it with `tabindex="-1"`) after the scroll, pass `{ preventScroll: true }` to `focus()` so it doesn't start a second, competing scroll:

```javascript
await targetElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
targetHeading.focus({ preventScroll: true });
```

## Constraints

- Await the promise returned by `scrollIntoView()`, `scroll()`, `scrollTo()` or `scrollBy()` instead of guessing durations with `setTimeout()`.
- Don't make a hand-built `new Promise()` around `scrollend` your primary implementation. `scrollend` doesn't fire when the target is already in view and nothing scrolls, while the method promises resolve in that case.
- Known Chrome bug: the promise from `scrollIntoView()` resolves too early when the document's root scroller is the one scrolling. On a nested scroll container it works as expected. Don't wrap your content in a scroll container (such as a `div` with `overflow-y: auto`) just to work around the bug.

## Accessibility

Give the control that triggers the scroll an appropriate role. If the scroll takes the user to another place in the current context, use an `<a>` with an `href`, which has the implicit `link` role and the expected keyboard behaviour. Move focus to the place scrolled to so people can continue navigating from there.

Don't convey important information only through a visual change when the scroll completes. If the interaction produces important information, show it as text with sufficient contrast and announce it to screen reader users through an ARIA live region.

## Fallback strategies

Browser support for Scroll method promises: Limited availability.
Supported by: Chrome 150 (Jun 2026) and Edge 150 (Jul 2026).
Unsupported in: Firefox and Safari.

In unsupported browsers these methods return `undefined` instead of a `Promise`.

- Progressive enhancement: `await undefined` is valid and resolves on the next microtask, so `await element.scrollIntoView({ behavior: 'smooth' })` doesn't throw. The post-scroll code just runs as soon as the scroll starts. For non-essential flourishes such as a temporary highlight, this is often enough.
- Faithful fallback: if your Baseline target lacks scroll method promises and the action must wait for the scroll to finish, check whether the return value is a `Promise` (`result instanceof Promise`). If it is `undefined`, wait for `scrollend` on the scroll container, with a short idle timeout for when the element is already in view and nothing scrolls:

```javascript
function scrollIntoViewAsync(element, options, scroller = window) {
  const result = element.scrollIntoView(options);

  // Supporting browsers return a Promise.
  if (result instanceof Promise) {
    return result;
  }

  return new Promise((resolve) => {
    let timeoutId;

    const finish = () => {
      clearTimeout(timeoutId);
      scroller.removeEventListener('scrollend', finish);
      scroller.removeEventListener('scroll', onScroll);
      resolve();
    };

    const onScroll = () => {
      // Restart the idle timer on every scroll event. In browsers without scrollend,
      // this resolves once scrolling goes idle.
      clearTimeout(timeoutId);
      timeoutId = setTimeout(finish, 100);
    };

    scroller.addEventListener('scrollend', finish, { once: true });
    scroller.addEventListener('scroll', onScroll, { passive: true });

    // Resolve if no scroll event arrives within the idle window (for example, already in view).
    // 100ms is an example; it only needs to exceed the gap between scroll events.
    timeoutId = setTimeout(finish, 100);
  });
}
```
