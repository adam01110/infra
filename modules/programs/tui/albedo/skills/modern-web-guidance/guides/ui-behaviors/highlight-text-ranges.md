# Highlight Text Ranges

The CSS Custom Highlight API styles arbitrary text ranges without changing the DOM. Use it for search-result highlighting, syntax coloring, collaborative editing cursors, or spelling and grammar markers, instead of wrapping text in extra elements or rewriting `innerHTML`.

## Core implementation

Collect the target text nodes, create `Range` and `Highlight` objects, register them in the `HighlightRegistry`, and style them with the `::highlight()` pseudo-element.

### 1. Collect text nodes and create ranges

Collect the element's text nodes with a `TreeWalker` (not by manipulating `innerHTML`), then create `Range` objects at the character offsets to highlight. Range start and end must be set on text nodes, not element nodes.

```javascript
const article = document.querySelector("article");

const treeWalker = document.createTreeWalker(article, NodeFilter.SHOW_TEXT);
const allTextNodes = [];
let currentNode = treeWalker.nextNode();
while (currentNode) {
  allTextNodes.push(currentNode);
  currentNode = treeWalker.nextNode();
}

// Offsets are set on a text node.
const range = new Range();
range.setStart(textNode, matchStartIndex);
range.setEnd(textNode, matchEndIndex);
```

Walking the tree is expensive, so cache the text-node list and rebuild it only when the DOM content changes.

### 2. Create a highlight from the ranges

Group one or more ranges into a `Highlight`. Ranges that share a style belong in one highlight.

```javascript
const searchHighlight = new Highlight(...matchingRanges);
```

### 3. Register the highlight

Register each highlight under a custom name in `CSS.highlights`, a `Map`-like `HighlightRegistry`. Clear earlier highlights first so stale ranges don't stay on the page.

```javascript
CSS.highlights.clear();

CSS.highlights.set("search-results", searchHighlight);
```

When highlights overlap, `priority` controls stacking; higher priority paints on top.

```javascript
const primary = new Highlight(...primaryRanges);
primary.priority = 1;

const secondary = new Highlight(...secondaryRanges);
secondary.priority = 0; // Painted first, behind primary.

CSS.highlights.set("primary", primary);
CSS.highlights.set("secondary", secondary);
```

### 4. Style with `::highlight()`

```css
::highlight(search-results) {
  background-color: #0000FF;
  color: white;
}
```

Only a few properties work inside `::highlight()`: `color`, `background-color`, `text-decoration` and its longhands, `text-shadow`, `-webkit-text-stroke-color`, `-webkit-text-fill-color` and `-webkit-text-stroke-width`. Others, such as `background-image`, `font-size` or `padding`, are ignored.

## Accessibility

Custom highlights are purely presentational and are not exposed to the accessibility tree, so they don't replace semantic HTML. Use `<mark>` when the highlighted text is semantically relevant to the document (such as a user-selected passage) or when the highlight carries meaning (such as marking a heading element or an ARIA attribute in an HTML tutorial). Keep custom highlights for transient, visual-only effects like search results, or for syntax coloring whose meaning is also conveyed by nearby indicators (such as a "+" before added code).

- Text contrast against the highlight background must meet WCAG 2.2 Success Criterion 1.4.3 Contrast (Minimum) (Level AA): at least 4.5:1 for text smaller than 18 point (or 14 point bold), and at least 3:1 for text at 18 point or larger (or 14 point bold or larger).
- The highlight background needs at least 3:1 contrast against adjacent colors to meet WCAG 2.2 Success Criterion 1.4.11 Non-text Contrast (Level AA). It can be lower if the highlighted text has another visual indicator, such as `text-decoration: underline` or a subtle `text-shadow`.
- Don't rely on color alone to convey meaning. If a highlight marks an error, pair it with another indicator such as `text-decoration: wavy underline`, an adjacent text label or an icon.

## Fallback strategies

Baseline status for Custom highlights: Newly available. It's been Baseline since 2026-03-24.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 149 (Mar 2026), and Safari 17.2 (Dec 2023).

In browsers without the API, the text must still be legible and usable without the highlight. Detect support before using it:

```javascript
if (CSS.highlights) {
  // CSS Custom Highlight API is supported.
} else {
  // Fallback: wrap matches in <mark> elements.
}
```

If the highlight is essential to the experience, fall back to wrapping matches in `<mark>`. This modifies the DOM, so preserve event listeners and don't break the document structure.

```javascript
if (!CSS.highlights) {
  // Walk text nodes and wrap matches in <mark>, preserving structure.
  const walker = document.createTreeWalker(article, NodeFilter.SHOW_TEXT);
  const nodes = [];
  for (let n = walker.nextNode(); n; n = walker.nextNode()) nodes.push(n);

  const term = searchTerm.toLowerCase();
  // An empty term would match at every position and loop forever. Before a new
  // search, unwrap earlier marks (mark.replaceWith(...mark.childNodes), then
  // article.normalize()) so marks don't nest.
  if (term) for (const textNode of nodes) {
    const text = textNode.textContent;
    let pos = text.toLowerCase().indexOf(term);
    if (pos === -1) continue;

    const frag = document.createDocumentFragment();
    let last = 0;
    while (pos !== -1) {
      frag.append(text.slice(last, pos));
      const mark = document.createElement("mark");
      // Assigning textContent avoids HTML injection.
      mark.textContent = text.slice(pos, pos + term.length);
      frag.append(mark);
      last = pos + term.length;
      pos = text.toLowerCase().indexOf(term, last);
    }
    frag.append(text.slice(last));
    textNode.replaceWith(frag);
  }
}
```
