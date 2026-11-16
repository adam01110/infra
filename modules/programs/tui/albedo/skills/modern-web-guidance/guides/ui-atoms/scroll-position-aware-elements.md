# Scroll Position Aware Elements

## Overview

Floating controls such as a "Back to top" link are more useful when they appear only when needed. Container scroll-state queries (`container-type: scroll-state`) style elements according to their container's scroll position, without JavaScript scroll listeners or observers.

## Implementation

### 1. Establish the scroll container

Declare the scroll container as a scroll-state query container:

```css
.scroller {
  overflow-y: auto;
  container-type: scroll-state;
}
```

### 2. Style the floating element

Place the element inside the container, hidden by default:

```css
.back-to-top {
  position: sticky;
  bottom: 20px;
  visibility: hidden;
  opacity: 0;
  translate: 0 20px;
  transition:
    visibility 0.3s,
    opacity 0.3s ease,
    translate 0.3s ease;
}
```

Sticky and floating elements sit above the scrolling content. Give the main content enough bottom padding or margin that the button does not permanently cover the last elements when the user scrolls to the bottom.

### 3. Respond to the scroll state

Use `@container` with `scroll-state()`. The user has scrolled down when the container can be scrolled toward the top:

```css
@container scroll-state(scrollable: top) {
  .back-to-top {
    visibility: visible;
    opacity: 1;
    translate: 0 0;
  }
}
```

### 4. Manage focus and scroll container semantics

A control that hides with scroll position can lose focus. If a user focused on "Back to top" scrolls the container with `Page Up` or `Home` instead of activating the control, it becomes `visibility: hidden` at the top of the region and focus would otherwise reset to `<body>`. Listen for `focusout` and, when the hidden control loses focus without focus moving to another element, move focus to the scrollable region. The region then needs to be focusable and named, for example with `tabindex="0"`, `role="region"` and an `aria-label`. A sketch:

```javascript
const scroller = document.querySelector('.scroller');
const backToTop = document.querySelector('.back-to-top');

backToTop.addEventListener('focusout', (event) => {
  // relatedTarget is null when focus is not moving to another element.
  if (!event.relatedTarget && getComputedStyle(backToTop).visibility === 'hidden') {
    scroller.focus();
  }
});
```

## Fallback strategies

Browser support for Container scroll-state queries: Limited availability.
Supported by: Chrome 144 (Jan 2026) and Edge 144 (Jan 2026).
Unsupported in: Firefox and Safari.

### Basic fallback

Without scroll-state query support, the default `visibility: hidden` keeps the element invisible permanently. To keep it usable, make it always visible in unsupported browsers:

```css
/* Unsupported browsers: always visible. */
.back-to-top {
  visibility: visible;
  opacity: 1;
  translate: 0 0;
}

/* Supported browsers: visibility follows the scroll state. */
@supports (container-type: scroll-state) {
  .back-to-top {
    visibility: hidden;
    opacity: 0;
    translate: 0 20px;
  }

  @container scroll-state(scrollable: top) {
    .back-to-top {
      visibility: visible;
      opacity: 1;
      translate: 0 0;
    }
  }
}
```

### IntersectionObserver fallback

If the visibility must stay dynamic, use an `IntersectionObserver` to toggle a class when a sentinel element at the top of the scroller leaves view.

```html
<!-- Sentinel at the top of the scroller. -->
<div class="scroll-sentinel"></div>
```

```css
/* Keeps the sentinel from affecting layout. */
.scroll-sentinel {
  height: 0;
  width: 0;
  visibility: hidden;
}

.scrolled .back-to-top {
  visibility: visible;
  opacity: 1;
  translate: 0 0;
}
```

```javascript
if (!CSS.supports('container-type', 'scroll-state')) {
  const sentinel = document.querySelector('.scroll-sentinel');
  const scroller = document.querySelector('.scroller');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      // A sentinel out of view means the user has scrolled down.
      scroller.classList.toggle('scrolled', !entry.isIntersecting);
    });
  }, { root: scroller });

  observer.observe(sentinel);
}
```
