# Optimizing Interactions in Complex Layouts

Keep frame rates high (60fps) and interaction latency low during drag-and-drop or heavy mutations in complex multi-column layouts such as Kanban boards or large data grids.

## Overview

In a complex layout, a small change to one item, such as dragging a card or editing a cell, can set off style and layout recalculation that reflows the whole page. The result is dropped frames and high Interaction to Next Paint (INP).

Applying `content-visibility: auto` to self-contained layout regions, such as the columns of a Kanban board, isolates that rendering work.

### How this helps on-screen elements

For elements already visible on screen, the browser does not skip rendering. The benefit comes entirely from the layout, style and paint containment that `content-visibility: auto` applies. Containment is a boundary: the browser knows that changes inside the container cannot affect the geometry or styles of anything outside it, so the reflow stays inside the container instead of recalculating the whole page's layout.

## Implementation

### 1. Choose containment regions

Apply `content-visibility: auto` to large, self-contained containers that act as isolated layout units, such as grid columns or board lists.

```css
.board-column {
  content-visibility: auto;

  /* Placeholder size, required to prevent layout shifts. For a vertical
     column, give a reasonable width and height.
     - 'auto' (optional) remembers the rendered size; it needs a <length>
       to use for the first render.
     - '300px' is the estimated width and '800px' the estimated height;
       replace them with your component's expected size. Any CSS <length>
       works. */
  contain-intrinsic-size: auto 300px auto 800px;
}
```

### 2. Keep interactions inside the container

Make sure mutations caused by an interaction happen inside the contained column, so they benefit from the containment.

```javascript
// Drag and drop: moving an item reflows only the target column, not the
// whole board.
function moveItemToColumn(itemId, columnId) {
  const item = document.getElementById(itemId);
  const column = document.getElementById(columnId);
  column.appendChild(item);
}
```

## Browser support and fallback

Baseline status for content-visibility: Newly available. It's been Baseline since 2025-09-15.
Supported by: Chrome 108 (Nov 2022), Edge 108 (Dec 2022), Firefox 130 (Sep 2024), and Safari 26 (Sep 2025).

Browsers without support ignore the property, and mutations cause the usual page-wide reflow. For similar isolation in older browsers, apply containment directly:

```css
@supports not (content-visibility: auto) {
  .board-column {
    contain: layout style paint;
  }
}
```
