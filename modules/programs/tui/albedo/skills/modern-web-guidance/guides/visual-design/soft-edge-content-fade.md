# Soft Edge Content Fade

## Overview

To fade the edges of a container to transparent (for example to hint that more content scrolls into view, or to fade out text), use CSS masking with a linear gradient. Unlike a semi-transparent overlay, a mask fades the content itself, so the background shows through naturally and text selection and pointer events are unaffected.

## Implementation

### Fading the bottom edge

Useful for showing that a scrollable area has more content below.

```css
.container {
  overflow-y: auto;

  /* Prefixed property for older browsers. */
  -webkit-mask-image: linear-gradient(to bottom, black 80%, transparent 100%);
  mask-image: linear-gradient(to bottom, black 80%, transparent 100%);
}
```

### Fading the top and bottom edges

One gradient with several color stops fades both edges.

```css
.dual-fade-container {
  /* Content is fully visible between 10% and 90% of the height. */
  -webkit-mask-image: linear-gradient(to bottom, transparent 0%, black 10%, black 90%, transparent 100%);
  mask-image: linear-gradient(to bottom, transparent 0%, black 10%, black 90%, transparent 100%);
}
```

## Fallback strategies

Baseline status for Masks: Widely available. It's been Baseline since 2023-12-07.
Supported by: Chrome 120 (Dec 2023), Edge 120 (Dec 2023), Firefox 53 (Apr 2017), and Safari 15.4 (Mar 2022).

In a browser without `mask-image` or its prefixed version, the content doesn't fade and shows hard edges. Make sure the interface still works and the content stays readable without the fade (progressive enhancement).

A semi-transparent overlay can serve as a fallback, but it requires knowing the background color, and it blocks text selection underneath unless it has `pointer-events: none`. On a scrolling container, an absolutely positioned overlay would scroll away with the content, so put it on a non-scrolling wrapper (`.fade-wrapper` below) around the scroller.

```css
@supports (not (mask-image: linear-gradient(to bottom, black, transparent))) and (not (-webkit-mask-image: linear-gradient(to bottom, black, transparent))) {
  .fade-wrapper {
    position: relative;
  }

  .fade-wrapper::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 20%;
    /* Assumes a solid white background. */
    background: linear-gradient(to bottom, rgba(255,255,255,0), rgba(255,255,255,1));
    pointer-events: none; /* Keep the text underneath interactive. */
  }
}
```
