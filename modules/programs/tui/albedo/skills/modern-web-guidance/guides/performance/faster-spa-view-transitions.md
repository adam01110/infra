# Faster SPA View Transitions via State Caching

Make navigation between views in a single-page application (SPA) near-instant by caching the rendered state of inactive views instead of destroying them.

## Overview

Destroying an inactive view, or hiding it with `display: none`, means the browser has to rebuild or recalculate its full layout and paint when the user returns.

With `content-visibility: hidden` on inactive views, the browser takes the element's contents out of layout and stops painting them, but keeps their rendering state cached in memory. Switching back restores the view almost instantly.

### CPU versus memory

- CPU: large savings. The browser skips layout and paint for hidden views entirely.
- Memory: high cost. Every DOM node, event listener and piece of state of each hidden view stays in memory.

Choose accordingly:

- Use this for applications with a small, predictable number of views, such as a 3-to-5 tab interface.
- In highly dynamic applications that generate dozens of unique reports or have unbounded dynamic routes, do not cache every view unconditionally. Memory grows until it can crash the browser on low-end devices.
- In such applications, add an eviction strategy, such as a least-recently-used cache, that destroys old views when a memory threshold is reached.

## Implementation

### 1. Configure view containers

Set `content-visibility: hidden` on inactive views.

`content-visibility: hidden` hides the element's contents only. The element itself is still styled and painted: its background, borders, padding and margins remain.

```css
.spa-view.inactive {
  content-visibility: hidden;

  /* Optional: take hidden views out of the layout flow. */
  position: absolute;
}
```

### 2. Manage focus

When swapping views, manage keyboard focus to keep the interface accessible. Set `inert` on hidden views so their controls drop out of the tab order, and move focus to the new view so the tab order stays logical. The view needs `tabindex="-1"` to be focusable.

```javascript
function switchToView(viewId) {
  document.querySelectorAll('.spa-view').forEach(view => {
    view.classList.add('inactive');
    view.setAttribute('aria-hidden', 'true');
    view.setAttribute('inert', 'inert');
  });

  const activeView = document.getElementById(viewId);
  activeView.classList.remove('inactive');
  activeView.setAttribute('aria-hidden', 'false');
  activeView.removeAttribute('inert');

  // A view element is not focusable without tabindex.
  activeView.tabIndex = -1;
  activeView.focus();
}
```

## Browser support and fallback

Baseline status for content-visibility: Newly available. It's been Baseline since 2025-09-15.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 130 (Sep 2024), and Safari 26 (Sep 2025).

Browsers without `content-visibility` ignore the property and would render every view at once. Fall back to `display: none` there:

```css
@supports not (content-visibility: hidden) {
  .spa-view.inactive {
    display: none;
  }
}
```
