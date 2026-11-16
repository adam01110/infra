# Build a Scrollspy Navigation

A scrollspy navigation highlights the link for the section currently in view, so users know where they are in a long document as they scroll. It is common in two places:

- Single-page websites, where the main navigation links to sections of one page rather than separate URLs.
- Long-form content, where a table of contents or sidebar tracks progress through an article, guide, or documentation.

## How to implement

CSS can do this natively with the `scroll-target-group` property and the `:target-current` pseudo-class, replacing the older `IntersectionObserver` script (still needed as a fallback, below).

1. Build the navigation from anchor links whose fragment identifiers (`<a href="#section-1">`) match the `id` of each content section.
2. Set `scroll-target-group: auto` on the container of the links. The browser then treats the links as markers that track their targets.
3. Style the active link with `:target-current`, which matches a link whose target is visible in the scroll container.
4. Mirror the state in `aria-current="true"` with a script when scrolling stops, because `:target-current` is not exposed to assistive technologies.

## Example code

This example highlights the active link in a fixed navigation menu.

```css
/* The container of the markers needs scroll-target-group: auto. */
nav {
  scroll-target-group: auto;
}
nav a:target-current {
  color: var(--accent, #007bff);
  border-bottom-color: var(--accent, #007bff);
}
```

```html
<nav>
  <a href="#intro">Introduction</a>
  <a href="#features">Features</a>
  <a href="#pricing">Pricing</a>
</nav>

<main>
  <!-- Each section needs a unique id matching a link fragment, and tabindex="-1" so it can receive focus. -->
  <section id="intro" tabindex="-1">
    <h2>Introduction</h2>
  </section>
  <section id="features" tabindex="-1">
    <h2>Features</h2>
  </section>
  <section id="pricing" tabindex="-1">
    <h2>Pricing</h2>
  </section>
</main>

<script type="module">
  if (CSS.supports('scroll-target-group: auto')) {
    const syncAriaCurrent = () => {
      const currentLink = document.querySelector('nav a:target-current');
      document.querySelectorAll('nav a').forEach(link => {
        link.setAttribute('aria-current', link === currentLink ? 'true' : 'false');
      });
    };
    // Initial sync. The DOM must be loaded: use type="module" or wait for DOMContentLoaded.
    syncAriaCurrent();
    // Element scrollend does not bubble; if the sections scroll in a container
    // rather than the document, listen on that container instead.
    document.addEventListener('scrollend', syncAriaCurrent);
  }
</script>
```

## Accessibility considerations

Give each target section `tabindex="-1"`. After a user follows an anchor link, the section can then receive focus, so keyboard users can scroll the container or continue navigating from that content.

```html
<li><a href="#section-2">Section 2</a></li>
…
<section id="section-2" tabindex="-1">
  <h2>Section 2</h2>
</section>
```

If the scrollable container is not `<body>`, make it focusable with `tabindex="0"` and give it an accessible name describing its content and, unless it already has an implicit role (as `<main>` does), a role such as `role="region"`. This keeps it operable across browser and assistive technology combinations.

## Best practices

- Put `scroll-target-group: auto` on a dedicated container for the navigation links, so the browser knows which links to track.
- Give targets unique `id` attributes matching the links' `href` values.
- Make sections tall enough that only one or two are visible at a time; `scroll-target-group` identifies the visible target most clearly then.
- Mirror the visual state with `aria-current`. `:target-current` only affects visuals and is not exposed to screen readers.
- Do not rely on color alone for the active state. Add another cue such as font weight, an underline, or an indicator dot, or make the color contrast large enough for users with color vision deficiencies.

## Fallback strategies

Browser support for scroll-target-group: Limited availability.
Supported by: Chrome 140 (Sep 2025) and Edge 140 (Sep 2025).
Unsupported in: Firefox and Safari.

Where `scroll-target-group` is unsupported, fall back to `IntersectionObserver`. Place this classic script after the sections (or defer it), so its `querySelectorAll` finds them:

```html
<script>
  if (!CSS.supports('scroll-target-group: auto')) {
    const navLinks = document.querySelectorAll('nav a');
    const sections = document.querySelectorAll('main section');

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute('id');
          navLinks.forEach(link => {
            const isActive = link.getAttribute('href') === `#${id}`;
            link.classList.toggle('target-current', isActive);
            link.setAttribute('aria-current', isActive);
          });
        }
      });
    }, { rootMargin: '-50% 0px -50% 0px', threshold: 0 });

    sections.forEach(section => observer.observe(section));
  }
</script>

<style>
  /* Combine the pseudo-class and the fallback class inside :is(). A plain
     selector list (nav a:target-current, nav a.target-current) would be
     dropped entirely by browsers that do not recognize :target-current. */
  nav a:is(:target-current, .target-current) {
    color: var(--accent, #007bff);
    border-bottom-color: var(--accent, #007bff);
    font-weight: bold;
  }
</style>
```
