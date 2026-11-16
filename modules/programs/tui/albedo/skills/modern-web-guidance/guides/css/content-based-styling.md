# Content Based Styling

Giving a component a different layout depending on its content used to need JavaScript or template logic that injected modifier classes such as `.card--has-image` or `.card--text-only`.

The `:has()` pseudo-class acts as a parent selector: it styles a container based on the presence or absence of specific descendants. With it, layout variations follow the component's actual DOM content entirely in CSS. Combine it with `:not()` to target the absence of content explicitly, for example to define default layouts.

## Implementing content-based container styling

Put `:has()` on the container element and use it to detect the presence of specific child content.

1. Define the default styling: give the container its base layout, such as a single-column stack.
2. Apply content-based overrides: target the container with `:has([child-selector])` and apply the layout for when that content is present, such as a multi-column grid.

Example: a card that switches to a side-by-side layout when it contains an image.

```css
/* 1. Default state on the container: applies when there is no image */
.article-card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
  border: 1px solid #ccc;
  border-radius: 8px;
}

/* 2. Row layout when an image is present */
.article-card:has(img) {
  flex-direction: row;
  align-items: center;
}

/* Styling the image itself needs no :has() */
.article-card img {
  width: 150px;
  height: auto;
  border-radius: 4px;
}

/* :not(:has()) targets the absence of content: cards without an image */
.article-card:not(:has(img)) {
  background-color: #f9f9f9;
}
```

```html
<!-- Assume an <h1> precedes these components in the document -->
<!-- Card with an image: row layout -->
<article class="article-card">
  <img src="thumbnail.jpg" alt="Article thumbnail" />
  <div class="content">
    <h2>Card With Image</h2>
    <p>This card lays out its content horizontally.</p>
  </div>
</article>

<!-- Card without an image: default column layout -->
<article class="article-card">
  <div class="content">
    <h2>Text-Only Card</h2>
    <p>This card lays out its content vertically, and gets its background color from the :not(:has()) rule.</p>
  </div>
</article>
```

Performance: scope `:has()` to the most specific component container possible (such as `.article-card`). Avoid anchoring it to high-level elements like `body:has(img)` when the styling change is local, because broad `:has()` queries can trigger more layout recalculation.

### Fallback strategies

Baseline status for :has(): Widely available. It's been Baseline since 2023-12-19.
Supported by: Chrome 105 (Sep 2022), Edge 105 (Sep 2022), Firefox 121 (Dec 2023), and Safari 15.4 (Mar 2022).

If the content-based layout is critical to the user experience or page design, provide a fallback for browsers without `:has()`. Purely decorative effects can use `:has()` as a progressive enhancement with no fallback.

For a critical layout, define a traditional class-based fallback (such as `.has-image`) inside `@supports not selector(:has(*))`.

Unlike interactive state, content presence is usually known at render time. The most robust fallback is for the server-side templating engine or static site generator to add a class like `.has-image` to the container when the child (such as an image) exists in the data.

Without server-side rendering, use a small script gated by `CSS.supports()` that detects the content and adds the class on load or after dynamic content is injected.

```css
/* Fallback for browsers without :has() */
@supports not selector(:has(*)) {
  /* Modifier classes with the same layout overrides */
  .article-card.has-image {
    flex-direction: row;
    align-items: center;
  }

  .article-card:not(.has-image) {
    background-color: #f9f9f9;
  }
}
```

```javascript
// Only needed without SSR; only runs where :has() is unsupported
if (!CSS.supports('selector(:has(*))')) {
  const cards = document.querySelectorAll('.article-card');

  cards.forEach(card => {
    if (card.querySelector('img')) {
      card.classList.add('has-image');
    }
  });
}
```
